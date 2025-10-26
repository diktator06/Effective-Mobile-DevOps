# Мониторинг процесса test

## Описание
Система мониторинга процесса `test` с отправкой heartbeat на сервер мониторинга.

## Установка и настройка

### 1. Скопируйте скрипт в системную директорию
```bash
sudo cp monitor_test.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/monitor_test.sh
```

### 2. Создайте log файл с нужными правами
```bash
sudo touch /var/log/monitoring.log
sudo chmod 644 /var/log/monitoring.log
```

### 3. Установите systemd service и timer
```bash
sudo cp monitor-test.service /etc/systemd/system/
sudo cp monitor-test.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable monitor-test.timer
sudo systemctl start monitor-test.timer
```

### 4. Проверьте статус сервиса и таймера
```bash
sudo systemctl status monitor-test.timer
sudo systemctl status monitor-test.service
```

### 5. Просмотр логов
```bash
# Просмотр лог файла
sudo tail -f /var/log/monitoring.log

# Просмотр системных логов
sudo journalctl -u monitor-test.service -f
```

## Функциональность

- ✅ Проверка наличия процесса `test` каждую минуту
- ✅ Отправка HTTPS запросов на сервер мониторинга при запущенном процессе
- ✅ Логирование перезапуска процесса в `/var/log/monitoring.log`
- ✅ Логирование недоступности сервера мониторинга
- ✅ Автозапуск при загрузке системы через systemd

## Структура логов

Формат записи в лог:
```
[YYYY-MM-DD HH:MM:SS] [LEVEL] message
```

Где:
- `LEVEL` может быть `INFO` или `ERROR`
- `INFO` - используется для логирования перезапуска процесса
- `ERROR` - используется для логирования ошибок связи с сервером мониторинга

## Настройка времени опроса

По умолчанию таймер запускает проверку каждую минуту. 
Для изменения интервала отредактируйте файл таймера:
```bash
sudo nano /etc/systemd/system/monitor-test.timer
```

Измените значение `OnUnitActiveSec=1min` на нужное (например, `30s`, `5min`).
После изменения перезагрузите systemd:
```bash
sudo systemctl daemon-reload
sudo systemctl restart monitor-test.timer
```

## Управление сервисом

```bash
# Старт таймера
sudo systemctl start monitor-test.timer

# Остановка таймера
sudo systemctl stop monitor-test.timer

# Перезапуск таймера
sudo systemctl restart monitor-test.timer

# Включение автозапуска таймера
sudo systemctl enable monitor-test.timer

# Отключение автозапуска таймера
sudo systemctl disable monitor-test.timer

# Проверка списка таймеров
sudo systemctl list-timers monitor-test.timer
```

