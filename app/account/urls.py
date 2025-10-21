from django.contrib.auth import views as auth_views
from django.urls import path
from . import views

app_name = 'account'

urlpatterns = [
    path('login/', auth_views.LoginView.as_view(
        template_name='account/login.html',
        next_page='blog:post_list'
    ), name='login'),
    path('logout/', auth_views.LogoutView.as_view(
        next_page='blog:post_list'
    ), name='logout'),
    path('register/', views.register, name='register'),
    path('profile/', views.profile, name='profile'),
    path('user_detail/<slug:username>', views.user_detail, name='user_detail')
]