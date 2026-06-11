fx_version 'cerulean'
game 'gta5'

author 'Ordinary George'
description 'DUI Interactions Resource'
version '1.0.0'

lua54 'yes'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

shared_script '@ox_lib/init.lua'

files {
    'nui/blank.html',
    'nui/index.html',
    'nui/keyb.html',
    'nui/plate.html',
    'nui/style.css',
    'nui/script.js'
}

ui_page 'nui/keyb.html'
