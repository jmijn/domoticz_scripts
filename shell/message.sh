#!/bin/sh

# Shell script to send a text message using Telegram
#
# See https://core.telegram.org/bots#creating-a-new-bot how to create a
# Telegram bot. Fill in your token in the TOKEN variable below.
#
# Then create a group in which you add the bot, and anyone you want to
# receive the messages. Then fetch the chat_id of your group (can be tricky,
# Google "telegram get chat_id"). Then enter the CHAT_ID below.
#
# The script accepts 1 parameter, which should be the text to be sent. If your
# text contains spaces, wrap it in quotes:
# messages.sh "this is a test"
#
# (c) 2017 Johnny Mijnhout

############## EDIT THESE SETTINGS TO YOUR PERSONAL VALUES #####################

TOKEN=<your:token>
CHAT_ID=<your_chat_id>

############################# END SETTINGS #####################################

TEXT=$1
curl -s "https://api.telegram.org/bot$TOKEN/sendMessage?chat_id=$CHAT_ID&text=$TEXT" > /dev/null &
