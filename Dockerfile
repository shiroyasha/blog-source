FROM ruby:2.3.1

# Install node
RUN wget -O - https://nodejs.org/dist/v6.10.0/node-v6.10.0-linux-x64.tar.xz | tar Jx --strip=1 -C /usr/local

WORKDIR /app

ADD Gemfile .
ADD Gemfile.lock .
RUN bundle install

ENV MIDDLEMAN_HOST="0.0.0.0"
CMD bundle exec middleman -p 5000 --bind-address "0.0.0.0" --verbose
