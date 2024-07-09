# Use ARM64 version of Ubuntu as the base image
FROM arm64v8/buildpack-deps:jammy AS builder

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    make \
    tcl \
    tcl-dev \
    tk \
    tk-dev \
    libgl1-mesa-dev \
    libgl2ps-dev \
    libvtk9-dev \
    libxi-dev \
    libxmu-dev \
    && rm -rf /var/lib/apt/lists/*

# Set up work directory
WORKDIR /occt

# Copy OCCT source code
COPY . .

# Build OCCT
RUN mkdir build && cd build \
    && cmake -DCMAKE_BUILD_TYPE=release .. \
    && make -j$(nproc) \
    && make install

# Create final image
FROM arm64v8/buildpack-deps:jammy

# Copy installed OCCT from builder stage
COPY --from=builder /usr/local/ /usr/local/

# Set library path
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Verify the architecture and library
RUN echo "OCCT architecture:" && uname -m && \
    echo "OCCT libTKBO.so info:" && file /usr/local/lib/libTKBO.so