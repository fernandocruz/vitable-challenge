from datetime import timedelta
from unittest.mock import patch

from django.contrib.auth.models import User
from django.test import TestCase, override_settings
from django.utils import timezone
from rest_framework.authtoken.models import Token
from rest_framework.test import APIClient

from copilot.models import (
    Appointment,
    Conversation,
    Message,
    OtpCode,
    Patient,
)
from copilot.otp_service import OtpRateLimitExceeded, OtpService
from copilot.services import MockCopilotService
from scheduling.models import Doctor, Specialty, TimeSlot


# --- Model Tests ---


class TestConversationModel(TestCase):
    def test_uuid_auto_generated(self):
        c = Conversation.objects.create()
        self.assertIsNotNone(c.session_id)

    def test_message_ordering(self):
        c = Conversation.objects.create()
        m1 = Message.objects.create(conversation=c, role='user', content='first')
        m2 = Message.objects.create(conversation=c, role='assistant', content='second')
        messages = list(c.messages.all())
        self.assertEqual(messages[0].id, m1.id)
        self.assertEqual(messages[1].id, m2.id)


class TestPatientModel(TestCase):
    def test_str(self):
        p = Patient.objects.create(
            name='John Doe',
            email='john@company.com',
            phone='+1234567890',
            date_of_birth='1990-01-01',
        )
        self.assertEqual(str(p), 'John Doe (john@company.com)')

    def test_unique_email(self):
        Patient.objects.create(
            name='A', email='a@test.com', phone='1', date_of_birth='1990-01-01'
        )
        from django.db import IntegrityError

        with self.assertRaises(IntegrityError):
            Patient.objects.create(
                name='B', email='a@test.com', phone='2', date_of_birth='1991-01-01'
            )

    def test_default_not_verified(self):
        p = Patient.objects.create(
            name='A', email='a@test.com', phone='1', date_of_birth='1990-01-01'
        )
        self.assertFalse(p.is_verified)


# --- Service Tests ---


class TestMockCopilotService(TestCase):
    def setUp(self):
        self.service = MockCopilotService()

    def test_greeting(self):
        greeting = self.service.get_greeting()
        self.assertIn('health copilot', greeting.lower())

    def test_follow_up_questions(self):
        history = [
            {'role': 'assistant', 'content': 'greeting'},
            {'role': 'user', 'content': 'I have headaches'},
        ]
        resp = self.service.get_response(history)
        self.assertIsNone(resp['recommendation'])
        self.assertIn('?', resp['content'])

    def test_recommendation_after_enough_messages(self):
        history = [
            {'role': 'assistant', 'content': 'greeting'},
            {'role': 'user', 'content': 'headaches'},
            {'role': 'assistant', 'content': 'how long?'},
            {'role': 'user', 'content': 'one week'},
            {'role': 'assistant', 'content': 'severity?'},
            {'role': 'user', 'content': 'moderate, about 7'},
            {'role': 'assistant', 'content': 'medication?'},
            {'role': 'user', 'content': 'just ibuprofen'},
        ]
        resp = self.service.get_response(history)
        self.assertIsNotNone(resp['recommendation'])
        self.assertEqual(resp['recommendation']['specialty'], 'Neurology')

    def test_detects_cardiology(self):
        history = [
            {'role': 'user', 'content': 'chest pain'},
            {'role': 'user', 'content': 'a week'},
            {'role': 'user', 'content': 'moderate'},
            {'role': 'user', 'content': 'no'},
        ]
        resp = self.service.get_response(history)
        self.assertEqual(resp['recommendation']['specialty'], 'Cardiology')

    def test_detects_dermatology(self):
        history = [
            {'role': 'user', 'content': 'skin rash'},
            {'role': 'user', 'content': 'a few days'},
            {'role': 'user', 'content': 'mild'},
            {'role': 'user', 'content': 'no'},
        ]
        resp = self.service.get_response(history)
        self.assertEqual(resp['recommendation']['specialty'], 'Dermatology')

    def test_fallback_general_practice(self):
        history = [
            {'role': 'user', 'content': 'I feel unwell'},
            {'role': 'user', 'content': 'a while'},
            {'role': 'user', 'content': 'not sure'},
            {'role': 'user', 'content': 'no'},
        ]
        resp = self.service.get_response(history)
        self.assertEqual(resp['recommendation']['specialty'], 'General Practice')

    def test_urgency_high(self):
        history = [
            {'role': 'user', 'content': 'severe headache'},
            {'role': 'user', 'content': 'today'},
            {'role': 'user', 'content': '10'},
            {'role': 'user', 'content': 'no'},
        ]
        resp = self.service.get_response(history)
        self.assertEqual(resp['recommendation']['urgency'], 'high')

    def test_urgency_low(self):
        history = [
            {'role': 'user', 'content': 'mild headache'},
            {'role': 'user', 'content': 'today'},
            {'role': 'user', 'content': 'mild'},
            {'role': 'user', 'content': 'no'},
        ]
        resp = self.service.get_response(history)
        self.assertEqual(resp['recommendation']['urgency'], 'low')


OTP_FIXED = {'CODE_LENGTH': 6, 'EXPIRY_MINUTES': 10, 'MAX_PER_HOUR': 5, 'BACKEND': 'fixed'}
OTP_CONSOLE = {'CODE_LENGTH': 6, 'EXPIRY_MINUTES': 10, 'MAX_PER_HOUR': 5, 'BACKEND': 'console'}
OTP_EMAIL = {'CODE_LENGTH': 6, 'EXPIRY_MINUTES': 10, 'MAX_PER_HOUR': 5, 'BACKEND': 'email'}


class TestOtpService(TestCase):
    @override_settings(OTP_SETTINGS=OTP_FIXED)
    def test_fixed_backend_code(self):
        service = OtpService()
        code = service.generate_and_send('test@test.com')
        self.assertEqual(code, '111111')

    @override_settings(OTP_SETTINGS=OTP_FIXED)
    def test_fixed_include_in_response(self):
        self.assertTrue(OtpService().should_include_in_response())

    @override_settings(OTP_SETTINGS=OTP_CONSOLE)
    def test_console_include_in_response(self):
        self.assertTrue(OtpService().should_include_in_response())

    @override_settings(OTP_SETTINGS=OTP_EMAIL)
    def test_email_not_include_in_response(self):
        self.assertFalse(OtpService().should_include_in_response())

    @override_settings(OTP_SETTINGS=OTP_CONSOLE)
    def test_console_generates_6_digit_code(self):
        service = OtpService()
        with patch('builtins.print'):
            code = service.generate_and_send('test@test.com')
        self.assertEqual(len(code), 6)
        self.assertTrue(code.isdigit())

    @override_settings(OTP_SETTINGS=OTP_FIXED)
    def test_otp_stored_in_db(self):
        OtpService().generate_and_send('test@test.com')
        otp = OtpCode.objects.get(email='test@test.com')
        self.assertEqual(otp.code, '111111')
        self.assertFalse(otp.is_used)
        self.assertGreater(otp.expires_at, timezone.now())

    @override_settings(OTP_SETTINGS={**OTP_FIXED, 'MAX_PER_HOUR': 2})
    def test_rate_limit(self):
        service = OtpService()
        service.generate_and_send('test@test.com')
        service.generate_and_send('test@test.com')
        with self.assertRaises(OtpRateLimitExceeded):
            service.generate_and_send('test@test.com')


# --- API Tests ---


@override_settings(OTP_SETTINGS=OTP_FIXED)
class TestConversationAPI(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_create_conversation(self):
        resp = self.client.post('/api/copilot/conversations/')
        self.assertEqual(resp.status_code, 201)
        data = resp.json()
        self.assertIn('session_id', data)
        self.assertEqual(len(data['messages']), 1)
        self.assertEqual(data['messages'][0]['role'], 'assistant')

    def test_retrieve_conversation(self):
        resp = self.client.post('/api/copilot/conversations/')
        cid = resp.json()['id']
        resp = self.client.get(f'/api/copilot/conversations/{cid}/')
        self.assertEqual(resp.status_code, 200)
        self.assertIn('messages', resp.json())

    def test_send_message(self):
        resp = self.client.post('/api/copilot/conversations/')
        cid = resp.json()['id']
        resp = self.client.post(
            f'/api/copilot/conversations/{cid}/messages/',
            {'content': 'I have a headache'},
            format='json',
        )
        self.assertEqual(resp.status_code, 200)
        self.assertIn('message', resp.json())
        self.assertEqual(resp.json()['message']['role'], 'assistant')

    def test_recommendation_after_full_conversation(self):
        resp = self.client.post('/api/copilot/conversations/')
        cid = resp.json()['id']
        messages = [
            'I have terrible headaches',
            'About a week, getting worse',
            'Severity is about 7, moderate',
            'Just ibuprofen, persistent pain',
        ]
        result = None
        for msg in messages:
            resp = self.client.post(
                f'/api/copilot/conversations/{cid}/messages/',
                {'content': msg},
                format='json',
            )
            result = resp.json()
        self.assertIsNotNone(result['recommendation'])
        self.assertEqual(result['recommendation']['specialty'], 'Neurology')


@override_settings(OTP_SETTINGS=OTP_FIXED)
class TestPatientAuthAPI(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_register_new_patient(self):
        resp = self.client.post(
            '/api/copilot/patients/register/',
            {
                'name': 'John Doe',
                'email': 'john@company.com',
                'phone': '+1234567890',
                'date_of_birth': '1990-05-15',
            },
            format='json',
        )
        self.assertEqual(resp.status_code, 201)
        self.assertEqual(resp.json()['patient']['name'], 'John Doe')
        self.assertEqual(resp.json()['otp'], '111111')
        self.assertEqual(Patient.objects.count(), 1)

    def test_register_existing_email_updates(self):
        Patient.objects.create(
            name='Old Name',
            email='john@company.com',
            phone='000',
            date_of_birth='1990-01-01',
        )
        resp = self.client.post(
            '/api/copilot/patients/register/',
            {
                'name': 'New Name',
                'email': 'john@company.com',
                'phone': '+999',
                'date_of_birth': '1991-02-02',
            },
            format='json',
        )
        self.assertEqual(resp.status_code, 200)
        patient = Patient.objects.get(email='john@company.com')
        self.assertEqual(patient.name, 'New Name')
        self.assertEqual(patient.phone, '+999')

    def test_send_otp_existing_patient(self):
        Patient.objects.create(
            name='A', email='a@test.com', phone='1', date_of_birth='1990-01-01'
        )
        resp = self.client.post(
            '/api/copilot/patients/send-otp/',
            {'email': 'a@test.com'},
            format='json',
        )
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.json()['otp'], '111111')

    def test_send_otp_unknown_email(self):
        resp = self.client.post(
            '/api/copilot/patients/send-otp/',
            {'email': 'nobody@test.com'},
            format='json',
        )
        self.assertEqual(resp.status_code, 404)

    def test_verify_otp_success(self):
        Patient.objects.create(
            name='A', email='a@test.com', phone='1', date_of_birth='1990-01-01'
        )
        OtpCode.objects.create(
            email='a@test.com',
            code='111111',
            expires_at=timezone.now() + timedelta(minutes=10),
        )
        resp = self.client.post(
            '/api/copilot/patients/verify-otp/',
            {'email': 'a@test.com', 'code': '111111'},
            format='json',
        )
        self.assertEqual(resp.status_code, 200)
        self.assertIn('token', resp.json())
        self.assertTrue(resp.json()['patient']['is_verified'])

    def test_verify_otp_wrong_code(self):
        Patient.objects.create(
            name='A', email='a@test.com', phone='1', date_of_birth='1990-01-01'
        )
        OtpCode.objects.create(
            email='a@test.com',
            code='111111',
            expires_at=timezone.now() + timedelta(minutes=10),
        )
        resp = self.client.post(
            '/api/copilot/patients/verify-otp/',
            {'email': 'a@test.com', 'code': '999999'},
            format='json',
        )
        self.assertEqual(resp.status_code, 400)

    def test_verify_otp_expired(self):
        Patient.objects.create(
            name='A', email='a@test.com', phone='1', date_of_birth='1990-01-01'
        )
        OtpCode.objects.create(
            email='a@test.com',
            code='111111',
            expires_at=timezone.now() - timedelta(minutes=1),
        )
        resp = self.client.post(
            '/api/copilot/patients/verify-otp/',
            {'email': 'a@test.com', 'code': '111111'},
            format='json',
        )
        self.assertEqual(resp.status_code, 400)

    def test_verify_otp_already_used(self):
        Patient.objects.create(
            name='A', email='a@test.com', phone='1', date_of_birth='1990-01-01'
        )
        OtpCode.objects.create(
            email='a@test.com',
            code='111111',
            expires_at=timezone.now() + timedelta(minutes=10),
            is_used=True,
        )
        resp = self.client.post(
            '/api/copilot/patients/verify-otp/',
            {'email': 'a@test.com', 'code': '111111'},
            format='json',
        )
        self.assertEqual(resp.status_code, 400)

    def test_patient_me_authenticated(self):
        patient = Patient.objects.create(
            name='A', email='a@test.com', phone='1', date_of_birth='1990-01-01'
        )
        user = User.objects.create_user(username='a@test.com', email='a@test.com')
        token = Token.objects.create(user=user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Token {token.key}')
        resp = self.client.get('/api/copilot/patients/me/')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.json()['email'], 'a@test.com')

    def test_patient_me_unauthenticated(self):
        resp = self.client.get('/api/copilot/patients/me/')
        self.assertEqual(resp.status_code, 401)

    @override_settings(OTP_SETTINGS={**OTP_FIXED, 'MAX_PER_HOUR': 2})
    def test_register_rate_limit(self):
        data = {
            'name': 'A',
            'email': 'a@test.com',
            'phone': '1',
            'date_of_birth': '1990-01-01',
        }
        self.client.post('/api/copilot/patients/register/', data, format='json')
        self.client.post('/api/copilot/patients/register/', data, format='json')
        resp = self.client.post(
            '/api/copilot/patients/register/', data, format='json'
        )
        self.assertEqual(resp.status_code, 429)


@override_settings(OTP_SETTINGS=OTP_FIXED)
class TestAppointmentAPI(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.specialty = Specialty.objects.create(name='Neurology')
        self.doctor = Doctor.objects.create(name='Dr. Brain', specialty=self.specialty)
        self.slot = TimeSlot.objects.create(
            doctor=self.doctor,
            start_time=timezone.now() + timedelta(days=1),
            is_available=True,
        )
        self.patient = Patient.objects.create(
            name='A',
            email='a@test.com',
            phone='1',
            date_of_birth='1990-01-01',
            is_verified=True,
        )
        self.user = User.objects.create_user(username='a@test.com', email='a@test.com')
        self.token = Token.objects.create(user=self.user)

    def test_create_appointment_marks_slot_unavailable(self):
        resp = self.client.post(
            '/api/copilot/appointments/',
            {
                'patient': self.patient.id,
                'doctor': self.doctor.id,
                'time_slot': self.slot.id,
                'symptoms_summary': 'headaches',
                'urgency_level': 'medium',
            },
            format='json',
        )
        self.assertEqual(resp.status_code, 201)
        self.slot.refresh_from_db()
        self.assertFalse(self.slot.is_available)

    def test_list_requires_auth(self):
        resp = self.client.get('/api/copilot/appointments/')
        self.assertEqual(resp.status_code, 401)

    def test_list_returns_only_patient_appointments(self):
        # Create appointment for our patient
        Appointment.objects.create(
            patient=self.patient,
            doctor=self.doctor,
            time_slot=self.slot,
            symptoms_summary='headaches',
            urgency_level='medium',
        )
        # Create another patient's appointment
        other_patient = Patient.objects.create(
            name='B', email='b@test.com', phone='2', date_of_birth='1991-01-01'
        )
        other_slot = TimeSlot.objects.create(
            doctor=self.doctor,
            start_time=timezone.now() + timedelta(days=2),
        )
        Appointment.objects.create(
            patient=other_patient,
            doctor=self.doctor,
            time_slot=other_slot,
            symptoms_summary='other',
            urgency_level='low',
        )

        self.client.credentials(HTTP_AUTHORIZATION=f'Token {self.token.key}')
        resp = self.client.get('/api/copilot/appointments/')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(len(resp.json()), 1)
        self.assertEqual(resp.json()[0]['doctor_name'], 'Dr. Brain')

    def test_duplicate_time_slot_fails(self):
        Appointment.objects.create(
            patient=self.patient,
            doctor=self.doctor,
            time_slot=self.slot,
            symptoms_summary='first',
            urgency_level='low',
        )
        from django.db import IntegrityError

        with self.assertRaises(IntegrityError):
            Appointment.objects.create(
                patient=self.patient,
                doctor=self.doctor,
                time_slot=self.slot,
                symptoms_summary='duplicate',
                urgency_level='low',
            )
