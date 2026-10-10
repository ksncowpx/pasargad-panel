# مرحله اول: گرفتن فایل اجرایی کدی از ایمیج رسمی
FROM caddy:2-alpine AS caddy-bin

# مرحله دوم: سیستم اصلی پاسارگاد
FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# ۱. کپی کردن Caddy بدون نیاز به مخزن APT
COPY --from=caddy-bin /usr/bin/caddy /usr/bin/caddy

# ۲. نصب پیش‌نیازهای ضروری و سوپروایزر
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    supervisor \
    procps \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ۳. دانلود و نصب هسته رسمی Xray
RUN bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# ۴. دانلود سورس پنل پاسارگاد از گیت‌هاب
WORKDIR /app
RUN git clone https://github.com/hrostami/pasargad.git /app/pasargad

# ۵. نصب کتابخانه‌های پایتونی پاسارگاد
WORKDIR /app/pasargad
RUN pip3 install --no-cache-dir -r requirements.txt

# ۶. انتقال کانفیگ‌ها
WORKDIR /app
COPY Caddyfile /app/Caddyfile
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh

# پورت
EXPOSE 8080

CMD ["/app/entrypoint.sh"]
