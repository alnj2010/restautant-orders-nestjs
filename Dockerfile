ARG NODE_VERSION=20.15

FROM node:${NODE_VERSION} as dev

WORKDIR /usr/src/app

# Install basic development tools
RUN apt update && apt install -y less man-db sudo

ENV DEVCONTAINER=true

RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --include=dev

COPY . .

EXPOSE 3000

CMD ["npm","run","start:debug"]

