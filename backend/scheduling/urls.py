from rest_framework.routers import DefaultRouter

from .views import DoctorViewSet, SpecialtyViewSet

router = DefaultRouter()
router.register('specialties', SpecialtyViewSet)
router.register('doctors', DoctorViewSet)

urlpatterns = router.urls
