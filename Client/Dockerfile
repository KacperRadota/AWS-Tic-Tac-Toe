FROM node:21-bookworm as build
COPY . /app
WORKDIR /app
RUN npm install
RUN npm run build
FROM nginx:1.25-bookworm
COPY --from=build /app/dist /usr/share/nginx/html
