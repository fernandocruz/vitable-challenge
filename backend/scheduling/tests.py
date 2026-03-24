from datetime import timedelta

from django.db import IntegrityError
from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient

from scheduling.models import Doctor, Specialty, TimeSlot


class TestSpecialtyModel(TestCase):
    def test_str(self):
        s = Specialty.objects.create(name='Cardiology', description='Heart')
        self.assertEqual(str(s), 'Cardiology')

    def test_unique_name(self):
        Specialty.objects.create(name='Neurology')
        with self.assertRaises(IntegrityError):
            Specialty.objects.create(name='Neurology')

    def test_ordering(self):
        Specialty.objects.create(name='Zebra')
        Specialty.objects.create(name='Alpha')
        names = list(Specialty.objects.values_list('name', flat=True))
        self.assertEqual(names, ['Alpha', 'Zebra'])


class TestDoctorModel(TestCase):
    def setUp(self):
        self.specialty = Specialty.objects.create(name='Cardiology')

    def test_str(self):
        d = Doctor.objects.create(name='Dr. Smith', specialty=self.specialty)
        self.assertEqual(str(d), 'Dr. Smith (Cardiology)')

    def test_cascade_delete(self):
        Doctor.objects.create(name='Dr. Smith', specialty=self.specialty)
        self.specialty.delete()
        self.assertEqual(Doctor.objects.count(), 0)


class TestTimeSlotModel(TestCase):
    def setUp(self):
        specialty = Specialty.objects.create(name='Cardiology')
        self.doctor = Doctor.objects.create(name='Dr. Smith', specialty=specialty)
        self.time = timezone.now() + timedelta(days=1)

    def test_default_available(self):
        slot = TimeSlot.objects.create(doctor=self.doctor, start_time=self.time)
        self.assertTrue(slot.is_available)

    def test_unique_together(self):
        TimeSlot.objects.create(doctor=self.doctor, start_time=self.time)
        with self.assertRaises(IntegrityError):
            TimeSlot.objects.create(doctor=self.doctor, start_time=self.time)

    def test_ordering(self):
        t1 = self.time + timedelta(hours=2)
        t2 = self.time + timedelta(hours=1)
        TimeSlot.objects.create(doctor=self.doctor, start_time=t1)
        TimeSlot.objects.create(doctor=self.doctor, start_time=t2)
        times = list(TimeSlot.objects.values_list('start_time', flat=True))
        self.assertEqual(times[0], t2)
        self.assertEqual(times[1], t1)


class TestSpecialtyAPI(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.s1 = Specialty.objects.create(name='Cardiology', description='Heart')
        self.s2 = Specialty.objects.create(name='Neurology', description='Brain')

    def test_list(self):
        resp = self.client.get('/api/scheduling/specialties/')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(len(resp.json()), 2)

    def test_retrieve(self):
        resp = self.client.get(f'/api/scheduling/specialties/{self.s1.id}/')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.json()['name'], 'Cardiology')


class TestDoctorAPI(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.cardio = Specialty.objects.create(name='Cardiology')
        self.neuro = Specialty.objects.create(name='Neurology')
        self.d1 = Doctor.objects.create(
            name='Dr. Heart', specialty=self.cardio, bio='Heart specialist'
        )
        self.d2 = Doctor.objects.create(
            name='Dr. Brain', specialty=self.neuro, bio='Brain specialist'
        )
        self.slot_available = TimeSlot.objects.create(
            doctor=self.d1,
            start_time=timezone.now() + timedelta(days=1),
            is_available=True,
        )
        self.slot_booked = TimeSlot.objects.create(
            doctor=self.d1,
            start_time=timezone.now() + timedelta(days=1, hours=1),
            is_available=False,
        )

    def test_list_all(self):
        resp = self.client.get('/api/scheduling/doctors/')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(len(resp.json()), 2)

    def test_filter_by_specialty(self):
        resp = self.client.get(f'/api/scheduling/doctors/?specialty={self.cardio.id}')
        self.assertEqual(len(resp.json()), 1)
        self.assertEqual(resp.json()[0]['name'], 'Dr. Heart')

    def test_retrieve_includes_available_slots(self):
        resp = self.client.get(f'/api/scheduling/doctors/{self.d1.id}/')
        data = resp.json()
        self.assertEqual(data['name'], 'Dr. Heart')
        self.assertEqual(len(data['available_slots']), 1)

    def test_slots_action_only_available(self):
        resp = self.client.get(f'/api/scheduling/doctors/{self.d1.id}/slots/')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(len(resp.json()), 1)
        self.assertTrue(resp.json()[0]['is_available'])

    def test_slots_action_empty_for_no_slots(self):
        resp = self.client.get(f'/api/scheduling/doctors/{self.d2.id}/slots/')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(len(resp.json()), 0)
