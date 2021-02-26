#FROM node:14.15.4-slim AS prisma
#
#ENV NODE_ENV=production
#WORKDIR /usr/src/app
#
#RUN npm install -g @prisma/cli@2.17.0
#COPY prisma/schema.prisma prisma/schema.prisma
#RUN prisma generate

FROM node:14.15.4

ENV NODE_ENV=production
WORKDIR /usr/src/app

RUN chown node:node .
USER node

COPY package*.json ./
COPY prisma/schema.prisma prisma/schema.prisma
RUN npm install --production
RUN npm run generate

COPY server.js .
#COPY --from=prisma /usr/src/app/node_modules/.prisma node_modules/.prisma

EXPOSE 3000
ENTRYPOINT [ "npm", "run", "start" ]
