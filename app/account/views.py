from django.contrib.auth import authenticate, login
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse
from django.shortcuts import render, get_object_or_404
from .forms import LoginForm, UserRegisterForm
from django.shortcuts import redirect
from django.contrib.auth.models import User
from django.contrib import messages
from .models import Subscription


def user_login(request):
    if request.method == 'POST':
        form = LoginForm(request.POST)
        if form.is_valid():
            cd = form.cleaned_data
            user = authenticate(
                request,
                username=cd['username'],
                password=cd['password']
            )
            if user is not None:
                if user.is_active:
                    login(request, user)
                    return HttpResponse('Authentication successfully')
                else:
                    return HttpResponse('Disabled account')
            else:
                return HttpResponse('Invalid login')
    else:
        form = LoginForm()
    return render(request, 'account/login.html', {'form': form})

def register(request):
    if request.method == 'POST':
        form = UserRegisterForm(request.POST)
        if form.is_valid():
            form.save()
            cd = form.cleaned_data
            username = cd['username']
            messages.success(
                request,
                f"{username}, your account has been created! You are now able to log in"
            )
            return redirect('account:login')
    else:
        form = UserRegisterForm()
    return render(request, 'account/register.html', {'form': form})

@login_required(login_url='/account/login/')
def profile(request):
    return render(request, 'account/profile.html')

@login_required(login_url='/account/login/')
def user_detail(request, username):
    if request.method == 'POST':
        sub_from = request.user
        sub_to = get_object_or_404(
            User, username=username
        )

        if sub_from == sub_to:
            messages.error(request, "You can not subscribe to yourself")
            return redirect('account:user_detail', username=username)

        subscription, created = Subscription.objects.get_or_create(
            sub_from=sub_from,
            sub_to=sub_to,
        )

        if created:
            messages.success(request, f"You are now subscribed to {sub_to.username}")
        else:
            messages.info(request, f"You are already subscribed to {sub_to.username}.")


    user = get_object_or_404(

        User, username=username
    )
    return render(
        request,
        'account/user_detail.html',
        {
            'user': user
        }
    )
