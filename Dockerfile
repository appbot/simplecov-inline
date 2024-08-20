# syntax=docker/dockerfile:1
FROM ruby:3.2.3-alpine as base

RUN apk --update add build-base git curl

WORKDIR /app

COPY . /app
RUN bundle install
