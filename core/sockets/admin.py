from django.contrib import admin

from .models import Socket

@admin.register(Socket)
class SocketAdmin(admin.ModelAdmin):
    list_display = ('short_id', 'user', 'path', 'active', 'last_ping', 'user_ip')
    search_fields = ('id', 'user__username', 'user__email', 'path', 'user_ip')


