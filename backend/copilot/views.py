from django.utils import timezone
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Appointment, Conversation, Message, OtpCode, Patient
from .otp_service import OtpRateLimitExceeded, OtpService
from .serializers import (
    AppointmentSerializer,
    ConversationCreateSerializer,
    ConversationSerializer,
    PatientSerializer,
    RegisterPatientSerializer,
    SendMessageSerializer,
    SendOtpSerializer,
    VerifyOtpSerializer,
)
from .services import get_ai_service


class RegisterPatientView(APIView):
    def post(self, request):
        serializer = RegisterPatientSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        patient, created = Patient.objects.get_or_create(
            email=data['email'],
            defaults={
                'name': data['name'],
                'phone': data['phone'],
                'date_of_birth': data['date_of_birth'],
            },
        )

        if not created:
            patient.name = data['name']
            patient.phone = data['phone']
            patient.date_of_birth = data['date_of_birth']
            patient.save()

        otp_service = OtpService()
        try:
            code = otp_service.generate_and_send(patient.email)
        except OtpRateLimitExceeded:
            return Response(
                {'error': 'Too many OTP requests. Try again later.'},
                status=status.HTTP_429_TOO_MANY_REQUESTS,
            )

        response_data = {
            'patient': PatientSerializer(patient).data,
            'message': 'OTP sent to your work email.',
        }
        if otp_service.should_include_in_response():
            response_data['otp'] = code

        return Response(
            response_data,
            status=status.HTTP_201_CREATED if created
            else status.HTTP_200_OK,
        )


class SendOtpView(APIView):
    def post(self, request):
        serializer = SendOtpSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email']

        try:
            Patient.objects.get(email=email)
        except Patient.DoesNotExist:
            return Response(
                {'error': 'No patient found with this email.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        otp_service = OtpService()
        try:
            code = otp_service.generate_and_send(email)
        except OtpRateLimitExceeded:
            return Response(
                {'error': 'Too many OTP requests. Try again later.'},
                status=status.HTTP_429_TOO_MANY_REQUESTS,
            )

        response_data = {
            'message': 'OTP sent to your work email.',
        }
        if otp_service.should_include_in_response():
            response_data['otp'] = code

        return Response(response_data)


class VerifyOtpView(APIView):
    def post(self, request):
        serializer = VerifyOtpSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email']
        code = serializer.validated_data['code']

        try:
            otp = OtpCode.objects.filter(
                email=email,
                code=code,
                is_used=False,
                expires_at__gt=timezone.now(),
            ).latest('created_at')
        except OtpCode.DoesNotExist:
            return Response(
                {'error': 'Invalid or expired OTP.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        otp.is_used = True
        otp.save()

        patient = Patient.objects.get(email=email)
        patient.is_verified = True
        patient.save()

        from rest_framework.authtoken.models import Token
        from django.contrib.auth.models import User

        user, _ = User.objects.get_or_create(
            username=email,
            defaults={'email': email},
        )
        token, _ = Token.objects.get_or_create(user=user)

        return Response({
            'token': token.key,
            'patient': PatientSerializer(patient).data,
        })


class PatientMeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            patient = Patient.objects.get(
                email=request.user.username,
            )
            return Response(PatientSerializer(patient).data)
        except Patient.DoesNotExist:
            return Response(
                {'error': 'Patient profile not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )


class ConversationViewSet(viewsets.GenericViewSet):
    queryset = Conversation.objects.prefetch_related('messages')

    def get_serializer_class(self):
        if self.action == 'create':
            return ConversationCreateSerializer
        return ConversationSerializer

    def retrieve(self, request, pk=None):
        conversation = self.get_object()
        serializer = ConversationSerializer(conversation)
        return Response(serializer.data)

    def create(self, request):
        conversation = Conversation.objects.create()
        ai_service = get_ai_service()
        greeting = ai_service.get_greeting()
        Message.objects.create(
            conversation=conversation,
            role='assistant',
            content=greeting,
        )
        serializer = ConversationSerializer(conversation)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=['post'])
    def messages(self, request, pk=None):
        conversation = self.get_object()
        serializer = SendMessageSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user_content = serializer.validated_data['content']

        Message.objects.create(
            conversation=conversation,
            role='user',
            content=user_content,
        )

        messages = list(
            conversation.messages.values_list('role', 'content')
        )
        history = [
            {'role': role, 'content': content}
            for role, content in messages
        ]

        ai_service = get_ai_service()
        ai_response = ai_service.get_response(history)

        assistant_message = Message.objects.create(
            conversation=conversation,
            role='assistant',
            content=ai_response['content'],
        )

        return Response({
            'message': {
                'id': assistant_message.id,
                'role': 'assistant',
                'content': ai_response['content'],
                'created_at': assistant_message.created_at,
            },
            'recommendation': ai_response.get('recommendation'),
        })


class AppointmentViewSet(viewsets.ModelViewSet):
    queryset = Appointment.objects.select_related(
        'doctor', 'doctor__specialty', 'time_slot', 'patient'
    )
    serializer_class = AppointmentSerializer
    http_method_names = ['get', 'post']

    def get_permissions(self):
        if self.action == 'list':
            return [IsAuthenticated()]
        return super().get_permissions()

    def get_queryset(self):
        qs = super().get_queryset()
        if self.action == 'list' and self.request.user.is_authenticated:
            qs = qs.filter(patient__email=self.request.user.username)
        return qs

    def perform_create(self, serializer):
        appointment = serializer.save()
        time_slot = appointment.time_slot
        time_slot.is_available = False
        time_slot.save()
