FROM ghcr.io/cirruslabs/flutter:3.32.6 as build-env

RUN flutter doctor -v

COPY . /app/

WORKDIR /app/

RUN flutter clean
RUN flutter pub get

RUN dart run build_runner build --delete-conflicting-outputs

RUN flutter build web

FROM nginx:1.29.0-alpine

COPY --from=build-env /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]