fx_version 'cerulean'
game 'gta5'

author 'Pingu'
description 'Cokerun script'
version '1.0.0'
lua54 'yes'

client_scripts {
    'client/client.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config/cl_config.lua'
}

server_scripts {
    'server/server.lua',
    'config/sv_config.lua'
}

files {
    'locales/*.json'
}