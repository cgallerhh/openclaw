FROM node:24-alpine

RUN npm install -g openclaw@latest grammy @grammyjs/runner @grammyjs/transformer-throttler @aws-sdk/client-bedrock

WORKDIR /app
COPY openclaw.config.json .

EXPOSE 18789

RUN mkdir -p /root/.openclaw && cp /app/openclaw.config.json /root/.openclaw/config.json

CMD ["openclaw", "gateway", "--allow-unconfigured"]
