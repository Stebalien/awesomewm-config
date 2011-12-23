#!/bin/zsh

coproc awesome-client || exit 0

event=$1

set_status() {
    print -p "pianobar.set(\"${(q)1}\", \"${(q)2}\")"
}

while read line; do
    local key="${line%%\=*}"
    local value="${line##*\=}"
    case $key in
        artist)
            set_status "artist" "$value"
            ;;
        title)
            set_status "title" "$value"
            ;;
        album)
            set_status "album" "$value"
            ;;
    esac
done
            
case $1 in
    songstart|songcontinue)
        print -p "pianobar.setPlaying(true)"
        ;;
    songfinish|songpause)
        print -p "pianobar.setPlaying(false)"
        ;;
esac

print -p "pianobar.fireUpdate()"

