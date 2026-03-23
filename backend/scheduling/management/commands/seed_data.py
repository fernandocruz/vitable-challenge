from datetime import timedelta

from django.core.management.base import BaseCommand
from django.utils import timezone

from scheduling.models import Doctor, Specialty, TimeSlot

SPECIALTIES = [
    ('General Practice', 'Primary care for general health concerns'),
    ('Cardiology', 'Heart and cardiovascular system'),
    ('Dermatology', 'Skin, hair, and nail conditions'),
    ('Orthopedics', 'Bones, joints, and musculoskeletal system'),
    ('Neurology', 'Brain, spine, and nervous system'),
    ('ENT', 'Ear, nose, and throat conditions'),
    ('Gastroenterology', 'Digestive system and gastrointestinal tract'),
]

DOCTORS = [
    ('Dr. Sarah Johnson', 'General Practice', 'Board-certified family medicine physician with 15 years of experience.'),
    ('Dr. Michael Chen', 'General Practice', 'Specializing in preventive care and chronic disease management.'),
    ('Dr. Emily Rodriguez', 'Cardiology', 'Expert in heart disease prevention and treatment.'),
    ('Dr. James Wilson', 'Cardiology', 'Interventional cardiologist with focus on minimally invasive procedures.'),
    ('Dr. Lisa Park', 'Dermatology', 'Specializing in medical and cosmetic dermatology.'),
    ('Dr. Robert Kim', 'Dermatology', 'Expert in skin cancer screening and treatment.'),
    ('Dr. Amanda Foster', 'Orthopedics', 'Sports medicine and joint replacement specialist.'),
    ('Dr. David Martinez', 'Orthopedics', 'Spine and back pain specialist.'),
    ('Dr. Jennifer Lee', 'Neurology', 'Expert in headaches, migraines, and neurological disorders.'),
    ('Dr. Thomas Brown', 'Neurology', 'Specializing in movement disorders and epilepsy.'),
    ('Dr. Rachel Green', 'ENT', 'Expert in sinus conditions and hearing disorders.'),
    ('Dr. Kevin White', 'ENT', 'Specializing in voice and swallowing disorders.'),
    ('Dr. Maria Santos', 'Gastroenterology', 'Expert in digestive disorders and endoscopy.'),
    ('Dr. Andrew Taylor', 'Gastroenterology', 'Specializing in liver disease and IBD.'),
]


class Command(BaseCommand):
    help = 'Seed the database with specialties, doctors, and time slots'

    def handle(self, *args, **options):
        self.stdout.write('Seeding specialties...')
        specialty_map = {}
        for name, description in SPECIALTIES:
            specialty, _ = Specialty.objects.get_or_create(
                name=name, defaults={'description': description}
            )
            specialty_map[name] = specialty

        self.stdout.write('Seeding doctors...')
        for name, specialty_name, bio in DOCTORS:
            Doctor.objects.get_or_create(
                name=name,
                defaults={
                    'specialty': specialty_map[specialty_name],
                    'bio': bio,
                },
            )

        self.stdout.write('Seeding time slots...')
        now = timezone.now().replace(minute=0, second=0, microsecond=0)
        start = now + timedelta(days=1)

        for doctor in Doctor.objects.all():
            for day_offset in range(7):
                day = start + timedelta(days=day_offset)
                for hour in [9, 10, 11, 14, 15, 16]:
                    slot_time = day.replace(hour=hour)
                    TimeSlot.objects.get_or_create(
                        doctor=doctor,
                        start_time=slot_time,
                        defaults={'is_available': True},
                    )

        total_slots = TimeSlot.objects.count()
        self.stdout.write(self.style.SUCCESS(
            f'Done! {Specialty.objects.count()} specialties, '
            f'{Doctor.objects.count()} doctors, '
            f'{total_slots} time slots'
        ))
