##!/bin/bash
export DIALOGRC="$(dirname "$0")/dialogrc_mono"export DIALOGRC="$(dirname "$0")/dialogrc_mono"export DIALOGRC="$(dirname "$0")/dialogrc_mono"export DIALOGRC="$(dirname "$0")/dialogrc_mono"export DIALOGRC="$(dirname "$0")/dialogrc_mono"export DIALOGRC="$(dirname "$0")/dialogrc_mono"export DIALOGRC="$(dirname "$0")/dialogrc_mono"export DIALOGRC="$(dirname "$0")/dialogrc_mono"export DIALOGRC="$(dirname "$0")/dialogrc_mono"
# ============================================================
#  Ruleta GUI — Martingala / Inverse Labouchere
#  Requiere: dialog  (sudo apt install dialog)
# ============================================================

# ── Colores de terminal (mensajes fuera de dialog) ──────────
green="\e[0;32m\033[1m";  end="\033[0m\e[0m"
red="\e[0;31m\033[1m";    yellow="\e[0;33m\033[1m"
blue="\e[0;34m\033[1m";   purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"; gray="\e[0;37m\033[1m"

# ── Ctrl-C limpio ────────────────────────────────────────────
function ctrl_c(){
  clear
  echo -e "\n${red}[!] Saliendo...${end}"
  tput cnorm; exit 1
}
trap ctrl_c INT

# ── Verificar dialog ─────────────────────────────────────────
if ! command -v dialog &>/dev/null; then
  echo -e "${red}[!] 'dialog' no está instalado.${end}"
  echo -e "${yellow}    sudo apt install dialog${end}"
  exit 1
fi

DIALOG_OK=0
BACKTITLE="🎰  Simulador de Ruleta"

# ════════════════════════════════════════════════════════════
#  MENÚ PRINCIPAL
# ════════════════════════════════════════════════════════════
function main_menu(){
  while true; do
    CHOICE=$(dialog --clear \
      --backtitle "$BACKTITLE" \
      --title "[ MENÚ PRINCIPAL ]" \
      --menu "Elige una opción:" 15 50 4 \
      "1" "Jugar — Martingala" \
      "2" "Jugar — Inverse Labouchere" \
      "3" "¿Cómo funcionan las estrategias?" \
      "4" "Salir" \
      3>&1 1>&2 2>&3)

    case $CHOICE in
      1) setup_game "Martingala" ;;
      2) setup_game "InverseLabrouchere" ;;
      3) show_help ;;
      4|"") clear; echo -e "${yellow}[+] ¡Hasta la próxima!${end}"; tput cnorm; exit 0 ;;
    esac
  done
}

# ════════════════════════════════════════════════════════════
#  PANTALLA DE AYUDA
# ════════════════════════════════════════════════════════════
function show_help(){
  dialog --backtitle "$BACKTITLE" \
    --title "[ ESTRATEGIAS ]" \
    --msgbox "\
MARTINGALA\n\
──────────\n\
Doblas la apuesta cada vez que pierdes.\n\
Cuando ganas, recuperas todo y vuelves\n\
a la apuesta inicial.\n\
Riesgo: una racha mala te arruina rápido.\n\
\n\
INVERSE LABOUCHERE\n\
──────────────────\n\
Partes de una secuencia [1 2 3 4].\n\
Tu apuesta = primer + último número.\n\
• Si GANAS  → añades la apuesta al final.\n\
• Si PIERDES → eliminas los extremos.\n\
La secuencia se renueva al superar\n\
el tope de ganancias fijado." \
    20 55
}

# ════════════════════════════════════════════════════════════
#  CONFIGURACIÓN ANTES DE JUGAR
# ════════════════════════════════════════════════════════════
function setup_game(){
  local TECHNIQUE=$1

  # ── Dinero inicial ───────────────────────────────────────
  MONEY=$(dialog --backtitle "$BACKTITLE" \
    --title "[ CONFIGURACIÓN ]" \
    --inputbox "¿Con cuánto dinero quieres jugar? ($)" \
    8 40 "100" \
    3>&1 1>&2 2>&3) || return

  if ! [[ "$MONEY" =~ ^[0-9]+$ ]] || [ "$MONEY" -le 0 ]; then
    dialog --msgbox "⚠️  Introduce un número entero positivo." 6 40
    return
  fi

  # ── Par o impar ─────────────────────────────────────────
  EVEN_ODD=$(dialog --backtitle "$BACKTITLE" \
    --title "[ CONFIGURACIÓN ]" \
    --menu "¿En qué quieres apostar?" 10 40 2 \
    "even" "Par" \
    "odd"  "Impar" \
    3>&1 1>&2 2>&3) || return

  # ── Apuesta inicial (solo Martingala) ───────────────────
  if [ "$TECHNIQUE" == "Martingala" ]; then
    INITIAL_BET=$(dialog --backtitle "$BACKTITLE" \
      --title "[ CONFIGURACIÓN ]" \
      --inputbox "¿Cuánto quieres apostar inicialmente? ($)" \
      8 40 "10" \
      3>&1 1>&2 2>&3) || return

    if ! [[ "$INITIAL_BET" =~ ^[0-9]+$ ]] || [ "$INITIAL_BET" -le 0 ]; then
      dialog --msgbox "⚠️  Introduce un número entero positivo." 6 40
      return
    fi

    if [ "$INITIAL_BET" -ge "$MONEY" ]; then
      dialog --msgbox "⚠️  La apuesta no puede ser mayor o igual que tu dinero." 6 45
      return
    fi

    play_martingala
  else
    play_labouchere
  fi
}

# ════════════════════════════════════════════════════════════
#  JUEGO — MARTINGALA
# ════════════════════════════════════════════════════════════
function play_martingala(){
  local money=$MONEY
  local initial_bet=$INITIAL_BET
  local backup_bet=$INITIAL_BET
  local play_counter=0
  local log=""

  tput civis
  while true; do
    let play_counter+=1
    money=$(( money - initial_bet ))
    local rn=$(( RANDOM % 37 ))
    local result=""
    local win=false

    # ── Evaluar resultado ──────────────────────────────────
    if [ "$EVEN_ODD" == "even" ]; then
      if [ "$rn" -eq 0 ]; then
        result="Salió 0 → pierdes"
      elif [ $(( rn % 2 )) -eq 0 ]; then
        result="Salió $rn (PAR) → ¡GANAS!"
        win=true
      else
        result="Salió $rn (impar) → pierdes"
      fi
    else
      if [ $(( rn % 2 )) -eq 1 ]; then
        result="Salió $rn (IMPAR) → ¡GANAS!"
        win=true
      else
        result="Salió $rn (par/0) → pierdes"
      fi
    fi

    if $win; then
      local reward=$(( initial_bet * 2 ))
      money=$(( money + reward ))
      log="Jugada $play_counter: Apostaste \$$initial_bet → $result → Saldo: \$$money"
      initial_bet=$backup_bet
    else
      log="Jugada $play_counter: Apostaste \$$initial_bet → $result → Saldo: \$$money"
      initial_bet=$(( initial_bet * 2 ))
    fi

    # ── ¿Sin dinero? ───────────────────────────────────────
    if [ "$money" -lt 0 ]; then
      tput cnorm
      dialog --backtitle "$BACKTITLE" \
        --title "[ GAME OVER ]" \
        --msgbox "💸 ¡Te quedaste sin dinero!\n\nJugadas totales: $play_counter\n\n$log" \
        10 50
      return
    fi

    # ── Mostrar estado y preguntar si continuar ─────────────
    dialog --backtitle "$BACKTITLE" \
      --title "[ MARTINGALA — Jugada $play_counter ]" \
      --yesno \
"$log\n\n\
Próxima apuesta: \$$initial_bet\n\
Saldo actual:    \$$money\n\n\
¿Seguir jugando?" \
      12 55

    if [ $? -ne 0 ]; then
      tput cnorm
      dialog --backtitle "$BACKTITLE" \
        --title "[ RESUMEN ]" \
        --msgbox "Terminaste con \$$money 💰\nJugadas: $play_counter" \
        8 40
      return
    fi
  done
}

# ════════════════════════════════════════════════════════════
#  JUEGO — INVERSE LABOUCHERE
# ════════════════════════════════════════════════════════════
function play_labouchere(){
  local money=$MONEY
  local -a seq=(1 2 3 4)
  local play_counter=0
  local bet_to_renew=$(( money + 50 ))

  # Calcula apuesta desde la secuencia
  function calc_bet(){
    if [ "${#seq[@]}" -ge 2 ]; then
      echo $(( seq[0] + seq[-1] ))
    elif [ "${#seq[@]}" -eq 1 ]; then
      echo "${seq[0]}"
    else
      seq=(1 2 3 4)
      echo $(( seq[0] + seq[-1] ))
    fi
  }

  tput civis
  while true; do
    let play_counter+=1
    local bet=$(calc_bet)
    money=$(( money - bet ))
    local rn=$(( RANDOM % 37 ))
    local result=""
    local win=false

    # ── Evaluar resultado ──────────────────────────────────
    if [ "$EVEN_ODD" == "even" ]; then
      if [ "$rn" -ne 0 ] && [ $(( rn % 2 )) -eq 0 ]; then
        result="Salió $rn (PAR) → ¡GANAS!"
        win=true
      else
        result="Salió $rn → pierdes"
      fi
    else
      if [ $(( rn % 2 )) -eq 1 ]; then
        result="Salió $rn (IMPAR) → ¡GANAS!"
        win=true
      else
        result="Salió $rn → pierdes"
      fi
    fi

    # ── Actualizar secuencia ───────────────────────────────
    if $win; then
      local reward=$(( bet * 2 ))
      money=$(( money + reward ))
      if [ "$money" -gt "$bet_to_renew" ]; then
        bet_to_renew=$(( bet_to_renew + 50 ))
        seq=(1 2 3 4)
      else
        seq+=($bet)
        seq=("${seq[@]}")
      fi
    else
      if [ "$money" -lt $(( bet_to_renew - 100 )) ]; then
        bet_to_renew=$(( bet_to_renew - 50 ))
      fi
      unset seq[0]; unset 'seq[-1]' 2>/dev/null
      seq=("${seq[@]}")
      if [ "${#seq[@]}" -eq 0 ]; then
        seq=(1 2 3 4)
      fi
    fi

    local seq_str="[${seq[*]}]"
    local next_bet=$(calc_bet)

    # ── ¿Sin dinero? ───────────────────────────────────────
    if [ "$money" -lt 0 ]; then
      tput cnorm
      dialog --backtitle "$BACKTITLE" \
        --title "[ GAME OVER ]" \
        --msgbox "💸 ¡Te quedaste sin dinero!\n\nJugadas totales: $play_counter\n$result" \
        10 50
      return
    fi

    # ── Mostrar estado ─────────────────────────────────────
    dialog --backtitle "$BACKTITLE" \
      --title "[ LABOUCHERE — Jugada $play_counter ]" \
      --yesno \
"Apostaste: \$$bet  →  $result\n\n\
Saldo:       \$$money\n\
Secuencia:   $seq_str\n\
Prox. apuesta: \$$next_bet\n\
Tope renovación: \$$bet_to_renew\n\n\
¿Seguir jugando?" \
      13 55

    if [ $? -ne 0 ]; then
      tput cnorm
      dialog --backtitle "$BACKTITLE" \
        --title "[ RESUMEN ]" \
        --msgbox "Terminaste con \$$money 💰\nJugadas: $play_counter" \
        8 40
      return
    fi
  done
}

# ════════════════════════════════════════════════════════════
#  ENTRADA
# ════════════════════════════════════════════════════════════
clear
main_menu !/bin/bash
