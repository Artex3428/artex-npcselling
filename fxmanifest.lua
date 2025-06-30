fx_version 'cerulean'
games { 'gta5' }

author 'Artex <https://artex3428.xyz>'
description 'This is a npc selling script'
version '1.0.0'

lua54 "yes"

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
}

client_scripts {
    'config.lua',
    'client/client.lua',
}

server_scripts {
    'config.lua',
    'server/server.lua',
}
