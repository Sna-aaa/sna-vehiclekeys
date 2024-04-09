fx_version 'cerulean'

game 'gta5'

description 'QB Sna VehicleKeys'

version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
	'bridge/locale.lua',
    'locales/en.lua',
	'locales/*.lua',
    'config.lua',
}

client_scripts {
    'bridge/**/client.lua',
    'prg/client.lua'
}

server_scripts {	
    '@oxmysql/lib/MySQL.lua',
	'bridge/**/server.lua',
    'prg/server.lua'
}


lua54 'yes'