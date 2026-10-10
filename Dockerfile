FROM python:3.10-slim

# تنظیم متغیرهای محیطی
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# ۱. نصب پیش‌نیازهای سیستمی، Caddy و Supervisor
RUN apt-get update && apt-get install -y \
    curl \
    git \
    supervisor \
    debian-keyring \
    debian-archive-keyring \
    apt-transport-https \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list \
    && apt-get update \
    && apt-get install -y caddy \
    && rm -rf /var/lib/apt/lists/*

# ۲. دانلود و نصب هسته رسمی Xray
RUN bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# ۳. دانلود سورس پنل پاسارگاد از گیت‌هاب
WORKDIR /app
RUN git clone https://github.com/hrostami/pasargad.git /app/pasargad

# ۴. نصب کتابخانه‌های پایتونی پاسارگاد
WORKDIR /app/pasargad
RUN pip3 install --no-cache-dir -r requirements.txt

# ۵. بازگشت به ریشه و انتقال فایل‌های کانفیگ
WORKDIR /app
COPY Caddyfile /app/Caddyfile
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh

# پورت پیش‌فرض
EXPOSE 8080

CMD ["/app/entrypoint.sh"]