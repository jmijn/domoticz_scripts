-- Domoticz script to check traffic jams
--
-- This script uses Google Directions API to check the duration of travel
-- between 2 geolocations at certain times. You can set the maximum travel
-- time in minutes, if the duration is longer than this time a notification
-- will be sent.
--
-- Get a Google Directions API key here:
-- https://developers.google.com/maps/documentation/directions/
-- and click "get a key".
--
-- Fetch your geolocations for example by searching for a location on
-- https://maps.google.com
-- You will find the geolocation after the @ symbol in the url.
--
-- In Domotics create new hardware of type Dummy if you don't already
-- have it. After that, create a new virtual sensor, type = 'waarschuwing'. In
-- 'apparaten' you will find this new device. The number in the 'Idx'
-- column is your virtual_device_index.
--
-- Create a new user variable in 'gebruikers variablen'. Give it a name
-- and set type to 'integer'. The name you used is your user_variable_name.
--
-- (c) 2017 Johnny Mijnhout

------------ EDIT THESE SETTINGS TO YOUR PERSONAL VALUES ----------------------------

-- location coordinates (for example 12.3456,65.4321)
home_coordinates = "<-- your home geo location -->"
work_coordinates = "<-- your work geo location -->"

-- Google Directions API key
google_api_key = "<-- your Google Directions API key -->"

-- virtual text sensor index number
virtual_device_index = "<-- your index number -->"

-- user variable to store if a notification has been sent
user_variable_name = "<-- your user variable name -->"

-- check interval
check_internal_minutes = 15

-- hours between which you want to check
home_hour_start = 7
home_hour_end   = 9
work_hour_start = 15
work_hour_end   = 17

-- maximum travel time
max_home_work_minutes = 60
max_work_home_minutes = 60

-- location names
home_name = "huis"
work_name = "werk"

------------------------ END SETTINGS -----------------------------------------------

-- init commandArray
commandArray = {}

-- check if a message has been sent
message_sent = tonumber(uservariables[user_variable_name])

-- only run this script every x minutes on week days
day_number  = tonumber(os.date("%w"))
time_object = os.date("*t")
if time_object.min % check_internal_minutes > 0 or day_number == 0 or day_number == 6 then
  goto done
end

-- decide time of day for direction
if time_object.hour >= home_hour_start and time_object.hour <= home_hour_end then
  origin_coordinates      = home_coordinates
  destination_coordinates = work_coordinates
  destination_name        = work_name
  max_travel_minutes      = max_home_work_minutes
elseif time_object.hour >= work_hour_start and time_object.hour <= work_hour_end then
  origin_coordinates      = work_coordinates
  destination_coordinates = home_coordinates
  destination_name        = home_name
  max_travel_minutes      = max_work_home_minutes
else
  -- reset message sent to receive new messages when travelling back
  if message_sent == 1 then
    commandArray["Variable:"..user_variable_name] = "0"
  end
  goto done
end

-- import json lib
json = (loadfile "/home/pi/domoticz/scripts/lua/JSON.lua")()

-- get traffic data from Google Directions API
json_data  = assert(io.popen("curl 'https://maps.googleapis.com/maps/api/directions/json?origin="..origin_coordinates.."&destination="..destination_coordinates.."&departure_time=now&key="..google_api_key.."'"))
json_table = json_data:read("*all")
json_data:close()
gmaps      = json:decode(json_table)

-- Read from the data table
distance_km      = math.ceil(gmaps.routes[1].legs[1].distance.value/1000)
duration_minutes = math.ceil(gmaps.routes[1].legs[1].duration_in_traffic.value/60)
summary_text     = gmaps.routes[1].summary

-- calculate delay
delay_minutes    = duration_minutes - max_travel_minutes
if delay_minutes < 0 then
  delay_minutes = 0
end

-- translate summary text
summary_text = string.gsub(summary_text, "and", "en")

-- create string with travel information
travel_text = tostring(duration_minutes).." min reistijd naar "..tostring(destination_name).." ("..tostring(distance_km).." km), via "..tostring(summary_text)

-- set message to be pushed and stored
if delay_minutes > 0 then
  message = "FILE! "..travel_text
  -- if no message has been sent, send out the notification
  if message_sent == 0 then
    commandArray["SendNotification"] = message
    commandArray["Variable:"..user_variable_name] = "1"
  end
  -- set alert status
  if delay_minutes > 30 then
      alert_status = 4
  elseif delay_minutes > 15 then
      alert_status = 3
  elseif delay_minutes > 0 then
      alert_status = 2
  end
else
  message = "Weg is vrij, "..travel_text
  -- if a message has been sent, send a new one that traffic has cleared
  if message_sent == 1 then
    commandArray["SendNotification"] = message
    commandArray["Variable:"..user_variable_name] = "0"
  end
  --reset alert status
  alert_status = 1
end
-- append time to message
message = message.." (update "..tostring(os.date("%H:%M"))..")"

-- update virtual device alert + counter
commandArray['UpdateDevice'] = virtual_device_index.."|"..alert_status.."|"..tostring(message)

::done::
return commandArray
