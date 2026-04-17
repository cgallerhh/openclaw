FROM node:24-alpine

RUN npm install -g openclaw@latest grammy @grammyjs/runner @grammyjs/transformer-throttler

WORKDIR /app
COPY openclaw.config.json .

EXPOSE 18789

RUN mkdir -p /root/.openclaw

CMD cp /app/openclaw.config.json /root/.openclaw/config.json && openclaw gateway --allow-unconfigured
