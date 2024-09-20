#!/bin/bash

# Define the URL
URL="http://10.42.5.50/"

# Start Firefox and open the URL
firefox "$URL" &

# Wait for Firefox to launch
sleep 5

# Use xdotool to press F11 to make Firefox fullscreen
xdotool search --sync --onlyvisible --class "firefox" windowactivate key F11

# Wait for the page to load
sleep 2

# Automatically type the password if a password field is focused
xdotool type "TopSecretScreen!"
xdotool key Return

echo "Firefox started in fullscreen and password entered if prompted."