import os
import shutil
import zipfile

def create_ipa():
    # Пути
    project_root = os.path.dirname(os.path.abspath(__file__))
    app_path = os.path.join(project_root, 'build', 'ios', 'iphoneos', 'Runner.app')
    payload_path = os.path.join(project_root, 'Payload')
    zip_path = os.path.join(project_root, 'Payload.zip')
    ipa_path = os.path.join(project_root, 'Evrotracker.ipa')
    
    try:
        # Проверяем существование .app файла
        if not os.path.exists(app_path):
            print(f"Ошибка: {app_path} не найден")
            print("Сначала выполните: flutter build ios")
            return
        
        # Создаем папку Payload
        if os.path.exists(payload_path):
            shutil.rmtree(payload_path)
        os.makedirs(payload_path)
        
        # Копируем .app в Payload
        payload_app_path = os.path.join(payload_path, 'Runner.app')
        shutil.copytree(app_path, payload_app_path)
        
        # Создаем zip-архив
        if os.path.exists(zip_path):
            os.remove(zip_path)
        
        def zipdir(path, ziph):
            for root, _, files in os.walk(path):
                for file in files:
                    file_path = os.path.join(root, file)
                    arcname = os.path.relpath(file_path, os.path.dirname(path))
                    ziph.write(file_path, arcname)
        
        with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            zipdir(payload_path, zipf)
        
        # Переименовываем в .ipa
        if os.path.exists(ipa_path):
            os.remove(ipa_path)
        os.rename(zip_path, ipa_path)
        
        # Очищаем временные файлы
        if os.path.exists(payload_path):
            shutil.rmtree(payload_path)
        
        print(f"IPA файл успешно создан: {ipa_path}")
        
    except Exception as e:
        print(f"Ошибка при создании IPA: {e}")
        # Очищаем временные файлы в случае ошибки
        if os.path.exists(payload_path):
            shutil.rmtree(payload_path)
        if os.path.exists(zip_path):
            os.remove(zip_path)

if __name__ == "__main__":
    create_ipa() 