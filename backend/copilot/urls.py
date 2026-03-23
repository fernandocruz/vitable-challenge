from rest_framework.routers import DefaultRouter

from .views import AppointmentViewSet, ConversationViewSet

router = DefaultRouter()
router.register('conversations', ConversationViewSet)
router.register('appointments', AppointmentViewSet)

urlpatterns = router.urls
