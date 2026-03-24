from datetime import timedelta

from django.core.management.base import BaseCommand
from django.utils import timezone

from copilot.models import OtpCode


class Command(BaseCommand):
    help = 'Delete OTP codes older than 24 hours'

    def handle(self, *args, **options):
        cutoff = timezone.now() - timedelta(hours=24)
        count, _ = OtpCode.objects.filter(
            created_at__lt=cutoff,
        ).delete()
        self.stdout.write(
            self.style.SUCCESS(f'Deleted {count} expired OTP codes')
        )
