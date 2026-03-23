from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import Appointment, Conversation, Message
from .serializers import (
    AppointmentSerializer,
    ConversationCreateSerializer,
    ConversationSerializer,
    SendMessageSerializer,
)
from .services import get_ai_service


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
        # Create initial greeting from assistant
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

        # Save user message
        Message.objects.create(
            conversation=conversation,
            role='user',
            content=user_content,
        )

        # Get all messages for context
        messages = list(
            conversation.messages.values_list('role', 'content')
        )
        history = [{'role': role, 'content': content} for role, content in messages]

        # Get AI response
        ai_service = get_ai_service()
        ai_response = ai_service.get_response(history)

        # Save assistant message
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
        'doctor', 'doctor__specialty', 'time_slot'
    )
    serializer_class = AppointmentSerializer
    http_method_names = ['get', 'post']

    def perform_create(self, serializer):
        appointment = serializer.save()
        # Mark time slot as unavailable
        time_slot = appointment.time_slot
        time_slot.is_available = False
        time_slot.save()
