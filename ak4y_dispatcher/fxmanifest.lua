fx_version 'cerulean'
games { 'gta5' }

lua54 'yes'

author 'Copilot'
description 'AK4Y Dispatcher ESX'
version '1.0.0'

shared_script 'config.lua'

server_script 'server/main.lua'
client_script 'client/main.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}
