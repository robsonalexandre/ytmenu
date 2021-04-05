#!/usr/bin/env bash
#
__FILE__=$(readlink -f "${BASH_SOURCE[0]}")
APP_PATH=${__FILE__%/*}
#APP_DEBUG=1
BASE_URL='https://youtu.be'
BASE_FEED_XML='https://www.youtube.com/feeds/videos.xml?channel_id='
MENU_FORMAT='%3s - %s\n'
LIMITE_RECENTES=5
MPV_OPT=(
  '--no-terminal'
  '--ytdl-format=bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best'
  '--untimed'
)
COLUMNS=80    # Comente esta linha para usar a largura do terminal
declare -g yt_canais yt_videos canal_title

function getYtCanaisFavoritos() {
  readarray -t yt_canais < <(sed '/^#/{N;s/\n/|/};/^\s*$/d' "$APP_PATH/sources")
}

function getYtVideos() {
  local xml canal_url=$1
  xml=$(wget -qO- "$canal_url")
  canal_title=${canal_title:-$(grep -m1 -oP '(?<=<title>)[^<]+' <<< "$xml")}
  readarray -t yt_videos < <(grep -oP '(?<=yt:videoId>|media:title>)[^<]+' <<< "$xml" | sed 'N;s/\n/|/' | head -n $LIMITE_RECENTES)
}

function menu_selecionar_canal() {
  local canal title url i=0
  getYtCanaisFavoritos
  hr 'Selecione o canal na lista de favoritos'
  for canal in "${yt_canais[@]}"; do
    IFS='|' read title url <<< "$canal"
    printf "$MENU_FORMAT" $((++i)) "$title"
  done
  printf "$MENU_FORMAT\n" 'q' 'Sair'
  hr
  [[ $flash_message ]] && { printf '%s\n' "$flash_message"; flash_message=; }
}

function menu_selecionar_video() {
  local video id title url=$1 i=0
  getYtVideos "$url"
  hr "Selecione um dos 5 vídeos mais recentes do canal $canal_title"
  for video in "${yt_videos[@]}"; do
    IFS='|' read id title <<< "$video"
    printf "$MENU_FORMAT" $((++i)) "$title"
  done
  if ! grep -q "$url" "$APP_PATH/sources"; then
    printf "$MENU_FORMAT" 's' 'Salvar canal na lista de favoritos'
  fi
  printf "$MENU_FORMAT" 'm' 'Voltar ao menu anterior'
  printf "$MENU_FORMAT\n" 'q' 'Sair'
  hr
  [[ $flash_message ]] && { printf '%s\n' "$flash_message"; flash_message=; }
}

function hr() {
  local length=${COLUMNS:-$(tput cols)}
  borda=$(printf -v borda "+%*s+" "$((length-2))"; echo ${borda// /-};)
  if [[ $1 ]]; then
    n=$(((length-${#1})/2))
    m=$((n+${#1}))
    borda="${borda::$n}${1}${borda:$m}"
  fi
  echo "$borda"
}

function _ajuda() {
  cat <<EOT >&2
$*
  Usage: ytmenu [OPTIONS] [CHANNEL_URL|FEED_XML_URL|VIDEO_ID]
Options:
   General Options:
     -h|--help           Print this help text and exit
EOT
  return 1
}

function dd() {
  if [ -x "$APP_DEBUG" ] && $APP_DEBUG ||
     [[ ${APP_DEBUG,,} == @(true|1|on) ]]; then
    printf "<!--\n [+] $(echo $*|cat -A)\n-->\n" >&2
  fi
}

shopt -s extglob
function main() {
  while :; do
    case $rota in
      selecionar_canal)
        menu_selecionar_canal
        read -p 'Selecione opção: => '
        case ${REPLY,,} in
          +([0-9]))
            opt=$((REPLY-1))
            IFS='|' read canal_title canal_url <<< "${yt_canais[$opt]}"
            rota=selecionar_video
            [[ $canal_url ]] || { flash_message="Opção: $REPLY é uma opção indisponível"; rota=selecionar_canal; }
            ;;
          q) echo "Até mais..."; break;;
          *) flash_message="Opção: $REPLY inválida...";;
        esac
        ;;
      selecionar_video)
        menu_selecionar_video "$canal_url"
        read -p 'Selecione opção: => '
        case ${REPLY,,} in
          +([0-9]))
            opt=$((REPLY-1))
            IFS='|' read videoId media_title <<< "${yt_videos[$opt]}"
            rota=reproduzir_video
            [[ $videoId ]] || { flash_message="Opção: $REPLY é uma opção indisponível"; rota=selecionar_video; }
            ;;
          m) rota=selecionar_canal;;
          s) rota=salvar_canal;;
          q) echo "Até mais..."; break;;
          *) flash_message="Opção: $REPLY inválida...";;
        esac
        ;;
      salvar_canal)
        if ! grep "$canal_url" "$APP_PATH/sources"; then
          sed -i "$ a\ \n# $canal_title\n$canal_url" "$APP_PATH/sources"
        fi
        rota=selecionar_video
        ;;
      reproduzir_video)
        [[ $videoId ]] &&
          mpv "${MPV_OPT[@]}" "$BASE_URL/$videoId" &
        break
        ;;
      *)
        flash_message="Canal/Vídeo inválido"
        rota=selecionar_canal
        ;;
    esac
  done
}

rota=selecionar_canal
if [[ $1 ]]; then
  case $1 in
    -h|--help) _ajuda; exit 1;;
  esac
  rota=selecionar_video
  canal_url=$1
  prefix_url=(
    '?(http?(s)://)www.youtube.com/feeds/videos.xml?channel_id='
    '?(http?(s)://)www.youtube.com/channel/'
  )
  for pre in "${prefix_url}"; do
    canal_url=${canal_url#$pre}
  done
  canal_url="$BASE_FEED_XML$canal_url"
fi
main
