from rest_framework import serializers

from .models import Appointment, Conversation, Message


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


class AppointmentSerializer(serializers.ModelSerializer):
    doctor_name = serializers.CharField(source='doctor.name', read_only=True)
    specialty_name = serializers.CharField(
        source='doctor.specialty.name', read_only=True
    )
    start_time = serializers.DateTimeField(
        source='time_slot.start_time', read_only=True
    )

    class Meta:
        model = Appointment
        fields = [
            'id',
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
