FROM openjdk:11-jdk-slim

RUN apt-get update && apt-get install -y \
    wget unzip python3 python3-pip apt-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Android SDK
RUN mkdir -p /opt/android-sdk/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip -d /opt/android-sdk/cmdline-tools && \
    rm cmdline-tools.zip && \
    mv /opt/android-sdk/cmdline-tools/cmdline-tools /opt/android-sdk/cmdline-tools/latest

ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools

RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-25" "build-tools;25.0.2"

WORKDIR /app
COPY MyCamera/ .

RUN chmod +x ./gradlew
RUN ./gradlew assembleDebug --no-daemon

RUN mkdir -p /serve && \
    cp app/build/outputs/apk/debug/app-debug.apk /serve/

WORKDIR /serve
EXPOSE 5000
CMD ["python3", "-m", "http.server", "5000"]
