#!/bin/bash

# --- Модернизированный скрипт для загрузки изображения из буфера обмена ---
# Требование: утилита pngpaste (установка: brew install pngpaste)

# 1. Получаем длинную ссылку (как раньше)
if [[ -n "$1" && -f "$1" ]]; then
    # Если передан путь к файлу — используем его
    TMP_FILE="$1"
else
    # Иначе — извлекаем из буфера обмена
    TMP_FILE="/tmp/clipboard-img-$(date +%s).png"
    trap 'rm -f "$TMP_FILE"' EXIT

    if ! pngpaste "$TMP_FILE"; then
        echo "Ошибка: Изображение в буфере обмена не найдено." >&2
        echo "Убедитесь, что вы скопировали скриншот, а не текст." >&2
        echo "Также проверьте, установлена ли утилита 'pngpaste' (brew install pngpaste)." >&2
        exit 1
    fi
fi

# 3. Загружаем временный файл на Zipline.
UPLOAD_RESULT=$(curl -s \
     -H "authorization: MTc1MDYwMzc4NjY0MA==.NzgzZjUxZGYzOTk1MmI3YWU3ZmY2OTc3MDY3ZTgxNmUuNjg2NzE4MzA3ZWFmZWU5NWVhM2ZiNDI3ZDc1NTY2YzJiMWQyNGY4ZjQzZDQxODRkN2JjMWUzYzJmNzQ1OTRiNDMxYTY0MGM5MzAyNDJjNjc1MTNhMjMxYTBhOWI4YzYwYmU5OGI3MjYwN2NhYzFlMzk1YWNkMjdiNjIzNDQ1NDkxN2Q4NGFhOGU5ODMwNjAwYzkyZDA1NTAyZmQ2NGMxZA==" \
     -H "x-zipline-format: uuid" \
     -H "x-zipline-domain: files.arturavers.com" \
     -F "file=@$TMP_FILE;type=image/png" \
     https://files.arturavers.com/api/upload)

# 4. Обрабатываем результат.
#    Сначала получаем URL из ответа сервера с помощью jq.
LONG_URL=$(echo "$UPLOAD_RESULT" | jq -r .files[0].url)

#    Проверяем, получили ли мы валидный URL.
if [[ "$LONG_URL" == "http"* ]]; then
    # 2. Получаем короткую ссылку
    SHORT_URL=$(curl -s \
        -H "authorization: MTc1MDYwMzc4NjY0MA==.NzgzZjUxZGYzOTk1MmI3YWU3ZmY2OTc3MDY3ZTgxNmUuNjg2NzE4MzA3ZWFmZWU5NWVhM2ZiNDI3ZDc1NTY2YzJiMWQyNGY4ZjQzZDQxODRkN2JjMWUzYzJmNzQ1OTRiNDMxYTY0MGM5MzAyNDJjNjc1MTNhMjMxYTBhOWI4YzYwYmU5OGI3MjYwN2NhYzFlMzk1YWNkMjdiNjIzNDQ1NDkxN2Q4NGFhOGU5ODMwNjAwYzkyZDA1NTAyZmQ2NGMxZA==" \
        https://files.arturavers.com/api/user/urls \
        -H 'content-type: application/json' \
        -H "x-zipline-domain: files.arturavers.com" \
        -d "{\"destination\": \"$LONG_URL\"}" | jq -r .url)
    echo "$SHORT_URL"
else
    echo "Ошибка при загрузке. Ответ сервера:" >&2
    echo "$UPLOAD_RESULT" >&2
    exit 1
fi
