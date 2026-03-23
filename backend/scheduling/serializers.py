from rest_framework import serializers

from .models import Doctor, Specialty, TimeSlot


class SpecialtySerializer(serializers.ModelSerializer):
    class Meta:
        model = Specialty
        fields = ['id', 'name', 'description']


class TimeSlotSerializer(serializers.ModelSerializer):
    class Meta:
        model = TimeSlot
        fields = ['id', 'doctor', 'start_time', 'is_available']


class DoctorSerializer(serializers.ModelSerializer):
    specialty_name = serializers.CharField(source='specialty.name', read_only=True)

    class Meta:
        model = Doctor
        fields = ['id', 'name', 'specialty', 'specialty_name', 'bio']


class DoctorDetailSerializer(serializers.ModelSerializer):
    specialty = SpecialtySerializer(read_only=True)
    available_slots = serializers.SerializerMethodField()

    class Meta:
        model = Doctor
        fields = ['id', 'name', 'specialty', 'bio', 'available_slots']

    def get_available_slots(self, obj):
        slots = obj.time_slots.filter(is_available=True)
        return TimeSlotSerializer(slots, many=True).data
