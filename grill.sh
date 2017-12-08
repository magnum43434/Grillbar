#!/bin/bash
# Opgave Aflevering

#Variabler
pris1=45
pris2=65
pris3=35
pris4=30
pris5=27
ialt=0
derp=0

menu1="Burger menu med pomfritter og sodavand"
menu2="Stor burger menu med pomfritter og sodavand"
menu3="Fransk hotdog med sodavand"
menu4="Hotdog menu med sodavand"
menu5="Pomfritter menu med sodavand"

SERVICE='checker'

#Start function
function main {
  if ps ax | grep -v grep | grep $SERVICE > /dev/null; then
    bestilling
  else
    if [ -f ./checker.sh ]; then
      chmod +x checker.sh
      gnome-terminal -x bash -c './checker.sh; exec bash'
      main
    else
      create
    fi
  fi
}

function menuen {
  clear
  echo "----------------------------------------------------"
  echo "| $(echo $menu1 $pris1 "kr")"
  echo "| $(echo $menu2 $pris2 "kr")"
  echo "| $(echo $menu3 $pris3 "kr")"
  echo "| $(echo $menu4 $pris4 "kr")"
  echo "| $(echo $menu5 $pris5 "kr")"
  echo "----------------------------------------------------"
}

#Laver en pause som venter på man klikker enter
function pause(){
   read -p "$*"
}

#udviser det du har bestilt og gemmer det i en fil der hedder bestillinger
function regning {
  clear
  regningbestil=$(cat bestilling)
  regningpris=$(cat priser)
  rm -f ./bestilling
  rm -f ./priser
  echo "---------------------------------------------------"
  paste -d' ' <(echo "$regningbestil") <(echo "$regningpris")
  echo "---------------------------------------------------"
  echo "" >> bestillinger
  echo "$(date +%H:%M:%S)" >> bestillinger
  echo "$(paste -d' ' <(echo "$regningbestil") <(echo "$regningpris"))" >> bestillinger
  echo ""
  pause 'Press [Enter] key to continue...'
  main
}

#giver dig menuen og mulighed for at bestille det du vil have
function bestilling {
  menuen
  echo "Hvad vil du bestille"
  read valg
  case $valg in

    [1]*)
      bestil=$menu1
      pris=$pris1
      ;;
    [2]*)
      bestil=$menu2
      pris=$pris2
      ;;
    [3]*)
      bestil=$menu3
      pris=$pris3
      ;;
    [4]*)
      bestil=$menu4
      pris=$pris4
      ;;
    [5]*)
      bestil=$menu5
      pris=$pris5
      ;;
    [exit]*)
      pkill -f checker.sh
      clear
      return
      ;;
  esac
  clear
  echo "Du har valgt menuen:"
  echo "$bestil"
  echo ""
  echo "Vil du have mere?"
  echo "Ja eller Nej"
  read forsaet

  case $forsaet in
    [Ja-ja]*)
      ialt=$(($ialt + $pris))
      echo "$bestil" >> bestilling
      echo "$pris"" kr." >> priser
      bestilling
      ;;
    [Nej-nej]*)
      ialt=$(($ialt + $pris))
      echo "$bestil" >> bestilling
      echo "$pris"" kr." >> priser
      echo "Ialt" >> bestilling
      echo "$ialt"" kr." >> priser
      echo "$ialt" >> omsaetning
      regning
      ;;
    [omsætning]*)
      awk '{ sum += $1 } END { print sum }' omsaetning
    ;;
  esac
}
#laver fil check hvis den ikke findes
function create {
  wget https://raw.githubusercontent.com/magnum43434/Grillbar/master/checker.sh
  main
}

function log {
  mkdir -p ./logfiles;
  cp ./bestillinger ./logfiles
  cp ./omsaetning ./logfiles
  summen=$(awk '{ sum += $1 } END { print sum }' ./logfiles/omsaetning)
  echo "" >> ./logfiles/omsaetning
  echo "Ialt:""$summen" >> ./logfiles/omsaetning
  chmod 555 ./logfiles/bestillinger
  chmod 555 ./logfiles/omsaetning
  fzip logfiles
  mv ./logfiles.zip ./$(date +%d-%m-%Y).zip
  rm -f ./bestillinger
  rm -f ./omsaetning
  rm -rf ./logfiles
}
#zipper mapper
function fzip {
    zip -r $1 $1
}

main
