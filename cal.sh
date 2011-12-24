#!/bin/zsh


year=`date +%y`
month=`date +%m`
day=`date +%_d`

case $month in
    1)
        pmonth=12
        nmonth=2
        ;;
    12)
        pmonth=11
        nmonth=1
        ;;
    *)
        pmonth=$(($month-1))
        nmonth=$(($month+1))
        ;;
esac

color="#666666"
color2="#336ec0"

format() {
    IFS="\n"
    while read line; do
        printf '%s%-21s%s\n' "$1" "$line" "$2"
    done
}

paste -d ' ' <(cal $pmonth $year | format "<span color=\"$color\">" "</span>") \
      <(cal | format "" "" | sed "1!s:$day\b:<span color=\"$color2\">$day</span>:") \
      <(cal $nmonth $year | format "<span color=\"$color\">" "</span>") | head -n-1
echo "<span color=\"$color\">_________________________________________________________________</span>"
rem | tail -n+2 | fold -s -64
