FROM node:24-alpine

RUN apk add --no-cache git curl

# Install himalaya email CLI (Gmail IMAP/SMTP)
RUN curl -sSL https://github.com/pimalaya/himalaya/releases/latest/download/himalaya-x86_64-unknown-linux-musl.tar.gz \
    | tar -xz -C /usr/local/bin/ himalaya \
    && chmod +x /usr/local/bin/himalaya

RUN npm install -g openclaw@latest grammy @grammyjs/runner @grammyjs/transformer-throttler @aws-sdk/client-bedrock

WORKDIR /app
COPY openclaw.config.json .

EXPOSE 18789

RUN mkdir -p /root/.openclaw

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
