#!/bin/zsh


year=`date +%Y`
month=`date +%m`
day=`date +%_d`

case $month in
    01)
        pmonth=12
        nmonth=2
        pyear=$(($year-1))
        nyear=$year
        ;;
    12)
        pmonth=11
        nmonth=1
        pyear=$year
        nyear=$(($year+1))
        ;;
    *)
        pmonth=$(($month-1))
        nmonth=$(($month+1))
        pyear=$year
        nyear=$year
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

paste -d ' ' <(cal $pmonth $pyear | format "<span color=\"$color\">" "</span>") \
      <(cal | format "" "" | sed "1!s:$day\b:<span color=\"$color2\">$day</span>:") \
      <(cal $nmonth $nyear | format "<span color=\"$color\">" "</span>") | head -n-1
echo "<span color=\"$color\">_________________________________________________________________</span>"
echo "<u>Reminders</u>"
rem | tail -n+2 | fold -s -64
echo "<u>Todo</u>"
sed -e '/^$/d' -e 's/^/• /' ~/Documents/Notes/todo.txt | fold -s -64

