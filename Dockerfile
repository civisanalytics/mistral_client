ARG RUBY_VERSION
FROM ruby:${RUBY_VERSION}
ARG RAILS_VERSION

# Set the working directory in the container to /app
WORKDIR /src

# Add metadata to the image to describe which port the container is listening on at runtime

COPY . .

RUN bundle install
