fx_version 'cerulean'
game 'gta5'

author 'Manason'
description 'API for playing native audio'
version '1.1.1'

shared_scripts {
    '@ox_lib/init.lua',
}

server_scripts {
	'server/*'
}

client_scripts {
	'client/*'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'