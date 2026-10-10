#!/bin/bash

# ساخت پوشه‌های لاگ اگر وجود نداشته باشند
mkdir -p /var/log/supervisor

# تنظیمات پیش‌فرض برای اجرای پاسارگاد در صورت نیاز
export UWSGI_PORT=8000

echo "Starting Supervisor to manage Pasargad and Caddy..."

# اجرای سوپروایزر
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf