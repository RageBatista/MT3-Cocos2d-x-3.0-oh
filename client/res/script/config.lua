-----===========================================------
-- lua配置文件
-----===========================================------
Config = {}



-----===========================================------
--是否接入第三方
Config.TRD_PLATFORM = 0 --MT3.ChannelManager:IsTrdPlatform()
--第三方平台名称
Config.CUR_3RD_PLATFORM = "" --MT3.ChannelManager:GetCur3rdPlatform()
--第三方帐号后缀
Config.CUR_3RD_LOGIN_SUFFIX = "" --MT3.ChannelManager:GetPlatformLoginSuffix()
-----===========================================------
--是否为Android
Config.MOBILE_ANDROID = MT3.ChannelManager:IsAndroid()

--免费
Config.PlatformIOS = "108800100"

--点卡
Config.PlatformPointIOS = "108800101"

Config.PlatformOfLocojoy = {
    "208800000",
    "208890201","208890202","208890203","208890204","208890205",
    "208890206","208890207","208890208","208890209","208890210",
    "208890211","208890212","208890213","208890214","208890215",
    "208890216","208890217","208890218","208890219","208890220",
    "208890221","208890222","208890223","208890224","208890225",
    "208890226","208890227","208890228","208890229","208890230",
    "208890231","208890232","208890233","208890234","208890235",
    "208890236","208890237","208890238","208890239","208890240",
    "208890241","208890242","208890243","208890244","208890245",
    "208890246","208890247","208890248","208890249","208890250",
}

Config.PlatformOfYingYongBao = {"208804000","208804001","208804002","208804003","208804004","208804005"} --yingyongbao
Config.PlatformOfLenovo = "208800900"  --lenovo
Config.PlatformOfCoolPad = "208802900"  --coolpad

Config.PlatformOfRongHe = "208800401"  --360融合

Config.androidNotifyAll = false
function Config.isKoreanAndroid()
    if Config.CUR_3RD_LOGIN_SUFFIX == "krgp" or Config.CUR_3RD_LOGIN_SUFFIX == "krts" or Config.CUR_3RD_LOGIN_SUFFIX == "krnv" or Config.CUR_3RD_LOGIN_SUFFIX == "krlg" then
        return true
    else
        return false
    end
end

function Config.isTaiWan()
    if Config.CUR_3RD_LOGIN_SUFFIX == "efis" 
    	or Config.CUR_3RD_LOGIN_SUFFIX == "efad" 
    	or Config.CUR_3RD_LOGIN_SUFFIX == "lngz" 
    	or Config.CUR_3RD_LOGIN_SUFFIX == "tw36"
    	or Config.CUR_3RD_LOGIN_SUFFIX == "twap" then
        return true
    else
        return false
    end
end
function Config.setCur3rdPlatform(str)
    Config.CUR_3RD_PLATFORM  = str
end

function Config.IsLocojoy()
    for _,id in pairs(Config.PlatformOfLocojoy) do
        if gGetChannelName() == id then
            return true
        end
    end
    return false
end

function Config.IsYingYongBao()
    for _,id in pairs(Config.PlatformOfYingYongBao) do
        if gGetChannelName() == id then
            return true
        end
    end
    return false
end

function Config_IsRongHe()
    if gGetChannelName() == Config.PlatformOfRongHe then
        return true
    end
    return false
end

function Config_IsLocojoy()
	return Config.IsLocojoy()
end

function Config.GetGameName(servertype)
    local gameName
    if servertype ~= nil then
        if servertype == "0" then
            gameName = GameTable.common.GetCCommonTableInstance():getRecorder(426).value
        else
            gameName = BeanConfigManager.getInstance():GetTableByName("fushi.ccommondaypay"):getRecorder(426).value
        end
    else
         if  IsPointCardServer() then
            gameName = BeanConfigManager.getInstance():GetTableByName("fushi.ccommondaypay"):getRecorder(426).value
        else
            gameName = GameTable.common.GetCCommonTableInstance():getRecorder(426).value
        end
    end
    return gameName
end

function Config.IsWinApp()
    return Config.CUR_3RD_PLATFORM == "winapp"
end

--在登陆前，通过读取配置文件判断是不是点卡服
function Config.IsPointCardServerBeforeLogin()
    local inifile = gGetGameApplication():GetIniFileName()
    local isPoint = IniFile:read_profile_int("ClientSetting", "bIsPointVersion", 1, inifile);
    if isPoint > 0 then
        return true
    end
    return false
end

return Config
