FROM quay.io/upslopeio/node-alpine as build
WORKDIR /react-intro
COPY ./react-intro .
RUN npm install
RUN npm run build

FROM quay.io/upslopeio/nginx-unprivileged
COPY --from=build react-intro/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf