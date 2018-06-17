FROM ruby:2.4.1

RUN apt-get update && apt-get install -y cron build-essential mysql-client libmysqlclient-dev apt-transport-https --no-install-recommends && \
  rm -rf /var/lib/apt/lists/*

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -y yarn && rm -rf /var/lib/apt/sources.list.d/yarn.list

ENV APP_DIR /app
ENV RAILS_ENV=production
ENV DEVISE_SECRET=19f234fe50fa877a72d670c3122b29ff77aa1bbd027c220e3a6aaf7ff8c24618de182ff8fa52dbba685c48bf1ced7c0ab7a549765bedab441a5d31ff22a18f8b
ENV SECRET_KEY_BASE=19f234fe50fa877a72d670c3122b29ff77aa1bbd027c220e3a6aaf7ff8c24618de182ff8fa52dbba685c48bf1ced7c0ab7a549765bedab441a5d31ff22a18f8b

RUN mkdir -p $APP_DIR
RUN mkdir -p /backup
WORKDIR $APP_DIR

COPY Gemfile* $APP_DIR/
RUN gem install bundler --no-ri --no-rdoc && \
  bundle install --without development test

COPY . $APP_DIR
RUN bundle exec rake assets:precompile
RUN whenever --update-crontab

COPY entrypoint.sh /usr/local/bin
RUN ln -s /usr/local/bin/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
