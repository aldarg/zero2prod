FROM lukemathwalker/cargo-chef:latest-rust-1.76.0 as chef
WORKDIR /app
RUN apt update && apt install lld clang -y

FROM chef as planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef as builder
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
ENV SQLX_OFFLINE true
RUN cargo build --release --bin zero2prod

FROM builder as dev
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.7.3/wait /wait
RUN chmod +x /wait
RUN cargo install sqlx-cli --no-default-features --features native-tls,postgres
WORKDIR /app

FROM debian:bullseye-slim AS runtime
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends openssl ca-certificates \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/target/release/zero2prod zero2prod
COPY configuration configuration

ENV APP_ENVIRONMENT production
ENTRYPOINT ["./zero2prod"]