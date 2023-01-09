FROM node:16-alpine as build
WORKDIR /app
ADD package.json yarn.lock /app/
RUN yarn install --frozen-lockfile
COPY . .
RUN yarn build


FROM node:16-alpine as dependencies
WORKDIR /app
ADD package.json yarn.lock /app/
RUN yarn install --frozen-lockfile --production


FROM node:16-alpine
ENV NODE_ENV production
WORKDIR /app
RUN apk add --update --no-cache dumb-init vim
COPY --from=dependencies --chown=node:node /app/node_modules /app/node_modules
COPY --from=build --chown=node:node /app/dist /app/dist
USER node
EXPOSE 8080
CMD dumb-init node dist/index.js
