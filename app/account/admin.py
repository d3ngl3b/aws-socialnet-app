from django.contrib import admin
from .models import Profile, Subscription


@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'image']
    search_fields = ['user']
    search_fields = ['user__username', 'user__email']


@admin.register(Subscription)
class SubscriptionAdmin(admin.ModelAdmin):
    list_display = ['sub_from', 'sub_to', 'created',]
    list_filter = ['sub_from', 'sub_to']
    search_fields = ['sub_from', 'sub_to', 'created']
    raw_id_fields = ['sub_from', 'sub_to']