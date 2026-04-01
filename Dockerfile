FROM node:24-alpine

RUN npm install -g openclaw@latest

WORKDIR /app
COPY openclaw.config.json .

EXPOSE 18789

CMD ["openclaw", "gateway", "start", "--config", "/app/openclaw.config.json"]
