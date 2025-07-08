#!/bin/bash

echo "직장생활은 처음이라 앱 실행 스크립트"
echo "=================================="

# Flutter 의존성 설치
echo "1. Flutter 의존성 설치 중..."
flutter pub get

# Hive 어댑터 생성
echo "2. Hive 어댑터 생성 중..."
flutter packages pub run build_runner build

# 앱 실행
echo "3. 앱 실행 중..."
flutter run

echo "앱 실행 완료!"