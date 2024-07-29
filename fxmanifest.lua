fx_version "cerulean"
game "gta5"

author "Abyss | Nexus Development"
description "Container Run"
version "1.0.0"
lua54 "yes"

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua'
}

files {
    'locales/*.json'
  }

dependencies {
    'ox_lib'
}

use_experimental_fxv2_oal "yes"
