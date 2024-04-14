FROM ruby:2.3.1

WORKDIR /app

# install node
RUN set -uex \
    && apt-get update \
    && apt-get install -y ca-certificates curl gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && NODE_MAJOR=18 \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install nodejs -y

ADD Gemfile .
ADD Gemfile.lock .
RUN bundle install

ENV MIDDLEMAN_HOST="0.0.0.0"
CMD bundle exec middleman -p 5000 --bind-address "0.0.0.0" --verbose
