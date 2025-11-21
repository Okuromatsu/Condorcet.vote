#!/bin/sh

# Exit immediately if a command exits with a non-zero status
set -e

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Create superuser if environment variables are set
if [ -n "$DJANGO_SUPERUSER_USERNAME" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ]; then
    echo "Checking superuser configuration..."
    python manage.py shell << END
import os
from django.contrib.auth import get_user_model

User = get_user_model()
username = os.environ['DJANGO_SUPERUSER_USERNAME']
password = os.environ['DJANGO_SUPERUSER_PASSWORD']
email = os.environ.get('DJANGO_SUPERUSER_EMAIL', 'admin@example.com')

if not User.objects.filter(username=username).exists():
    print(f"Creating superuser {username}")
    User.objects.create_superuser(username, email, password)
else:
    print(f"Superuser {username} already exists. Updating password.")
    u = User.objects.get(username=username)
    u.set_password(password)
    u.save()
END
fi

# Start Gunicorn
echo "Starting Gunicorn..."
exec gunicorn condorcet_project.wsgi:application --bind 0.0.0.0:8000
