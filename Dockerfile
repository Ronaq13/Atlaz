# syntax=docker/dockerfile:1
# =============================================================================
# Stage 1: Build gems and assets
# =============================================================================
FROM ruby:4.0.3-slim AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      libvips \
      libyaml-dev \
      pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /rails

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without "development test" && \
    bundle install && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap cache
RUN bundle exec bootsnap precompile app/ lib/

# =============================================================================
# Stage 2: Final runtime image
# =============================================================================
FROM ruby:4.0.3-slim AS runtime

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libpq5 \
      libvips \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd --system --gid 1000 rails && \
    useradd  --system --uid 1000 --gid rails --create-home rails

WORKDIR /rails

# Copy built artifacts from build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=rails:rails /rails /rails

USER rails

EXPOSE 3013

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD curl -f http://localhost:3013/up || exit 1

# Default: start Rails server (overridden for Sidekiq)
CMD ["bundle", "exec", "thrust", "bin/rails", "server", "-b", "0.0.0.0", "-p", "3013"]
