fx_version 'cerulean'
game 'gta5'

author "SwisserAI"
description "Generated with SwisserAI - https://ai.swisser.dev | qbx_adminmenu"
repository "https://github.com/Qbox-project/qbx_adminmenu"
version '0.1.3'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'shared/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

client_scripts {
    'client/*.lua',
}

ui_page "html/ui.html"

files {
    "locales/*.json",
    "html/ui.html",
    "html/style.css",
    "html/js/*.js",
    "html/tailwind.css",
    "html/fonts/*.woff2",
    "html/fonts.css"
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
