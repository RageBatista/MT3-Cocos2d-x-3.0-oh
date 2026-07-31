require "logic.dialog"

CChatOutBoxOperatelDlg = { bOpenChatWnd = true }
setmetatable(CChatOutBoxOperatelDlg, Dialog)
CChatOutBoxOperatelDlg.__index = CChatOutBoxOperatelDlg

local WNDSTATE_NONE = 1
local WNDSTATE_SHOW = 2
local WNDSTATE_HIDE = 3

local _instance

local SHOWMINHEIGHT = 0
local SHOWMAXHEIGHT = 0
local CHAZHI = 90

local ChanelImageSetName = "liaotian"  --频道图标set

local ChanelImageName = {
	"liaotian_dangqian",
	"liaotian_duiwu",
	"liaotian_zhiye",
	"liaotian_gonghui",
	"liaotian_shijie",	
	"liaotian_xitong",
	"liaotian_xiaoxi",
	"NewsNormal",
	"NewsNormal",
	"FamilyNormal",
	"TrumpetNormal",
	"SuidNormal",
    "InCampNormal",
    "yijianhanhua",
	"yijianhanhua"
};


function CChatOutBoxOperatelDlg.getInstance()
	if not _instance then
		_instance = CChatOutBoxOperatelDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function CChatOutBoxOperatelDlg.getInstanceAndShow()
	if not _instance then
		_instance = CChatOutBoxOperatelDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function CChatOutBoxOperatelDlg.getInstanceNotCreate()
	return _instance
end

function CChatOutBoxOperatelDlg.DestroyDialog()

	CChatOutBoxOperatelDlg.ClearVoice(nil)

	if _instance then
		if not _instance.m_bCloseIsHide then
            NotificationCenter.removeObserver(Notifi_TeamListChange, CChatOutBoxOperatelDlg.refreshTesmVoiceBtn_Change)
            NotificationCenter.removeObserver(Notifi_TeamMemberStateChange, CChatOutBoxOperatelDlg.refreshTesmVoiceBtn)
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function CChatOutBoxOperatelDlg.ToggleOpenClose()
	if not _instance then
		_instance = CChatOutBoxOperatelDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CChatOutBoxOperatelDlg.GetLayoutFileName()
	return "chatoutsimple.layout"
end

function CChatOutBoxOperatelDlg:new()
	local self = { }
	self = Dialog:new()
	setmetatable(self, CChatOutBoxOperatelDlg)
	return self
end

local function EnsureVoiceCdTimeShow(self)
	self.m_VioceBtnCdTimeShow = self.m_VioceBtnCdTimeShow or {}
	for i = 0, 3 do
		self.m_VioceBtnCdTimeShow[i] = self.m_VioceBtnCdTimeShow[i] or 0
	end
end

local function UpdateVoiceCdTime(self, index, maskWnd, cdWnd, fElapse)
	EnsureVoiceCdTimeShow(self)
	if self.m_VioceBtnCdTimeShow[index] == 0 then
		return
	end

	if not maskWnd or not cdWnd then
		self.m_VioceBtnCdTimeShow[index] = 0
		return
	end

	self.m_VioceBtnCdTimeShow[index] = self.m_VioceBtnCdTimeShow[index] - fElapse / 1000
	if self.m_VioceBtnCdTimeShow[index] <= 0 then
		self.m_VioceBtnCdTimeShow[index] = 0
		maskWnd:setVisible(false)
		cdWnd:setVisible(false)
	else
		cdWnd:setText(math.floor(self.m_VioceBtnCdTimeShow[index]))
	end
end

local function SetVoiceCdTime(self, index, maskWnd, cdWnd, time)
	EnsureVoiceCdTimeShow(self)
	time = tonumber(time) or 0
	if not maskWnd or not cdWnd or time <= 0 then
		self.m_VioceBtnCdTimeShow[index] = 0
		if maskWnd then
			maskWnd:setVisible(false)
		end
		if cdWnd then
			cdWnd:setVisible(false)
		end
		return
	end

	maskWnd:setVisible(true)
	cdWnd:setVisible(true)
	cdWnd:setText(math.floor(time))
	self.m_VioceBtnCdTimeShow[index] = time
end

local function IsChatContentBoxReady(self)
	return self
		and self.m_pMainFrame
		and self.m_pAniWnd
		and self.m_pMinButton
		and self.m_pMaxButton
		and self.m_udimBackYScale ~= nil
		and self.m_udimBackYoffset ~= nil
		and self.m_fAniSpeed ~= nil
end

function CChatOutBoxOperatelDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)

	self.m_MainFrame = winMgr:getWindow("chatoutsimple/mainback")

	--好友按钮
	self.m_pFriendBtn = CEGUI.Window.toPushButton(winMgr:getWindow("chatoutsimple/mainback/friend"))
	self.m_pFriendBtn:subscribeEvent("Clicked", CChatOutBoxOperatelDlg.HandleFriendBtnClick, self)

    --精灵按钮
    self.m_pJinglingBtn = CEGUI.Window.toPushButton(winMgr:getWindow("chatoutsimple/mainback/jingling"))
    self.m_pJinglingBtn:subscribeEvent("Clicked", CChatOutBoxOperatelDlg.HandleJinglingBtnClick, self)

	--显示聊天栏的按钮
	self.m_pShowBoxBtn = CEGUI.Window.toPushButton(winMgr:getWindow("chatoutsimple"))
	self.m_pShowBoxBtn:subscribeEvent("Clicked", CChatOutBoxOperatelDlg.HandleShowChatOutBoxBtnClick, self)

	--聊天框点击
	self.m_pContentBox = CEGUI.Window.toRichEditbox(winMgr:getWindow("chatoutsimple/back/main"))
	self.m_pContentBox:subscribeEvent("MouseButtonDown", CChatOutBoxOperatelDlg.HandleWndDownClick, self)
	self.m_pContentBox:subscribeEvent("MouseButtonUp", CChatOutBoxOperatelDlg.HandleWndUpClick, self)
	
	--放大按钮
	self.m_pMaxButton = CEGUI.Window.toPushButton(winMgr:getWindow("chatoutsimple/back/shangjiantou"))
	self.m_pMaxButton:subscribeEvent("Clicked", CChatOutBoxOperatelDlg.HandleMaxWindow, self)
	
	--缩小按钮
	self.m_pMinButton = CEGUI.Window.toPushButton(winMgr:getWindow("chatoutsimple/back/xiajiantou"))
	self.m_pMinButton:subscribeEvent("Clicked", CChatOutBoxOperatelDlg.HandleMinWindow, self)
	self.m_pMinButton:setVisible(false)

	--设置
	self.m_pSystemButton = CEGUI.Window.toPushButton(winMgr:getWindow("chatoutsimple/back/system"))
	self.m_pSystemButton:subscribeEvent("Clicked", CChatOutBoxOperatelDlg.HandleSystem, self)

	--好友消息，邮件消息提示
	self.m_pFriendTips = winMgr:getWindow("chatoutsimple/mainback/friend/friendtips")
	self.m_pFriendTips:setVisible(false)

    --在线客服
    self.m_pKefu = winMgr:getWindow("chatoutsimple/mainback/kefu")
    self.m_pKefu:subscribeEvent("Clicked", CChatOutBoxOperatelDlg.HandleKeFu, self)

	--邮件提示红点
	self.m_pMailTips = winMgr:getWindow("chatoutsimple/mainback/friend/mailtips")
	self.m_pMailTips:setVisible(false)

	--录像按钮
	self.m_StartRecordBtn = CEGUI.toPushButton(winMgr:getWindow("chatoutsimple/mainback/luping"))
	self.m_StartRecordBtn:subscribeEvent("Clicked", CChatOutBoxOperatelDlg.HandleStartRecord, self)
	self.m_StartRecordBtn:setVisible(false)

	self.m_StopRecordBtn = CEGUI.toPushButton(winMgr:getWindow("chatoutsimple/mainback/quxiao"))
	self.m_StopRecordBtn:subscribeEvent("Clicked", CChatOutBoxOperatelDlg.HandleStopRecord, self)
	self.m_StopRecordBtn:setVisible(false)

    --窗口动画
	self.m_pAniWnd = winMgr:getWindow("chatoutsimple/back");

	--世界
	self.m_pVoiceWorldBtn = CEGUI.toPushButton(winMgr:getWindow("voiceWorld"))
	self.m_pVoiceWorldBtn:subscribeEvent("MouseButtonDown", CChatOutBoxOperatelDlg.HandleVoiceBegin, self)
	self.m_pVoiceWorldBtn:subscribeEvent("MouseButtonUp", CChatOutBoxOperatelDlg.HandleVoiceEnd, self)
	self.m_pVoiceWorldBtn:subscribeEvent("MouseMove", CChatOutBoxOperatelDlg.HandleVoiceMove, self)
	self.m_pVoiceWorldBtn:SetMouseLeaveReleaseInput(false)
	self.m_pVoiceWorldBtn:setVisible(false)
	self.m_pVoiceWorldBtn_mask = winMgr:getWindow("voiceWorld/mask")
	self.m_pVoiceWorldBtn_mask:setVisible(false)
	self.m_pVoiceWorldBtn_cdtime = winMgr:getWindow("voiceWorld/cdtime")
	self.m_pVoiceWorldBtn_cdtime:setVisible(false)

	--工会
	self.m_pVoiceUnionBtn = CEGUI.toPushButton(winMgr:getWindow("voiceunion"))
	self.m_pVoiceUnionBtn:subscribeEvent("MouseButtonDown", CChatOutBoxOperatelDlg.HandleVoiceBegin, self)
	self.m_pVoiceUnionBtn:subscribeEvent("MouseButtonUp", CChatOutBoxOperatelDlg.HandleVoiceEnd, self)
	self.m_pVoiceUnionBtn:subscribeEvent("MouseMove", CChatOutBoxOperatelDlg.HandleVoiceMove, self)
	self.m_PosGonghui_x = self.m_pVoiceUnionBtn:getPosition().x.offset
	self.m_PosGonghui_y = self.m_pVoiceUnionBtn:getPosition().y.offset
	self.m_pVoiceUnionBtn:SetMouseLeaveReleaseInput(false)
	self.m_pVoiceUnionBtn_mask = winMgr:getWindow("voiceunion/mask")
	self.m_pVoiceUnionBtn_mask:setVisible(false)
	self.m_pVoiceUnionBtn_cdtime = winMgr:getWindow("voiceunion/cdtime")
	self.m_pVoiceUnionBtn_cdtime:setVisible(false)

	--职业
	self.m_pVoiceClassBtn = CEGUI.toPushButton(winMgr:getWindow("voiceteam"))
	self.m_pVoiceClassBtn:subscribeEvent("MouseButtonDown", CChatOutBoxOperatelDlg.HandleVoiceBegin, self)
	self.m_pVoiceClassBtn:subscribeEvent("MouseButtonUp", CChatOutBoxOperatelDlg.HandleVoiceEnd, self)
	self.m_pVoiceClassBtn:subscribeEvent("MouseMove", CChatOutBoxOperatelDlg.HandleVoiceMove, self)
	self.m_pVoiceClassBtn:SetMouseLeaveReleaseInput(false)
	self.m_pVoiceClassBtn_mask = winMgr:getWindow("voiceteam/mask")
	self.m_pVoiceClassBtn_mask:setVisible(false)
	self.m_pVoiceClassBtn_cdtime = winMgr:getWindow("voiceteam/cdtime")
	self.m_pVoiceClassBtn_cdtime:setVisible(false)

	--队伍
	self.m_pVoiceTeamBtn = CEGUI.toPushButton(winMgr:getWindow("voiceteam2"))
	self.m_pVoiceTeamBtn:subscribeEvent("MouseButtonDown", CChatOutBoxOperatelDlg.HandleVoiceBegin, self)
	self.m_pVoiceTeamBtn:subscribeEvent("MouseButtonUp", CChatOutBoxOperatelDlg.HandleVoiceEnd, self)
	self.m_pVoiceTeamBtn:subscribeEvent("MouseMove", CChatOutBoxOperatelDlg.HandleVoiceMove, self)
	self.m_pVoiceTeamBtn:setVisible(false)
	self.m_PosTeam_x = self.m_pVoiceTeamBtn:getPosition().x.offset
	self.m_PosTeam_y = self.m_pVoiceTeamBtn:getPosition().y.offset
	self.m_pVoiceTeamBtn:SetMouseLeaveReleaseInput(false)

	self.m_pVoiceTeamBtn_mask = winMgr:getWindow("voiceteam2/mask")
	self.m_pVoiceTeamBtn_mask:setVisible(false)
	self.m_pVoiceTeamBtn_cdtime = winMgr:getWindow("voiceteam2/cdtime")
	self.m_pVoiceTeamBtn_cdtime:setVisible(false)

	self:GetWindow():subscribeEvent("Hidden", CChatOutBoxOperatelDlg.ClearVoice, self)
	self:GetWindow():subscribeEvent("AlphaChanged", CChatOutBoxOperatelDlg.ClearVoice, self)

	local nShowGonghui = require("logic.task.taskhelper").isInGonghui()
	self.m_pVoiceUnionBtn:setVisible(nShowGonghui)

    NotificationCenter.addObserver(Notifi_TeamListChange, CChatOutBoxOperatelDlg.refreshTesmVoiceBtn_Change)
    NotificationCenter.addObserver(Notifi_TeamMemberStateChange, CChatOutBoxOperatelDlg.refreshTesmVoiceBtn)

	CChatOutBoxOperatelDlg.refreshTeamVoiceBtnPos()

	self.m_WndState = WNDSTATE_NONE
	self.m_fAniElapseTime = 0
	self.m_aniWndShow = false
	self.m_bRecording = false
	self.m_ConfigWnd = nil
	self.m_pConfigWnd = nil
	self.m_VoiceBtnLastClickTime = 0
	self.m_voiceChanelid = 0
	self.m_voiceBeginTime = 0
	self.m_fAniTotalTime = 500
	self.m_fAniSpeed = 140 / self.m_fAniTotalTime

	self.m_udimBackYScale  = self.m_pAniWnd:getYPosition().scale
	self.m_udimBackYoffset = self.m_pAniWnd:getYPosition().offset
	SHOWMINHEIGHT = math.abs(self.m_pAniWnd:getPixelSize().height)
	SHOWMAXHEIGHT = math.abs(SHOWMINHEIGHT) + CHAZHI

	--获得服务器设置信息
	self.m_bFilterChannel = { }
	self.m_bFilterChannel[0] = gGetGameConfigManager():GetConfigValue("worldchannel") > 0
	self.m_bFilterChannel[1] = gGetGameConfigManager():GetConfigValue("guildchannel") > 0
	self.m_bFilterChannel[2] = gGetGameConfigManager():GetConfigValue("careerchannel") > 0
	self.m_bFilterChannel[3] = gGetGameConfigManager():GetConfigValue("currentchannel") > 0
	self.m_bFilterChannel[4] = gGetGameConfigManager():GetConfigValue("groupchannel") > 0
	self.m_bFilterChannel[5] = gGetGameConfigManager():GetConfigValue("zuduichannel") > 0

	EnsureVoiceCdTimeShow(self)

	--是否显示录像按钮
	local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
	local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(SettingEnum.screenrecord)
	local value = gGetGameConfigManager():GetConfigValue(record.key)
	if value == 1 then
		self:EnableRecordScreen(true)
	end

end

function CChatOutBoxOperatelDlg:HandleStartRecord(e)
	if gGetGameApplication():GetRecordState() == 0 then
		gGetGameApplication():StartRecordForIOS()
	elseif gGetGameApplication():GetRecordState() == 1 then
		GetCTipsManager():AddMessageTipById(162144)
	end
end

function CChatOutBoxOperatelDlg:HandleStopRecord(e)
	gGetGameApplication():StopRecordForIOS()
	self.m_StartRecordBtn:setVisible(true)
	self.m_StopRecordBtn:setVisible(false)
end

function CChatOutBoxOperatelDlg:EnableRecordScreen(enable)
	if enable then
		self.m_StartRecordBtn:setVisible(true)
		self.m_StopRecordBtn:setVisible(false)
	else
		self.m_StartRecordBtn:setVisible(false)
		self.m_StopRecordBtn:setVisible(false)
	end
end

-- c++用-----------bengin
function CChatOutBoxOperatelDlg.SetOpenChatWnd(open)
	CChatOutBoxOperatelDlg.bOpenChatWnd = open
end
-----end------

function CChatOutBoxOperatelDlg:ShowChatContent()
	if self.m_aniWndShow == false then
		self.m_WndState = WNDSTATE_SHOW
		self.m_aniWndShow = true
	end
end

function CChatOutBoxOperatelDlg:HideChatContent()
	if self.m_aniWndShow == true then
		self.m_WndState = WNDSTATE_HIDE
		self.m_aniWndShow = false
	end
end

function CChatOutBoxOperatelDlg:UpdateChatContentBox(fElapse)
	EnsureVoiceCdTimeShow(self)
	if not self.m_pMainFrame then
		self.m_WndState = WNDSTATE_NONE
		return
	end

	if self.m_WndState ~= WNDSTATE_NONE then
		if not IsChatContentBoxReady(self) then
			self.m_WndState = WNDSTATE_NONE
		elseif self.m_WndState == WNDSTATE_SHOW then
			if math.abs(self.m_pAniWnd:getYPosition().offset) - math.abs(self.m_udimBackYoffset) >= CHAZHI then
				self.m_pMinButton:setVisible(true)
				self.m_pMaxButton:setVisible(false)
				self.m_pAniWnd:setYPosition(CEGUI.UDim(self.m_udimBackYScale, -(math.abs(self.m_udimBackYoffset) + CHAZHI)))
				self.m_pAniWnd:setHeight(CEGUI.UDim(0, SHOWMAXHEIGHT))
				self.m_WndState = WNDSTATE_NONE
			else
				local curYPos = self.m_pAniWnd:getYPosition().offset - self.m_fAniSpeed * fElapse
				self.m_pAniWnd:setYPosition(CEGUI.UDim(self.m_udimBackYScale, curYPos))
                local h = self.m_pAniWnd:getHeight()
                h.offset = h.offset + self.m_fAniSpeed * fElapse
                self.m_pAniWnd:setHeight(h)
			end
		elseif self.m_WndState == WNDSTATE_HIDE then
			if math.abs(self.m_pAniWnd:getYPosition().offset) <= math.abs(self.m_udimBackYoffset) then
				self.m_pMinButton:setVisible(false)
				self.m_pMaxButton:setVisible(true)
				self.m_pAniWnd:setYPosition(CEGUI.UDim(self.m_udimBackYScale, self.m_udimBackYoffset))
				self.m_pAniWnd:setHeight(CEGUI.UDim(0, SHOWMINHEIGHT))
				self.m_WndState = WNDSTATE_NONE
			else
				local curYPos = self.m_pAniWnd:getYPosition().offset + self.m_fAniSpeed * fElapse
				self.m_pAniWnd:setYPosition(CEGUI.UDim(self.m_udimBackYScale, curYPos))
                local h = self.m_pAniWnd:getHeight()
                h.offset = h.offset - self.m_fAniSpeed * fElapse
                self.m_pAniWnd:setHeight(h)
			end
		end
	end

	UpdateVoiceCdTime(self, 0, self.m_pVoiceWorldBtn_mask, self.m_pVoiceWorldBtn_cdtime, fElapse)
	UpdateVoiceCdTime(self, 1, self.m_pVoiceUnionBtn_mask, self.m_pVoiceUnionBtn_cdtime, fElapse)
	UpdateVoiceCdTime(self, 2, self.m_pVoiceClassBtn_mask, self.m_pVoiceClassBtn_cdtime, fElapse)
	UpdateVoiceCdTime(self, 3, self.m_pVoiceTeamBtn_mask, self.m_pVoiceTeamBtn_cdtime, fElapse)
	
	if self.m_StartRecordBtn and self.m_StopRecordBtn and gGetGameApplication():GetRecordState() == 2 and self.m_StartRecordBtn:isVisible() then
		self.m_StartRecordBtn:setVisible(false)
		self.m_StopRecordBtn:setVisible(true)
		GetCTipsManager():AddMessageTipById(162145)
	end
end

function CChatOutBoxOperatelDlg.setGonghuiVoiceBtnVisible(bVisible)
	local this = CChatOutBoxOperatelDlg.getInstance()

	if this.m_pVoiceUnionBtn then
		this.m_pVoiceUnionBtn:setVisible(bVisible > 0)
		CChatOutBoxOperatelDlg.refreshTeamVoiceBtnPos()
	end
end

function CChatOutBoxOperatelDlg:HandleFriendBtnClick(args)
    local this = CChatOutBoxOperatelDlg.getInstance()

    if this.m_pMailTips:isVisible() then
        -- 注释掉这行代码，使其不执行
         require "logic.friend.friendmaillabel".Show(1)
    else
        require "logic.friend.friendmaillabel".Show(1)
    end
end

function CChatOutBoxOperatelDlg:HandleJinglingBtnClick(args)
    require "logic.jingling.jinglingdlg".getInstanceAndShow()
end

function CChatOutBoxOperatelDlg:HandleShowChatOutBoxBtnClick(args)
	local dlg = CChatOutputDialog.getInstance()
	if dlg then
		if dlg.m_pMainFrame:isVisible() == false then
			dlg:ToShow()
			--self.m_MainFrame:setVisible(false)
		end
	end
end

function CChatOutBoxOperatelDlg:HandleWndDownClick(args)
	CChatOutBoxOperatelDlg.bOpenChatWnd = true
end

function CChatOutBoxOperatelDlg:HandleWndUpClick(args)
	if CChatOutBoxOperatelDlg.bOpenChatWnd then
		CChatOutBoxOperatelDlg.bOpenChatWnd = false
		self:HandleShowChatOutBoxBtnClick(args)
	end
end

function CChatOutBoxOperatelDlg:HandleMaxWindow(args)
	if self.m_WndState == WNDSTATE_NONE then
		self:ShowChatContent()
	end
end

function CChatOutBoxOperatelDlg:HandleMinWindow(args)
	if self.m_WndState == WNDSTATE_NONE then
		self:HideChatContent()
	end
end

function CChatOutBoxOperatelDlg:HandleSystem(args)
	if self.m_pConfigWnd then
		return
	end

	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_pConfigWnd = winMgr:loadWindowLayout("insetpindaodialog.layout")

	if self.m_pConfigWnd then
		local checkBox1 = CEGUI.Window.toCheckbox(winMgr:getWindow("insetpindaodialog/pinbi/pindao1/box1"))
		checkBox1:setSelectedNoEvent(self.m_bFilterChannel[0])
		checkBox1:subscribeEvent("CheckStateChanged", CChatOutBoxOperatelDlg.HandleConfig1, self)

		local checkBox2 = CEGUI.Window.toCheckbox(winMgr:getWindow("insetpindaodialog/pinbi/pindao2/box2"))
		checkBox2:setSelectedNoEvent(self.m_bFilterChannel[1])
		checkBox2:subscribeEvent("CheckStateChanged", CChatOutBoxOperatelDlg.HandleConfig2, self)

		local checkBox3 = CEGUI.Window.toCheckbox(winMgr:getWindow("insetpindaodialog/pinbi/pindao3/box3"))
		checkBox3:setSelectedNoEvent(self.m_bFilterChannel[2])
		checkBox3:subscribeEvent("CheckStateChanged", CChatOutBoxOperatelDlg.HandleConfig3, self)

		local checkBox4 = CEGUI.Window.toCheckbox(winMgr:getWindow("insetpindaodialog/pinbi/pindao4/box4"))
		checkBox4:setSelectedNoEvent(self.m_bFilterChannel[3])
		checkBox4:subscribeEvent("CheckStateChanged", CChatOutBoxOperatelDlg.HandleConfig4, self)

		local checkBox5 = CEGUI.Window.toCheckbox(winMgr:getWindow("insetpindaodialog/pinbi/pindao5/box5"))
		checkBox5:setSelectedNoEvent(self.m_bFilterChannel[4])
		checkBox5:subscribeEvent("CheckStateChanged", CChatOutBoxOperatelDlg.HandleConfig5, self)

		local checkBox6 = CEGUI.Window.toCheckbox(winMgr:getWindow("insetpindaodialog/pinbi/pindao6/box6"))
		checkBox6:setSelectedNoEvent(self.m_bFilterChannel[5])
		checkBox6:subscribeEvent("CheckStateChanged", CChatOutBoxOperatelDlg.HandleConfig6, self)

		local okButton = winMgr:getWindow("insetpindaodialog/pinbi/OK");
		okButton:subscribeEvent("Clicked", CChatOutBoxOperatelDlg.HandleConfigOk, self)
		winMgr:getWindow("root_wnd"):addChildWindow(self.m_pConfigWnd)
	end
end

function CChatOutBoxOperatelDlg:HandleKeFu(args)
    gGetGameApplication():showMQView()
end

function CChatOutBoxOperatelDlg:HandleConfig1(e)
	self.m_bFilterChannel[0] = not self.m_bFilterChannel[0]
	local isOpen = 0
	if self.m_bFilterChannel[0] then
		isOpen = 1
	end

	require "logic.systemsettingdlgnew".sendGameConfig(12, isOpen)
end

function CChatOutBoxOperatelDlg:HandleConfig2(e)
	self.m_bFilterChannel[1] = not self.m_bFilterChannel[1]
	local isOpen = 0
	if self.m_bFilterChannel[1] then
		isOpen = 1
	end

	require "logic.systemsettingdlgnew".sendGameConfig(13, isOpen)
end

function CChatOutBoxOperatelDlg:HandleConfig3(e)
	self.m_bFilterChannel[2] = not self.m_bFilterChannel[2]
	local isOpen = 0
	if self.m_bFilterChannel[2] then
		isOpen = 1
	end

	require "logic.systemsettingdlgnew".sendGameConfig(14, isOpen)
end

function CChatOutBoxOperatelDlg:HandleConfig4(e)
	self.m_bFilterChannel[3] = not self.m_bFilterChannel[3]
	local isOpen = 0
	if self.m_bFilterChannel[3] then
		isOpen = 1
	end

	require "logic.systemsettingdlgnew".sendGameConfig(15, isOpen)
end

function CChatOutBoxOperatelDlg:HandleConfig5(e)
	self.m_bFilterChannel[4] = not self.m_bFilterChannel[4]
	local isOpen = 0
	if self.m_bFilterChannel[4] then
		isOpen = 1
	end

	require "logic.systemsettingdlgnew".sendGameConfig(16, isOpen)
end

function CChatOutBoxOperatelDlg:HandleConfig6(e)
	self.m_bFilterChannel[5] = not self.m_bFilterChannel[5]
	local isOpen = 0
	if self.m_bFilterChannel[5] then
		isOpen = 1
	end

	require "logic.systemsettingdlgnew".sendGameConfig(29, isOpen)
end

function CChatOutBoxOperatelDlg:HandleConfigOk(e)
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pConfigWnd)
	self.m_pConfigWnd = nil
end

function CChatOutBoxOperatelDlg:HandleVoiceBegin(args)
	--按钮点击间隔判断
	local lastClickTime = self.m_VoiceBtnLastClickTime
	local curTime = gGetServerTime()

	local isOK = true
	self.m_VoiceBtnLastClickTime = curTime
	if curTime - lastClickTime < VOICE_BTN_CLICK_INTERVAL then
		GetCTipsManager():AddMessageTipById(160172)
		isOK = false
	end

	--频道发言间隔判断
	local wndArgs = CEGUI.toWindowEventArgs(args)
	local strWndName = wndArgs.window:getName()
	self.m_voiceChanelid = ChannelType.CHANNEL_CURRENT
	if strWndName == "voiceWorld" then
		--世界频道
		self.m_pVoiceWorldBtn:activate()
		self.m_voiceChanelid = ChannelType.CHANNEL_WORLD
	elseif strWndName == "voiceunion" then
		--公会频道
		self.m_pVoiceUnionBtn:activate()
		self.m_voiceChanelid = ChannelType.CHANNEL_CLAN
	elseif strWndName == "voiceteam" then
		--职业频道
		self.m_pVoiceClassBtn:activate()
		self.m_voiceChanelid = ChannelType.CHANNEL_PROFESSION
	elseif strWndName == "voiceteam2" then
		--队伍频道
		self.m_pVoiceTeamBtn:activate()
		self.m_voiceChanelid = ChannelType.CHANNEL_TEAM
	end

	local mainRole = GetMainCharacter and GetMainCharacter() or nil
	local roleLevel = 0
	if mainRole and mainRole.getlevel then
		roleLevel = mainRole:getlevel()
	end
	if roleLevel < 45 and self.m_voiceChanelid == ChannelType.CHANNEL_PROFESSION then
		GetCTipsManager():AddMessageTipById(144480)
		isOK = false
	end

	----if GetMainCharacter():getlevel() < 45 and self.m_voiceChanelid == ChannelType.CHANNEL_WORLD then
		---GetCTipsManager():AddMessageTipById(140501)
		---isOK = false
      ----end


	if GetChatManager() then
		local fCdTime = GetChatManager():getSendChatInCdTime(self.m_voiceChanelid)
		if fCdTime > 0 then
			local tips = MHSD_UTILS.get_msgtipstring(160238)
			local sb = StringBuilder:new()
			sb:Set("parameter1", math.floor(fCdTime))
			local message = sb:GetString(tips)
			sb:delete()
			GetCTipsManager():AddMessageTip(message)
			isOK = false
		end
	end

    if self.m_bRecording then
        isOK = false
    end

	if isOK then
		require("logic.chat.voicedialog").DestroyDialog()

		local bCanRecord = gGetWavRecorder():canRecord()
		if bCanRecord then
			if gGetWavRecorder():start() then
				gGetVoiceManager():registerAutoClose(VOICE_RECORD_TYPE_CHAT)
				self.m_bRecording = true

                -- 为了防止录下杂音，必须在gGetWavRecorder():start()时调用，这里不调用
				--gGetVoiceManager():PauseMusicAndEffectForLua()

				self.m_voiceBeginTime = gGetServerTime()

				--启动录音后再显示界面
			    local pVoiceUI = require("logic.chat.voicedialog").getInstanceAndShow()
			    SetPositionScreenCenter(pVoiceUI:GetWindow())
			    pVoiceUI:setVoiceRecordUI(true)
			end
		else
			gGetVoiceManager():showTip_RequirePermission()
		end
	end

	if strWndName == "voiceWorld" then
		--世界频道
		self.m_pVoiceWorldBtn:activate()
	elseif strWndName == "voiceunion" then
		--公会频道
		self.m_pVoiceUnionBtn:activate()
	elseif strWndName == "voiceteam" then
		--职业频道
		self.m_pVoiceClassBtn:activate()
	elseif strWndName == "voiceteam2" then
		--队伍频道
		self.m_pVoiceTeamBtn:activate()
	end

end

function CChatOutBoxOperatelDlg:HandleVoiceEnd(args)
	if not self.m_bRecording then
		return
	end

	if not require("logic.chat.voicedialog").getInstanceNotCreate() then
		return
	end

	self.m_bRecording = false

    require("logic.chat.voicedialog").DestroyDialog()

	gGetVoiceManager():ResumeEffectForLua()
	local BackMusic = gGetGameConfigManager():GetConfigValue("sound")
	if BackMusic ~= 0 then
		gGetVoiceManager():ResumeMusicForLua()
	end

	gGetWavRecorder():stop()
	gGetVoiceManager():unregisterAutoClose()

	local mouseEvent = CEGUI.toMouseEventArgs(args)

    if mouseEvent.handled == 0 then
        local wndArgs = CEGUI.toWindowEventArgs(args)
        local pVoiceBtn = CEGUI.toPushButton(wndArgs.window)
        if not self:isHitVoiceRecordUI(pVoiceBtn, mouseEvent.position.x, mouseEvent.position.y) then
            return
        end
    end

	if mouseEvent.handled == 0 or mouseEvent.handled == 2 then
		local recordTime = gGetServerTime() - self.m_voiceBeginTime
		if recordTime < 500 then  
			GetCTipsManager():AddMessageTipById(160141)
			return
		end

		gGetVoiceManager():ProcessVoiceDataForLua(recordTime, self.m_voiceChanelid, 0)

	end
end

function CChatOutBoxOperatelDlg:HandleVoiceMove(args)
	if self.m_bRecording then
		local wndArgs = CEGUI.toWindowEventArgs(args)
		local pVoiceBtn = CEGUI.toPushButton(wndArgs.window)
		local mouseEvent = CEGUI.toMouseEventArgs(args)

        local pVoiceUI = require("logic.chat.voicedialog").getInstanceNotCreate()
        if pVoiceUI then
		    pVoiceUI:setVoiceRecordUI(self:isHitVoiceRecordUI(pVoiceBtn, mouseEvent.position.x, mouseEvent.position.y));
        end
	end
end

function CChatOutBoxOperatelDlg:SetCdTimeForChannel(channelid, time)
	EnsureVoiceCdTimeShow(self)
	if channelid == ChannelType.CHANNEL_WORLD then
		--世界频道
		SetVoiceCdTime(self, 0, self.m_pVoiceWorldBtn_mask, self.m_pVoiceWorldBtn_cdtime, time)
	elseif channelid == ChannelType.CHANNEL_CLAN then
		--公会频道
		SetVoiceCdTime(self, 1, self.m_pVoiceUnionBtn_mask, self.m_pVoiceUnionBtn_cdtime, time)
	elseif channelid == ChannelType.CHANNEL_PROFESSION then
		--职业频道
		SetVoiceCdTime(self, 2, self.m_pVoiceClassBtn_mask, self.m_pVoiceClassBtn_cdtime, time)
	elseif channelid == ChannelType.CHANNEL_TEAM then
		--队伍频道
		SetVoiceCdTime(self, 3, self.m_pVoiceTeamBtn_mask, self.m_pVoiceTeamBtn_cdtime, time)
	end
end

function CChatOutBoxOperatelDlg:isHitVoiceRecordUI(pVoiceBtn, mouseX, mouseY)
	local pos = pVoiceBtn:GetScreenPos()
	local sz = pVoiceBtn:getPixelSize()

	local x = mouseX - pos.x;
	local y = mouseY - pos.y;
	local radii = sz.width / 2;
	local absX = radii - x;
	local absY = radii - y;

	return(absX * absX + absY * absY) <(radii * radii)
end

function CChatOutBoxOperatelDlg.ClearVoice(args)
    if _instance then
	    local eVoiceEnd = CEGUI.EventArgs()
    	eVoiceEnd.handled = 3
		_instance:HandleVoiceEnd(eVoiceEnd)
    end
end

function CChatOutBoxOperatelDlg.refreshTeamVoiceBtnPos()

	local this = CChatOutBoxOperatelDlg.getInstance()

	if this.m_pVoiceUnionBtn:isVisible() then
		this.m_pVoiceTeamBtn:setPosition(CEGUI.UVector2(CEGUI.UDim(0, this.m_PosTeam_x), CEGUI.UDim(0, this.m_PosTeam_y)))
	else
		this.m_pVoiceTeamBtn:setPosition(CEGUI.UVector2(CEGUI.UDim(0, this.m_PosGonghui_x), CEGUI.UDim(0, this.m_PosGonghui_y)))
	end

end

function CChatOutBoxOperatelDlg.refreshTesmVoiceBtn_Change()
	CChatOutBoxOperatelDlg.refreshTeamBtn()
end

function CChatOutBoxOperatelDlg.refreshTesmVoiceBtn()
	CChatOutBoxOperatelDlg.refreshTeamBtn()
end

function CChatOutBoxOperatelDlg.refreshTeamBtn()

	if GetTeamManager() == nil then
		return
	end

	local bShowVoiceBtn = false
	local bOnTeam = GetTeamManager():IsOnTeam()
	if bOnTeam == false then
		bShowVoiceBtn = false
	else
		bShowVoiceBtn = true

		local myself = GetTeamManager():GetMemberSelf()
		if myself and myself.eMemberState == eTeamMemberAbsent then
			bShowVoiceBtn = true
		end
	end

	CChatOutBoxOperatelDlg.setTeamVoiceBtnVisible(bShowVoiceBtn)

end

function CChatOutBoxOperatelDlg.setTeamVoiceBtnVisible(bVisible)
	local this = CChatOutBoxOperatelDlg.getInstance()

	if this.m_pVoiceTeamBtn then
		this.m_pVoiceTeamBtn:setVisible(bVisible)
		CChatOutBoxOperatelDlg.refreshTeamVoiceBtnPos()
	end
end

function CChatOutBoxOperatelDlg.RefreshNotify()
	local this = CChatOutBoxOperatelDlg.getInstance()

	this.m_pFriendTips:setVisible(false)
	this.m_pMailTips:setVisible(false)

	local nFriendMsgNum = gGetFriendsManager():GetNotReadMsgNum()
	local nMailMsgNum = require("logic.friend.maildialog").GlobalGetMailNotReadNum()

	--邮件优先显示
	if nMailMsgNum > 0 then
		this.m_pMailTips:setVisible(true)
	elseif nFriendMsgNum > 0 then
		this.m_pFriendTips:setVisible(true)
	end

    require("logic.friend.friendmaillabel").checkRedPoint()
end

function CChatOutBoxOperatelDlg:GetMsgTitleByType(ltype, roleTitle, roleCamp)
	local channel = "<I s=\""..ChanelImageSetName.."\" i=\""..ChanelImageName[ltype].."\"></I>"
	local camp = ""
	local title = ""
	
    if roleCamp == 1 then
        camp = "<I s=\"MainControl\" i=\"campred\"></I>"
    elseif roleCamp == 2 then
        camp = "<I s=\"MainControl\" i=\"campblue\"></I>"
	end

	if roleTitle > 0 then
		local titleRecord = BeanConfigManager.getInstance():GetTableByName("title.ctitleconfig"):getRecorder(roleTitle)
		if titleRecord then
			if titleRecord.chatsee then
				strTitle = titleRecord.imageui
			end
		end
	end
    
	local strText = channel..camp..title
  
	return strText
end

function CChatOutBoxOperatelDlg:AddChatMsgUuid(uuid, text)
    local ccMgr = GetChatCellManager()
	local cci, channel = ccMgr:GetChatInfoFormUuid(uuid)
    if cci then
        local record = {}
        record.channel = channel
        record.roleid = cci.m_iRoleId
        record.roleShapeId = cci.m_iShapeId
        record.roleTitle = 0
        record.roleCamp = 0
        record.strName = cci.m_sRoleName
        record.chatContent = text
        record.recordID = cci.m_bIsVoice and -1 or cci.m_iRecordId -- 语音的recordID需要为-1，才能出现小喇叭图标
        self:AddChatMsg(record,true,true,true)
    end
end

function CChatOutBoxOperatelDlg:AddChatMsg(record, bRefreshBox, bHandleEnd, bAppendRecord)
	local this = CChatOutBoxOperatelDlg.getInstance()

	local ltype = record.channel
	-- do not show the system msg and message msg in left-down corner chat box
	if ltype == ChannelType.CHANNEL_MESSAGE then
		return
	end

	if this.m_bFilterChannel[0] == false and ltype == ChannelType.CHANNEL_WORLD then
		--世界
		return
	end
	if this.m_bFilterChannel[1] == false and ltype == ChannelType.CHANNEL_CLAN then
		--工会
		return
	end
	if this.m_bFilterChannel[2] == false and ltype == ChannelType.CHANNEL_PROFESSION then
		--职业
		return
	end
	if this.m_bFilterChannel[3] == false and ltype == ChannelType.CHANNEL_CURRENT then
		--当前
		return
	end
	if this.m_bFilterChannel[4] == false and ltype == ChannelType.CHANNEL_TEAM then
		--队伍
		return
	end
	if this.m_bFilterChannel[5] == false and ltype == ChannelType.CHANNEL_TEAM_APPLY then
		--队伍
		return
	end
	
	--排除自身获得奖励的消息添加到综合频道
	if record.roleID == -gGetDataManager():GetMainCharacterID()  then
		return
	end

	local bCheckShied = false
	if ltype == ChannelType.CHANNEL_CURRENT
		or ltype == ChannelType.CHANNEL_TEAM
		or ltype == ChannelType.CHANNEL_PROFESSION
		or ltype == ChannelType.CHANNEL_CLAN
		or ltype == ChannelType.CHANNEL_FAMILY
		or ltype == ChannelType.CHANNEL_WORLD
		or ltype == ChannelType.CHANNEL_BUGLE
		or ltype == ChannelType.CHANNEL_CAMP then

		bCheckShied = true
	end

	if not record.forceCheckShied then
		bCheckShied = false
	end

	if record.strName == "" then
		bCheckShied = false
	end

	local TitleParseString = self:GetMsgTitleByType(ltype, record.roleTitle, record.roleCamp)
	this.m_pContentBox:AppendParseText(CEGUI.String(TitleParseString), false)

	if record.strName ~= "" and this.m_pContentBox then
		local text = "<T t=\"[" .. record.strName .. "]\"" .. " c=\"" .. "FF00C6FF" .. "\"" .. "></T>"
		this.m_pContentBox:AppendParseText(CEGUI.String(text), false)
	end

	if record.hasVoice then
		local strText = "<I s=\"liaotian\" i=\"liaotian_yuyin_biaoshi\"></I>";
		this.m_pContentBox:AppendParseText(CEGUI.String(strText), false)
	end

	local MsgParseString = record.chatContent

	local allid = BeanConfigManager.getInstance():GetTableByName("chat.cchatcolorconfig"):getAllID()

	for i = 1, #allid do
		local colorConfig = BeanConfigManager.getInstance():GetTableByName("chat.cchatcolorconfig"):getRecorder(allid[i])

		local color = colorConfig.color
		local toReplace = colorConfig.chatlist[ltype - 1]
		if string.len(toReplace) > 1 then
			local outputstrings = { }
			local isDoubleColors = false
			if string.find(toReplace, ",") then
				local delimiters = ","
				outputstrings = StringBuilder.Split(toReplace, delimiters)
				isDoubleColors = true
			end

            local pos = string.find(MsgParseString, "c=['\"]"..color)

            if pos ~= nil then
                if isDoubleColors then
                    if string.len(outputstrings[2]) == 8 then
                        MsgParseString = string.gsub(MsgParseString, "(c=['\"])"..color.."['\"]", "c=\""..outputstrings[2].."\"")
                        MsgParseString = string.gsub(MsgParseString, "(TextColor=['\"])"..color.."['\"]", "TextColor=\""..outputstrings[2].."\"")
                    end
                else
                        MsgParseString = string.gsub(MsgParseString, "(c=['\"])"..toReplace.."['\"]", "c=\""..outputstrings[2].."\"")
                        MsgParseString = string.gsub(MsgParseString, "(TextColor=['\"])"..toReplace.."['\"]", "TextColor=\""..outputstrings[2].."\"")
                end
            end

            pos = string.find(MsgParseString, "ob=\""..color)

            if pos ~= nil then
                if isDoubleColors then
                    if string.len(outputstrings[2]) == 8 then
                        MsgParseString = string.gsub(MsgParseString, "(c=['\"])%x+['\"]%s(ob=\""..color.."\")", "c=\""..outputstrings[2].."\"")
                        MsgParseString = string.gsub(MsgParseString, "(TextColor=['\"])%x+['\"]%s(ob=\""..color.."\")", "TextColor=\""..outputstrings[2].."\"")
                    end
                else
                        MsgParseString = string.gsub(MsgParseString, "(c=['\"])%x+['\"]%s(ob=\""..toReplace.."\")", "c=\""..outputstrings[2].."\"")
                        MsgParseString = string.gsub(MsgParseString, "(TextColor=['\"])%x+['\"]%s(ob=\""..toReplace.."\")", "TextColor=\""..outputstrings[2].."\"")
                end
            end


		end
	end

	this.m_pContentBox:AppendParseText(CEGUI.String(MsgParseString), bCheckShied)
	this.m_pContentBox:AppendBreak()
    this.m_pContentBox:SetMaxLineNumber(100)
	this.m_pContentBox:CheckLineCount()

	if this.m_pContentBox and bRefreshBox then
		this.m_pContentBox:Refresh()
	end
end

function CChatOutBoxOperatelDlg.AddChatMsg_(channel, roleid, shapeid, roleTitle, roleCamp, strName, strMsg, recordID)
    --TODO: 删除c++里调用的代码，之前聊天的bug导致新手战斗的语音在这里显示不出来，现在不需要了
    do return end

	--[[if not _instance then
		return
	end

	local record = stChatRecord.new()
	record.channel = channel
	record.roleid = roleid
	record.roleShapeId = shapeid
	record.roleTitle = roleTitle
	record.roleCamp = roleCamp
	record.strName = strName
	record.chatContent = strMsg
	record.recordID = recordID
	record.forceCheckShied = true

	_instance:AddChatMsg(record, true, true, true)--]]
end

function CChatOutBoxOperatelDlg.HandleVoiceEnd_(args)
	if not _instance then
		return
	end
	_instance:HandleVoiceEnd(args)
end

function CChatOutBoxOperatelDlg.AddChatMsgUuid_(uuid, text)
    if _instance then
        _instance:AddChatMsgUuid(uuid, text)
    end
end


return CChatOutBoxOperatelDlg
