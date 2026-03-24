from rest_framework import serializers

from .models import Appointment, Conversation, Message, Patient


class MessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = ['id', 'role', 'content', 'created_at']
        read_only_fields = ['id', 'role', 'created_at']


class ConversationSerializer(serializers.ModelSerializer):
    messages = MessageSerializer(many=True, read_only=True)

    class Meta:
        model = Conversation
        fields = ['id', 'session_id', 'messages', 'created_at']
        read_only_fields = ['id', 'session_id', 'created_at']


class ConversationCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Conversation
        fields = ['id', 'session_id', 'created_at']
        read_only_fields = ['id', 'session_id', 'created_at']


class SendMessageSerializer(serializers.Serializer):
    content = serializers.CharField()


class PatientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Patient
        fields = [
            'id',
            'name',
            'email',
            'phone',
            'date_of_birth',
            'is_verified',
            'created_at',
        ]
        read_only_fields = ['id', 'is_verified', 'created_at']


class RegisterPatientSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=200)
    email = serializers.EmailField()
    phone = serializers.CharField(max_length=20)
    date_of_birth = serializers.DateField()


class SendOtpSerializer(serializers.Serializer):
    email = serializers.EmailField()


class VerifyOtpSerializer(serializers.Serializer):
    email = serializers.EmailField()
    code = serializers.CharField(max_length=6)


class AppointmentSerializer(serializers.ModelSerializer):
    doctor_name = serializers.CharField(source='doctor.name', read_only=True)
    specialty_name = serializers.CharField(
        source='doctor.specialty.name', read_only=True
    )
    start_time = serializers.DateTimeField(
        source='time_slot.start_time', read_only=True
    )
    patient_name = serializers.CharField(
        source='patient.name', read_only=True, default=''
    )

    class Meta:
        model = Appointment
        fields = [
            'id',
            'patient',
            'patient_name',
            'conversation',
            'doctor',
            'doctor_name',
            'specialty_name',
            'time_slot',
            'start_time',
            'symptoms_summary',
            'urgency_level',
            'status',
            'created_at',
        ]
        read_only_fields = ['id', 'status', 'created_at']
