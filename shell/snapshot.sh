#!/bin/sh

# Shell script to send photos using Telegram
#
# See https://core.telegram.org/bots#creating-a-new-bot how to create a
# Telegram bot. Fill in your token in the TOKEN variable below.
#
# Then create a group in which you add the bot, and anyone you want to
# receive the messages. Then fetch the chat_id of your group (can be tricky,
# Google "telegram get chat_id"). Then enter the CHAT_ID below.
#
# (c) 2017 Johnny Mijnhout

############## EDIT THESE SETTINGS TO YOUR PERSONAL VALUES #####################

TOKEN=<your:token>
CHAT_ID=<your_chat_id>

############################# END SETTINGS #####################################

ROOT_DIR='/home/pi/Pictures/webcams'
DATE=`date +%Y%m%d`
TIME=`date +%H%M%S`
HOUR=`date +%H`
TEXT=$1
START_HOUR=$2
END_HOUR=$3

if [ ! -z "$START_HOUR" ] && [ ! -z "$END_HOUR" ]; then
	if [ "$START_HOUR" -lt "$END_HOUR" ]; then
		if [ "$HOUR" -lt "$START_HOUR" ] || [ "$HOUR" -gt "$END_HOUR" ]; then
			exit 0
		fi
	else
		if [ "$HOUR" -lt "$START_HOUR" ] && [ "$HOUR" -gt "$END_HOUR" ]; then
			exit 0
		fi
	fi
fi

if [ -z "$TEXT" ]; then
        TEXT="Activiteit op $DATE om $TIME"
fi

curl -s "https://api.telegram.org/bot$TOKEN/sendMessage?chat_id=$CHAT_ID&text=$TEXT" > /dev/null &

umask 000
mkdir -p $ROOT_DIR/$DATE

(avconv -rtsp_transport tcp -i 'rtsp://192.168.0.112:554/user=admin&password=&channel=1&stream=0.sdp?real_stream--rtp-caching=100' -f image2 -vframes 1 -pix_fmt yuvj420p $ROOT_DIR/$DATE/$TIME.garage.jpg > /dev/null 2>&1 &&
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendPhoto" -F chat_id="$CHAT_ID" -F caption="$TEXT" -F photo="@$ROOT_DIR/$DATE/$TIME.garage.jpg" > /dev/null) &

(avconv -rtsp_transport tcp -i 'rtsp://192.168.0.113:554/user=admin&password=&channel=1&stream=0.sdp?real_stream--rtp-caching=100' -f image2 -vframes 1 -pix_fmt yuvj420p $ROOT_DIR/$DATE/$TIME.voortuin.jpg > /dev/null 2>&1 &&
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendPhoto" -F chat_id="$CHAT_ID" -F caption="$TEXT" -F photo="@$ROOT_DIR/$DATE/$TIME.voortuin.jpg" > /dev/null) &

exit 0
