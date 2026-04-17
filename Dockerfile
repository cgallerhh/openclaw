FROM node:24-alpine

RUN apk add --no-cache git

RUN npm install -g openclaw@latest grammy @grammyjs/runner @grammyjs/transformer-throttler @aws-sdk/client-bedrock

WORKDIR /app
COPY openclaw.config.json .

EXPOSE 18789

RUN mkdir -p /root/.openclaw

CMD cp /app/openclaw.config.json /root/.openclaw/config.json && \
    { [ -n "$TELEGRAM_API_KEY" ] && openclaw channels add --channel telegram --token "$TELEGRAM_API_KEY" || true; } && \
    openclaw gateway --allow-unconfigured
