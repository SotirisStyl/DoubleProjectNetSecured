#!/bin/bash

# Step 1: Install Flutter SDK (only if not already installed)
if [ ! -d "/opt/flutter" ]; then
  echo "Installing Flutter SDK..."
  git clone https://github.com/flutter/flutter.git /opt/flutter
  export PATH="$PATH:/opt/flutter/bin"
else
  echo "Flutter SDK already installed"
fi

# Step 2: Run Flutter Doctor to ensure dependencies are met (optional)
flutter doctor

# Step 3: Clean, get dependencies and build Flutter web app
flutter clean
flutter pub get
flutter build web
