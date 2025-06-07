FROM ruby:3.4-alpine

RUN apk update
RUN apk add build-base bash gcc git patch bzip2 libffi-dev openssl-dev ncurses-dev gdbm-dev zlib-dev readline-dev yaml-dev

WORKDIR /app

COPY . .

RUN bundle install

CMD ["/bin","/bash"]