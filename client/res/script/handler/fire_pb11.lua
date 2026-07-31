local gLastServerTime = 0

local sanswerroleteamstate = require "protodef.fire.pb.sanswerroleteamstate"
function sanswerroleteamstate:process()
    LogInfo("enter sanswerroleteamstate process")
    require "logic.contactroledlg"
    ContactRoleDialog.RefreshRoleTeamState(self.roleid, self.teamstate)
    require "logic.family.familycaidan".RefreshTeamState(self.roleid, self.teamstate)
end
local ssendqueueinfo = require "protodef.fire.pb.ssendqueueinfo"
function ssendqueueinfo:process()
    require "logic.loginwaitingdialog"
    LogInfo("enter ssendqueueinfo process")
    if gGetScene() then
        --如果在游戏中断线重连时要求排队则退回到登陆
        gGetGameApplication():ExitGame(eExitType_ToLogin)
    else
        --CLoginWaitingDialog:OnExit()
        LoginWaitingDialog.DestroyDialog()
        local dlg = require "logic.loginqueuedialog"
        dlg.getInstance():RefreshInfo(self.order, self.queuelength, self.minutes)
    end
end

local ssendslowqueueinfo = require "protodef.fire.pb.ssendslowqueueinfo"
function ssendslowqueueinfo:process()
    require "logic.loginwaitingdialog"
    LogInfo("enter ssendslowqueueinfo process")
    if gGetScene() then
        --如果在游戏中断线重连时要求排队则退回到登陆
        gGetGameApplication():ExitGame(eExitType_ToLogin)
    else
        --CLoginWaitingDialog:OnExit()
        LoginWaitingDialog.DestroyDialog();
        local dlg = require "logic.loginqueuedialog"
        dlg.getInstance():RefreshInfo1(self.order, self.queuelength, self.second)
    end
end

local ssendservermultiexp = require "protodef.fire.pb.ssendservermultiexp"
function ssendservermultiexp:process()
    LogInfo("____ssendservermultiexp:process: expcount: " .. self.addvalue)

    if self.addvalue == 0 then

    elseif self.addvalue == 2 then

    end
end

local sgacdkickoutmsg1 = require "protodef.fire.pb.sgacdkickoutmsg1"
function sgacdkickoutmsg1:process()
    LogInfo("sgacdkickoutmsg1 process")
    if gGetGameUIManager() then
        GetCTipsManager():AddMessageTipById(162163) --此账号已被服务器禁止登录，请联系客服。
    end
end

local kickoutmsg = require("protodef.fire.pb.sgacdkickoutmsg")
function kickoutmsg:process()
    --如果出现异常没有收到ErrorInfo会停留在登陆等待界面，这里直接返回登陆界面
    gGetGameApplication():ExitGame(eExitType_ToLogin)

    if gGetGameUIManager() then
        local reasonIndex = tonumber(self.reason)
        if reasonIndex > 6 then
            reasonIndex = 6
        end
        local serverTime = gGetServerTime()
        local time = StringCover.getTimeStruct(self.endtime / 1000)
        local year = time.tm_year + 1900
        local month = time.tm_mon + 1
        local day = time.tm_mday
        local hour = time.tm_hour
        local minute = time.tm_min
        local second = time.tm_sec
        local strTime = string.format("%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second)

        local sb = StringBuilder:new()
        sb:Set("parameter1", MHSD_UTILS.get_resstring(11584 + (reasonIndex - 1)))
        sb:Set("parameter2", strTime)
        local strMsg = sb:GetString(MHSD_UTILS.get_msgtipstring(143740))
        sb:delete()

        gGetMessageManager():AddConfirmBox(eConfirmOK, strMsg,
                MessageManager.HandleDefaultCancelEvent, MessageManager,
                MessageManager.HandleDefaultCancelEvent, MessageManager)
    end
end

local p = require "protodef.fire.pb.srecommendsnames"
function p:process()
    if require "logic.createroledialog":getInstanceOrNot() then
        --141316	这个名字已经有人用过了，请重新取名。
        GetCTipsManager():AddMessageTip(
                GameTable.message.GetCMessageTipTableInstance():getRecorder(141316).msg, false)
    end
end

p = require "protodef.fire.pb.sgivename"
function p:process()
    local dlg = require "logic.createroledialog":getInstanceOrNot()
    if dlg then
        dlg:GiveName(self.rolename)
    end
end

local p = require "protodef.fire.pb.steamvote"
function p:process()
    local strbuilder = StringBuilder:new()
    strbuilder:Set("parameter1", self.parms[1])
    strbuilder:Set("parameter2", self.parms[2])
    local msg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(145773))
    strbuilder:delete()

    local function ClickYes(self, args)
        gGetMessageManager():CloseCurrentShowMessageBox()
        local req = require "protodef.fire.pb.cteamvoteagree".Create()
        req.result = 0
        LuaProtocolManager.getInstance():send(req)
    end

    local function ClickNo(self, args)
        if CEGUI.toWindowEventArgs(args).handled ~= 1 then
            gGetMessageManager():CloseCurrentShowMessageBox()
        end
        local req = require "protodef.fire.pb.cteamvoteagree".Create()
        req.result = 1
        LuaProtocolManager.getInstance():send(req)
    end

    gGetMessageManager():AddMessageBox("", msg, ClickYes, self, ClickNo, self, eMsgType_Normal, 10000, 0, 0, nil, MHSD_UTILS.get_resstring(996), MHSD_UTILS.get_resstring(997))
end

local p = require "protodef.fire.pb.sserveridresponse"
function p:process()
    -- Set ServerID to android.lua
    local LuaAndroid = require "android"
    LuaAndroid.serverid = self.serverid

    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "ysuc" then
        require "luaj"
        local tempTable = {}
        tempTable[1] = tostring(gGetDataManager():GetMainCharacterID())
        tempTable[2] = gGetDataManager():GetMainCharacterName()
        tempTable[3] = tostring(gGetDataManager():GetMainCharacterLevel())
        tempTable[4] = tostring(self.serverid)
        tempTable[5] = gGetLoginManager():GetSelectArea() .. "-" .. gGetLoginManager():GetSelectServer()
        luaj.callStaticMethod("com.locojoy.mini.mt3.uc.UcPlatform", "submitExtendDataWhenLogined", tempTable, nil)
    elseif Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "kuwo" then
        require "luaj"
        local param = {}
        param[1] = tostring(self.serverid)
        luaj.callStaticMethod("com.locojoy.mini.mt3.kuwo.PlatformKuwo", "setServerId", param, "(I)V")
    elseif Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "lngz" then
        require "luaj"
        local param = {}
        param[1] = tostring(self.serverid)
        luaj.callStaticMethod("com.locojoy.mini.mt3.longzhong.PlatformLongZhong", "setserverid", param, "(Ljava/lang/String)V")
    elseif Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "efad" then
        require "luaj"
        local param = {}
        param[1] = tostring(gGetDataManager():GetMainCharacterID())
        param[2] = tostring(self.serverid)
        luaj.callStaticMethod("com.locojoy.mini.mt3.efun.PlatformEFun", "ShowFlowButton", param, nil)
    elseif Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "thlm" then
        require "luaj"
        local param = {}
        param[1] = tostring(self.serverid)
        param[2] = tostring(gGetDataManager():GetMainCharacterID())
        luaj.callStaticMethod("pet.saga.hero.th.PlatformLemon", "showFlow", param, nil)
    elseif Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_PLATFORM == "this" then
        MT3.ChannelManager:CommonInterface(1, self.serverid)
    end

end

local p = require "protodef.fire.pb.sreqhelpcountview"
function p:process()
    local data = {}
    data.expvalue = self.expvalue
    data.expvaluemax = self.expvaluemax
    data.shengwangvalue = self.shengwangvalue
    data.shengwangvaluemax = self.shengwangvaluemax
    data.factionvalue = self.factionvalue
    data.factionvaluemax = self.factionvaluemax

    data.helpgiveitemnum = self.helpgiveitemnum
    data.helpgiveitemnummax = self.helpgiveitemnummax
    data.helpitemnum = self.helpitemnum
    data.helpitemnummax = self.helpitemnummax

    local dlg = require "logic.characterinfo.supportcountdlg"
    dlg.getInstanceAndShow():refreshData(data)
end

local p = require "protodef.fire.pb.sreqpointschemetime"
function p:process()
    local dlg = require "logic.characterinfo.characterpropertyaddptrdlg".getInstanceNotCreate()
    if dlg then
        dlg.schemeChangeTime = self.schemetimes
        dlg:OpenScheme()
    end
end

local sstartplaycg = require "protodef.fire.pb.sstartplaycg"
function sstartplaycg:process()
    if not gGetSceneMovieManager() then
        return
    end
    gGetSceneMovieManager():EnterMovieScene(self.id)
end

local sshowedbeginnertips = require "protodef.fire.pb.sshowedbeginnertips"
function sshowedbeginnertips:process()
    for k, nGuideId in pairs(self.tipid) do
        NewRoleGuideManager.getInstance():SetGuideStateId(k, true)
    end
    NewRoleGuideManager.getInstance():setReceiveGuideList(true)
    NewRoleGuideManager.getInstance():UnLockBtn()
    NewRoleGuideManager.getInstance():SetFinshProcess(true)
    NewRoleGuideManager.getInstance():setGuideModel(self.pilottype)
    if gGetGameApplication():isFirstTimeEnterGame() == 10 and self.pilottype == 2 and GetMainCharacter():GetLevel() == 1 then
        guideModelSelectDlg.getInstanceAndShow()
    end
end

local serror = require "protodef.fire.pb.serror"
function serror:process()
    if not gGetGameUIManager() then
        return
    end
    local ErrorCodes = require("protodef.rpcgen.fire.pb.errorcodes"):new()
    local nTipId = 0
    if self.error == ErrorCodes.AddItemToBagException then
        nTipId = 100001
    elseif self.error == ErrorCodes.NotEnoughMoney then
        nTipId = 100003
    elseif self.error == ErrorCodes.EquipPosNotSuit then
        nTipId = 100068
    elseif self.error == ErrorCodes.EquipLevelNotSuit then
        nTipId = 100065
    elseif self.error == ErrorCodes.EquipSexNotSuit then
        nTipId = 100066
    else
    end
    local strTip = require("utils.mhsdutils").get_msgtipstring(nTipId)
    GetCTipsManager():AddMessageTip(strTip)

end

local srefsmoney = require "protodef.fire.pb.srefsmoney"
function srefsmoney:process()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    roleItemManager:SetReserveMoney(self.smoney)
end

local sgametime = require "protodef.fire.pb.sgametime"
function sgametime:process()
    if not gGetGameApplication() then
        return
    end
    if gLastServerTime ~= 0 then
        --不是第一次发送数据  检查数据是否正确
        if self.servertime - gLastServerTime < -3600000 or self.servertime - gLastServerTime > 3600000 then
            LogErr('[LUA ERROR] protodef.fire.pb.sgametime: ' .. self.servertime)
            return
        end
    end
    gLastServerTime = gLastServerTime
    gGetGameApplication():SetTime(self.servertime)
end

local snotifyshieldstate = require "protodef.fire.pb.snotifyshieldstate"
function snotifyshieldstate:process()

end

--重置系统设置返回
local sresetsysconfig = require "protodef.fire.pb.sresetsysconfig"
function sresetsysconfig:process()
    local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()

    -- 系统设置的处理相关（只需要修改循环的范围即可）
    for k = SettingEnum.Music, SettingEnum.refuseotherseeequip do
        local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(k)
        if self.sysconfigmap[k] ~= nil then
            gGetGameConfigManager():SetConfigValue(record.key, self.sysconfigmap[k])
        end
    end

    gGetGameConfigManager():ApplyConfig()
    gGetGameConfigManager():SaveConfig()
end

local sgeturl = require("protodef.fire.pb.sgeturl")
function sgeturl:process()
    local url = self.md5
    IOS_MHSD_UTILS.OpenURL(url)
end

local screateroleerror = require "protodef.fire.pb.screateroleerror"
function screateroleerror:process()

    if not gGetGameUIManager() then
        return
    end
    local nTipId = 0
    if self.err == self.CREATE_OVERLEN then
        nTipId = 140403
    elseif self.err == self.CREATE_INVALID then
        nTipId = 140403
    elseif self.err == self.CREATE_DUPLICATED then
        nTipId = 140404
    elseif self.err == self.CREATE_SHORTLEN then
        nTipId = 140403
    elseif self.err == self.CREATE_CREATE_GM_FORBID then
        nTipId = 190065
    else
        nTipId = self.err
    end

    local strTip = GameTable.message.GetCMessageTipTableInstance():getRecorder(nTipId).msg
    GetCTipsManager():AddMessageTip(strTip, false)

    local dlg = require "logic.createroledialog":getInstanceOrNot()
    if dlg then
        dlg:setBtnStartState(false)
    end
end

local sreturnlogin = require "protodef.fire.pb.sreturnlogin"
function sreturnlogin:process()
    SimpleAudioEngine:sharedEngine():resumeBackgroundMusic()
    if GetCTipsManager() then
        GetCTipsManager():clearMessages()
    end
    if gGetGameApplication() then
        gGetGameApplication():ExitGame(eExitType_ToLogin)
    end
    TableDataManager:instance():releaseAllTable()

    if self.reason == 1 then
        local function ClickYes(args)
            gGetMessageManager():CloseConfirmBox(eConfirmOK, false)
        end
        gGetMessageManager():AddConfirmBox(eConfirmOK, MHSD_UTILS.get_msgtipstring(162174), ClickYes, 0,
                ClickYes, 0)
    elseif self.reason == 2 then
        local function ClickYes(args)
            gGetMessageManager():CloseConfirmBox(eConfirmOK, false)
        end
        gGetMessageManager():AddConfirmBox(eConfirmOK, MHSD_UTILS.get_msgtipstring(162189), ClickYes, 0,
                ClickYes, 0)
    end
    --    --应用宝平台下switchAccount
    --    if MT3.ChannelManager:IsAndroid() == 1 then
    --         if gGetChannelName() == Config.PlatformOfYingYongBao then
    --                gGetLoginManager():LoginAgain()
    --                local dlg = require("logic.selectserverentry").getInstanceAndShow()
    --                if dlg then
    --                    dlg:SetYingyongBaoVisible(true)
    --                    dlg:SetEnterGameVisible(false)
    --                end
    --            return
    --         end
    --    end

end

local srefreshhp = require "protodef.fire.pb.srefreshhp"
function srefreshhp:process()
    if not gGetDataManager() then
        return
    end
    if not GetBattleManager() then
        return
    end
    gGetDataManager():RefreshRoleHp(self.hp)
end

local srefreshuserexp = require "protodef.fire.pb.srefreshuserexp"
function srefreshuserexp:process()
    if not gGetDataManager() then
        return
    end
    gGetDataManager():RefreshCurExp(self.curexp)
end
local sserverlevel = require "protodef.fire.pb.sserverlevel"
function sserverlevel:process()
    if not gGetDataManager() then
        return
    end
    gGetDataManager():setServerLevel(self.slevel)
    gGetDataManager():setServerLevelDays(self.newleveldays)
    local dlg = require "logic.petandusericon.userandpeticon".getInstanceNotCreate()
    if dlg then
        dlg:updateServerLevel()
    end
end
local screaterole = require "protodef.fire.pb.screaterole"
function screaterole:process(args)
    local cgeturl = require("protodef.fire.pb.cgeturl"):new()
    LuaProtocolManager:send(cgeturl)
    -- 安卓
    if Config.MOBILE_ANDROID == 1 then
        gGetGameUIManager():setLoginProgress(true)
    end
    if gGetLoginManager() == nil then
        return
    end
    gGetGameApplication():SetWaitForEnterWorldState(true)
    gGetGameApplication():DrawLoginBar(20)
    tolua.cast(Nuclear.GetEngine(), "Nuclear::Engine"):Draw()

    local roleInfo = fire.pb.RoleInfo()
    roleInfo.components = std.map_char_int_()
    roleInfo.roleid = self.newinfo.roleid
    roleInfo.rolename = self.newinfo.rolename
    roleInfo.school = self.newinfo.school
    roleInfo.shape = self.newinfo.shape
    roleInfo.level = self.newinfo.level
    SetRoleCreatTime(self.newinfo.rolecreatetime)
    for k, v in pairs(self.newinfo.components) do
        roleInfo.components[k] = v
    end
    gGetLoginManager():GetRoleList():push_back(roleInfo)
    gGetLoginManager():SetPreLoginRoleID(self.newinfo.roleid)
    local dlg = require "logic.createroledialog":getInstanceOrNot()
    if dlg then
        dlg:DestroyDialog()
    end

    dlg = require "logic.selectroledlg":getInstanceNotCreate()
    if dlg then
        dlg:DestroyDialog()
    end
    SelectServerEntry.DestroyDialog()
    gGetGameApplication():BeginDrawServantIntro()

    if MT3.ChannelManager:IsAndroid() ~= 1 then
        gGetGameApplication():gCallChartBoost()
    end

    if gGetGameApplication():GetXmlBeanReady() then
        gGetGameApplication():DrawLoginBar(20)
        tolua.cast(Nuclear.GetEngine(), "Nuclear::Engine"):Draw()
        local numMaxShowNum = SystemSettingNewDlg.GetMaxDisplayPlayerNum()
        gGetNetConnection():send(fire.pb.CEnterWorld(gGetLoginManager():GetPreLoginRoleID(), numMaxShowNum))
    else
        gGetGameApplication():DrawLoginBar(10)
        tolua.cast(Nuclear.GetEngine(), "Nuclear::Engine"):Draw()
        gGetGameApplication():SetWaitToEnterWorld(true)
        gGetGameApplication():SetEnterWorldRoleID(gGetLoginManager():GetPreLoginRoleID())
    end
    core.Logger:flurryEvent("create_role")
    if MT3.ChannelManager:isDefineSDK() == true then
        MT3.ChannelManager:onRegister_sta(tostring(self.newinfo.roleid), self.newinfo.rolename)
    end
end

local srsproleinfo = require "protodef.fire.pb.srsproleinfo"
function srsproleinfo:process()
    local role_hp_buffid = 500009
    local role_mp_buffid = 500010
    local pet_hp_buffid = 500138
    local pet_mp_buffid = 500139
    local pet_loy_buffid = 500140

    if self.hpmpstore[role_hp_buffid] ~= nil then
        gGetDataManager():setHPMPStore(role_hp_buffid, self.hpmpstore[role_hp_buffid])
    end
    if self.hpmpstore[role_mp_buffid] ~= nil then
        gGetDataManager():setHPMPStore(role_mp_buffid, self.hpmpstore[role_mp_buffid])
    end
    if self.hpmpstore[pet_hp_buffid] ~= nil then
        gGetDataManager():setHPMPStore(pet_hp_buffid, self.hpmpstore[pet_hp_buffid])
    end
    if self.hpmpstore[pet_mp_buffid] ~= nil then
        gGetDataManager():setHPMPStore(pet_mp_buffid, self.hpmpstore[pet_mp_buffid])
    end
    if self.hpmpstore[pet_loy_buffid] ~= nil then
        gGetDataManager():setHPMPStore(pet_loy_buffid, self.hpmpstore[pet_loy_buffid])
    end
    if self.reqkey == 1 then
        require "logic.characterinfo.characterinfodlg".UpdateHpMpStoreInstance()
    elseif self.reqkey == 2 then
        require "logic.showhide".ShowHpOrMpDlg()
    end
end

local saddpointattrdata = require "protodef.fire.pb.saddpointattrdata"
function saddpointattrdata:process()
    if gGetDataManager() then
        gGetDataManager():setRoleAttrFloatValue(fire.pb.attr.AttrType.MAX_HP, self.max_hp)
        gGetDataManager():setRoleAttrFloatValue(fire.pb.attr.AttrType.MAX_MP, self.max_mp)
        gGetDataManager():setRoleAttrFloatValue(fire.pb.attr.AttrType.ATTACK, self.attack)
        gGetDataManager():setRoleAttrFloatValue(fire.pb.attr.AttrType.DEFEND, self.defend)
        gGetDataManager():setRoleAttrFloatValue(fire.pb.attr.AttrType.MAGIC_ATTACK, self.magic_attack)
        gGetDataManager():setRoleAttrFloatValue(fire.pb.attr.AttrType.MAGIC_DEF, self.magic_def)
        gGetDataManager():setRoleAttrFloatValue(fire.pb.attr.AttrType.SPEED, self.speed)
    end

end
local srolelist = require "protodef.fire.pb.srolelist"
function srolelist:process()
    require "logic.loginqueuedialog"
    require "logic.selectserversdialog"
    require "logic.newswarndlg".hideBoard()
    LoginQueueDlg.DestroyDialog()
    SelectServersDialog.DestroyDialog()

    require "logic.createroledialog".setZhaoMuOpenStatus(self.gacdon)
    require "logic.friend.friendmaillabel".setZhaoMuOpenStatus(self.gacdon)

    if gGetLoginManager() then
        gGetLoginManager():SaveAccount()
    end
    -- 原始登陆流程
    local function originalLogin()
        if self.prevroleinbattle == 1 then
            require "logic.login.logindlg".DestroyDialog()
            gGetGameApplication():BeginDrawServantIntro()
            if gGetGameApplication():GetXmlBeanReady() then
                gGetGameApplication():DrawLoginBar(20)
                if gGetLoginManager() then
                    gGetLoginManager():SetLoginState(eLoginState_Null) --eLoginState_Null 0
                end

                local numMaxShowNum = require "logic.systemsettingdlgnew".GetMaxDisplayPlayerNum()

                gGetNetConnection():send(fire.pb.CEnterWorld(self.prevloginroleid, numMaxShowNum))
                require "logic.task.taskhelper".SendIsHavePingDingAnBangTask()
            else
                gGetGameApplication():DrawLoginBar(10)
                if gGetLoginManager() then
                    gGetLoginManager():SetLoginState(eLoginState_Null)  --eLoginState_Null 0
                end
                gGetGameApplication():SetWaitToEnterWorld(true)
                gGetGameApplication():SetEnterWorldRoleID(self.prevloginroleid)
            end
            gGetGameApplication():SetWaitForEnterWorldState(true)
        else
            if not gGetLoginManager() then
                return
            end
            if not gGetLoginManager() then
                return
            end
            gGetLoginManager():GetRoleList():clear()
            local total = #self.roles
            for i = 1, total do
                local roleInfo = fire.pb.RoleInfo()
                roleInfo.components = std.map_char_int_()
                roleInfo.roleid = self.roles[i].roleid
                roleInfo.rolename = self.roles[i].rolename
                roleInfo.school = self.roles[i].school
                roleInfo.shape = self.roles[i].shape
                roleInfo.level = self.roles[i].level
                for k, v in pairs(self.roles[i].components) do
                    roleInfo.components[k] = v
                end
                gGetLoginManager():GetRoleList():push_back(roleInfo)
            end
            gGetStateManager():setGameState(1) --eGameStateLogin 1
            gGetLoginManager():SetPreLoginRoleID(self.prevloginroleid)
            gGetLoginManager():UpdateRoleList()

            require "logic.task.taskhelper".SendIsHavePingDingAnBangTask()
        end
    end

    local dlg = require("logic.maincontrol").getInstanceNotCreate()
    -- 断线重连情况走之前逻辑
    if dlg then
        originalLogin()
        gGetStateManager():setGameState(eGameStateRunning)
    else
        local total = #self.roles
        if total <= 1 then
            originalLogin()
        else
            if not gGetLoginManager() then
                return
            end
            if not gGetLoginManager() then
                return
            end
            gGetStateManager():setGameState(1) --eGameStateLogin 1
            gGetLoginManager():SetPreLoginRoleID(self.prevloginroleid)
            require "logic.task.taskhelper".SendIsHavePingDingAnBangTask()
            local dlg = require "logic.selectroledlg":getInstanceAndShow()
            dlg:initRoleList(self.roles)
        end
    end

    require "logic.loginwaitingdialog".DestroyDialog()
end

local snotifydeviceinfo = require "protodef.fire.pb.snotifydeviceinfo"
function snotifydeviceinfo:process()
    gGetLoginManager():SetIp(self.ip)
end

local enterword2 = require "protodef.fire.pb.item.qnguo.senterword"
function enterword2:process()
    if not gGetDataManager() then
        return
    end
    --初始化潜能果次数
    gGetDataManager():setUseQianNengGuoNum(self.returnData.useqiannengguonum)
end

local enterword = require "protodef.fire.pb.senterworld"
function enterword:process()
    TeamManager.purgeData() --如果是断线重连需要先清除旧数据再重新接收
    TeamManager.newInstance()
    WelfareManager.newInstance()
    MainRoleDataManager.newInstance()
    TaskManager_CToLua.newInstance()
    FriendManager.getInstance()
    SelectServerEntry.DestroyDialog()
    gGetGameApplication():StartGame()
    CurrencyManager.init()

    if not gGetGameApplication() or not gGetDataManager() or not gGetScene() then
        return
    end

    SetRoleCreatTime(self.mydata.rolecreatetime)

    gGetScene():SetFirstEnterScene(true)
    gGetGameApplication():DrawLoginBar(20)

    gGetDataManager():setContribution(self.mydata.factionvalue)

    --发送请求潜能果次数
    local cmd = require "protodef.fire.pb.item.qnguo.centerword".Create()
    LuaProtocolManager.getInstance():send(cmd)

    gGetDataManager():UpdateMainCharacterData(self.mydata)

    gGetDataManager():UpdateFubenSetting(self.mydata.lineconfigmap)

    --地图添加主角
    gGetScene():AddMainCharacter(self.mydata.roleid, GetRoleSex(self.mydata.shape), self.mydata.shape, 0)
    if GetMainCharacter() then
        local components = std.map_char_int_()
        for k, v in pairs(self.mydata.components) do
            components[k] = v
        end
        GetMainCharacter():UpdateSpriteComponent(components)
        GetMainCharacter():RefreshRoleInfoOfThisServer()
    end

    gGetDataManager():SetMainCharacterLearnFormation(self.mydata.learnedformsmap)

    local mainpack = require("logic.item.mainpackdlg"):getInstanceOrNot()
    if mainpack then
        mainpack:ClearItemTable()
    end

    for k, v in pairs(self.mydata.baginfo) do
        RoleItemManager.getInstance():ClearBag(k)
        RoleItemManager.getInstance():AddBagItem(k, v)
    end

    RoleItemManager.getInstance():CheckEquipEffect()
    if self.mydata.depotnameinfo then
        RoleItemManager.getInstance():setDepotNames(self.mydata.depotnameinfo)
    end

    gGetDataManager():AddMyPetList(self.mydata.pets)
    gGetDataManager():SetMaxPetNum(self.mydata.petmaxnum)
    gGetDataManager():UpdateGameSetting(self.mydata.sysconfigmap)
    gGetDataManager():UpdateTitleMap(self.mydata.titles)

    if gGetGameConfigManager() then
        local bRet = gGetGameConfigManager():GetStepLoadTextureInMovie() or gGetGameConfigManager():GetStepLoadTextureAlways()
        Nuclear.GetEngine():SetStepLoadTexture(bRet)
    end
    require "logic.pointcardserver.pointcardservermanager".getInstance()

    if IsPointCardServer() then
        local cquerysubscribeinfo = require("protodef.fire.pb.fushi.payday.cquerysubscribeinfo").Create()
        LuaProtocolManager.getInstance():send(cquerysubscribeinfo)
    end
    require "logic.selectroledlg".DestroyDialog()

end

local ssetfunopenclose = require "protodef.fire.pb.ssetfunopenclose"
function ssetfunopenclose:process()
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        manager.m_OpenFunctionList = self
    end
    local dlg = LogoInfoDialog.getInstanceNotCreate()
    if dlg then
        dlg:refreshRedpack()
    end
    dlg = require "logic.pointcardserver.messageforpointcarddlg".getInstanceNotCreate()
    if dlg then
        dlg:refreshbtn()
    end
    dlg = require "logic.pointcardserver.messageforpointcardnotcashdlg".getInstanceNotCreate()
    if dlg then
        dlg:refreshbtn()
    end
    require "logic.qiandaosongli.loginrewardmanager"
    local mgr = LoginRewardManager.getInstance()
    mgr:refreshMonthCard()

    local dlg = require("logic.qiandaosongli.jianglinewdlg").getInstanceNotCreate()
    if dlg then
        dlg.DestroyDialog()
        dlg.getInstanceAndShow()
        dlg:showSysId(1)
    end

end

local sgetbindtel = require "protodef.fire.pb.sgetbindtel"
function sgetbindtel:process()
    local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
    shoujianquanmgr.tel = self.tel
    shoujianquanmgr.createdate = self.createdate
    shoujianquanmgr.isfistloginofday = self.isfistloginofday
    shoujianquanmgr.isgetbindtelaward = self.isgetbindtelaward
    shoujianquanmgr.isbindtelagain = self.isbindtelagain

    if not shoujianquanmgr.needBindTelAgain() and shoujianquanmgr.notBind4DaysAndFirstLoginToday() then
        require("logic.shoujianquan.shoujiguanliantixing").getInstanceAndShow()
    end

    shoujianquanmgr.refreshAwardOpen()
    shoujianquanmgr.refreshAwardRedPoint()
end

local sbindtelagain = require "protodef.fire.pb.sbindtelagain"
function sbindtelagain:process()
    local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
    shoujianquanmgr.isbindtelagain = 1

    local dlg = require("logic.systemsettingdlgnew").getInstanceNotCreate()
    if dlg then
        dlg:refreshShouJiAnQuan()
    end
end

local sunbindtel = require "protodef.fire.pb.sunbindtel"
function sunbindtel:process()
    if self.status == 1 then
        local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
        shoujianquanmgr.tel = 0

        local dlg = require("logic.shoujianquan.shoujijiechushuru").getInstanceNotCreate()
        if dlg then
            ShouJiJieChuShuRu.DestroyDialog()
            GetCTipsManager():AddMessageTipById(191020)
        end

        local dlg = require("logic.systemsettingdlgnew").getInstanceNotCreate()
        if dlg then
            dlg:refreshShouJiAnQuan()
        end
    end
end

local scheckcodefinishtime = require "protodef.fire.pb.scheckcodefinishtime"
function scheckcodefinishtime:process()
    local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
    shoujianquanmgr.finishtimepoint = self.finishtimepoint

    local dlg = require("logic.shoujianquan.shoujiguanlianshuru").getInstanceNotCreate()
    if dlg then
        dlg:BeginCountDown()
    end
end

local sbindtel = require "protodef.fire.pb.sbindtel"
function sbindtel:process()
    if self.status == 1 then
        local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
        if shoujianquanmgr.isBindTel() then
            shoujianquanmgr.telrecord = 0
            shoujianquanmgr.isbindtelagain = 0
            require("logic.shoujianquan.shoujiguanlianshuru").DestroyDialog()
            GetCTipsManager():AddMessageTipById(191018)
        else
            shoujianquanmgr.telrecord = 0
            shoujianquanmgr.isbindtelagain = 0
            shoujianquanmgr.isgetbindtelaward = 2
            shoujianquanmgr.tel = shoujianquanmgr.telforconfirm
            require("logic.shoujianquan.shoujiguanlianshuru").DestroyDialog()
            require("logic.shoujianquan.shoujiguanlianchenggong").getInstanceAndShow()
            shoujianquanmgr.refreshAwardRedPoint()

            local dlg = require("logic.qiandaosongli.shoujiguanlianjiangli").getInstanceNotCreate()
            if dlg then
                dlg:refreshUI()
            end
        end

        local dlg = require("logic.systemsettingdlgnew").getInstanceNotCreate()
        if dlg then
            dlg:refreshShouJiAnQuan()
        end
    end
end

local sgetbindtelaward = require "protodef.fire.pb.sgetbindtelaward"
function sgetbindtelaward:process()
    if self.status == 1 then
        local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
        shoujianquanmgr.isgetbindtelaward = 1
        shoujianquanmgr.refreshAwardOpen()
        shoujianquanmgr.refreshAwardRedPoint()
        require("logic.qiandaosongli.jianglinewdlg").DestroyDialog()
    end
end

-----------------------------------------------------------------------------
fire_pb = {}

function fire_pb.Move_Lua_SRoleEnterScene_ProtocolType()
    return require("protodef.fire.pb.move.sroleenterscene").PROTOCOL_TYPE
end

function fire_pb.Move_Lua_SRoleEnterScene_ENTER()
    return require("protodef.fire.pb.move.sroleenterscene").ENTER
end

function fire_pb.Move_Lua_SRoleEnterScene_QUEST_CG()
    return require("protodef.fire.pb.move.sroleenterscene").QUEST_CG
end

local ssendhelpsw = require "protodef.fire.pb.ssendhelpsw"
function ssendhelpsw:process()
    local dlg = require "logic.shop.scoreexchangeshop".getInstanceAndShow()
    dlg:setHelpSW(self.helpsw)
end

function AlertKick()
    local p = require "protodef.fire.pb.ckick":new()
    require "manager.luaprotocolmanager":send(p)
end

return fire_pb

-----------------------------------------------------------------------------