FROM ruby:2.4.1

RUN mkdir -p /app
WORKDIR /app

RUN apt-get update && apt-get install -y mysql-client libmysqlclient-dev apt-transport-https --no-install-recommends && rm -rf /var/lib/apt/lists/* && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

ENV DB_USERNAME=root
ENV DB_PASSWORD=root
ENV SECRET_KEY_BASE=44dabb1d3fd9f65fa5e6040827a34eda5495b36b3d9a43c3d7e7eff73b2b55e832552f8da7c814e6ea6969128c67bb77020276dc06761ec42d04213c8f0bde5c
ENV DEVISE_SECRET=44dabb1d3fd9f65fa5e6040827a34eda5495b36b3d9a43c3d7e7eff73b2b55e832552f8da7c814e6ea6969128c67bb77020276dc06761ec42d04213c8f0bde5c

COPY ./Gemfile /app
COPY ./Gemfile.lock /app
RUN bundle install --without development test

COPY . /app
RUN bundle exec rake assets:precompile

COPY app-entrypoint.sh /usr/local/bin
RUN ln -s /usr/local/bin/app-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["app-entrypoint.sh"]

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
