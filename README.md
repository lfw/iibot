
## iibot

A simple and expandable bot created in bash based on [ii] by [suckless].

#### featuring:

 * Simple Command Editing - `commands.sh` can be modified to add new commands. Anything that goes to STDOUT will be sent to the channel. 
 * Keyword Identification - `chatter.sh` is passed all messages that are not a chanserv message or a user command. Use this to add your snarky comments.
 * ChanServ Message Processing - `chanserv.sh` recieves all chanserv message. The default config uses this to keep track of oped and voiced users.
 * Hot Editing of script files - Since these 3 scripts are executed on request, you can edit them at any time.
 * Simple Testing - You can run the above 3 scripts from the command line to test there functionality before putting them into use.
 * Auto Reconnect - ii bot will automaticly reconnect and rejoin its default channels if the connection is lost.
 * Channel Logging - All chanels are logged to a user defined file
 * Simple Configuration - /config holds all settings needed to start up iibot.
 * Basic user authorization - By default, iibot uses voice and op status to set user authorization levels.


#### Example configuration file

HOST=irc.freenode.net  
NICK=mybot  
PORT=6667  
NICK_IDENT="account password"  
CHANS[0]=#mychannel  

FS=${SCRIPT_DIR}/fs  
PIDFILE=${SCRIPT_DIR}/ii_${HOST}.pid  
LOG=${SCRIPT_DIR}/log  
