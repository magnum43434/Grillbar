#!/bin/bash
# Opgave Aflevering

#Variabler
pris1=45
pris2=65
pris3=35
pris4=30
pris5=27
ialt=0

menu1="Burger menu med pomfritter og sodavand"
menu2="Stor burger menu med pomfritter og sodavand"
menu3="Fransk hotdog med sodavand"
menu4="Hotdog menu med sodavand"
menu5="Pomfritter menu med sodavand"

#Start function
function main {
  if pidof -x "checker.sh" >/dev/null; then
    bestilling
  else
    chmod +x checker.sh
    terminal -e ./checker.sh
    main
  fi

#   if [ -e check.sh ] #hvis cron virker så uncomment if
#   then
#     echo "ok"
#     timer
#     bestilling
#   else
#     echo "nok"
#     create
# fi
}

function menuen {
  clear
  echo "################################################################"
  echo "# Burger menu med pomfritter og sodavand                 45 kr #"
  echo "# Stor burger menu med pomfritter og sodavand            65 kr #"
  echo "# Fransk hotdog menu med sodavand                        35 kr #"
  echo "# Hotdog menu med sodavand                               30 kr #"
  echo "# Pomfrit menu med sodavand                              27 kr #"
  echo "################################################################"
}

#Laver en pause som venter på man klikker enter
function pause(){
   read -p "$*"
}
#laver en cron som kører det function log gør
function timer {
  place=$(pwd)
  place="$place/check.sh"
  #skriver ud nuværende crontab
  crontab -l > mycron
  #echo ny cron ind cron fil
  echo "30 23 * * 1-5 $place" >> mycron
  #installer ny cron fil
  crontab mycron
  rm mycron
  echo "done"
}

#udviser det du har bestilt og gemmer det i en fil der hedder bestillinger
function regning {
  clear
  regningbestil=$(cat bestilling)
  regningpris=$(cat priser)
  rm -f ./bestilling
  rm -f ./priser
  echo "###################################################"
  paste -d' ' <(echo "$regningbestil") <(echo "$regningpris")
  echo "###################################################"
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

    [burger]*)
      bestil=$menu1
      pris=$pris1
      ;;
    [storburger]*)
      bestil=$menu2
      pris=$pris2
      ;;
    [fransk]*)
      bestil=$menu3
      pris=$pris3
      ;;
    [hotdog]*)
      bestil=$menu4
      pris=$pris4
      ;;
    [pomfritter]*)
      bestil=$menu5
      pris=$pris5
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
#laver filen check hvis den ikke findes
function create {
  touch check.sh
  chmod +x ./check.sh

  echo "#!/bin/bash" >>check.sh
  echo "" >>check.sh
  echo  "mkdir -p ./logfiles;" >>check.sh
  echo  "cp ./bestillinger ./logfiles" >>check.sh
  echo  "cp ./omsaetning ./logfiles" >>check.sh
  echo  "summen=$\(awk '{ sum += $1 } END { print sum }' ./logfiles/omsaetning)" >>check.sh
  echo  "echo "" >> ./logfiles/omsaetning" >>check.sh
  echo  "echo "Ialt:""$summen" >> ./logfiles/omsaetning" >>check.sh
  echo  "chmod 555 ./logfiles/bestillinger" >>check.sh
  echo  "chmod 555 ./logfiles/omsaetning" >>check.sh
  echo  "fzip logfiles" >>check.sh
  echo  "mv ./logfiles.zip ./$\(date +%d-%m-%Y).zip" >>check.sh
  echo  "rm -f ./bestillinger" >>check.sh
  echo  "rm -f ./omsaetning" >>check.sh
  echo  "rm -rf ./logfiles" >>check.sh
  echo  "" >>check.sh
  echo  "function fzip {" >>check.sh
  echo      "zip -r $1 $1" >>check.sh
  echo  "}" >>check.sh
  sed 's/[\]//g' check.sh
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
  main
}
#zipper mapper
function fzip {
    zip -r $1 $1
}

main
