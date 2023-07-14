#!/bin/bash

#Colors
greenColor="\e[0;32m\033[1m"
endColor="\033[0m\e[0m"
redColor="\e[0;31m\033[1m"
blueColor="\e[0;34m\033[1m"
yellowColor="\e[0;33m\033[1m"
purpleColor="\e[0;35m\033[1m"
turquoiseColor="\e[0;36m\033[1m"
grayColor="\e[0;37m\033[1m"

ctrl_c(){
  echo -e "\n\n[+]Saliendo... \n"
  tput cnorm && exit 1
}

#ctr+c
trap ctrl_c INT

#--------variables globales--------------
main_url="https://htbmachines.github.io/bundle.js"


#--------funciones-----------------------
#panel de ayuda
function helpPanel(){
  echo -e "\n${yellowColor}[+]${endColor} ${grayColor} Uso:${endColor}"
  echo -e "\t${purpleColor}-u${endColor} ${grayColor} Descargar o actualizar archivos necesarios${endColor}"
  echo -e "\t${purpleColor}-m${endColor} ${grayColor} Buscar máquina por un nombre${endColor}"
  echo -e "\t${purpleColor}-i${endColor} ${grayColor} Buscar por dirección IP${endColor}"
  echo -e "\t${purpleColor}-d${endColor} ${grayColor} Buscar por la dificultad de una máquina${endColor}"
  echo -e "\t${purpleColor}-s${endColor} ${grayColor} Buscar por Skills${endColor}"
  echo -e "\t${purpleColor}-o${endColor} ${grayColor} Buscar por el sistema operativo${endColor}"
  echo -e "\t${purpleColor}-y${endColor} ${grayColor} Obtener link de la resolución de la máquina${endColor}"
  echo -e "\t${purpleColor}-h${endColor} ${grayColor} Mostrar este panel de ayuda${endColor}"
  
  echo -e "\n"
}

function updateFiles(){
 tput civis
 #detectar si el archivo existe para descargarlo o actualizarlo
  if [ ! -f bundle.js ]; then

    echo -e "\n[+] Descargando archivos necesarios..."
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js 
    echo -e "\n[+] Todos los archivos han sido descargados"

  else   
    echo -e "\n[+] Comprobando si hay actualizaciones pendientes..."
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js 
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}') 
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')
    
    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n[+] No han encontrado actualizaciones, estás al día."
      rm bundle_temp.js
    else
      echo "\n[+] Se han ecnontrado actualizaciones"
      sleep 1

      rm bundle.js && mv bundle_temp.js bundle.js

      echo -e "\n[+] Los archivos han sido actualizados."
    fi
      
  fi
  tput cnorm
}

function searchMachine(){
  machineName="$1"
 
  machineNameChecker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' )"
  
  if [ "$machineNameChecker" ]; then
    echo -e "\n${yellowColor}[+]${endColor} ${grayColor}Listando las propiedades de la máquina ${endColor}${blueColor}$machineName${endColor}${grayColor}:${endColor}\n"
    echo -e "$machineNameChecker"
  else
    echo -e "\n${redColor}[!] La máquina proporcionada no existe${endColor}\n"
  fi
}


function searchIP(){
  ipAddress="$1"
  
  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | tr -d "\n" )"
 
  if [ "$machineName" ]; then
    echo -e "\n${yellowColor}[+]${endColor} El IP ${greenColor}$ipAddress${endColor} corresponde a la máquina ${blueColor}$machineName${endColor}"
  else 
    echo -e "\n${redColor}[!] La dirección IP proporcionada no existe${endColor}\n"
  fi
}


function getYoutubeLink(){
  machineName="$1"

  youtubeLink="$(cat bundle.js | awk "/name: \"Tentacle\"/,/resuelta:/" | grep "youtube:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

  if [ "$youtubeLink" ]; then
    echo -e "\n[+] El link es: $youtubeLink"
  else
    echo -e "\n${redColor}[!] La máquina proporcionada no existe${endColor}"
  fi

}

function getMachinesDificulty(){
  difficulty="$1"

  results_check="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}'| tr -d '"' | tr -d ',' | column)"

  if [ "$results_check" ]; then
      echo -e "\n[+] Representando las máquinas que poseen un nivel de dificultad ${blueColor}$difficulty${endColor}:"
      echo -e "\n$results_check"
  else
    echo -e "\n${redColor}[!] No existen máquinas con la difcultad proporcionada ${endColor}"  
  fi
}

function getOSMachines() {
  os="$1"

  os_results="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}'| tr -d '"' | tr -d ',' | column)"

  if [ "$os_results" ]; then
    echo -e "\n[+] Mostrando las máquinas cuyo sistema operativo es $os"
    echo -e "\n$os_results"
  else
    echo -e "\n${redColor}[!] No existen máquinas con el sistema operativo proporcionado ${endColor}"  
  fi

}

function getOSDifficultyMachines(){
  difficulty="$1"
  os="$2"

  results_check="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ','| column)"
  
  if [ "$results_check" ]; then
    echo -e "\n[+] Listando máquinas dde dificultad $difficulty con sistema operativo $os:"
    echo -e "\n$results_check"
  else 
    echo -e "\n${redColor}[!] No existen máquinas con los parámetros indicados ${endColor}"  
  fi

}

function getSkill(){
  skill="$1"

  check_skill="$(cat bundle.js | grep "skills:" -B 7 | grep "$skill" -i -B 6 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$check_skill" ]; then
    echo -e "\n[+] A continuación se muestran las maquinas que tratan con la Skill ${blueColor}$skill${endColor}:"
    echo -e "$check_skill\n"
  else
    echo -e "\n${redColor}[!] No se ha encontrado niinguna máquina con la Skill indicada ${endColor}"     
  fi

}


#----------------------------------

#Indicadores (para contadores de parámetros)
declare -i parameter_counter=0

#la letra seguida de : significa que lleva un argumento 
while getopts "m:ui:y:d:o:s:h" arg; do
#son distintos casos
  case $arg in
    #dentro de los casos tenemos:
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; let parameter_counter+=5;;
    o) os="$OPTARG"; let parameter_counter+=6;;
    s) skill="$OPTARG"; let parameter_counter+=7;;
    h) ;;
  esac 
done

#-eq aplica más para valores numéricos
if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  getMachinesDificulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  getOSMachines $os
#suma de dificultad + os 
elif [ $parameter_counter -eq 11 ]; then
  getOSDifficultyMachines $difficulty $os

#como pueden haber varios argumentos la variable skill se pone entre ""
elif [ $parameter_counter -eq 7 ]; then
  getSkill "$skill"
else
  helpPanel
fi









