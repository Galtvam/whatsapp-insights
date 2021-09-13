FROM runmymind/docker-android-sdk:ubuntu-standalone

RUN mkdir -p /whatsapp-insights/workspace

WORKDIR /whatsapp-insights/workspace

RUN apt-get update && apt-get install -y python3.8 python3-pip gnupg python3-tk && \
    python3.8 -m pip install -U pip && \
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list && \
    apt-get update && apt-get install -y google-chrome-stable && \
    wget -O /whatsapp-insights/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/93.0.4577.63/chromedriver_linux64.zip && \
    unzip /whatsapp-insights/chromedriver_linux64.zip -d /whatsapp-insights

# Installing Android image for Android Emulator creating
RUN /opt/android-sdk-linux/cmdline-tools/latest/bin/sdkmanager --install "system-images;android-29;google_apis;x86_64"

# Create the Android Emulator
RUN /opt/android-sdk-linux/cmdline-tools/latest/bin/avdmanager -v create avd --force \
    --name whatsapp-insights --package "system-images;android-29;google_apis;x86_64" \
    --device "Nexus 5"

ENV PATH=/opt/android-sdk-linux/platform-tools/:$PATH

ENV CHROMEDRIVER=/whatsapp-insights/chromedriver

ENV SDK_MANAGER=/opt/android-sdk-linux/cmdline-tools/latest/bin/sdkmanager

ENV AVD_MANAGER=/opt/android-sdk-linux/cmdline-tools/latest/bin/avdmanager

ENV QTWEBENGINE_DISABLE_SANDBOX=1

ADD adbkey /root/.android/adbkey

ADD adbkey.pub /root/.android/adbkey.pub

# Copying project requirements to install before moving all project, to
# reduce the number of steps to rebuild whenever changing project files.
COPY ./requirements.txt /whatsapp-insights/requirements.txt

RUN python3.8 -m pip install -r /whatsapp-insights/requirements.txt

COPY . /whatsapp-insights

ENTRYPOINT ["python3.8", "/whatsapp-insights/main.py"]
