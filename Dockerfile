FROM alpine:3.14
RUN apk add --no-cache bash
WORKDIR /code
COPY logging.sh .
