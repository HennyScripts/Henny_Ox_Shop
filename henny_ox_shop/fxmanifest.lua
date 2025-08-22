fx_version 'cerulean'
game 'gta5'

author 'Henny Development Team'
description 'A modern, standalone shop system for FiveM with ox_inventory integration.'
version '1.0.0'

shared_script '@ox_lib/init.lua'


shared_script 'config.lua'

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/styles.css',
    'html/script.js'

}

lua54 'yes'
