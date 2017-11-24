#!/bin/bash

function main {
while [[ true ]]; do
  checker
done
}

function checker {
  string1=$(date +%H:%M:%S)
  string2="23:30:00"
  StartDate=$(date -u -d "$string1" +"%s")
  FinalDate=$(date -u -d "$string2" +"%s")

  if [[ $StartDate -eq $FinalDate ]]; then
    log
  else
    main
  fi
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
  sleep 90
  main
}
#zipper mapper
function fzip {
    zip -r $1 $1
}

main
