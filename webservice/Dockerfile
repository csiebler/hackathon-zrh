FROM ruby:alpine
MAINTAINER Clemens Siebler <clemens.siebler@gmail.com>

RUN gem install sinatra
RUN gem install shotgun
RUN gem install aws-sdk

RUN mkdir /sinatra
COPY webservice.rb /sinatra

EXPOSE 8080
ENTRYPOINT shotgun --host 0.0.0.0 --port 8080 /sinatra/webservice.rb