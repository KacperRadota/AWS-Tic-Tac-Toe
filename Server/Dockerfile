FROM node:21-bookworm
COPY . /app
WORKDIR /app
RUN npm install
EXPOSE 3000
ENTRYPOINT ["npm", "start"]