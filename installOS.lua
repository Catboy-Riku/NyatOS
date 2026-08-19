shell.run("wget https://raw.githubusercontent.com/Catboy-Riku/NyatOS/refs/heads/main/startup startup")
sleep(1)

shell.run("wget https://gist.githubusercontent.com/zyxkad/a5e02d16d244b20b026ecfb06f662210/raw/aes.lua aes.lua")
sleep(1)

shell.run("wget https://raw.githubusercontent.com/Egor-Skriptunoff/pure_lua_SHA/master/sha2.lua sha2.lua")
sleep(1)

shell.run("wget https://raw.githubusercontent.com/Catboy-Riku/NyatOS/main/nyatos_crypto.lua nyatos_crypto.lua")
sleep(1)

shell.run("wget https://raw.githubusercontent.com/simadude/buccshot/refs/heads/main/buccshot.lua buccshot.lua")
sleep(1)

fs.makeDir("music")

shell.run("wget run https://raw.githubusercontent.com/knijn/musicify/main/install.lua")
sleep(1)

shell.run("wget https://raw.githubusercontent.com/Catboy-Riku/NyatOS/main/music/Forest%20Interlude.dfpwm music/Forest%20Interlude.dfpwm")
sleep(1)

shell.run("set musicify.repo https://raw.githubusercontent.com/Catboy-Riku/NyatOS/main/index.json")
sleep(3)

shell.run("reboot")
