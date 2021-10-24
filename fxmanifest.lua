fx_version 'adamant'

game 'gta5'

description 'advsql'

version '0.9'

server_scripts {
	"@mysql-async/lib/MySQL.lua",
    "server.lua"
}

dependencies {
	'mysql-async'
}
