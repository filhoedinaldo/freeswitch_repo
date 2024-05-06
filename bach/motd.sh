#!/bin/bash
#
# Copyright (C) 2022 DigiVox
# File:            dgvx-motd
# Description:     Digivox 10logo system file
#
# Initial version: Sthenley Macedo <sthenley.macedo@digivox.com.br>
# Revision:        Edinaldo Lima <edinaldo.lima@digivox.com.br>
# Initial date:    2022-08-19
# Revision date:   2024-04-27
# Version:         1.2
#
WHITE='\033[0;37m'
BLUE='\033[0;34m'
BLUEB='\033[1;34m'
ORANGE='\033[38;5;208m'
CYAN='\033[0;36m'
CYANB='\033[1;36m'
GREEN='\033[0;32m'  # Verde para ativo
RED='\033[0;31m'    # Vermelho para inativo
BOLD='\033[1;37m'
OFF='\033[0m'


UP_SECONDS="$(/usr/bin/cut -d. -f1 /proc/uptime)"
UP_SEC=$((${UP_SECONDS}%60))
UP_MIN=$((${UP_SECONDS}/60%60))
UP_HOR=$((${UP_SECONDS}/3600%24))
UP_DAY=$((${UP_SECONDS}/86400))
UPTIME=`printf "%d day(s), %02dh%02dm%02ds" "$UP_DAY" "$UP_HOR" "$UP_MIN" "$UP_SEC"`

# Lista de serviços e suas unidades systemd correspondentes
# Lista de serviços do systemd e Docker
SERVICES=(
    "PostgreSQL Main|postgresql@14-main.service"
    "PostgreSQL DB2|postgresql@14-db2.service"
    "Redis|redis-server.service"
    "SipServer|sipserver.service"
    "Docker|docker"
    "Memcached|memcached.service"
    "NGINX|nginx.service"
    "Zabbix Agent|zabbix-agent.service"
    "HAProxy|haproxy.service"
    "OpenSips|opensips.service"
    "Redis|redis|container"
    "Rabbitmq porta 5672|monit-rabbitmq_5672|container"
    "Unity Manager|unity|container"
    "Unity Integrations|unity-integration-server-new|container"
    "Unity Integration porta 9090|unity-integration-server-9090|container"
    "Unity Monit|monit|container"
    "Unity API|unity-api|container"
    "Unity Web API Messages|unity-web-api-messages-v2|container"
    "Unity IVR|unity-ivr|container"
    "Unity Call Center Active Monitor|callcenter-active-monitor|container"
    "Unity Monitoring|unity-monitoring|container"
    "Squad Login|squad-login|container"
    "Squad Softphone|new-squad-sp|container"
    "Squad Events|squad-events|container"
    "Squad Events Publisher|squad-events-publisher|container"
    "Squad APP|new-squad-app|container"
    "Squad Anonymous|squad-anonymous|container"
)



# Função para verificar o status do serviço
format_status() {
    local service="$1"

    # Verificar o estado de carregamento (LoadState) do serviço
    local IS_LOAD=$(systemctl show -p LoadState --value "$service" 2>/dev/null)

    if [ "$IS_LOAD" == "loaded" ]; then
        # Verificar o estado ativo (is-active) do serviço usando systemctl
        local IS_ACTIVE=$(systemctl is-active --quiet "$service" && echo "Ativo" || echo "Inativo")

        if [ "$IS_ACTIVE" == "Ativo" ]; then
            echo -e "OK"
        else
            echo -e "ERROR"
        fi
    else
        # Se o serviço não estiver carregado, retornar string vazia
        echo ""
    fi
}

# Função para verificar o status de um contêiner Docker
check_docker_container() {
    local container_name="$1"
    local container_status
    local container_inspect=$(docker inspect --format="'{{.State.Running}}'" "$container_name" 2>/dev/null )
#    local container_inspect=$(docker inspect "$container_name" &>/dev/null)

    # Verificar o status do contêiner usando `docker inspect`
    if [ "$container_inspect"  == "'true'" ]; then
        #container_status="OK"
        echo "OK"
    elif [ "$container_inspect"  == "'false'" ]; then

        #container_status="ERROR"
        echo "ERROR"

   else
        #container_status="ERROR"
        echo "NOT INSTALLED"
    fi
    #echo "$container_status"
}

# get the load averages
read one five fifteen rest < /proc/loadavg

echo -e "${ORANGE}


███████ ███    ███  █████  ██████  ████████ ███████ ██████   █████   ██████ ███████ 
██      ████  ████ ██   ██ ██   ██    ██    ██      ██   ██ ██   ██ ██      ██      
███████ ██ ████ ██ ███████ ██████     ██    ███████ ██████  ███████ ██      █████   
     ██ ██  ██  ██ ██   ██ ██   ██    ██         ██ ██      ██   ██ ██      ██      
███████ ██      ██ ██   ██ ██   ██    ██    ███████ ██      ██   ██  ██████ ███████ 
                                                                         by DIGIVOX
  ${WHITE}`date +"%A, %Y-%m-%d %H:%M:%S%:z"`
  `uname -srvm`
  ${CYAN}Uptime...................: ${CYANB}${UPTIME}
  ${CYAN}Memory...................: ${CYANB}`free -hm | awk 'FNR == 2 {print $3 " / " $2 " free"}'`
  ${CYAN}Load Averages............: ${CYANB}${one}, ${five}, ${fifteen} (1, 5, 15 min)
  ${CYAN}Running Processes........: ${CYANB}`ps ax | wc -l | tr -d " "`
  ${CYAN}IP Addresses.............: ${CYANB}`hostname -I`

  ${WHITE}Status dos Serviços:"


## Iterar sobre a lista de serviços e exibir apenas os que têm status "OK" ou "ERROR"
for entry in "${SERVICES[@]}"; do
    # Separar o nome do serviço e o tipo (systemd unit ou Docker container)
    service_name="${entry%%|*}"
    service_type_temp="${entry#*|}"
    service_type="${service_type_temp%%|*}"
    service_docker="${entry##*|}"

    #if [ "$service_docker" == "container" ]; then
    #    # Verificar o status do contêiner Docker
    #    status=$(check_docker_container "$service_type")
    #echo ""
    #else
        # Verificar o status do serviço systemd
        service_unit="$service_type"
        status_systemd=$(format_status "$service_unit")
    #fi
#echo -e "$service_docker"

    # Verificar se o status é "OK" ou "ERROR" antes de imprimir
    if [[ "$status_systemd" == "OK" || "$status_systemd" == "ERROR" ]]; then
        if [ "$status_systemd" == "OK" ]; then
            #echo -e "${CYAN}${service_name} Status..........:${CYANB} [  ${GREEN}${status}${CYANB}  ]${OFF}"
            echo -e "  ${CYANB}[  ${GREEN}${status_systemd}${CYANB}  ] ${CYAN}${service_name} ${OFF}"
        else
#           echo -e "$container_inspect"
            #echo -e "${CYAN}${service_name} Status..........:${CYANB} [  ${RED}${status}${CYANB}  ]${OFF}"
            echo -e "  ${CYANB}[  ${RED}${status_systemd}${CYANB}  ] ${CYAN}${service_name} ${OFF}"
        fi
    fi
done

echo -e "  
  ${WHITE}Status dos Serviços Docker"

## Iterar sobre a lista de serviços e exibir apenas os que têm status "OK" ou "ERROR"
for entry in "${SERVICES[@]}"; do
    # Separar o nome do serviço e o tipo (systemd unit ou Docker container)
    service_name="${entry%%|*}"
    service_type_temp="${entry#*|}"
    service_type="${service_type_temp%%|*}"
    service_docker="${entry##*|}"

    #if [ "$service_docker" == "container" ]; then
        # Verificar o status do contêiner Docker
        status_docker=$(check_docker_container "$service_type")
    #else
        # Verificar o status do serviço systemd
        #service_unit="$service_type"
        #status=$(format_status "$service_unit")
    #fi
#echo -e "$service_docker"

    # Verificar se o status é "OK" ou "ERROR" antes de imprimir
    if [[ "$status_docker" == "OK" || "$status_docker" == "ERROR" ]]; then
        if [ "$status_docker" == "OK" ]; then
            #echo -e "${CYAN}${service_name} Status..........:${CYANB} [  ${GREEN}${status}${CYANB}  ]${OFF}"
            echo -e "  ${CYANB}[  ${GREEN}${status_docker}${CYANB}  ] ${CYAN}${service_name} ${OFF}"
        else
#           echo -e "$container_inspect"
            #echo -e "${CYAN}${service_name} Status..........:${CYANB} [  ${RED}${status}${CYANB}  ]${OFF}"
            echo -e "  ${CYANB}[  ${RED}${status_docker}${CYANB}  ] ${CYAN}${service_name} ${OFF}"
        fi
    fi
done


echo -e "
  ${WHITE}Sistema de Arquivo:"

# Obter informações de espaço em disco para /dev/sda
df -h | grep '/dev/sd' | while read -r partition size used avail percent mount; do
    echo -e "  ${CYAN}Partição [${partition}]: ${CYAN}Tam.: ${CYANB}${size}, ${CYAN}Uso%: ${CYANB}${percent}, ${CYAN}Montado em: ${CYANB}${mount}${OFF}"
done


echo -e "
Need help? Type '${BOLD}dgvx${OFF}'"



#EOF
