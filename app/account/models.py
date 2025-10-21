from django.db import models
from django.contrib.auth.models import User

class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    image = models.ImageField(default='profile_pics/default.jpg', upload_to='profile_pics/')

    def __str__(self):
        return f'{self.user.username} Profile'

class Subscription(models.Model):
    sub_from = models.ForeignKey(
        User, on_delete=models.CASCADE, related_name='subscriptions'
    )
    sub_to = models.ForeignKey(
        User, on_delete=models.CASCADE, related_name='subscribers'
    )
    created = models.DateTimeField(
        auto_now_add=True
    )

    class Meta:
        ordering = ['created']
        indexes = [
            models.Index(fields=['sub_to'])
        ]

    def __str__(self):
        return f"Subscription from {self.sub_from.username} to {self.sub_to.username}"