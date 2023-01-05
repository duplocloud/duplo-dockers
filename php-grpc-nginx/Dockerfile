FROM trafex/php-nginx:latest
# Install composer from the official image
COPY --from=composer/composer /usr/bin/composer /usr/bin/composer

# Install zip and pdo so that composer works
# Add whatever other php extensions you need in the image here
USER root
RUN apk add --no-cache gcc musl-dev php81-zip php81-pdo autoconf php81-dev php81-pear php81-pear zlib-dev make g++ linux-headers
# set back to non-root after installing extensions

RUN pecl81 install grpc
