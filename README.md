# NyatOS
A simple text based OS with its own custom Musicify integration and some other programs for Computer Craft.<br />
For the people who dont like all the kerfuffle of a complicated OS, just paste and go.

Computer 0 (first computer placed on a MC server) is designated as the NyatOS server, <br />
any subsequent computers are clients.

Server computer also functions as a client with server functions running in the background.

**Games included:**<br />
Forest Quest (Text adventure game written entirely by myself)<br />
Blackjack (Classic Blackjack by astralwuzhere, debugged and expanded by myself)<br />
Buccshot (Text based version of Buckshot Roulette written entirely by mydudesima)

<br />

**Default user logins are as follows:**

*Yo a little help here!?...* <br />
*Alright alright I got it, stand back son.. One, one, one, uhmmmuhhhhh.. ONE!*

Admin User : Admin  
Admin Pass : 1111

Guest User : Guest  
Guest Pass : $pass42

Keep in mind that the logins are case-sensitive.

Also I would highly recommend changing the admin password and username by using the OS after installing. <br />
Simply login using the default admin login, then change what you want from there.

# Installation

Installing it is super easy, just paste the command below into a fresh computer,  
wait for it to ask you to press enter, then it should reboot automatically into NyatOS.

```sh
wget run https://raw.githubusercontent.com/Catboy-Riku/NyatOS/main/installOS.lua
```

# Known Issues

At first launch the entire program on Computer 0 takes up ~860,000 bytes of the default CC:Tweaked config max 1,000,000.

This will eventually cause an out of memory error if you make too much save data and don't change the max in CC:Tweaked's config.

Similarly, when trying to install the OS more then once per load-in into your Minecraft world it will give an out of memory error.<br />
This part can be hotfixed by simply exiting to the Minecraft main menu, loading back in, and trying again.

To provide a permanant fix just add a 0 to the very first config setting of `computercraft-server.toml`:

```toml
computer_space_limit = 10000000
```

This gives each computer 10MB storage max instead of the measly 1MB.

# Credits

Musicify - knijn <br />
AES translation - zyxkad <br />
Pure lua sha2 - Egor-Skriptunoff <br />
Buccshot - mydudesima <br />
Blackjack base - astralwuzhere
