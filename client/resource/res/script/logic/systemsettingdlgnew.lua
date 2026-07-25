require "logic.dialog"
require "logic.newswarndlg"
require "logic.lockscreendlg"
require "protodef.fire.pb.csetmaxscreenshownum"

SystemSettingNewDlg = {}

setmetatable(SystemSettingNewDlg, Dialog)
SystemSettingNewDlg.__index = SystemSettingNewDlg

function SystemSettingNewDlg:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.7)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function SystemSettingNewDlg:OnCreate()
	Dialog.OnCreate(self)

	SetPositionScreenCenter(self:GetWindow())

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_musicEnable = CEGUI.toCheckbox(winMgr:getWindow("SystemSetting1/GameSetting/swich1"))
	self.m_musicEnable:subscribeEvent("CheckStateChanged", SystemSettingNewDlg.handleOnMusicSwitch, self)
	self.m_soundEnable = CEGUI.toCheckbox(winMgr:getWindow("SystemSetting1/GameSetting/swich2"))
	self.m_soundEnable:subscribeEvent("CheckStateChanged", SystemSettingNewDlg.handleOnSoundSwitch, self)
	
	self.m_volumBar = CEGUI.Window.toProgressBar(winMgr:getWindow("SystemSetting1/GameSetting/HS12"))
	self.m_volumButton = CEGUI.toPushButton(winMgr:getWindow("SystemSetting1/GameSetting/HS12/anniu"))
	self.m_volumButton:subscribeEvent("MouseMove", SystemSettingNewDlg.handleVolumChanged, self)
	self.m_volumButton:subscribeEvent("MouseLeave", SystemSettingNewDlg.HandleButtonUp, self)
	self.m_volumButton:subscribeEvent("MouseButtonUp", SystemSettingNewDlg.HandleButtonUp, self)
	
	

	self.m_volumButton:EnableClickAni(false)
	self.m_volumButton:SetMouseLeaveReleaseInput(false)

	self.m_volumButtonOrgOffset = self.m_volumButton:getPosition().x.offset
	
	self.ccshengying = CEGUI.toGroupButton(winMgr:getWindow("SystemSetting1/cc1btn"))
	self.ccshengying:subscribeEvent("SelectStateChanged", SystemSettingNewDlg.shezhiTypeTab, self)
	
	self.cchuamian = CEGUI.toGroupButton(winMgr:getWindow("SystemSetting1/cc2btn"))
	self.cchuamian:subscribeEvent("SelectStateChanged", SystemSettingNewDlg.shezhiTypeTab, self)
	
	self.ccyxshezhi = CEGUI.toGroupButton(winMgr:getWindow("SystemSetting1/cc3btn"))
	self.ccyxshezhi:subscribeEvent("SelectStateChanged", SystemSettingNewDlg.shezhiTypeTab, self)
	
	self.ccyxxiazai = CEGUI.toGroupButton(winMgr:getWindow("SystemSetting1/cc4btn"))
	self.ccyxxiazai:subscribeEvent("SelectStateChanged", SystemSettingNewDlg.shezhiTypeTab, self)
	
	self.cc1 = winMgr:getWindow("SystemSetting1/cc1")
	self.cc2 = winMgr:getWindow("SystemSetting1/cc2")
	self.cc3 = winMgr:getWindow("SystemSetting1/cc3")
	self.cc4 = winMgr:getWindow("SystemSetting1/cc4")

   	self.ccxttips = CEGUI.toRichEditbox(winMgr:getWindow("SystemSetting1/cc4/xiashuomingc1"))
	self.ccxttips:Clear()
    self.ccxttips:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7550)))
    self.ccxttips:Refresh()
	
	self.m_sceneEffectOpen = CEGUI.toRadioButton(winMgr:getWindow("SystemSetting1/FunctionSetting/changjing1"))
	self.m_sceneEffectClose = CEGUI.toRadioButton(winMgr:getWindow("SystemSetting1/FunctionSetting/changjing2"))
	self.m_sceneEffectOpen:setGroupID(1)
	self.m_sceneEffectClose:setGroupID(1)
	self.m_sceneEffectOpen:subscribeEvent("SelectStateChanged", SystemSettingNewDlg.handleRadioButton, self)
	self.m_sceneEffectClose:subscribeEvent("SelectStateChanged", SystemSettingNewDlg.handleRadioButton, self)

	self.m_personShowMore = CEGUI.toRadioButton(winMgr:getWindow("SystemSetting1/FunctionSetting/tongping1"))
	self.m_personShowLess = CEGUI.toRadioButton(winMgr:getWindow("SystemSetting1/FunctionSetting/tongping2"))
	self.m_personShowMore:setGroupID(2)
	self.m_personShowLess:setGroupID(2)
	self.m_personShowMore:subscribeEvent("SelectStateChanged", SystemSettingNewDlg.handleRadioButton, self)
	self.m_personShowLess:subscribeEvent("SelectStateChanged", SystemSettingNewDlg.handleRadioButton, self)

	self.m_refreshHigh = CEGUI.toRadioButton(winMgr:getWindow("SystemSetting1/FunctionSetting/huamian1"))
	self.m_refreshLow = CEGUI.toRadioButton(winMgr:getWindow("SystemSetting1/FunctionSetting/huamian2"))
	self.m_refreshHigh:setGroupID(3)
	self.m_refreshLow:setGroupID(3)
	self.m_refreshHigh:subscribeEvent("SelectStateChanged", SystemSettingNewDlg.handleRadioButton, self)
	self.m_refreshLow:subscribeEvent("SelectStateChanged", SystemSettingNewDlg.handleRadioButton, self)
	
	

	self.m_sceneEffectOpen:EnableClickAni(false)
	self.m_sceneEffectClose:EnableClickAni(false)
	self.m_personShowMore:EnableClickAni(false)
	self.m_personShowLess:EnableClickAni(false)
	self.m_refreshHigh:EnableClickAni(false)
	self.m_refreshLow:EnableClickAni(false)

	self.m_autoPlayVoiceBangpai = CEGUI.toCheckbox(winMgr:getWindow("SystemSetting1/bangpai"))
	self.m_autoPlayVoiceBangpai:setID(7)
	self.m_autoPlayVoiceShijie = CEGUI.toCheckbox(winMgr:getWindow("SystemSetting1/shijie"))
	self.m_autoPlayVoiceShijie:setID(8)
	self.m_autoPlayVoiceDuiwu = CEGUI.toCheckbox(winMgr:getWindow("SystemSetting1/duiwu"))
	self.m_autoPlayVoiceDuiwu:setID(9)
	self.m_autoPlayVoiceZhiye = CEGUI.toCheckbox(winMgr:getWindow("SystemSetting1/zhiye1"))
	self.m_autoPlayVoiceZhiye:setID(10)
	self.m_autoPlayVoiceBangpai:subscribeEvent("CheckStateChanged", SystemSettingNewDlg.handleAutoVoice, self)
	self.m_autoPlayVoiceShijie:subscribeEvent("CheckStateChanged", SystemSettingNewDlg.handleAutoVoice, self)
	self.m_autoPlayVoiceDuiwu:subscribeEvent("CheckStateChanged", SystemSettingNewDlg.handleAutoVoice, self)
	self.m_autoPlayVoiceZhiye:subscribeEvent("CheckStateChanged", SystemSettingNewDlg.handleAutoVoice, self)

	self.m_refuseFriend = CEGUI.toCheckbox(winMgr:getWindow("SystemSetting1haoyouyaoqing"))
	self.m_refuseFriend:subscribeEvent("CheckStateChanged", SystemSettingNewDlg.handleRefuseTeam, self)

	self.m_refusePVP = CEGUI.toCheckbox(winMgr:getWindow("SystemSetting1/jujueqiecuo"))
	self.m_refusePVP:subscribeEvent("CheckStateChanged", SystemSettingNewDlg.handleRefusePvp, self)

	-- 拒绝公会邀请
	self.m_refuseClan = CEGUI.toCheckbox(winMgr:getWindow("SystemSetting1gonghuiyaoqing"))
	self.m_refuseClan:subscribeEvent("CheckStateChanged", SystemSettingNewDlg.handleRefuseClan, self)

	-- 拒绝查看装备
	self.m_refuseSeeEquip = CEGUI.toCheckbox(winMgr:getWindow("SystemSetting1jujuechakanzhuangbei"))
	self.m_refuseSeeEquip:subscribeEvent("CheckStateChanged", SystemSettingNewDlg.handleRefuseSeeEquip, self)

	-- 录屏
	local LuPingZi = winMgr:getWindow("SystemSetting1/luping")
	self.m_LuPingSwitch = CEGUI.toSwitch(winMgr:getWindow("SystemSetting1/GameSetting/swich21"))
	self.m_LuPingSwitch:subscribeEvent("StatusChanged", SystemSettingNewDlg.handleLuPingSwitch, self)

    -- Roll点设置
	self.m_rollSetting = CEGUI.toCheckbox(winMgr:getWindow("SystemSetting1haoyouyaoqing11"))
	self.m_rollSetting:subscribeEvent("CheckStateChanged", SystemSettingNewDlg.handleRollSettingCheck, self)



    self.checkBoxOpenLockItem = CEGUI.toRadioButton(winMgr:getWindow("SystemSetting1/FunctionSetting/huamian11"))
	self.checkBoxOpenLockItem:subscribeEvent("SelectStateChanged", SystemSettingNewDlg.clickOpenCloseLock, self)
    self.checkBoxCloseLockItem = CEGUI.toRadioButton(winMgr:getWindow("SystemSetting1/FunctionSetting/huamian21"))
	self.checkBoxCloseLockItem:subscribeEvent("SelectStateChanged", SystemSettingNewDlg.clickOpenCloseLock, self)
    self.checkBoxOpenLockItem:setGroupID(4)
	self.checkBoxCloseLockItem:setGroupID(4)
    self.checkBoxOpenLockItem:EnableClickAni(false)
    self.checkBoxCloseLockItem:EnableClickAni(false)

	local buttonQuitAccout = CEGUI.toPushButton(winMgr:getWindow("SystemSetting1/zhanghaoqu/anniu1"))--退出游戏
	self:addButtonAnimation(buttonQuitAccout, "studyBtnPress")
	buttonQuitAccout:subscribeEvent("Clicked", SystemSettingNewDlg.handleQuitAccout, self)

	local buttonLockScreen = CEGUI.toPushButton(winMgr:getWindow("SystemSetting1/zhanghaoqu/anniu2"))--锁定屏幕
	--self:addButtonAnimation(buttonLockScreen, "xstudyBtnPress")
	buttonLockScreen:subscribeEvent("Clicked", SystemSettingNewDlg.handleLockScreenClicked, self)

	local buttonNewsWarn = CEGUI.toPushButton(winMgr:getWindow("SystemSetting1/zhanghaoqu/anniu3"))--游戏公告
	self:addButtonAnimation(buttonNewsWarn, "xstudyBtnPress")
	buttonNewsWarn:subscribeEvent("Clicked", SystemSettingNewDlg.handleNewWarnClick, self)

	local buttonForum = CEGUI.toPushButton(winMgr:getWindow("SystemSetting1/zhanghaoqu/anniu31"))
	buttonForum:subscribeEvent("Clicked", SystemSettingNewDlg.handleForumClick, self)
	if MT3.ChannelManager:IsAndroid() == 1 then
		if Config.IsLocojoy() then
			buttonForum:setVisible(true)
		else
			buttonForum:setVisible(false)
		end
	else
		buttonForum:setVisible(true)
	end

    local buttonUserCenter = CEGUI.toPushButton(winMgr:getWindow("SystemSetting1/zhanghaoqu/anniu312"))
    buttonUserCenter:subscribeEvent("Clicked", SystemSettingNewDlg.handleUserCenterClick, self)
    if gGetChannelName() == Config.PlatformOfRongHe then
        if MT3.ChannelManager:IsSupportUserCenter() == 1 then
            buttonUserCenter:setVisible(true)
        else
            buttonUserCenter:setVisible(false)
        end
    else
         buttonUserCenter:setVisible(false)
    end



    self.buttonFBSetting = CEGUI.toPushButton(winMgr:getWindow("SystemSetting1/zhanghaoqu/anniu32"))--自动进入副本
	self:addButtonAnimation(self.buttonFBSetting, "studyBtnPress")
    self.buttonFBSetting:subscribeEvent("Clicked", SystemSettingNewDlg.handleFuBenSettingClick, self)
    
	
	local moidfypass = CEGUI.toPushButton(winMgr:getWindow("SystemSetting1/zhanghaoqu/pass"))--修改密码
	moidfypass:subscribeEvent("Clicked", SystemSettingNewDlg.handleModifyPassClicked, self)
	
	self.cc_libaozhongxin = CEGUI.toPushButton(winMgr:getWindow("SystemSetting1/zhanghaoqu/libaozhongxin"))--礼包中心
	self:addButtonAnimation(self.cc_libaozhongxin, "studyBtnPress")
	self.cc_libaozhongxin:subscribeEvent("Clicked", SystemSettingNewDlg.handleGiftCenterClick, self)
	
	self.cc_lianxikefu = CEGUI.toPushButton(winMgr:getWindow("SystemSetting1/zhanghaoqu/annicccu3"))--联系客服
	self:addButtonAnimation(self.cc_lianxikefu, "xstudyBtnPress")
	
	self.cc_xiazaiyouxi = CEGUI.toPushButton(winMgr:getWindow("SystemSetting1/cc4/xiazai"))--游戏下载
	self:addButtonAnimation(self.cc_xiazaiyouxi, "studyBtnPress")
	self.cc_xiazaiyouxi:subscribeEvent("Clicked", SystemSettingNewDlg.handleDownloadGameClick, self)



	local curAccoutText = winMgr:getWindow("SystemSetting1/zhanghaoqu/zhanghao1")
	local curServerText = winMgr:getWindow("SystemSetting1/zhanghaoqu/fuwuqi1")
	local curIDnumberText = winMgr:getWindow("SystemSetting1/zhanghaoqu/IDnumber")
	local curSchoolText = winMgr:getWindow("SystemSetting1/zhanghaoqu/juese")
	local curLevelText = winMgr:getWindow("SystemSetting1/zhanghaoqu/level")
	
	curAccoutText:setText(gGetDataManager():GetMainCharacterName())

    
    local serverName = gGetLoginManager():GetSelectServer()
    local pos = string.find(serverName, "-")
    if pos then
        curServerText:setText(string.sub(serverName, 1, pos - 1))
    else
        curServerText:setText(serverName)
    end
	
	curIDnumberText:setText(gGetDataManager():GetMainCharacterID())
	curSchoolText:setText(gGetDataManager():GetMainCharacterSchoolName())
	curLevelText:setText(gGetDataManager():GetMainCharacterLevel())
 
	

	self.headIcon = CEGUI.toItemCell(winMgr:getWindow("SystemSetting1/zhanghaoqu/renwukuang"))
	local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(gGetDataManager():GetMainCharacterShape())
	local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
	self.headIcon:SetImage(image)

	self.SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()


    --简化界面
    self.m_frameSetting = CEGUI.toCheckbox(winMgr:getWindow("SystemSetting1haoyouyaoqing1"))
    self.m_frameSetting:subscribeEvent("CheckStateChanged", SystemSettingNewDlg.handleFrameSimplify, self)

    self:LoadConfigForFrameSimplify()

	self:loadConfigInit()

	if Config.MOBILE_ANDROID ~= 1 and gGetGameApplication():GetRecordEnable() then
		LuPingZi:setVisible(true)
		self.m_LuPingSwitch:setVisible(true)
	else
		LuPingZi:setVisible(false)
		self.m_LuPingSwitch:setVisible(false)
	end

    self:refreshItemLockState()
end

function SystemSettingNewDlg:shezhiTypeTab()
    local selectedBtn = self.ccshengying:getSelectedButtonInGroup()  
    if self.ccshengying == selectedBtn then  
        self.cc1:setVisible(true)
        self.cc2:setVisible(false)
        self.cc3:setVisible(false) 
		self.cc4:setVisible(false) 
    elseif self.cchuamian == selectedBtn then  
        self.cc1:setVisible(false)
        self.cc2:setVisible(true)
        self.cc3:setVisible(false)
        self.cc4:setVisible(false) 		
    elseif self.ccyxshezhi == selectedBtn then  
        self.cc1:setVisible(false)
        self.cc2:setVisible(false)
        self.cc3:setVisible(true)
		self.cc4:setVisible(false)
    elseif self.ccyxxiazai == selectedBtn then  
        self.cc1:setVisible(false)
        self.cc2:setVisible(false)
        self.cc3:setVisible(false)
		self.cc4:setVisible(true) 		
    end
end



function SystemSettingNewDlg:refreshItemLockState()
    local itemManager = require("logic.item.roleitemmanager").getInstance()
    if itemManager.isOpenSafeLock==1 then
         self.checkBoxCloseLockItem:setSelectedNoEvent(false)
         self.checkBoxOpenLockItem:setSelectedNoEvent(true)
    else
         self.checkBoxCloseLockItem:setSelectedNoEvent(true)
         self.checkBoxOpenLockItem:setSelectedNoEvent(false)
    end
end



function SystemSettingNewDlg:clickOpenCloseLock(args)
    local e = CEGUI.toWindowEventArgs(args)
	local clickNode = e.window

    if clickNode==self.checkBoxOpenLockItem then
        local bSel = self.checkBoxOpenLockItem:isSelected()
        if bSel then
             local p =  require("protodef.fire.pb.copengoodlocks"):new()
             LuaProtocolManager:send(p)
        end
    elseif clickNode==self.checkBoxCloseLockItem then
        local bSel = self.checkBoxCloseLockItem:isSelected()
        if bSel then
            --self.checkBoxCloseLockItem:setSelectedNoEvent(false)
            require("logic.item.itemcloseLockinputpsddialog").getInstanceAndShow()
        end
    end   
end

function SystemSettingNewDlg:LoadConfigForFrameSimplify()
    local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(self.SettingEnum.framesimplify)
    if record.id ~= -1 then
        local strKey = record.key
        local value = gGetGameConfigManager():GetConfigValue(strKey)
        if value == 1 then 
	        self.m_frameSetting:setSelectedNoEvent(true)
        else
	        self.m_frameSetting:setSelectedNoEvent(false)
        end

    end
end
function SystemSettingNewDlg:handleFrameSimplify(e)
    local saveValue = 0
	if self.m_frameSetting:isSelected() then
		saveValue = 1
	end
    local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(self.SettingEnum.framesimplify)
    if record.id ~= -1 then
        local strKey = record.key
        gGetGameConfigManager():SetConfigValue(strKey, saveValue)
        gGetGameConfigManager():SaveConfig()
        local dlg = require "logic.maincontrol".getInstanceNotCreate()
        if dlg then
            dlg:initIsSimplify()
        end
        local dlg = require "logic.logo.logoinfodlg".getInstanceNotCreate()
        if dlg then
            dlg:initIsSimplify()
        end
    end

end


function SystemSettingNewDlg.DoResetConfig()
    local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
    local checkResetValue = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(359).value)

    local iniMgr = IniManager("SystemSetting.ini")
    local exist,_,_,resetValue = iniMgr:GetValueByName("GameConfig", "resetconfig", "")
    resetValue = tonumber(resetValue)
    if exist and checkResetValue == resetValue then return end

    for k = SettingEnum.Music, SettingEnum.screenrecord do
        local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(k)
        local resetRecord = BeanConfigManager.getInstance():GetTableByName("SysConfig.cgameconfigreset"):getRecorder(k)
        if record and resetRecord then
            local resetValue = resetRecord.iosvalue
            if MT3.ChannelManager:IsAndroid() == 1 then
                resetValue = resetRecord.andvalue
            end
            if record.value ~= resetValue then
                gGetGameConfigManager():SetConfigValue(record.key, resetValue)
            end
        end
    end
    gGetGameConfigManager():SetConfigValue("resetconfig", checkResetValue)
    gGetGameConfigManager():SaveConfig()
end

function SystemSettingNewDlg:handleLuPingSwitch(arg)
	local dlg = CChatOutBoxOperatelDlg.getInstanceNotCreate()
	if not dlg then
		return
	end

	if self.m_LuPingSwitch:getStatus() == CEGUI.ON then
		dlg:EnableRecordScreen(true)
		gGetGameConfigManager():SetConfigValue("screenrecord", 1)
	else
		dlg:EnableRecordScreen(false)
		gGetGameConfigManager():SetConfigValue("screenrecord", 0)
	end

	gGetGameConfigManager():ApplyConfig()
	gGetGameConfigManager():SaveConfig()
end

function SystemSettingNewDlg:HandleButtonUp(arg)
    self:dealWidthMoveOver()
end

function SystemSettingNewDlg:dealWidthMoveOver()

    local minOffset = self.m_volumButtonOrgOffset
    local maxOffset =  self.m_volumBar:getPixelSize().width- self.m_volumButton:getPixelSize().width * 0.75
    local totalWidth = maxOffset - minOffset

    local pos = self.m_volumButton:getPosition()

    local scale = math.abs(pos.x.offset + self.m_volumButton:getPixelSize().width * 0.5) / totalWidth

    local saveValue = 255.0 * scale
     if saveValue < 0 then
        saveValue = 0
    elseif saveValue > 255 then
        saveValue = 255
    end

	gGetGameConfigManager():SetConfigValue("soundvalue", saveValue)
	gGetGameConfigManager():ApplyConfig()
	gGetGameConfigManager():SaveConfig()
end

function SystemSettingNewDlg:handleForumClick(args)
    GetServerInfo():doEnterBBS()
--	IOS_MHSD_UTILS.OpenURL(GetServerInfo():getHttpAdressByEnum(eHttpCommunityUrl))
end

--用户中心，360融合sdk 
function SystemSettingNewDlg:handleUserCenterClick(args)
    MT3.ChannelManager:openUserCenter()
end

function SystemSettingNewDlg:handleGiftCenterClick(args)
    MT3.ChannelManager:openUserCenter()
end

function SystemSettingNewDlg:handleDownloadGameClick(args)
    IOS_MHSD_UTILS.OpenURL("http://mt3.locojoy.com")
end

function SystemSettingNewDlg:handleShouJiAnQuan(args)

    require("logic.item.safeseldialog").getInstanceAndShow()


end

function SystemSettingNewDlg:handleFuBenSettingClick(args)
    if gGetDataManager():GetMainCharacterLevel() >= tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(458).value) then
        local fbSettingDlg = require "logic.fuben.fubensetting".getInstanceAndShow()

        local pos = CEGUI.UVector2(CEGUI.UDim(0,  -self.buttonFBSetting:getPixelSize().width * 0.1), CEGUI.UDim(0.0, -fbSettingDlg:getFrameSize().height + self.buttonFBSetting:getPixelSize().height)) + self.buttonFBSetting:getPosition()--自动进入副本
        fbSettingDlg:GetWindow():setPosition(pos)
    else
        GetCTipsManager():AddMessageTipById(191039)
    end

end

function SystemSettingNewDlg:handleRefusePvp(args)
    local saveValue = 0
	if self.m_refusePVP:isSelected() then
		saveValue = 1
	end
	
	local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(self.SettingEnum.refuseqiecuo)
	if record ~= nil then
		local strKey = record.key
		gGetGameConfigManager():SetConfigValue(strKey, saveValue)
	end
	gGetGameConfigManager():ApplyConfig()
	gGetGameConfigManager():SaveConfig()
	
	SystemSettingNewDlg.sendGameConfig(self.SettingEnum.refuseqiecuo, saveValue)
end

function SystemSettingNewDlg:handleRefuseTeam(arg)
	--print("SystemSettingNewDlg:handleRefuseTeam")
	local saveValue = 0
	if self.m_refuseFriend:isSelected() then
		saveValue = 1
	end
	
	local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(self.SettingEnum.RefuseFriend)
	if record.id ~= -1 then
		local strKey = record.key
		gGetGameConfigManager():SetConfigValue(strKey, saveValue)
	end
	gGetGameConfigManager():ApplyConfig()
	gGetGameConfigManager():SaveConfig()
	
	SystemSettingNewDlg.sendGameConfig(self.SettingEnum.RefuseFriend, saveValue)
end

function SystemSettingNewDlg:handleRefuseClan(args)
	local saveValue = 0
	if self.m_refuseClan:isSelected() then
		saveValue = 1
	end
	
	local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(self.SettingEnum.refuseclan)
	if record.id ~= -1 then
		local strKey = record.key
		gGetGameConfigManager():SetConfigValue(strKey, saveValue)
	end
	gGetGameConfigManager():ApplyConfig()
	gGetGameConfigManager():SaveConfig()
	
	SystemSettingNewDlg.sendGameConfig(self.SettingEnum.refuseclan, saveValue)
end

function SystemSettingNewDlg:handleClickFubenSetting(arg)
    local fbSettingDlg = require "logic.fuben.fubensetting".getInstanceAndShow()
    local pos = CEGUI.UVector2(CEGUI.UDim(0,  self.m_fubenSetting:getPixelSize().width * 0.1), CEGUI.UDim(0.0, -fbSettingDlg:getFrameSize().height)) + self.m_fubenSetting:getPosition()--自动进入副本
    fbSettingDlg:GetWindow():setPosition(pos)
end

function SystemSettingNewDlg:handleRollSettingCheck(arg)
    local winargs = CEGUI.toWindowEventArgs(arg)
    local checkBox = CEGUI.Window.toCheckbox(winargs.window)
    local saveValue = 0
    if checkBox:isSelected() then
        saveValue = 1
    else
        saveValue = 0
    end

    local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
    local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(SettingEnum.rolldianshezhi)
	if record then
		local strKey = record.key
		gGetGameConfigManager():SetConfigValue(strKey, saveValue)
	end
	gGetGameConfigManager():SaveConfig()
end

--拒绝查看装备
function SystemSettingNewDlg:handleRefuseSeeEquip(arg)
	local saveValue = 0
	if self.m_refuseSeeEquip:isSelected() then
		saveValue = 1
	end
	
	local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(self.SettingEnum.refuseotherseeequip)
	if record.id ~= -1 then
		local strKey = record.key
		gGetGameConfigManager():SetConfigValue(strKey, saveValue)
	end
	gGetGameConfigManager():ApplyConfig()
	gGetGameConfigManager():SaveConfig()
	
	SystemSettingNewDlg.sendGameConfig(self.SettingEnum.refuseotherseeequip, saveValue)
end


function SystemSettingNewDlg:handleModifyPassClicked(arg)
	require "logic.passmodifydlg".getInstanceAndShow()
	self.DestroyDialog()
end
function SystemSettingNewDlg:handleLockScreenClicked(arg)
	LockScreenDlg.getInstanceAndShow()
	self.DestroyDialog()
end

function SystemSettingNewDlg:handleVolumChanged(arg)
	local moveEvent = CEGUI.toMouseEventArgs(arg)
	local delta = moveEvent.moveDelta						--移动偏移量

    local pos = self.m_volumButton:getPosition()
	local size = self.m_volumButton:getSize()

    local minOffset = self.m_volumButtonOrgOffset
    local maxOffset =  self.m_volumBar:getPixelSize().width - self.m_volumButton:getPixelSize().width * 0.75
    local totalWidth = maxOffset - minOffset
    pos.x.offset = pos.x.offset + delta.x

    if pos.x.offset < minOffset then
        pos.x.offset = minOffset
    end

    if pos.x.offset > maxOffset then
        pos.x.offset = maxOffset
    end

    self.m_volumButton:setPosition(pos)
	self.m_volumButton:setSize(size)

    local scale = math.abs(pos.x.offset + self.m_volumButton:getPixelSize().width * 0.5) / totalWidth
    self.m_volumBar:setProgress(scale)
end

function SystemSettingNewDlg:handleRadioButton(arg)
	local e = CEGUI.toWindowEventArgs(arg)
	local groupid = e.window:getGroupID()
	
	local saveID = 0
	local saveValue = 0
	if groupid == 1 then
		saveID = 4
		if self.m_sceneEffectOpen:isSelected() then
			saveValue = 1
		end
	elseif groupid == 2 then
		saveID = 5
		if self.m_personShowMore:isSelected() then
			saveValue = 1
		end
	elseif groupid == 3 then
		saveID = 6
		if self.m_refreshHigh:isSelected() then
			saveValue = 1
		end
	end
	
	local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(saveID)
	if record.id ~= -1 then
		local strKey = record.key
		gGetGameConfigManager():SetConfigValue(strKey, saveValue)
	end
	gGetGameConfigManager():ApplyConfig()
	gGetGameConfigManager():SaveConfig()
	
	if saveID == 4 then  --场景特效
        if saveValue == 1 then
            gGetGameConfigManager():SetConfigValue("sceneeffect", 1)
        else
            gGetGameConfigManager():SetConfigValue("sceneeffect", 0)
        end
        gGetScene():setSceneEffect()
	end
	
	if saveID == 5 then  --最大人数
		SystemSettingNewDlg.SendMaxPlayerNum()
	end
	
	if saveID == 6 then  --屏幕刷新频率
		SystemSettingNewDlg.handleChangeFPS()
	end
	
end

function SystemSettingNewDlg.run(dt)
--    if SystemSettingNewDlg.loadingover then
--        SystemSettingNewDlg.tick = SystemSettingNewDlg.tick + dt
--        if SystemSettingNewDlg.tick > 80 then
--            SystemSettingNewDlg.loadingover = false
--            SystemSettingNewDlg.tick = 0
--            if gGetGameConfigManager():GetConfigValue("sceneeffect") == 0 then
--                gGetScene():pauseSceneEffects()
--            end
--        end
--    end
end

function SystemSettingNewDlg.GetMaxDisplayPlayerNum()

	local value = gGetGameConfigManager():GetConfigValue("personshow")

	local beanConfigManager = BeanConfigManager.getInstance()
	local beanTabel = beanConfigManager:GetTableByName("SysConfig.ctongpingsetting")
	local record = beanTabel:getRecorder(1)

	local maxNum = 10

	if not value then
        value = 1
    end

	if value == 1 then
		maxNum = record.morevalue
	else
		maxNum = record.lessvalue
	end
	
	return maxNum
end

function SystemSettingNewDlg.SendMaxPlayerNum()
    LogInfo("SystemSettingNewDlg.SendMaxPlayerNum")
    
    local numMaxShow = SystemSettingNewDlg.GetMaxDisplayPlayerNum()
    require "mainticker"
    if PlayerCountByFPS < numMaxShow or  GetIsInFamilyFight()  then  --在公会战中为最大数
        numMaxShow = PlayerCountByFPS
    end
	print("numMaxShow  ========================== " .. numMaxShow)
    local setMaxShowNumAction = CSetMaxScreenShowNum.Create()
    setMaxShowNumAction.maxscreenshownum = numMaxShow
    LuaProtocolManager.getInstance():send(setMaxShowNumAction)
    if GetIsInFamilyFight() then
        local datamanager = require "logic.family.familyfightmanager"
        if datamanager then
            datamanager:SystemSetToResetData()
        end
    end
end

function SystemSettingNewDlg.handleChangeFPS()

    local value = gGetGameConfigManager():GetConfigValue("screenfresh")
	
	local beanConfigManager = BeanConfigManager.getInstance()
	local beanTabel = beanConfigManager:GetTableByName("SysConfig.cfpssetting")
	local record = beanTabel:getRecorder(1)
	
	local maxNum = 30
	
	if not value then
        value = 1
    end
	
	if value == 1 then
		maxNum = record.morevalue
	else
		maxNum = record.lessvalue
	end
	
	gSetMaxFps(maxNum)
end

function SystemSettingNewDlg:handleAutoVoice(arg)
	--print("SystemSettingNewDlg.handleAutoVoice")
	local e = CEGUI.toWindowEventArgs(arg)
	local window = e.window
	local id = window:getID()
	
	local saveValue = 0
	if window:isSelected() then
		saveValue = 1
	end
	
	local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(id)
	if record.id ~= -1 then
		local strKey = record.key
		gGetGameConfigManager():SetConfigValue(strKey, saveValue)
	end
	gGetGameConfigManager():ApplyConfig()
	gGetGameConfigManager():SaveConfig()
	
	SystemSettingNewDlg.sendGameConfig(id, saveValue)
end

function SystemSettingNewDlg:handleOnSoundSwitch(arg)
	--音效开关
	if self.m_soundEnable:isSelected() then
		gGetGameConfigManager():SetConfigValue("soundeffect", 1)
	else
		gGetGameConfigManager():SetConfigValue("soundeffect", 0)
	end
	gGetGameConfigManager():ApplyConfig()
	gGetGameConfigManager():SaveConfig()
end

function SystemSettingNewDlg:handleOnMusicSwitch(arg)
	--音乐开关
	if self.m_musicEnable:isSelected() then
		gGetGameConfigManager():SetConfigValue("sound", 1)
	else
		gGetGameConfigManager():SetConfigValue("sound", 0)
	end
	gGetGameConfigManager():ApplyConfig()
	gGetGameConfigManager():SaveConfig()
end

function SystemSettingNewDlg:handleQuitAccout(arg)
	gGetMessageManager():AddConfirmBox(
	eConfirmExitGame,
	MHSD_UTILS.get_msgtipstring(160016), --确定登出当前账号？？
	SystemSettingNewDlg.handleConfimQuitClick,self,
	MessageManager.HandleDefaultCancelEvent,MessageManager
	)
end

function SystemSettingNewDlg:handleNewWarnClick(arg)
	NewsWarnDlg.getInstanceAndShow()
end

function SystemSettingNewDlg:handleConfimQuitClick(arg)
    local p = require("protodef.fire.pb.creturntologin"):new()
	LuaProtocolManager:send(p)
    local huodongmanager = require"logic.huodong.huodongmanager".getInstanceNotCreate()
    if huodongmanager then
        huodongmanager:OpenPush()
    end
end

local p = require "protodef.fire.pb.sgetsysconfig"
function p:process()
    local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
    for k = SettingEnum.rolePointAdd, SettingEnum.zhenfaAdd do 
       if self.sysconfigmap[k] == 1 then
           YangChengListDlg.GameStartInitCell(k - 19)
        else
            local cellType = notify_cells[k - 19]
            if cellType then
                 YangChengListDlg.removeTheType(cellType)
            end
        end
    end
    
    if self.sysconfigmap[SettingEnum.equipendure] and self.sysconfigmap[SettingEnum.equipendure]==1 then
        YangChengListDlg.GameStartInitCell_xiuli()
    else
        local cellType = notify_cells[YangChengListDlg.nTypeXiuliKey]
        if cellType then
             YangChengListDlg.removeTheType(cellType)
        end
    end

    YangChengListDlg.setInit(1)

    for k = SettingEnum.skillopen, SettingEnum.patopen do
        if self.sysconfigmap[k] then
            MainControl.getInstanceNotCreate():setBtnOpenStatus(k, self.sysconfigmap[k])
        end
    end

    for k =SettingEnum.guajiopen, SettingEnum.huodongopen do
        if self.sysconfigmap[k] then
            LogoInfoDialog.getInstanceNotCreate():setBtnOpenStatus(k, self.sysconfigmap[k])
        end
    end

    -- 系统设置的处理相关（只需要修改循环的范围即可）
--	for k = SettingEnum.Music, SettingEnum.refuseotherseeequip do
-- 		local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(k)
--		if self.sysconfigmap[k] ~= nil then
--			gGetGameConfigManager():SetConfigValue(record.key, self.sysconfigmap[k])
--		end
--	end
    for k = SettingEnum.AutoVoiceGang, SettingEnum.TeamChannel do
		local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(k)
		if self.sysconfigmap[k] ~= nil then
			gGetGameConfigManager():SetConfigValue(record.key, self.sysconfigmap[k])
		end
	end

	local val = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(SettingEnum.refuseqiecuo)
	if self.sysconfigmap[SettingEnum.refuseqiecuo] ~= nil then
		gGetGameConfigManager():SetConfigValue(val.key, self.sysconfigmap[SettingEnum.refuseqiecuo])
	end

    local val = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(SettingEnum.refuseclan)
	if self.sysconfigmap[SettingEnum.refuseclan] ~= nil then
		gGetGameConfigManager():SetConfigValue(val.key, self.sysconfigmap[SettingEnum.refuseclan])
	end

    local val = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(SettingEnum.refuseotherseeequip)
	if self.sysconfigmap[SettingEnum.refuseotherseeequip] ~= nil then
		gGetGameConfigManager():SetConfigValue(val.key, self.sysconfigmap[SettingEnum.refuseotherseeequip])
	end

	gGetGameConfigManager():ApplyConfig()
	gGetGameConfigManager():SaveConfig()

    SystemSettingNewDlg.DoResetConfig()
end

function SystemSettingNewDlg.sendGameConfig(id, value)
	local req = require "protodef.fire.pb.cresetsysconfig".Create()
    req.sysconfigmap[id] = value
    LuaProtocolManager.getInstance():send(req)
end

function SystemSettingNewDlg:loadConfigInit()
    -- 系统设置的处理相关（修改循环的范围，然后加入新增系统设置代码）
	for id = self.SettingEnum.Music, self.SettingEnum.screenrecord do
		local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(id)
		if record.id ~= -1 then
			local strKey = record.key
			local value = gGetGameConfigManager():GetConfigValue(strKey)
			if value ~=-1 then
				local winMgr = CEGUI.WindowManager:getSingleton()
				if record.id == self.SettingEnum.Music then  --音乐开关
					if value == 0 then 
						self.m_musicEnable:setSelectedNoEvent(false)
					else
						self.m_musicEnable:setSelectedNoEvent(true)
					end
				elseif record.id == self.SettingEnum.Volume then --音量
                    local pos = self.m_volumButton:getPosition()
	                local size = self.m_volumButton:getSize()
                    local minOffset = self.m_volumButtonOrgOffset
                    local maxOffset =  self.m_volumBar:getPixelSize().width - self.m_volumButton:getPixelSize().width * 0.75
                    local totalWidth = maxOffset - minOffset
                    local scaleValue = value / 255.0
                    pos.x.offset = scaleValue * totalWidth - self.m_volumButton:getPixelSize().width * 0.5
                    self.m_volumButton:setPosition(pos)
	                self.m_volumButton:setSize(size)
                    self.m_volumBar:setProgress(scaleValue)
				elseif record.id == self.SettingEnum.SoundSpecEffect then  --音效开关
					if value == 0 then 
						self.m_soundEnable:setSelectedNoEvent(false)
					else
						self.m_soundEnable:setSelectedNoEvent(true)
					end
				elseif record.id == self.SettingEnum.SceneEffect then
					if value == 1 then  --场景特效
						self.m_sceneEffectOpen:setSelectedNoEvent(true)
					else
						self.m_sceneEffectClose:setSelectedNoEvent(true)
					end
				elseif record.id == self.SettingEnum.MaxScreenShowNum then
					if value == 1 then  --显示人数
						self.m_personShowMore:setSelectedNoEvent(true)
					else
						self.m_personShowLess:setSelectedNoEvent(true)
					end
				elseif record.id == self.SettingEnum.ScreenRefresh then
					if value == 1 then  --刷新频率
						self.m_refreshHigh:setSelectedNoEvent(true)
					else
						self.m_refreshLow:setSelectedNoEvent(true)
					end
				elseif record.id == self.SettingEnum.AutoVoiceGang then
					if value == 1 then  --自动语音 公会
						self.m_autoPlayVoiceBangpai:setSelectedNoEvent(true)
					else
						self.m_autoPlayVoiceBangpai:setSelectedNoEvent(false)
					end
				elseif record.id == self.SettingEnum.AutoVoiceWorld then
					if value == 1 then  --自动语音 世界
						self.m_autoPlayVoiceShijie:setSelectedNoEvent(true)
					else
						self.m_autoPlayVoiceShijie:setSelectedNoEvent(false)
					end
				elseif record.id == self.SettingEnum.AutoVoiceTeam then
					if value == 1 then  --自动语音 队伍
						self.m_autoPlayVoiceDuiwu:setSelectedNoEvent(true)
					else
						self.m_autoPlayVoiceDuiwu:setSelectedNoEvent(false)
					end
				elseif record.id == self.SettingEnum.AutoVoiceSchool then
					if value == 1 then  --自动语音 职业
						self.m_autoPlayVoiceZhiye:setSelectedNoEvent(true)
					else
						self.m_autoPlayVoiceZhiye:setSelectedNoEvent(false)
					end
				elseif record.id == self.SettingEnum.RefuseFriend then
					if value == 0 then  --好友拒绝邀请
						self.m_refuseFriend:setSelectedNoEvent(false)
					else
						self.m_refuseFriend:setSelectedNoEvent(true)
					end
				elseif record.id == self.SettingEnum.refuseqiecuo then
					if value == 0 then  --拒绝切磋
						self.m_refusePVP:setSelectedNoEvent(false)
					else
						self.m_refusePVP:setSelectedNoEvent(true)
					end
				elseif record.id == self.SettingEnum.refuseclan then
					if value == 0 then  --拒绝公会邀请
						self.m_refuseClan:setSelectedNoEvent(false)
					else
						self.m_refuseClan:setSelectedNoEvent(true)
					end
                elseif record.id == self.SettingEnum.refuseotherseeequip then
                    if value == 0 then  --拒绝查看装备
                        self.m_refuseSeeEquip:setSelectedNoEvent(false)
                    else
                        self.m_refuseSeeEquip:setSelectedNoEvent(true)
                    end
				elseif record.id == self.SettingEnum.screenrecord then
                    if value == 0 then  --拒绝查看装备
                        self.m_LuPingSwitch:setLookStatus(CEGUI.OFF)
                    else
                        self.m_LuPingSwitch:setLookStatus(CEGUI.ON)
                    end
				end
			end
		end
	end

    local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(self.SettingEnum.rolldianshezhi)
    if record then
        local strKey = record.key
        local value = gGetGameConfigManager():GetConfigValue(strKey)

        if value == 1 then
            self.m_rollSetting:setSelectedNoEvent(true)
        else
            self.m_rollSetting:setSelectedNoEvent(false)
        end
    end

end

local _instance

function SystemSettingNewDlg.getInstance()
	if not _instance then
		_instance = SystemSettingNewDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function SystemSettingNewDlg.getInstanceAndShow()
	if not _instance then
		_instance = SystemSettingNewDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function SystemSettingNewDlg.getInstanceNotCreate()
	return _instance
end


function SystemSettingNewDlg.DestroyDialog()
	if _instance then
	_instance.buttonFBSetting.animation:stop()
	_instance.cc_lianxikefu.animation:stop()
	_instance.cc_libaozhongxin.animation:stop()
	_instance.cc_xiazaiyouxi.animation:stop()
		if not _instance.m_bCloseIsHide then
            local dlg = require "logic.framesimplipy".getInstanceNotCreate()
            if dlg then
                if not _instance.m_frameSetting:isSelected() then
                    dlg:CloseDlg()
                end
                
            end
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end

	end
end

function SystemSettingNewDlg.ToggleOpenClose()
	if not _instance then
		_instance = SystemSettingNewDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function SystemSettingNewDlg.GetLayoutFileName()
	return "systemsetting1.layout"
end

function SystemSettingNewDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, SystemSettingNewDlg)
	
	self.m_eDialogType[DialogTypeTable.eDialogType_BattleClose] = 1
    self.m_eDialogType[DialogTypeTable.eDialogType_InScreenCenter] = 1
	return self
end

return SystemSettingNewDlg
