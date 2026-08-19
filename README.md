# NyatOS
A simple text based OS with its own custom Musicify integration and some other programs for Computer Craft.<br />
For the people who dont like all the kerfuffle of a complicated OS, just paste and go.<br />
<br />
Computer 0 (first computer placed on the a MC server) is designated as the NyatOS server, any subsequent computers are clients.
Server computer also functions as a client with server functions running in the background
<br />
Default user logins are as follows:<br />
<br />
*Yo a little help here!?... Alright alright I got it, stand back son.. One, one, one, uhhmmmuhhhhh one!<br />*
<br />
Admin User : Admin<br />
Admin Pass : 1111<br />
<br />
Guest User : Guest<br />
Guest Pass : $pass42<br />
<br />
<br />
Keep in mind that the logins are case-sensitive.<br />
Also I would highly recommend changing the admin password and username by using the OS after installing.<br />
Simply login using the default admin login, then change what you want from there.
<br />
# Installation
Installing it is super easy, just paste the command below into a fresh computer,<br />
wait for it to ask you to press enter, then it should reboot automatically into NyatOS.

```
wget run https://raw.githubusercontent.com/Catboy-Riku/NyatOS/main/installSecure.lua
```
<br />
# Known Issues
At first launch the entire program on Computer 0 takes up 860,160 bytes of the default CC:Tweaked config max 1,000,000.
This will eventually cause an out of memory error if you make too much save data and dont change the max in CC:Tweaked's config.
Just add a 0 to the very first config setting of computercraft-server.toml
```
computer_space_limit = 10000000
```
This gives each computer 10MB storage max instead of the measly 1MB
