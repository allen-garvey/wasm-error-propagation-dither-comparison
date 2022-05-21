FROM alpine:3.15
RUN apk update && apk add --no-cache \
    make \
    nodejs \ 
    npm \
    curl \
    tar \
    xz \
    python3 \
    bash

# create download directory
RUN mkdir -p $HOME/downloads

# install D (ldc2)
RUN curl -s -L https://github.com/ldc-developers/ldc/releases/download/v1.29.0/ldc2-1.29.0-linux-x86_64.tar.xz > $HOME/downloads/ldc2
RUN tar -xf $HOME/downloads/ldc2 -C $HOME && rm $HOME/downloads/ldc2
ENV PATH="$HOME/ldc2-1.29.0-linux-x86_64/bin:${PATH}"

# install C++ (emscripten)
RUN curl -s -L https://github.com/emscripten-core/emsdk/archive/refs/tags/3.1.10.tar.gz > $HOME/downloads/emcc
RUN tar -xf $HOME/downloads/emcc -C $HOME && rm $HOME/downloads/emcc
RUN ls $HOME
RUN $HOME/emsdk-3.1.10/emsdk install latest
ENV PATH="$HOME/emcc/emsdk/upstream/emscripten:$PATH"

# install Rust & wasm-pack
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh

# install zig
RUN curl -s -L https://ziglang.org/download/0.9.1/zig-linux-x86_64-0.9.1.tar.xz > $HOME/downloads/zig
RUN tar -xf $HOME/downloads/zig -C $HOME
ENV PATH="$HOME/zig-linux-x86_64-0.9.1:${PATH}"

# compile wasm
ADD wasm .
ADD makefile .
RUN make

# install npm dependencies
ADD package.json .
ADD package-lock.json .
RUN npm install

# add js / sass files
ADD sass .
ADD src .
ADD webpack.config.js .

# expose server port
EXPOSE 3000

CMD ["npm", "start"]