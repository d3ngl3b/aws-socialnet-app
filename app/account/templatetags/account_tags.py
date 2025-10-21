from django.contrib.auth.models import User
from django import template
from ..models import Subscription


register = template.Library()

@register.inclusion_tag('account/subscriptions.html')
def show_subscriptions(sub_from: User, count=5):
    subscriptions = Subscription.objects.filter(
        sub_from=sub_from
    ).order_by('-created')[:count]
    return {'subscriptions': subscriptions}