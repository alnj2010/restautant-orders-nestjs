# syntax=docker/dockerfile:1
# --------------BASE-------------------------
ARG NODE_VERSION=20.15
FROM node:${NODE_VERSION}-alpine AS base
WORKDIR /usr/src/app
EXPOSE 3000

# --------------DEV-------------------------
FROM node:${NODE_VERSION} AS dev
ENV NODE_ENV=development
ENV DEVCONTAINER=true
WORKDIR /usr/src/app
EXPOSE 3000
RUN apt update && apt install -y less man-db sudo
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
    -t robbyrussell
COPY package*.json ./
RUN npm ci --include=dev
COPY . .
CMD ["npm", "run", "start:debug"]

#--------------TEST--------------------------
FROM base AS test
ENV NODE_ENV=test
COPY package*.json ./
RUN npm ci --include=dev
USER node
COPY . .
RUN npm run test:cov

# --------------BUILD-------------------------
FROM base AS build
COPY --from=dev /usr/src/app/node_modules ./node_modules
COPY . .
RUN npm run build
ENV NODE_ENV=production
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# --------------PROD-------------------------
FROM base AS prod
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/dist ./dist
CMD [ "node", "dist/main.js" ]


