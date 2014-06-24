# README #

Tool to (re-)start an rFactor2 server at a specified date and time.

For example this allows you to run your public server similiar to iRacing, where a race session would start every full hour (every 2h, 3h, etc.)

![GUI screenshot](http://i.imgur.com/cSKTcJS.jpg)

### Usage ###

Set a start date and start time: This is when the server will be restarted for the first time.

Then set a restart time: The server will be restarted every x hours y minutes after the start time or last restart.

Then select the rF2 server window to control by clicking on it.

If you want to run your server on autopilot, make sure to disable session voting.
Also make sure that the restart time is not too close to the end of a race, as there is always some delay between switching sessions. A safe value should be *15-20min*.

Oh, and of course mention when a race takes places in your server name, like: 

*ServerX.com - Race session every full hour*

### Prerequisites ###

* Use AutoHotKey to compile.