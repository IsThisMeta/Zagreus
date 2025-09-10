FROM node:18-alpine
LABEL org.opencontainers.image.source="https://github.com/zebrralabs/zagreus-notification-service"
# Install packages, copy data, build project
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
# Copy APNS key
COPY AuthKey_7A74STAX6C.p8 /app/AuthKey_7A74STAX6C.p8
RUN npm run build
RUN npm prune --production
# Add Tini
RUN apk add --no-cache tini
ENTRYPOINT ["/sbin/tini", "--"]
# Start the docker version, expose port 8080
CMD ["npm", "run", "docker"]
EXPOSE 8080
