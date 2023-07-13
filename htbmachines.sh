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
  exit 1
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
  echo -e "\t${purpleColor}-h${endColor} ${grayColor} Mostrar este panel de ayuda${endColor}"
  
  echo -e "\n"
}

function searchMachine(){
  machineName= "$1"
  
  echo "$machineName"
}

function updateFiles(){
  curl -s $main_url > bundle.js
  js-beautify bundle.js | sponge bundle.js 
}



#----------------------------------

#Indicadores (para contadores de parámetros)
declare -i parameter_counter=0

#la letra seguida de : significa que lleva un argumento 
while getopts "m:uh" arg; do
#son distintos casos
  case $arg in
    #dentro de los casos tenemos:
    m) machineName=$OPTARG; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    h) ;;
  esac 
done

#-eq aplica más para valores numéricos
if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles

else
  helpPanel
fi









