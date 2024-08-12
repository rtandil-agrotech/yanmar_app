FROM ghcr.io/cirruslabs/flutter:3.24.0-0.2.pre

RUN flutter doctor -v

COPY . /app/

WORKDIR /app/

RUN flutter clean
RUN flutter pub get

RUN dart run build_runner build --delete-conflicting-outputs

RUN flutter build web

FROM nginx:1.25.2-alpine

COPY --from=build-env /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]