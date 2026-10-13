#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
flutter create . --project-name nexasoft_incidencias --platforms android,web,windows
flutter pub get
echo 'Preparación terminada. Ejecuta flutter devices y flutter run -d chrome'
