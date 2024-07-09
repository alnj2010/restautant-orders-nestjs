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
RUN --mount=type=bind,id=s/4d92fc04-d674-4ea8-93fb-7ccdad5fcd9b-package.json,source=package.json,target=package.json \
    --mount=type=bind,id=s/4d92fc04-d674-4ea8-93fb-7ccdad5fcd9b-package-lock.json,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,id=s/4d92fc04-d674-4ea8-93fb-7ccdad5fcd9b-/root/.npm,target=/root/.npm \
    npm ci --include=dev
COPY . .
CMD ["npm", "run", "start:debug"]

#--------------TEST--------------------------
FROM base AS test
ENV NODE_ENV=test
RUN --mount=type=bind,id=s/4d92fc04-d674-4ea8-93fb-7ccdad5fcd9b-package.json,source=package.json,target=package.json \
    --mount=type=bind,id=s/4d92fc04-d674-4ea8-93fb-7ccdad5fcd9b-package-lock.json,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,id=s/4d92fc04-d674-4ea8-93fb-7ccdad5fcd9b-/root/.npm,target=/root/.npm \
    npm ci --include=dev
USER node
COPY . .
RUN npm run test:cov

# --------------BUILD-------------------------
FROM base AS build
COPY --from=dev /usr/src/app/node_modules ./node_modules
COPY . .
RUN npm run build
ENV NODE_ENV=production
RUN --mount=type=bind,id=s/4d92fc04-d674-4ea8-93fb-7ccdad5fcd9b-package.json,source=package.json,target=package.json \
    --mount=type=bind,id=s/4d92fc04-d674-4ea8-93fb-7ccdad5fcd9b-package-lock.json,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,id=s/4d92fc04-d674-4ea8-93fb-7ccdad5fcd9b-/root/.npm,target=/root/.npm \
    npm ci --only=production && npm cache clean --force

# --------------PROD-------------------------
FROM base AS prod
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/dist ./dist
CMD [ "node", "dist/main.js" ]


