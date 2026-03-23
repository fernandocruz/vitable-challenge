from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import Doctor, Specialty, TimeSlot
from .serializers import (
    DoctorDetailSerializer,
    DoctorSerializer,
    SpecialtySerializer,
    TimeSlotSerializer,
)


class SpecialtyViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Specialty.objects.all()
    serializer_class = SpecialtySerializer


class DoctorViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Doctor.objects.select_related('specialty')

    def get_serializer_class(self):
        if self.action == 'retrieve':
            return DoctorDetailSerializer
        return DoctorSerializer

    def get_queryset(self):
        qs = super().get_queryset()
        specialty = self.request.query_params.get('specialty')
        if specialty:
            qs = qs.filter(specialty_id=specialty)
        return qs

    @action(detail=True, methods=['get'])
    def slots(self, request, pk=None):
        doctor = self.get_object()
        slots = doctor.time_slots.filter(is_available=True)
        serializer = TimeSlotSerializer(slots, many=True)
        return Response(serializer.data)
