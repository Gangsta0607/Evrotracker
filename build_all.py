#!/usr/bin/env python3

import argparse
import concurrent.futures
import os
import platform
import subprocess
import sys
import shutil
import multiprocessing
from datetime import datetime

def clean_project():
    """Очищает проект Flutter"""
    print("Очистка проекта...")
    commands = [
        "flutter clean",  # Основная очистка Flutter
        "rm -rf build",   # Удаление папки build
        "rm -rf .dart_tool",  # Удаление .dart_tool
        "rm -rf .flutter-plugins",  # Удаление информации о плагинах
        "rm -rf .flutter-plugins-dependencies",  # Удаление зависимостей плагинов
        "rm -rf ios/Pods",  # Удаление iOS pods
        "rm -rf ios/Podfile.lock",  # Удаление lock-файла iOS
        "rm -rf android/.gradle",  # Удаление gradle кэша
        "rm -rf pubspec.lock"  # Удаление lock-файла пакетов
    ]
    
    for cmd in commands:
        try:
            subprocess.run(cmd, shell=True, check=True)
            print(f"✓ {cmd}")
        except subprocess.CalledProcessError:
            print(f"⚠️ Ошибка при выполнении: {cmd}")
            continue

def optimize_ios_build():
    """Оптимизирует настройки для сборки iOS"""
    print("Оптимизация настроек iOS сборки...")
    
    # Оптимизация Podfile
    podfile_path = "ios/Podfile"
    if os.path.exists(podfile_path):
        with open(podfile_path, 'r') as f:
            content = f.read()
        
        # Проверяем, есть ли уже оптимизации
        optimizations_needed = True
        if "ENV['COCOAPODS_DISABLE_STATS'] = 'true'" in content and "install! 'cocoapods'" in content:
            optimizations_needed = False
            
        if optimizations_needed:
            # Добавляем оптимизации в Podfile
            with open(podfile_path, 'w') as f:
                # Добавляем отключение статистики CocoaPods, если еще не добавлено
                if "ENV['COCOAPODS_DISABLE_STATS'] = 'true'" not in content:
                    content = "# CocoaPods analytics sends network stats synchronously affecting flutter build latency.\nENV['COCOAPODS_DISABLE_STATS'] = 'true'\n\n" + content
                
                # Добавляем ускорение установки CocoaPods
                if "install! 'cocoapods'" not in content:
                    content = content.replace("flutter_ios_podfile_setup", "install! 'cocoapods', :deterministic_uuids => false\nflutter_ios_podfile_setup")
                
                f.write(content)
            print("✓ Podfile оптимизирован")
    
    # Создаем или обновляем .xcode.env файл для ускорения сборки
    xcode_env_path = "ios/.xcode.env"
    if not os.path.exists(xcode_env_path):
        with open(xcode_env_path, 'w') as f:
            f.write("FLUTTER_BUILD_MODE=release\n")
            f.write(f"FLUTTER_BUILD_NUMBER={multiprocessing.cpu_count()}\n")
            f.write("FLUTTER_XCODE_STRIP_SYMBOLS=true\n")
            f.write("BITCODE_GENERATION_MODE=none\n")
            f.write("SWIFT_OPTIMIZATION_LEVEL=-Osize\n")
        print("✓ Создан .xcode.env файл для оптимизации сборки")
    
    # Очистка кэша CocoaPods
    try:
        subprocess.run("cd ios && pod cache clean --all", shell=True, check=True)
        print("✓ Кэш CocoaPods очищен")
    except subprocess.CalledProcessError:
        print("⚠️ Ошибка при очистке кэша CocoaPods")
    
    # Предварительная компиляция Flutter модулей для ускорения сборки
    try:
        subprocess.run("flutter precache --ios", shell=True, check=True)
        print("✓ Flutter модули предварительно скомпилированы")
    except subprocess.CalledProcessError:
        print("⚠️ Ошибка при предварительной компиляции Flutter модулей")

def optimize_android_build():
    """Оптимизирует настройки для сборки Android"""
    print("Оптимизация настроек Android сборки...")
    
    # Создаем или обновляем gradle.properties для ускорения сборки
    gradle_props_path = "android/gradle.properties"
    
    # Оптимизации для gradle
    optimizations = {
        "org.gradle.jvmargs": f"-Xmx4g -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8",
        "org.gradle.parallel": "true",
        "org.gradle.daemon": "true",
        "org.gradle.configureondemand": "true",
        "org.gradle.caching": "true",
        "android.enableR8": "true",
        "android.enableJetifier": "true",
        "android.useAndroidX": "true",
        "kotlin.code.style": "official"
    }
    
    if os.path.exists(gradle_props_path):
        with open(gradle_props_path, 'r') as f:
            content = f.read()
        
        # Добавляем оптимизации, если их еще нет
        for key, value in optimizations.items():
            if key not in content:
                content += f"\n{key}={value}"
        
        with open(gradle_props_path, 'w') as f:
            f.write(content)
        
        print("✓ gradle.properties оптимизирован")
    
    # Предварительная компиляция Flutter модулей для Android
    try:
        subprocess.run("flutter precache --android", shell=True, check=True)
        print("✓ Flutter модули предварительно скомпилированы для Android")
    except subprocess.CalledProcessError:
        print("⚠️ Ошибка при предварительной компиляции Flutter модулей для Android")

def optimize_macos_build():
    """Оптимизирует настройки для сборки macOS"""
    print("Оптимизация настроек macOS сборки...")
    
    # Предварительная компиляция Flutter модулей для macOS
    try:
        subprocess.run("flutter precache --macos", shell=True, check=True)
        print("✓ Flutter модули предварительно скомпилированы для macOS")
    except subprocess.CalledProcessError:
        print("⚠️ Ошибка при предварительной компиляции Flutter модулей для macOS")

def optimize_web_build():
    """Оптимизирует настройки для сборки Web"""
    print("Оптимизация настроек Web сборки...")
    
    # Предварительная компиляция Flutter модулей для Web
    try:
        subprocess.run("flutter precache --web", shell=True, check=True)
        print("✓ Flutter модули предварительно скомпилированы для Web")
    except subprocess.CalledProcessError:
        print("⚠️ Ошибка при предварительной компиляции Flutter модулей для Web")

def ensure_release_dir():
    """Создает папку Release, если она не существует"""
    # Получаем абсолютный путь к текущему каталогу
    current_dir = os.path.dirname(os.path.abspath(__file__))
    # Создаем путь на уровень выше текущего каталога
    release_dir = os.path.join(os.path.dirname(current_dir), "Release")
    if not os.path.exists(release_dir):
        os.makedirs(release_dir)
    return release_dir

def copy_build(src, dst, platform_name):
    """Копирует собранные файлы в папку Release"""
    if not os.path.exists(src):
        print(f"[{platform_name}] Предупреждение: файл сборки не найден: {src}")
        return
    
    # Создаем подпапку для платформы
    platform_dir = os.path.dirname(dst)
    if not os.path.exists(platform_dir):
        os.makedirs(platform_dir)
    
    try:
        if os.path.isdir(src):
            if os.path.exists(dst):
                shutil.rmtree(dst)
            shutil.copytree(src, dst)
        else:
            shutil.copy2(src, dst)
        print(f"[{platform_name}] Файлы скопированы в: {dst}")
    except Exception as e:
        print(f"[{platform_name}] Ошибка при копировании: {e}")

def run_command(command, platform_name, env=None):
    """Выполняет команду сборки и возвращает результат"""
    start_time = datetime.now()
    print(f"[{platform_name}] Начало сборки: {start_time.strftime('%H:%M:%S')}")
    
    try:
        result = subprocess.run(
            command,
            shell=True,
            check=True,
            capture_output=True,
            text=True,
            env=env
        )
        end_time = datetime.now()
        duration = end_time - start_time
        print(f"[{platform_name}] Сборка успешно завершена за {duration.total_seconds():.1f} секунд")
        return True
    except subprocess.CalledProcessError as e:
        print(f"[{platform_name}] Ошибка сборки:")
        print(e.stderr)
        return False

def build_ios():
    """Собирает iOS приложение и создает IPA файл с оптимизациями"""
    # Обновляем зависимости с оптимизациями
    print("[iOS] Подготовка к сборке...")
    
    # Устанавливаем переменные окружения для ускорения сборки
    env = os.environ.copy()
    env["FLUTTER_XCODE_ONLY_ACTIVE_ARCH"] = "YES"  # Собирать только для текущей архитектуры
    env["DISABLE_MANUAL_TARGET_ORDER_BUILD_WARNING"] = "1"  # Отключить предупреждения
    env["COMPILER_INDEX_STORE_ENABLE"] = "NO"  # Отключить индексирование
    
    # Устанавливаем Pods с оптимизациями
    pod_install_cmd = "cd ios && pod install --repo-update"
    run_command(pod_install_cmd, "iOS-Pods")
    
    # Собираем с оптимизациями через Flutter (без прямого вызова xcodebuild)
    success = run_command("flutter build ios --release --no-codesign", "iOS", env)
    
    if success and os.path.exists("create_ipa.py"):
        success = run_command("python3 create_ipa.py", "iOS-IPA")
        if success:
            release_dir = ensure_release_dir()
            ios_dir = os.path.join(release_dir, "iOS")
            copy_build("Evrotracker.ipa", os.path.join(ios_dir, "Evrotracker.ipa"), "iOS")
    return success

def build_android():
    """Собирает Android приложение (APK и AAB) с оптимизациями"""
    # Устанавливаем переменные окружения для ускорения сборки
    env = os.environ.copy()
    env["GRADLE_OPTS"] = "-Dorg.gradle.daemon=true -Dorg.gradle.parallel=true -Dorg.gradle.configureondemand=true -Dorg.gradle.jvmargs=-Xmx4g"
    
    # Собираем APK с оптимизациями
    success = run_command("flutter build apk --target-platform android-arm,android-arm64 --split-per-abi", "Android-APK", env)
    if success:
        release_dir = ensure_release_dir()
        android_dir = os.path.join(release_dir, "Android")
        
        # Копируем все созданные APK файлы
        apk_files = [
            ("build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk", os.path.join(android_dir, "Evrotracker-arm.apk")),
            ("build/app/outputs/flutter-apk/app-arm64-v8a-release.apk", os.path.join(android_dir, "Evrotracker-arm64.apk")),
        ]
        
        for src, dst in apk_files:
            if os.path.exists(src):
                copy_build(src, dst, "Android-APK")
        
        # Собираем AAB для Google Play
        success = run_command("flutter build appbundle --target-platform android-arm,android-arm64", "Android-AAB", env)
        if success:
            copy_build(
                "build/app/outputs/bundle/release/app-release.aab",
                os.path.join(android_dir, "Evrotracker.aab"),
                "Android-AAB"
            )
    return success

def build_macos():
    """Собирает macOS приложение с оптимизациями"""
    # Устанавливаем переменные окружения для ускорения сборки
    env = os.environ.copy()
    env["MACOSX_DEPLOYMENT_TARGET"] = "10.14"  # Минимальная поддерживаемая версия
    env["COMPILER_INDEX_STORE_ENABLE"] = "NO"  # Отключить индексирование
    
    # Собираем с оптимизациями
    success = run_command("flutter build macos --release", "macOS", env)
    if success:
        release_dir = ensure_release_dir()
        macos_dir = os.path.join(release_dir, "macOS")
        
        # Исправляем путь к macOS приложению
        app_path = "build/macos/Build/Products/Release"
        # Ищем .app файл в директории
        if os.path.exists(app_path):
            app_files = [f for f in os.listdir(app_path) if f.endswith('.app')]
            if app_files:
                app_file = app_files[0]
                copy_build(
                    os.path.join(app_path, app_file),
                    os.path.join(macos_dir, "Evrotracker.app"),
                    "macOS"
                )
            else:
                print("[macOS] Не найдено .app файла в директории сборки")
        else:
            print("[macOS] Директория сборки не найдена")
    return success

def build_web():
    """Собирает Web версию с оптимизациями"""
    # Собираем с оптимизациями для производительности
    success = run_command("flutter build web --release --dart2js-optimization=O4", "Web")
    if success:
        release_dir = ensure_release_dir()
        web_dir = os.path.join(release_dir, "Web")
        copy_build(
            "build/web",
            web_dir,
            "Web"
        )
    return success

def clean_build_files():
    """Очищает временные файлы сборки, но сохраняет основные файлы проекта"""
    print("Очистка временных файлов сборки...")
    commands = [
        "rm -rf build/ios",
        "rm -rf build/android",
        "rm -rf build/macos",
        "rm -rf build/web",
        "rm -rf .dart_tool/flutter_build",
        "rm -rf ios/build",
        "rm -rf android/build",
        "rm -rf android/app/build",
        "rm -rf macos/build",
    ]
    
    for cmd in commands:
        try:
            subprocess.run(cmd, shell=True, check=True)
            print(f"✓ {cmd}")
        except subprocess.CalledProcessError:
            print(f"⚠️ Ошибка при выполнении: {cmd}")
            continue

def main():
    parser = argparse.ArgumentParser(description="Сборка приложения под все платформы")
    parser.add_argument("--parallel", "-p", action="store_true", 
                       help="Выполнять сборку параллельно")
    parser.add_argument("--platforms", nargs="+", 
                       choices=["ios", "android", "macos", "web"],
                       help="Список платформ для сборки (по умолчанию все доступные)")
    parser.add_argument("--clean", "-c", action="store_true",
                       help="Очистить проект перед сборкой")
    parser.add_argument("--optimize", "-o", action="store_true",
                       help="Оптимизировать настройки сборки")
    parser.add_argument("--clean-temp", "-t", action="store_true",
                       help="Очистить временные файлы сборки после завершения")
    args = parser.parse_args()

    if args.clean:
        clean_project()
        print("\nПроект очищен. Для завершения очистки выполните:\nflutter pub get\n")
        if not args.platforms and not args.optimize:  # Если указана только очистка без платформ
            return
    
    # Оптимизируем настройки сборки, если указан флаг
    if args.optimize:
        optimize_ios_build()
        optimize_android_build()
        optimize_macos_build()
        optimize_web_build()
    else:
        # Оптимизируем только для выбранных платформ
        if args.platforms:
            if "ios" in args.platforms:
                optimize_ios_build()
            if "android" in args.platforms:
                optimize_android_build()
            if "macos" in args.platforms:
                optimize_macos_build()
            if "web" in args.platforms:
                optimize_web_build()

    # Определяем доступные платформы в зависимости от ОС
    system = platform.system()
    available_platforms = {
        "ios": system == "Darwin",
        "android": True,
        "macos": system == "Darwin",
        "web": True
    }

    # Фильтруем платформы по аргументам командной строки
    if args.platforms:
        platforms_to_build = {p: available_platforms[p] for p in args.platforms}
    else:
        platforms_to_build = available_platforms

    build_functions = {
        "ios": build_ios,
        "android": build_android,
        "macos": build_macos,
        "web": build_web
    }

    # Отфильтровываем недоступные платформы
    platforms = [(name, func) for name, func in build_functions.items() 
                if platforms_to_build.get(name) and available_platforms[name]]

    if not platforms:
        print("Нет доступных платформ для сборки")
        return

    print(f"Начинаем сборку для платформ: {', '.join(name for name, _ in platforms)}")
    print(f"Режим сборки: {'параллельный' if args.parallel else 'последовательный'}")

    # Создаем папку Release
    ensure_release_dir()

    # Обновляем зависимости перед сборкой
    run_command("flutter pub get", "Flutter")

    success = True
    if args.parallel:
        # Определяем оптимальное количество потоков
        max_workers = min(len(platforms), multiprocessing.cpu_count())
        with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
            futures = {executor.submit(func): name for name, func in platforms}
            for future in concurrent.futures.as_completed(futures):
                platform_name = futures[future]
                try:
                    if not future.result():
                        success = False
                        print(f"Сборка для {platform_name} завершилась с ошибкой")
                except Exception as e:
                    success = False
                    print(f"Исключение при сборке {platform_name}: {e}")
    else:
        for name, func in platforms:
            if not func():
                success = False
                print(f"Сборка для {name} завершилась с ошибкой")

    if success:
        print("\nСборка успешно завершена для всех платформ!")
        release_dir = ensure_release_dir()
        print(f"Готовые сборки находятся в папке {os.path.abspath(release_dir)}")
        
        # Очистка временных файлов после сборки, если указан флаг
        if args.clean_temp:
            clean_build_files()
    else:
        print("\nСборка завершена с ошибками")
        sys.exit(1)

if __name__ == "__main__":
    main()