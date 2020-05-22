name = "让姐妹骨灰罐保鲜！Keeping fresh!"
description = "厌倦了在姐妹骨灰罐里的花枯萎？打开这个MOD将会让你不再烦恼这件事。\n Tired of withered flowers in sisturn? Opening this mod will keep you from worrying about it."
author = "BCI_Chen"
version = "1.3.5"
forumthread = ""
dst_compatible = true
don_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = true
api_version = 10
icon_atlas = "modicon.xml"
icon = "modicon.tex"
server_filter_tags = {""}
priority = -9999	--设置优先级

configuration_options = 
{
    {
        name = "Val",
        label = "反鲜？refreshes？",
        hover = "需要反鲜？Need to return fresh？",  
        options = 
        {
		    {description = "需要/Yes(default)", data = true},
            {description = "不要/No", data = false},
        },
        default = false,
    },
	{
        name = "evliGarden",
        label = "花园？garden？",
        hover = "需要花园？Need garden?",  
        options = 
        {
		    {description = "需要/Yes(default)", data = true},
            {description = "不要/No", data = false},
        },
        default = true,
    },
	{
        name = "Difficulty",
        label = "难度？Difficulty",
        hover = "是否需要暗影之心？Need shadowheart?",  
        options = 
        {
		    {description = "需要/Yes(default)", data = true},
            {description = "不要/No", data = false},
        },
        default = true,
    },

}