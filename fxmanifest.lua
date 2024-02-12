fx_version 'adamant'

game 'gta5'

description 'Miami Rank IV'

version '1.0.0'

server_scripts {
	'config.lua',
	-- 'server/main.lua'
}

client_scripts {
	'config.lua',
	'client/main.lua'
}

ui_page 'html/ui.html'

files {
	"stream/*.ytyp",
	"stream/*.ydr",
	"stream/*.ytd",
	'html/img/weapon/*.png',
	'html/img/team/*.png',
	'html/img/*.png',
    'html/ui.html'
}

-- data_file 'DLC_ITYP_REQUEST' 'stream/mmairdrop.ytyp'
-- data_file 'DLC_ITYP_REQUEST' 'stream/mmdekpredflag.ytyp'

exports {
	'getStatusRank'
}
