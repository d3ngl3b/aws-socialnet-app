#!/bin/bash
# Author: Gleb Denisov
# Description: This entrypoint runs Django setup commands and waits for database.

# Waiting for database
if [ "$DATABASE" = "postgres" ];then
  echo "[*] Waiting for Postgres to start..."

  while ! nc -z "$SQL_HOST" "$SQL_PORT";do
    sleep 0.1
  done

  echo "[*] Postgres started."
fi

# Django setup commands
#python3 manage.py flush --no-input
python manage.py makemigrations
python manage.py migrate

# Collect static files
STATIC_DIR="/usr/src/app/staticfiles"
python manage.py collectstatic

# Create superuser if it doesn't exist
echo "[*] Creating superuser"
DJANGO_SUPERUSER_USERNAME=${DJANGO_SUPERUSER_USERNAME:-admin}
DJANGO_SUPERUSER_EMAIL=${DJANGO_SUPERUSER_EMAIL:-admin@example.com}
DJANGO_SUPERUSER_PASSWORD=${DJANGO_SUPERUSER_PASSWORD:-adminpass}

python manage.py shell << END
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username="$DJANGO_SUPERUSER_USERNAME").exists():
    User.objects.create_superuser("$DJANGO_SUPERUSER_USERNAME", "$DJANGO_SUPERUSER_EMAIL", "$DJANGO_SUPERUSER_PASSWORD")
END

# CMD
exec "$@"