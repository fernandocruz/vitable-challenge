from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import (
    AppointmentViewSet,
    ConversationViewSet,
    PatientMeView,
    RegisterPatientView,
    SendOtpView,
    VerifyOtpView,
)

router = DefaultRouter()
router.register('conversations', ConversationViewSet)
router.register('appointments', AppointmentViewSet)

urlpatterns = [
    path(
        'patients/register/',
        RegisterPatientView.as_view(),
        name='patient-register',
    ),
    path(
        'patients/send-otp/',
        SendOtpView.as_view(),
        name='patient-send-otp',
    ),
    path(
        'patients/verify-otp/',
        VerifyOtpView.as_view(),
        name='patient-verify-otp',
    ),
    path(
        'patients/me/',
        PatientMeView.as_view(),
        name='patient-me',
    ),
    *router.urls,
]
