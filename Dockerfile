FROM node:24-alpine

RUN apk add --no-cache git curl

RUN npm install -g openclaw@2026.5.28 grammy @grammyjs/runner @grammyjs/transformer-throttler @aws-sdk/client-bedrock @tensorfold/openclaw-google-workspace

WORKDIR /app
COPY openclaw.config.json .
COPY skills ./skills

EXPOSE 18789

RUN mkdir -p /root/.openclaw

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
