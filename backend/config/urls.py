from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/scheduling/', include('scheduling.urls')),
    path('api/copilot/', include('copilot.urls')),
]
