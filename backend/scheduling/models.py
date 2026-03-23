from django.db import models


class Specialty(models.Model):
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True)

    class Meta:
        verbose_name_plural = 'specialties'
        ordering = ['name']

    def __str__(self):
        return self.name


class Doctor(models.Model):
    name = models.CharField(max_length=200)
    specialty = models.ForeignKey(
        Specialty,
        on_delete=models.CASCADE,
        related_name='doctors',
    )
    bio = models.TextField(blank=True)

    class Meta:
        ordering = ['name']

    def __str__(self):
        return f'{self.name} ({self.specialty.name})'


class TimeSlot(models.Model):
    doctor = models.ForeignKey(
        Doctor,
        on_delete=models.CASCADE,
        related_name='time_slots',
    )
    start_time = models.DateTimeField()
    is_available = models.BooleanField(default=True)

    class Meta:
        ordering = ['start_time']
        unique_together = ['doctor', 'start_time']

    def __str__(self):
        status = 'available' if self.is_available else 'booked'
        return f'{self.doctor.name} - {self.start_time} ({status})'
