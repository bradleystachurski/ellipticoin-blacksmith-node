FROM ubuntu
MAINTAINER Mason Fischer
RUN apt-get update
RUN apt-get install -y curl wget
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && dpkg -i erlang-solutions_1.0_all.deb
RUN apt-get update
RUN apt-get install -y esl-erlang elixir clang libclang-dev llvm librocksdb-dev
RUN mix local.hex --force && mix local.rebar --force
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN . $HOME/.cargo/env  && rustup default nightly
