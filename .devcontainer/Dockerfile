# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.192.0/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version: bionic, focal
ARG VARIANT="focal"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
     && apt-get -y install --no-install-recommends openjdk-8-jdk-headless


#
# Android SDK
ENV ANDROID_SDK_ROOT="/android-sdk"
ENV PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/cmdline-tools/tools/bin:$ANDROID_SDK_ROOT/build-tools:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator"

RUN wget --continue https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip \
    && mkdir android-sdk && unzip /commandlinetools-linux-7302050_latest.zip -d android-sdk \
    && rm /commandlinetools-linux-7302050_latest.zip \
    && mv /android-sdk/cmdline-tools /android-sdk/tools  \
    && mkdir /android-sdk/cmdline-tools && mv /android-sdk/tools /android-sdk/cmdline-tools/ \
    && yes | sdkmanager --licenses \
    && touch ~/.android/repositories.cfg \
    && sdkmanager "platforms;android-29" "platform-tools" "build-tools;29.0.2"

#
# Flutter SDK
ENV FLUTTER_HOME=/workspaces/flutter
ENV PATH=${PATH}:${FLUTTER_HOME}/bin

RUN mkdir /workspaces \
    && cd /workspaces \
	&& git clone https://github.com/flutter/flutter.git -b beta \
    && flutter precache \
	&& flutter config --no-analytics \