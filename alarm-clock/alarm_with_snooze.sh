#!/bin/bash

# Variables
SNOOZE_TIME=1  
FINAL_SNOOZE_SOUND="final_snooze.mp3"  
REGULAR_ALARM_SOUND="alarm_sound.mp3"  
MAX_SNOOZES=3  



play_sound() {
    local sound_file=$1
    if command -v mpg123 >/dev/null 2>&1; then
        mpg123 -q "$sound_file"
    else
        echo " Beep Beep Beep!"
        for i in {1..5}; do
            echo -en "\a"
            sleep 1
        done
    fi
}


vocalize_time() {
    local current_time
    current_time=$(date +"%I:%M %p")
    if command -v espeak >/dev/null 2>&1; then
        espeak "The time is now $current_time"
    else
        echo "The time is now $current_time"
    fi
}


snooze_alarm() {
    local snooze_count=0

    while [ $snooze_count -lt $MAX_SNOOZES ]; do
        read -p "Do you want to snooze the alarm? (yes/no): " response
        if [[ $response == "yes" || $response == "y" ]]; then
            snooze_count=$((snooze_count + 1))
            echo "Snooze #$snooze_count/$MAX_SNOOZES"
            echo "Snoozing for $SNOOZE_TIME minutes..."
            sleep $((SNOOZE_TIME * 60))

            if [ $snooze_count -eq $((MAX_SNOOZES - 1)) ]; then
                play_sound "$FINAL_SNOOZE_SOUND"
            else
                play_sound "$REGULAR_ALARM_SOUND"
            fi
        else
            echo "Alarm dismissed."
            vocalize_time
            exit 0
        fi
    done

    echo "Maximum number of snoozes reached. Alarm dismissed."
    vocalize_time
}

#USEAGE
if [ -z "$1" ]; then
    echo "Input alarm time as argument in HH:MM format. "
    exit 1
fi

alarm_time=$1

current_time=$(date +%s)
alarm_seconds=$(date -d "$alarm_time" +%s)

time_diff=$((alarm_seconds - current_time))

if [ $time_diff -lt 0 ]; then
    time_diff=$((time_diff + 86400)) 
fi

echo "Alarm set for $alarm_time."
sleep $time_diff

play_sound "$REGULAR_ALARM_SOUND"
snooze_alarm
