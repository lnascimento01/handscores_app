# Dockerfile
FROM ghcr.io/cirruslabs/flutter:stable

ENV ANDROID_SDK_ROOT=/opt/android-sdk \
    ANDROID_HOME=/opt/android-sdk \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl unzip xz-utils zip ca-certificates openssh-client git \
    && rm -rf /var/lib/apt/lists/*

# Aceitar licenças e pré-cache (android + web)
RUN yes | sdkmanager --licenses
RUN flutter --version && flutter precache --android --web

WORKDIR /app
