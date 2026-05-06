#!/bin/bash

#Colours
green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"
subrayar="\e[4m\033[1m"

function crtl_c(){
  echo -e "\n\n${red}[!] Saliendo...${end}"
  exit 1
  tput cnorm
}
# crtl_c 
trap crtl_c INT

function help_panel(){
  echo -e "\n${yellow}[+] ${end}${gray}Usages:${end}"
  echo -e "\t${purple}h) ${end}${gray}This panel :0${end}"
  echo -e "\t${purple}m) ${end}${gray}Amount of money to play${end}"
  echo -e "\t${purple}t) ${end}${gray}Technique to use${end}${purple} (Martingala / InverseLabrouchere) ${end}"
}
function Martingala (){
  echo -e "\n${yellow}[+]${end} ${gray}Actual money:${end} ${green}$money$ ${end}"
  echo -ne "${yellow}[+]${end} ${gray}How much money dou you plan to bet? -> ${end}" && read initial_bet
  echo -ne "${yellow}[+]${end} ${gray}On which do you want to bet continuously (even/odd)? -> ${end}" && read even_odd

  echo -e "\n${yellow}[+]${end} ${gray}We are going to start playing with the initial amount of${end}${green} $initial_bet$ ${end}${gray}in ${end}${blue}$even_odd${end}"
  
  backup_bet=$initial_bet
  play_counter=1
  jugadas_malas=" "
  
  tput civis
  while true; do
    money=$(($money-$initial_bet))
    echo -e "\n${yellow}[+]${end} ${gray}You bet${end} ${turquoise}$initial_bet$ ${end}${gray}and you have${end}${green} $money$ ${end}"
    random_number="$(($RANDOM % 37))"
    echo -e "${yellow}[+]${end} ${gray}The number has come out:${end} ${purple}$random_number${end}"

    if [ ! "$money" -lt 0 ]; then
      if [ "$even_odd" == "even" ]; then                                                      #Even numbers only
        if [ "$(($random_number % 2))" == 0 ]; then 
          if [ "$random_number" -eq 0 ]; then
            echo -e "${red}[+] The number is 0 you lose${end}"
            initial_bet=$((initial_bet*2))
            jugadas_malas+="$random_number "
            echo -e "${yellow}[+]${end} ${gray}Now you have${end}${blue} $money${end}"
          else 
            echo -e "${yellow}[+]${end} ${gray}The number is even you win!${end}"
            reward=$((initial_bet*2))
            echo -e "${yellow}[+]${end} ${gray}You win a total of${end} ${green}$reward ${end}"
            money=$(($money+$reward))
            echo -e "${yellow}[+]${end} ${gray}You have${end} ${green}$money$ ${end}"
            initial_bet=$backup_bet
            jugadas_malas=""
          fi
        else
          echo -e "${yellow}[+]${end} ${gray}The number is odd${end} ${red}you lose :c${end}"
          initial_bet=$((initial_bet*2))
          jugadas_malas+="$random_number "
          echo -e "${yellow}[+]${end} ${gray}Now you have${end}${blue} $money${end}"
        fi
      else                                                                                        #odd numbers 
        if [ "$(($random_number % 2))" -eq 1 ]; then
          echo -e "${yellow}[+]${end} ${gray}The number is odd you win!${end}"
          reward=$((initial_bet*2))
          echo -e "${yellow}[+]${end} ${gray}You win a total of${end} ${green}$reward ${end}"
          money=$(($money+$reward))
          echo -e "${yellow}[+]${end} ${gray}You have${end} ${green}$money$ ${end}"
          initial_bet=$backup_bet
          jugadas_malas=""
        else
          echo -e "${yellow}[+]${end} ${gray}The number is even${end} ${red}you lose :c${end}"
          initial_bet=$((initial_bet*2))
          jugadas_malas+="$random_number "
          echo -e "${yellow}[+]${end} ${gray}Now you have${end}${blue} $money${end}"
        fi  
      fi
    else
      echo -e "${red}[+] Te has quedado sin pasta cabrón, no ves que la casa siempre gana?${end}\n"
      echo -e "${yellow}[+]${end}${gray} Number of times played:${end}${yellow} $play_counter${end}"
      echo -e "\n${yellow}[+]${end}${gray} Bad plays:${end}${blue}[ $jugadas_malas]${end}"
      tput cnorm; exit 0
    fi
    let play_counter+=1
  done

  tput cnorm
}

function InverseLabrouchere(){
  echo -e "\n${yellow}[+]${end} ${gray}Actual money:${end} ${green}$money$ ${end}"
  echo -ne "${yellow}[+]${end} ${gray}On which do you want to bet continuously (even/odd)? -> ${end}" && read even_odd

  declare -a my_sequence=(1 2 3 4)

  echo -e "\n${yellow}[+]${end} ${gray}We start with the sequence${end} ${purple}[${my_sequence[@]}]${end}"
  
  bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
  
  jugadas_totales=0
  bet_to_renew=$(($money + 50))
  tput civis
  while true; do
    let jugadas_totales+=1
    random_number=$(($RANDOM % 37))
    if [ ! "$money" -lt 0 ]; then
      money=$(($money - $bet))
      echo -e "${yellow}[+]${end} ${gray}Total inversion of $bet$"
      echo -e "${yellow}[+]${end} ${gray}You have $money$ ${end}"

      echo -e "\n${yellow}[+]${end} ${gray}Ha salido el numero${end} ${blue}$random_number${end}"
      
      if [ "$even_odd" == "even" ]; then 
        if [ "$(($random_number % 2))" -eq 0 ] && [ "$random_number" -ne 0 ]; then 
          echo -e "${yellow}[+]${end} ${green}The number is even, you win!${end}"
          reward=$(($bet*2)) 
          let money+=$reward
          echo -e "${yellow}[+]${end} ${gray}You have ${end}${green}$money$ ${end}"

          if [ $money -gt $bet_to_renew ]; then 
            echo -e "${yellow}[+]${end} ${gray}Se ha superado el tope de $bet_to_renew$ para renovar nuestra secuencia${end}"
            bet_to_renew=$((bet_to_renew + 50))
            echo -e "${yellow}[+]${end} ${gray}El tope se ha establecido en${end} ${yellow}$bet_to_renew$ ${end}"
            my_sequence=(1 2 3 4)
            bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            echo -e "${yellow}[+]${end} ${gray}La secuencia ha sido restablecida a ${end}${purple}[${my_sequence[@]}${end}]"
          else
            my_sequence+=($bet)
            my_sequence=(${my_sequence[@]})

            echo -e "${yellow}[+]${end} ${gray}The new sequence is${end} ${purple}[${my_sequence[@]}]${end}"
            if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
             bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 1 ]; then
              bet=${my_sequence[0]}
            else
              echo -e "${red}[!] We lost our sequency${end}"
              my_sequence=(1 2 3 4)
              echo -e "${red}[!] Restablecemos la secuencia${end}${green} [${my_sequence[@]}]${end}"
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
          fi
        elif [ "$((random_number % 2))" -eq 1 ] || [ "$random_number" -eq 0 ]; then
          if [ "$((random_number % 2))" -eq 1 ]; then
           echo -e "${red}[!] The number is odd, you lose :c${end}"
          else 
            echo -e "${red}[!] The number is 0, you lose :C${end}"
          fi
          if [ $money -lt $((bet_to_renew-100)) ]; then 
            echo -e "${yellow}[+]${end} ${gray}Hemos llegado a un minimo crítico, se procede a reajustar el tope${end}"
            bet_to_renew=$((bet_to_renew - 50))
            echo -e "${yellow}[+] ${end}${gray}El tope se ha renovado a ${end}${yellow}$bet_to_renew$ ${end}"

            unset my_sequence[0]
            unset my_sequence[-1] 2>/dev/null
            
            my_sequence=(${my_sequence[@]})

            echo -e "${yellow}[+]${end} ${gray}The new sequence is${end} ${purple}[${my_sequence[@]}]${end}"
            if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
             bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 1 ]; then
              bet=${my_sequence[0]}
            else
              echo -e "${red}[!] We lost our sequency${end}"
              my_sequence=(1 2 3 4)
              echo -e "${red}[!] Restablecemos la secuencia${end}${green} [${my_sequence[@]}]${end}"
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
          else

            unset my_sequence[0]
            unset my_sequence[-1] 2>/dev/null
            
            my_sequence=(${my_sequence[@]})

            echo -e "${yellow}[+]${end}${gray} The sequence is now in the form${end}${purple} [${my_sequence[@]}]${end}"
            if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
             bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 1 ]; then
              bet=${my_sequence[0]}
            else
              echo -e "${red}[!] We lost our sequency${end}"
              my_sequence=(1 2 3 4)
              echo -e "${red}[!] Restablecemos la secuencia${end}${green} [${my_sequence[@]}]${end}"
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
          fi
        fi 
      elif [ "$even_odd" == "odd" ]; then                                                         #odd
        if [ "$(($random_number % 2))" -eq 1 ] && [ "$random_number" -ne 0 ]; then 
          echo -e "${yellow}[+]${end} ${green}The number is odd, you win!${end}"
          reward=$(($bet*2)) 
          let money+=$reward
          echo -e "${yellow}[+]${end} ${gray}You have ${end}${green}$money$ ${end}"

          if [ $money -gt $bet_to_renew ]; then 
            echo -e "${yellow}[+]${end} ${gray}Se ha superado el tope de $bet_to_renew$ para renovar nuestra secuencia${end}"
            bet_to_renew=$((bet_to_renew + 50))
            echo -e "${yellow}[+]${end} ${gray}El tope se ha establecido en${end} ${yellow}$bet_to_renew$ ${end}"
            my_sequence=(1 2 3 4)
            bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            echo -e "${yellow}[+]${end} ${gray}La secuencia ha sido restablecida a ${end}${purple}[${my_sequence[@]}${end}]"
          else
            my_sequence+=($bet)
            my_sequence=(${my_sequence[@]})

            echo -e "${yellow}[+]${end} ${gray}The new sequence is${end} ${purple}[${my_sequence[@]}]${end}"
            if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
             bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 1 ]; then
              bet=${my_sequence[0]}
            else
              echo -e "${red}[!] We lost our sequency${end}"
              my_sequence=(1 2 3 4)
              echo -e "${red}[!] Restablecemos la secuencia${end}${green} [${my_sequence[@]}]${end}"
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
          fi
        elif [ "$((random_number % 2))" -eq 0 ] || [ "$random_number" -eq 1 ]; then
          if [ "$random_number" -eq 0 ]; then
            echo -e "${red}[!] The number is 0, you lose :C${end}"
          else 
            echo -e "${red}[!] The number is even, you lose :c${end}"
          fi 
          if [ $money -lt $((bet_to_renew-100)) ]; then 
            echo -e "${yellow}[+]${end} ${gray}Hemos llegado a un minimo crítico, se procede a reajustar el tope${end}"
            bet_to_renew=$((bet_to_renew - 50))
            echo -e "${yellow}[+] ${end}${gray}El tope se ha renovado a ${end}${yellow}$bet_to_renew$ ${end}"

            unset my_sequence[0]
            unset my_sequence[-1] 2>/dev/null
            
            my_sequence=(${my_sequence[@]})

            echo -e "${yellow}[+]${end} ${gray}The new sequence is${end} ${purple}[${my_sequence[@]}]${end}"
            if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
             bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 1 ]; then
              bet=${my_sequence[0]}
            else
              echo -e "${red}[!] We lost our sequency${end}"
              my_sequence=(1 2 3 4)
              echo -e "${red}[!] Restablecemos la secuencia${end}${green} [${my_sequence[@]}]${end}"
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
          else

            unset my_sequence[0]
            unset my_sequence[-1] 2>/dev/null
            
            my_sequence=(${my_sequence[@]})

            echo -e "${yellow}[+]${end}${gray} The sequence is now in the form${end}${purple} [${my_sequence[@]}]${end}"
            if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
             bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 1 ]; then
              bet=${my_sequence[0]}
            else
              echo -e "${red}[!] We lost our sequency${end}"
              my_sequence=(1 2 3 4)
              echo -e "${red}[!] Restablecemos la secuencia${end}${green} [${my_sequence[@]}]${end}"
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
          fi
        fi 
      fi 
    else
      echo -e "${red}\n[+] Te has quedado sin pasta cabrón, no ves que la casa siempre gana?${end}"
      echo -e "${yellow}[+]${end}${gray} Number of times played:${end}${yellow} $jugadas_totales${end}\n"
      tput cnorm; exit 1
    fi
  done
  tput cnorm
}

while getopts "m:t:h" arg; do
  case $arg in
    m) money=$OPTARG;;
    t) TECHNIQUE=$OPTARG;;
    h) help_panel;;
  esac
done

if [ $money ] && [ $TECHNIQUE ]; then
  if [ $TECHNIQUE == "Martingala" ]; then 
    Martingala
  elif [ "$TECHNIQUE" == "InverseLabrouchere" ]; then
    InverseLabrouchere
  else 
    echo -e "$\n{red}[+] The technique does not exist${end}\n"
    help_panel
  fi
else
  help_panel
fi
