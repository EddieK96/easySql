fx_version 'adamant'

game 'gta5'

description 'EasySQL'

version '0.91'

shared_scripts {
	"common.lua"
}

server_scripts {
	"@mysql-async/lib/MySQL.lua",
    "server.lua"
}

dependencies {
	'mysql-async'
}
