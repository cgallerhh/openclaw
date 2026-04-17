FROM node:24-alpine

RUN apk add --no-cache git

RUN npm install -g openclaw@latest grammy @grammyjs/runner @grammyjs/transformer-throttler @aws-sdk/client-bedrock

WORKDIR /app
COPY openclaw.config.json .

EXPOSE 18789

RUN mkdir -p /root/.openclaw

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
