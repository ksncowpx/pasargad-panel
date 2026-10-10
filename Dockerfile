FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# ۱. نصب پکیج‌های پایه‌ای و کامپایلرها برای پایتون
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    supervisor \
    procps \
    unzip \
    ca-certificates \
    build-essential \
    python3-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# ۲. دانلود مستقیم باینری آماده Caddy (بدون دردسر APT)
RUN curl -sSL "https://caddyserver.com/api/download?os=linux&arch=amd64" -o /usr/bin/caddy && \
    chmod +x /usr/bin/caddy

# ۳. دانلود مستقیم باینری آماده Xray Core
RUN mkdir -p /tmp/xray && \
    curl -sSL "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip" -o /tmp/xray/xray.zip && \
    unzip /tmp/xray/xray.zip -d /tmp/xray && \
    mv /tmp/xray/xray /usr/local/bin/xray && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray

# ۴. دانلود سورس پاسارگاد
WORKDIR /app
RUN git clone https://github.com/hrostami/pasargad.git /app/pasargad

# ۵. آپدیت pip و نصب پکیج‌های پایتون
WORKDIR /app/pasargad
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir -r requirements.txt

# ۶. انتقال کانفیگ‌ها و دسترسی‌ها
WORKDIR /app
COPY Caddyfile /app/Caddyfile
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 8080

CMD ["/app/entrypoint.sh"]
