import uuid

from django.db import models


class Conversation(models.Model):
    session_id = models.UUIDField(default=uuid.uuid4, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f'Conversation {self.session_id}'


class Message(models.Model):
    ROLE_CHOICES = [
        ('user', 'User'),
        ('assistant', 'Assistant'),
        ('system', 'System'),
    ]

    conversation = models.ForeignKey(
        Conversation,
        on_delete=models.CASCADE,
        related_name='messages',
    )
    role = models.CharField(max_length=10, choices=ROLE_CHOICES)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['created_at']

    def __str__(self):
        return f'[{self.role}] {self.content[:50]}'


class Appointment(models.Model):
    URGENCY_CHOICES = [
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
    ]
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('confirmed', 'Confirmed'),
        ('cancelled', 'Cancelled'),
    ]

    conversation = models.ForeignKey(
        Conversation,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='appointments',
    )
    doctor = models.ForeignKey(
        'scheduling.Doctor',
        on_delete=models.CASCADE,
        related_name='appointments',
    )
    time_slot = models.OneToOneField(
        'scheduling.TimeSlot',
        on_delete=models.CASCADE,
        related_name='appointment',
    )
    symptoms_summary = models.TextField()
    urgency_level = models.CharField(max_length=10, choices=URGENCY_CHOICES)
    status = models.CharField(
        max_length=10,
        choices=STATUS_CHOICES,
        default='confirmed',
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f'Appointment with {self.doctor.name} - {self.time_slot.start_time}'
