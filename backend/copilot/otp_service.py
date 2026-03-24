import random
import secrets
import string
from datetime import timedelta

from django.conf import settings
from django.core.mail import send_mail
from django.utils import timezone

from .models import OtpCode


class OtpRateLimitExceeded(Exception):
    pass


class OtpService:
    def __init__(self):
        otp_settings = getattr(settings, 'OTP_SETTINGS', {})
        self._backend = otp_settings.get('BACKEND', 'console')
        self._code_length = otp_settings.get('CODE_LENGTH', 6)
        self._expiry_minutes = otp_settings.get('EXPIRY_MINUTES', 10)
        self._max_per_hour = otp_settings.get('MAX_PER_HOUR', 5)

    def generate_and_send(self, email):
        """Generate OTP, store it, deliver it. Returns the code."""
        self._check_rate_limit(email)

        code = self._generate_code()
        expires_at = timezone.now() + timedelta(minutes=self._expiry_minutes)

        OtpCode.objects.create(
            email=email,
            code=code,
            expires_at=expires_at,
        )

        self._deliver(email, code)
        return code

    def should_include_in_response(self):
        """True for console/fixed backends (dev/test). False for email (prod)."""
        return self._backend in ('console', 'fixed')

    def _generate_code(self):
        if self._backend == 'fixed':
            return '1' * self._code_length  # e.g., "111111"

        if self._backend == 'email':
            # Cryptographically secure for production
            return ''.join(
                secrets.choice(string.digits)
                for _ in range(self._code_length)
            )

        # console backend: standard random (sufficient for dev)
        return ''.join(
            random.choices(string.digits, k=self._code_length)
        )

    def _deliver(self, email, code):
        if self._backend == 'fixed':
            return  # No delivery for automated testing

        if self._backend == 'email':
            send_mail(
                subject='Health Copilot - Your verification code',
                message=f'Your verification code is: {code}\n\nThis code expires in {self._expiry_minutes} minutes.',
                from_email=None,  # Uses DEFAULT_FROM_EMAIL
                recipient_list=[email],
                fail_silently=False,
            )
            return

        # console backend
        print(f'\n*** OTP for {email}: {code} ***\n')

    def _check_rate_limit(self, email):
        one_hour_ago = timezone.now() - timedelta(hours=1)
        recent_count = OtpCode.objects.filter(
            email=email,
            created_at__gt=one_hour_ago,
        ).count()

        if recent_count >= self._max_per_hour:
            raise OtpRateLimitExceeded(
                'Too many OTP requests. Try again later.'
            )
