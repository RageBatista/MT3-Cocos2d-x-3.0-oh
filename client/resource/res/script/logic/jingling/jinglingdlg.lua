require "logic.dialog"

JinglingDlg = { }
setmetatable(JinglingDlg, Dialog)
JinglingDlg.__index = JinglingDlg

local USER_ASK_EDIT_MAXLENGTH = 475
local USER_ASK_HEIGHT = 106

local PAGE_TYPE_REDIAN = 1
local PAGE_TYPE_TUIJIAN = 2
local PAGE_TYPE_WENDA = 3
local PAGE_TYPE_KEFU = 4
local PAGE_TYPE_ZHIHUI = 5 --智慧试炼

local PAGE_SUB_TYPE_REDIAN = 11
local PAGE_SUB_TYPE_TUIJIAN = 12
local PAGE_SUB_TYPE_ZHIYIN = 13
local PAGE_SUB_TYPE_GEREN = 14

-- 精灵栏目分类id
local LANMU_REDIAN_ID = 1
local LANMU_TUIJIAN_ID = 13
local LANMU_KEFU_ID = 15

local QUEST_ASK_BY_KEYWORD = 888 -- 输入关键字提问

local QUEST_SPECIAL_KEJU_1 = -66661  -- 科举问题1
local QUEST_SPECIAL_KEJU_2 = -66662  -- 科举问题2
local QUEST_SPECIAL_KEJU_3 = -66663  -- 科举问题3

local QUEST_SPECIAL_SHUYU = -6666 --术语
local QUEST_SPECIAL_RENWEN = -66664 --人文百科

local JINGLING_HEAD_ID = 30257

local layoutPrfix = 0

local questHistory = {}
local saveDataReturn = { }
local _instance

local currentKejuTIndex = 1
local kejuQuestIDs = {}
local kejuIDSaved = {}

local renwenQuestIDs = {}
local renwenIDSaved = {}

function JinglingDlg.getInstance()
    if not _instance then
        _instance = JinglingDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function JinglingDlg.getInstanceAndShow()
    if not _instance then
        _instance = JinglingDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function JinglingDlg.getInstanceNotCreate()
    return _instance
end

function JinglingDlg.DestroyDialog()
    if _instance then
        saveDataReturn = { }
        GetServerInfo():clearJinglingData()
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function JinglingDlg.ToggleOpenClose()
    if not _instance then
        _instance = JinglingDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function JinglingDlg.GetLayoutFileName()
    return "jinglingjiemian.layout"
end

function JinglingDlg:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, JinglingDlg)
    return self
end

function JinglingDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local scrollPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("JinglingFrame/huadong1"))
	
    self.m_pageRedian = winMgr:getWindow("JinglingFrame/mainPageOne")
    self.m_pageWneda = winMgr:getWindow("JinglingFrame/wenda")
    self.m_questScrollPane = CEGUI.toScrollablePane(winMgr:getWindow("JinglingFrame/wenda/scroll"))
    self.m_BigImg = winMgr:getWindow("JinglingFrame/wenda/tipimg")
    self.m_BigImg_kuang = winMgr:getWindow("JinglingFrame/wenda/kuang")
    self.m_BigImg_text = winMgr:getWindow("JinglingFrame/wenda/text")

    self.m_askFrame = winMgr:getWindow("JinglingFrame/bottomAskQuestFrame")  
    self.m_boxShowText = winMgr:getWindow("JinglingFrame/bottomAskQuestFrame/wenzidi/text")
    self.m_inputBox = CEGUI.toRichEditbox(winMgr:getWindow("JinglingFrame/bottomAskQuestFrame/wenzidi/edit"))
    self.m_inputBox:subscribeEvent("KeyboardTargetWndChanged", JinglingDlg.HandleKeyboardTargetWndChanged, self)
    
    self.m_sendBtn = CEGUI.toPushButton(winMgr:getWindow("JinglingFrame/bottomAskQuestFrame/ButtonSend"))
    self.m_hsBtn = CEGUI.toPushButton(winMgr:getWindow("JinglingFrame/bottomAskQuestFrame/imagels"))

    self.m_yuyinBtn = CEGUI.toPushButton(winMgr:getWindow("JinglingFrame/bottomAskQuestFrame/yuyinbtn"))
    self.m_yuyinBtn:subscribeEvent("MouseButtonDown", JinglingDlg.HandleVoiceBegin, self)
    self.m_yuyinBtn:subscribeEvent("MouseButtonUp", JinglingDlg.HandleVoiceEnd, self)
    self.m_yuyinBtn:subscribeEvent("MouseMove", JinglingDlg.HandleVoiceMove, self)
    self.m_yuyinBtn:SetMouseLeaveReleaseInput(false)

    self.m_sendBtn:subscribeEvent("Clicked", JinglingDlg.handleSendAskContent, self)
    self.m_hsBtn:subscribeEvent("Clicked", JinglingDlg.handleHistoryClicked, self)

    self.m_redianTipText = winMgr:getWindow("JinglingFrame/diban/wenzi")
    

    -- 主界面四个按钮
    self.m_BTN_redian = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/leftTitlesFrame/titleButton1"))
    self.m_BTN_redian:setID(1)
    self.m_BTN_tuijian = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/leftTitlesFrame/titleButton2"))
    self.m_BTN_tuijian:setID(2)
    self.m_BTN_wenda = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/leftTitlesFrame/titleButton3"))
    self.m_BTN_wenda:setID(3)
    self.m_BTN_kefu = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/leftTitlesFrame/titleButton4"))
    self.m_BTN_kefu:setID(4)
    self.m_BTN_GM = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/leftTitlesFrame/titleButton5"))
    self.m_BTN_GM:setID(5)

    self.m_BTN_redian:subscribeEvent("MouseClick", JinglingDlg.handleMainPageBtnClick, self)
    self.m_BTN_tuijian:subscribeEvent("MouseClick", JinglingDlg.handleMainPageBtnClick, self)
    self.m_BTN_wenda:subscribeEvent("MouseClick", JinglingDlg.handleMainPageBtnClick, self)
    self.m_BTN_kefu:subscribeEvent("MouseClick", JinglingDlg.handleMainPageBtnClick, self)
    self.m_BTN_GM:subscribeEvent("MouseClick", JinglingDlg.handleMainPageBtnClick, self)
    -- 精灵推荐
    self.m_FrameTuijian = winMgr:getWindow("JinglingFrame/jinglingTuijian")
    -- 游戏指引
    self.m_FrameZhiyin = winMgr:getWindow("JinglingFrame/jinglingZhiyin")
    -- 游戏客服
    self.m_FrameKefu = winMgr:getWindow("JinglingFrame/kefu")

    --历史提问面板
    self.m_hisFrame = winMgr:getWindow("JinglingFrame/questhistory")
    self.m_hisFrameScroll = CEGUI.toScrollablePane(winMgr:getWindow("JinglingFrame/questhistory/scorll"))
    if MT3.ChannelManager:IsAndroid() == 1 then
        if Config.IsLocojoy() then
            self.m_BTN_kefu:setVisible(true)
        else
            self.m_BTN_kefu:setVisible(false)
        end
    end

    -- windows 版本屏蔽客服
    if Config.IsWinApp() then
        self.m_BTN_kefu:setVisible(false)
    end

    --    self.m_BTN_kefu:setEnabled(false)
    self.m_BTN_GM:setEnabled(false)
	



    self.m_RD_btn_cc1 = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/diban/diban1/rdbtn1"))
    self.m_RD_btn_cc1:setID(1)
	
    self.m_RD_btn_cc2 = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/diban/diban1/rdbtn2"))
    self.m_RD_btn_cc2:setID(2)
	
    self.m_RD_btn_cc3 = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/diban/diban1/rdbtn3"))
    self.m_RD_btn_cc3:setID(3)
	
    self.m_RD_btn_cc4 = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/diban/diban1/rdbtn4"))
    self.m_RD_btn_cc4:setID(4)
	
	self.m_RD_btn_cc5 = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/diban/diban1/rdbtn5"))
    self.m_RD_btn_cc5:setID(5)
	
	self.m_RD_btn_cc6 = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/diban/diban1/rdbtn6"))
    self.m_RD_btn_cc6:setID(6)
	
	self.m_RD_btn_cc7 = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/diban/diban1/rdbtn7"))
    self.m_RD_btn_cc7:setID(7)
	
	self.m_RD_btn_cc8 = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/diban/diban1/rdbtn8"))
    self.m_RD_btn_cc8:setID(8)
	
	self.m_RD_btn_cc9 = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/diban/diban1/rdbtn9"))
    self.m_RD_btn_cc9:setID(9)
	
	self.m_RD_btn_cc10 = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/diban/diban1/rdbtn10"))
    self.m_RD_btn_cc10:setID(10)
	
	self.m_RD_btn_cc11 = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/diban/diban1/rdbtn11"))
    self.m_RD_btn_cc11:setID(11)
	
	self.m_RD_btn_cc12 = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/diban/diban1/rdbtn12"))
    self.m_RD_btn_cc12:setID(12)
	
	self.m_RD_btn_cc13 = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/diban/diban1/rdbtn13"))
    self.m_RD_btn_cc13:setID(13)
	
	self.m_RD_btn_cc14 = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/diban/diban1/rdbtn14"))
    self.m_RD_btn_cc14:setID(14)
	
	self.m_RD_btn_cc15 = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/diban/diban1/rdbtn15"))
    self.m_RD_btn_cc15:setID(15)
	
	self.m_RD_btn_cc16 = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/diban/diban1/rdbtn16"))
    self.m_RD_btn_cc16:setID(16)
	
	self.m_RD_btn_cc17 = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/diban/diban1/rdbtn17"))
    self.m_RD_btn_cc17:setID(17)
	
	self.m_RD_btn_cc18 = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/diban/diban1/rdbtn18"))
    self.m_RD_btn_cc18:setID(18)
	
	self.m_RD_btn_redian = CEGUI.toGroupButton(winMgr:getWindow("JinglingFrame/diban/diban1/rdbtn19"))
    self.m_RD_btn_redian:setID(19)

    self.m_RD_btn_cc1:subscribeEvent("MouseClick", JinglingDlg.handleRedianBtnClick, self)
    self.m_RD_btn_cc2:subscribeEvent("MouseClick", JinglingDlg.handleRedianBtnClick, self)
    self.m_RD_btn_cc3:subscribeEvent("MouseClick", JinglingDlg.handleRedianBtnClick, self)
    self.m_RD_btn_cc4:subscribeEvent("MouseClick", JinglingDlg.handleRedianBtnClick, self)
	self.m_RD_btn_cc5:subscribeEvent("MouseClick", JinglingDlg.handleRedianBtnClick, self)
	self.m_RD_btn_cc6:subscribeEvent("MouseClick", JinglingDlg.handleRedianBtnClick, self)
	self.m_RD_btn_cc7:subscribeEvent("MouseClick", JinglingDlg.handleRedianBtnClick, self)
	self.m_RD_btn_cc8:subscribeEvent("MouseClick", JinglingDlg.handleRedianBtnClick, self)
	self.m_RD_btn_cc9:subscribeEvent("MouseClick", JinglingDlg.handleRedianBtnClick, self)
	self.m_RD_btn_cc10:subscribeEvent("MouseClick", JinglingDlg.handleRedianBtnClick, self)
	self.m_RD_btn_cc11:subscribeEvent("MouseClick", JinglingDlg.handleRedianBtnClick, self)
	self.m_RD_btn_cc12:subscribeEvent("MouseClick", JinglingDlg.handleRedianBtnClick, self)
	self.m_RD_btn_cc13:subscribeEvent("MouseClick", JinglingDlg.handleRedianBtnClick, self)
	self.m_RD_btn_cc14:subscribeEvent("MouseClick", JinglingDlg.handleRedianBtnClick, self)
	self.m_RD_btn_cc15:subscribeEvent("MouseClick", JinglingDlg.handleRedianBtnClick, self)
	self.m_RD_btn_cc16:subscribeEvent("MouseClick", JinglingDlg.handleRedianBtnClick, self)
	self.m_RD_btn_cc17:subscribeEvent("MouseClick", JinglingDlg.handleRedianBtnClick, self)
	self.m_RD_btn_cc18:subscribeEvent("MouseClick", JinglingDlg.handleRedianBtnClick, self)
	
	self.m_RD_btn_redian:subscribeEvent("MouseClick", JinglingDlg.handleRedianBtnClick, self)

    self.m_BTN_redian:setSelected(true, false)

    self.m_RDEdit = CEGUI.toRichEditbox(winMgr:getWindow("JinglingFrame/mainPageOne/redianEdit"))


    -- 热点界面16个问题按钮
    for i = 1, 16 do
        self["m_firstPageBtn" .. i] = CEGUI.Window.toPushButton(winMgr:getWindow("JinglingFrame/diban/bt" .. i))
    end

    -- 推荐界面12个问题按钮
    for i = 1, 16 do
        self["m_tuijianBtn" .. i] = CEGUI.Window.toPushButton(winMgr:getWindow("JinglingFrame/jinglingTuijian/tuijian" .. i))
    end

    -- 客服界面上面6个按钮
    for i = 1, 6 do
        self["m_kefuBtn" .. i] = CEGUI.Window.toPushButton(winMgr:getWindow("JinglingFrame/kefu/wenti" .. i))
    end

    -- 客服界面下面3个按钮
    self.m_kf_bbsBtn = CEGUI.Window.toPushButton(winMgr:getWindow("JinglingFrame/kefu/bottomBtn1"))
    self.m_kf_noticeBtn = CEGUI.Window.toPushButton(winMgr:getWindow("JinglingFrame/kefu/bottomBtn2"))
    self.m_kf_mqBtn = CEGUI.Window.toPushButton(winMgr:getWindow("JinglingFrame/kefu/bottomBtn3"))

    self.m_kf_bbsBtn:subscribeEvent("Clicked", JinglingDlg.handleEnterBBS, self)
    -- 论坛
    self.m_kf_noticeBtn:subscribeEvent("Clicked", JinglingDlg.handleNoticeClick, self)
    -- 更新公告
    self.m_kf_mqBtn:subscribeEvent("Clicked", JinglingDlg.handleKefuClick, self)
    -- 点击美洽

    self.currentRequireID = -1
    self.currentDataBackID = -1
    self.alreadyAsk = false
    self.m_questOffsetY = 0
    self.m_lastAskOffsetY = 0

    self.m_VoiceBtnLastClickTime = 0
    self.m_bRecording = false


    -- 初始化界面数据
    self:doRequestQuestByID(LANMU_REDIAN_ID)
    self.currentPageType = PAGE_TYPE_REDIAN
    self.currentPageSubType = PAGE_SUB_TYPE_REDIAN
    -- 记录热点界面的当前是哪个子界面
    self.m_RDEdit:setVisible(false)

    self.m_RD_btn_redian:setSelected(true, false)
    self.m_BTN_redian:setSelected(true, false)

    self.m_ZHI_HUI_SHI_LIAN = { }
	
	self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)
	
    scrollPane:addChildWindow(self.m_RD_btn_cc1)
    scrollPane:addChildWindow(self.m_RD_btn_cc2)
    scrollPane:addChildWindow(self.m_RD_btn_cc3)
    scrollPane:addChildWindow(self.m_RD_btn_cc4)
    scrollPane:addChildWindow(self.m_RD_btn_cc5)
    scrollPane:addChildWindow(self.m_RD_btn_cc6)
    scrollPane:addChildWindow(self.m_RD_btn_cc7)
    scrollPane:addChildWindow(self.m_RD_btn_cc8)
    scrollPane:addChildWindow(self.m_RD_btn_cc9)
    scrollPane:addChildWindow(self.m_RD_btn_cc10)
    scrollPane:addChildWindow(self.m_RD_btn_cc11)
    scrollPane:addChildWindow(self.m_RD_btn_cc12)
    scrollPane:addChildWindow(self.m_RD_btn_cc13)
    scrollPane:addChildWindow(self.m_RD_btn_cc14)
    scrollPane:addChildWindow(self.m_RD_btn_cc15)
    scrollPane:addChildWindow(self.m_RD_btn_cc16)
    scrollPane:addChildWindow(self.m_RD_btn_cc17)
    scrollPane:addChildWindow(self.m_RD_btn_cc18)
end

function JinglingDlg:AddHistoryRecord(record)
    table.insert(questHistory, record)
end

function JinglingDlg:handleKefuClick(arg)
    gGetGameApplication():showMQView()
end

function JinglingDlg:handleNoticeClick(arg)
    require "logic.newswarndlg".getInstanceAndShow()
end

function JinglingDlg:handleEnterBBS(arg)
    GetServerInfo():doEnterBBS()
end

function JinglingDlg:handleRedianBtnClick(arg)
    local e = CEGUI.toWindowEventArgs(arg)
    local id = e.window:getID()
    local hideRDBtn = false
    self.m_RDEdit:Clear()
    if id == 1 then
        self.m_RDEdit:setVisible(true)
        self.m_RDEdit:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7001)))
        hideRDBtn = true
    elseif id == 2 then
        self.m_RDEdit:setVisible(true)
        self.m_RDEdit:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7002)))
        hideRDBtn = true
    elseif id == 3 then
        self.m_RDEdit:setVisible(true)
        self.m_RDEdit:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7003)))
        hideRDBtn = true
    elseif id == 4 then
        self.m_RDEdit:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7004)))
        self.m_RDEdit:setVisible(true)
        hideRDBtn = true
	elseif id == 5 then
        self.m_RDEdit:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7005)))
        self.m_RDEdit:setVisible(true)
        hideRDBtn = true
	elseif id == 6 then
        self.m_RDEdit:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7006)))
        self.m_RDEdit:setVisible(true)
        hideRDBtn = true
	elseif id == 7 then
        self.m_RDEdit:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7007)))
        self.m_RDEdit:setVisible(true)
        hideRDBtn = true
	elseif id == 8 then
        self.m_RDEdit:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7008)))
        self.m_RDEdit:setVisible(true)
        hideRDBtn = true
	elseif id == 9 then
        self.m_RDEdit:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7009)))
        self.m_RDEdit:setVisible(true)
        hideRDBtn = true
	elseif id == 10 then
        self.m_RDEdit:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7010)))
        self.m_RDEdit:setVisible(true)
        hideRDBtn = true
	elseif id == 11 then
        self.m_RDEdit:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7011)))
        self.m_RDEdit:setVisible(true)
        hideRDBtn = true
	elseif id == 12 then
        self.m_RDEdit:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7012)))
        self.m_RDEdit:setVisible(true)
        hideRDBtn = true
	elseif id == 13 then
        self.m_RDEdit:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7013)))
        self.m_RDEdit:setVisible(true)
        hideRDBtn = true
	elseif id == 14 then
        self.m_RDEdit:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7014)))
        self.m_RDEdit:setVisible(true)
        hideRDBtn = true
	elseif id == 15 then
        self.m_RDEdit:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7015)))
        self.m_RDEdit:setVisible(true)
        hideRDBtn = true
	elseif id == 16 then
        self.m_RDEdit:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7016)))
        self.m_RDEdit:setVisible(true)
        hideRDBtn = true
	elseif id == 17 then
        self.m_RDEdit:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7017)))
        self.m_RDEdit:setVisible(true)
        hideRDBtn = true
	elseif id == 18 then
        self.m_RDEdit:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7018)))
        self.m_RDEdit:setVisible(true)
        hideRDBtn = true
	elseif id == 19 then
	    self.m_RDEdit:setVisible(false)
        hideRDBtn = false
    end

    self.m_RDEdit:Refresh()
    if hideRDBtn then
        for i = 1, 16 do
            self["m_firstPageBtn" .. i]:setVisible(false)
        end
        self.m_redianTipText:setVisible(false)
    else
        for i = 1, 16 do
            self["m_firstPageBtn" .. i]:setVisible(false)
        end
        self.m_redianTipText:setVisible(true)
    end

end

function JinglingDlg:handleMainPageBtnClick(arg)
    local e = CEGUI.toWindowEventArgs(arg)
    local id = e.window:getID()

    self:enterPage(id)
end

function JinglingDlg:checkPushState(id)
    if id == self.m_BTN_redian:getID() then
        self.m_BTN_redian:setSelected(true, false)
    end
end 

function JinglingDlg:HandleVoiceBegin(args)
    -- 按钮点击间隔判断
    local lastClickTime = self.m_VoiceBtnLastClickTime
    local curTime = gGetServerTime()
    self.m_VoiceBtnLastClickTime = curTime
    if curTime - lastClickTime < VOICE_BTN_CLICK_INTERVAL then
        GetCTipsManager():AddMessageTipById(160172)
        return
    end

    require("logic.chat.voicedialog").DestroyDialog()

    local bCanRecord = gGetWavRecorder():canRecord()
    if bCanRecord then
        if gGetWavRecorder():start() then
            gGetVoiceManager():registerAutoClose(VOICE_RECORD_TYPE_FRIEND)
            self.m_bRecording = true

            -- 为了防止录下杂音，必须在gGetWavRecorder():start()时调用，这里不调用
            --gGetVoiceManager():PauseMusicAndEffectForLua()

			self.m_voiceBeginTime = gGetServerTime()

			-- 启动录音后再显示界面
            local pVoiceUI = require("logic.chat.voicedialog").getInstanceAndShow()
            SetPositionScreenCenter(pVoiceUI:GetWindow())
            pVoiceUI:setVoiceRecordUI(true)
		end
	else
		gGetVoiceManager():showTip_RequirePermission()
	end
end

function JinglingDlg:HandleVoiceEnd(args)
    if not self.m_bRecording then
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

        gGetVoiceManager():ProcessVoiceDataForLua(recordTime, GetNumberValueForStrKey("VOICE_JINGLING_CHANNEL"), 0)
    end
end

function JinglingDlg.HandleVoiceEnd_(args)
	if not _instance then
		return
	end
	_instance:HandleVoiceEnd(args)
end

function JinglingDlg:HandleVoiceMove(args)
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

function JinglingDlg:isHitVoiceRecordUI(pVoiceBtn, mouseX, mouseY)
    local pos = pVoiceBtn:GetScreenPos()
    local sz = pVoiceBtn:getPixelSize()

    local x = mouseX - pos.x;
    local y = mouseY - pos.y;
    local radii = sz.width / 2;
    local absX = radii - x;
    local absY = radii - y;

    return(absX * absX + absY * absY) <(radii * radii)
end

function JinglingDlg.sendHttpConnectReturned(responseID)
    if _instance then
        _instance.currentDataBackID = responseID
        JinglingDlg.checkDataSavedAndInsert(responseID)
        if _instance.currentPageType == PAGE_TYPE_REDIAN and responseID == LANMU_REDIAN_ID then
            _instance:refreshRedianPage()
        elseif _instance.currentPageType == PAGE_TYPE_TUIJIAN and responseID == LANMU_TUIJIAN_ID then
            _instance:refreshTuijianPage()
        elseif _instance.currentPageType == PAGE_TYPE_KEFU and responseID == LANMU_KEFU_ID then
            _instance:refreshKefuPage()
        elseif responseID >= 1000 and _instance.currentPageType == PAGE_TYPE_WENDA then
            _instance:insertJingLingWND(responseID)
        end
    end
end

function JinglingDlg:insertUserWND(qid, text)
    if qid == QUEST_SPECIAL_KEJU_1 or qid == QUEST_SPECIAL_KEJU_2 or qid == QUEST_SPECIAL_KEJU_3 or qid == QUEST_SPECIAL_RENWEN then
        return
    end

    local content
    if text == nil then
        local data = GetServerInfo():getJinglingDataByID(qid)
        content = data.jl_title
    else
        content = text
    end

    content = "<T c=\"FF50321A\" t=\"" .. content .. "\"></T>"

    local winMgr = CEGUI.WindowManager:getSingleton()
    layoutPrfix = layoutPrfix + 1
    local wnd = winMgr:loadWindowLayout("jinglinguserask.layout", layoutPrfix)
    local headIconWnd = CEGUI.Window.toItemCell(winMgr:getWindow(layoutPrfix .. "jinglinguser/headimg"))
    local nameWnd = winMgr:getWindow(layoutPrfix .. "jinglinguser/nametext")
    local contentBase = winMgr:getWindow(layoutPrfix .. "jinglinguser/questbg")
    local contentEdit = CEGUI.toRichEditbox(winMgr:getWindow(layoutPrfix .. "jinglinguser/questbg/edit"))
    local sanjiao = winMgr:getWindow(layoutPrfix .. "jinglinguser/questbg/jiantou")
    contentEdit:AppendParseText(CEGUI.String(content))
    contentEdit:Refresh()
    local textSize = contentEdit:GetExtendSize()
    local bgSize = contentBase:getPixelSize()
    local bgPos = contentBase:getPosition()
    contentBase:setXPosition(CEGUI.UDim(0, bgPos.x.offset + USER_ASK_EDIT_MAXLENGTH - textSize.width - 5))
    contentBase:setSize(CEGUI.UVector2(CEGUI.UDim(0, textSize.width + 20), CEGUI.UDim(0, bgSize.height)))
    contentEdit:setHeight(CEGUI.UDim(0, textSize.height + 5))
    contentEdit:setYPosition(CEGUI.UDim(0, 5))
    --    self.m_questScrollPane:setVerticalScrollPosition(self.m_questOffsetY)

    local selfShape = gGetDataManager():GetMainCharacterShape()
    local selfName = gGetDataManager():GetMainCharacterName()
    local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(selfShape)
    headIconWnd:SetImage(gGetIconManager():GetItemIconByID(shapeConf.littleheadID))

    nameWnd:setText(selfName)
    self.m_questScrollPane:addChildWindow(wnd)
    wnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.2, 0), CEGUI.UDim(0, self.m_questOffsetY)))
    self.m_lastAskOffsetY = self.m_questOffsetY
    self.m_questOffsetY = self.m_questOffsetY + wnd:getPixelSize().height
end

function JinglingDlg:insertJingLingWND(qid, text, withoutFeed)
    local content = ""
    if text == nil then
        local data = GetServerInfo():getJinglingDataByID(qid)
        content = data.jl_content
    else
        content = text
    end

    if content == "" then
        JinglingDlg.doGotResponseNoMatch()
        return
    end

    local winMgr = CEGUI.WindowManager:getSingleton()
    layoutPrfix = layoutPrfix + 1
    local wnd = winMgr:loadWindowLayout("jinglinganswer.layout", layoutPrfix)
    local pWnd = winMgr:getWindow(layoutPrfix .. "JinglingQuest")
    local headIconWnd = CEGUI.Window.toItemCell(winMgr:getWindow(layoutPrfix .. "JinglingQuest/headimg"))
    local nameWnd = winMgr:getWindow(layoutPrfix .. "JinglingQuest/nametext")
    local contentBase = winMgr:getWindow(layoutPrfix .. "JinglingQuest/questbg")
    local contentEdit = CEGUI.toRichEditbox(winMgr:getWindow(layoutPrfix .. "JinglingQuest/questbg/edit"))
    
    local feedback = winMgr:getWindow(layoutPrfix .. "JinglingQuest/questbg/feedback")
    local feedbackBtnYes = CEGUI.toPushButton(winMgr:getWindow(layoutPrfix .. "JinglingQuest/questbg/feedback/btnYes"))
    local feedbackBtnNo = CEGUI.toPushButton(winMgr:getWindow(layoutPrfix .. "JinglingQuest/questbg/feedback/btnno"))
    feedbackBtnYes:subscribeEvent("Clicked", JinglingDlg.handleFeedBtnClick, self)
    feedbackBtnNo:subscribeEvent("Clicked", JinglingDlg.handleFeedBtnClick, self)
    feedbackBtnYes:setID(layoutPrfix)
    feedbackBtnNo:setID(layoutPrfix)
    if withoutFeed then
        feedback:setVisible(false)
    end
    contentEdit:getVertScrollbar():EnbalePanGuesture(false)

    contentEdit:AppendParseText(CEGUI.String(content))
    contentEdit:Refresh()

    local textSize = contentEdit:GetExtendSize()
    local bgSize = contentBase:getPixelSize()
    local bgPos = contentBase:getPosition()
    local newBgSizeHeight = textSize.height + 180 --40
    if withoutFeed then
        newBgSizeHeight = textSize.height + 40
    else
        newBgSizeHeight = textSize.height + 180
    end
    local pWndPos = pWnd:getPosition()
    contentBase:setSize(CEGUI.UVector2(CEGUI.UDim(0, bgSize.width), CEGUI.UDim(0, newBgSizeHeight)))
    contentBase:setPosition(bgPos)
    contentEdit:setYPosition(CEGUI.UDim(0, 20))
    if not withoutFeed then
        feedback:setYPosition(CEGUI.UDim(0, textSize.height + 50))
    end

    local selfShape = gGetDataManager():GetMainCharacterShape()
    headIconWnd:SetImage(gGetIconManager():GetItemIconByID(JINGLING_HEAD_ID))

    self.m_questScrollPane:addChildWindow(wnd)
    pWnd:setSize(CEGUI.UVector2(CEGUI.UDim(0, pWnd:getPixelSize().width), CEGUI.UDim(0, newBgSizeHeight + 50)))
    pWnd:setPosition(pWndPos)

    wnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, self.m_questOffsetY)))

    self.m_questOffsetY = self.m_questOffsetY + newBgSizeHeight + 50
    -- 背景框距离父控件的topoffset值
    self.m_questScrollPane:setVerticalScrollPosition(self.m_lastAskOffsetY /(self.m_questScrollPane:getVertScrollbar():getDocumentSize()))
end

function JinglingDlg:handleFeedBtnClick(arg)
    local e = CEGUI.toWindowEventArgs(arg)
    local btnID = e.window:getID()

    local winMgr = CEGUI.WindowManager:getSingleton()
    local tishi = winMgr:getWindow(btnID .. "JinglingQuest/questbg/feedback/tishi")
    local feedbackBtnYes = CEGUI.toPushButton(winMgr:getWindow(btnID .. "JinglingQuest/questbg/feedback/btnYes"))
    local feedbackBtnNo = CEGUI.toPushButton(winMgr:getWindow(btnID .. "JinglingQuest/questbg/feedback/btnno"))
    local thankText = CEGUI.toPushButton(winMgr:getWindow(btnID .. "JinglingQuest/questbg/feedback/thank"))
    if tishi then
        tishi:setVisible(false)
    end
    if feedbackBtnYes then
        feedbackBtnYes:setVisible(false)
    end
    if feedbackBtnNo then
        feedbackBtnNo:setVisible(false)
    end
    if thankText then
        thankText:setVisible(true)
    end
end

function JinglingDlg:run(delta)
        --local text1 = self.m_inputBox:GetPureText()
        --self.m_boxShowText:setVisible((text1 == "" and self.m_inputBox:hasInputFocus()))
end
function JinglingDlg:HandleKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.m_inputBox then
        self.m_boxShowText:setVisible(false)
    else
        if self.m_inputBox:GetPureText() == "" then
            self.m_boxShowText:setVisible(true)
        end
    end
end
function JinglingDlg.checkDataSavedAndInsert(responseid)
    if _instance then
        if not JinglingDlg.checkDataSaved(responseid) then
            table.insert(saveDataReturn, responseid)
        end
    end
end

function JinglingDlg.checkDataSaved(value)
    if _instance then
        local isValueSaved = false
        for _, v in pairs(saveDataReturn) do
            if v == value then
                isValueSaved = true
                break
            end
        end
        return isValueSaved
    end
end

-- 根据子界面类型 刷新热点界面
function JinglingDlg:refreshRedianPage()
    if self.currentPageType == PAGE_TYPE_REDIAN then
        -- 刷新热点界面
        if self.currentPageSubType == PAGE_SUB_TYPE_REDIAN then
            local allIds = std.vector_int_()
            GetServerInfo():getRedianIds(allIds)
            local vSize = allIds:size()
            if vSize > 16 then
                vSize = 16
            end

            for i = 0, vSize - 1 do
                local id = allIds[i]
                local data = GetServerInfo():getJinglingDataByID(id)
                self["m_firstPageBtn" ..(i + 1)]:setText(data.jl_title)
                self["m_firstPageBtn" ..(i + 1)]:setID(id)
                self["m_firstPageBtn" ..(i + 1)]:subscribeEvent("Clicked", JinglingDlg.HandleQuestClick, self)
            end
        end
    end
end

function JinglingDlg:refreshTuijianPage()
    if self.currentPageType == PAGE_TYPE_TUIJIAN then
        local allIds = std.vector_int_()
        GetServerInfo():getTuijianIds(allIds)
        local vSize = allIds:size()
        if vSize > 16 then
            vSize = 16
        end
        for i = 0, vSize - 1 do
            local id = allIds[i]
            local data = GetServerInfo():getJinglingDataByID(id)
            self["m_tuijianBtn" ..(i + 1)]:setText(data.jl_title)
            self["m_tuijianBtn" ..(i + 1)]:setID(id)
            self["m_tuijianBtn" ..(i + 1)]:subscribeEvent("Clicked", JinglingDlg.HandleQuestClick, self)
        end
    end
end

function JinglingDlg:refreshKefuPage()
    if self.currentPageType == PAGE_TYPE_KEFU then
        local allIds = std.vector_int_()
        GetServerInfo():getKefuIds(allIds)
        local vSize = allIds:size()
        if vSize > 6 then
            vSize = 6
        end
        for i = 0, vSize - 1 do
            local id = allIds[i]
            local data = GetServerInfo():getJinglingDataByID(id)
            self["m_kefuBtn" ..(i + 1)]:setText(data.jl_title)
            self["m_kefuBtn" ..(i + 1)]:setID(id)
            self["m_kefuBtn" ..(i + 1)]:subscribeEvent("Clicked", JinglingDlg.HandleQuestClick, self)
        end
    end

end

function JinglingDlg:HandleQuestClick(arg)
    self:enterPage(PAGE_TYPE_WENDA)
    local e = CEGUI.toWindowEventArgs(arg)
    local id = e.window:getID()

    self:insertUserWND(id)
    self:doRequestQuestByID(id)
    self.alreadyAsk = true
    self:checkQuestImageShow()
end

function JinglingDlg.globalRequstQuest(id, text)
    if _instance then
        _instance:enterPage(PAGE_TYPE_WENDA)
        _instance:insertUserWND(id, text)
        _instance:doRequestQuestByID(id)
        _instance.alreadyAsk = true
        _instance:checkQuestImageShow()
    end
end

function JinglingDlg:showKejuTest()
    self:enterPage(PAGE_TYPE_ZHIHUI)

    kejuQuestIDs = {}
    if currentKejuTIndex == 1 then
        kejuQuestIDs = BeanConfigManager.getInstance():GetTableByName("game.wisdomtrialvillpay"):getAllID()
    elseif currentKejuTIndex == 2 then
        kejuQuestIDs = BeanConfigManager.getInstance():GetTableByName("game.wisdomtrialprovpay"):getAllID()
    elseif currentKejuTIndex == 3 then
        kejuQuestIDs = BeanConfigManager.getInstance():GetTableByName("game.wisdomtrialstatepay"):getAllID()
    end

    self:doShowNextKeju()
end

function JinglingDlg:getNextKejuQuestID()
    local count = require "utils.tableutil".tablelength(kejuQuestIDs)
    local id = math.random(count)
    if not id or self:checkAlreadyExist(id) then
        self:getNextKejuQuestID()
    end
    return id
end

function JinglingDlg:checkAlreadyExist(id)
    local count = require "utils.tableutil".tablelength(kejuIDSaved)
    if count > 50 then
        kejuIDSaved = {}
        return false
    end
    for k, v in pairs (kejuIDSaved) do
        if v == id then
            return true
        end
    end
    return false
end

function JinglingDlg:doShowNextKeju(arg)
    if arg then
        local e = CEGUI.toWindowEventArgs(arg)
        e.window:setEnabled(false)
    end
    self.m_FrameZhiyin:cleanupNonAutoChildren()
    local cID = self:getNextKejuQuestID()
    table.insert(kejuIDSaved, cID)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local cellWnd = winMgr:loadWindowLayout("dashidati.layout")
    local quest = winMgr:getWindow("dashidati/di/di/biaoti")
    
    local BtnA = CEGUI.Window.toPushButton(winMgr:getWindow("dashidati/di/di/xuan1"))
    local BtnB = CEGUI.Window.toPushButton(winMgr:getWindow("dashidati/di/di/xuan2"))
    local BtnC = CEGUI.Window.toPushButton(winMgr:getWindow("dashidati/di/di/xuan3"))
    local BtnD = CEGUI.Window.toPushButton(winMgr:getWindow("dashidati/di/di/xuan4"))
    local answerA = winMgr:getWindow("dashidati/di/di/xuan1/zi")
    local answerB = winMgr:getWindow("dashidati/di/di/xuan2/zi")
    local answerC = winMgr:getWindow("dashidati/di/di/xuan3/zi")
    local answerD = winMgr:getWindow("dashidati/di/di/xuan4/zi")
    local wrong = winMgr:getWindow("dashidati/di/di/cuo")
    local right = winMgr:getWindow("dashidati/di/di/zhengque")
    local wrongText = winMgr:getWindow("dashidati/di/di/dacuo")
    local wrongText2 = winMgr:getWindow("dashidati/di/di/zhengquedaan")
    local rightText = winMgr:getWindow("dashidati/di/di/dadui")
    local nextButton = winMgr:getWindow("dashidati/di/di/nButton")
    nextButton:subscribeEvent("Clicked", JinglingDlg.doShowNextKeju, self)
    wrong:setVisible(false)
    right:setVisible(false)
    wrongText:setVisible(false)
    wrongText2:setVisible(false)
    rightText:setVisible(false)
    BtnA:EnableClickAni(false)
    BtnB:EnableClickAni(false)
    BtnC:EnableClickAni(false)
    BtnD:EnableClickAni(false)
    local record = nil
    if currentKejuTIndex == 1 then
        record = BeanConfigManager.getInstance():GetTableByName("game.wisdomtrialvillpay"):getRecorder(cID)
    elseif currentKejuTIndex == 2 then
        record = BeanConfigManager.getInstance():GetTableByName("game.wisdomtrialprovpay"):getRecorder(cID)
    elseif currentKejuTIndex == 3 then
        record = BeanConfigManager.getInstance():GetTableByName("game.wisdomtrialstatepay"):getRecorder(cID)
    end
    quest:setText(record.name)

    answerA:setText(record.options[0])
    answerB:setText(record.options[1])
    answerC:setText(record.options[2])
    answerD:setText(record.options[3])

    BtnA:setUserString("result", "corect")
    BtnB:setUserString("result", "A "..record.options[0])
    BtnC:setUserString("result", "A "..record.options[0])
    BtnD:setUserString("result", "A "..record.options[0])

    local random = math.random(1, 4)
    if random == 2 then
        answerA:setText(record.options[1])
        answerB:setText(record.options[0])
        BtnA:setUserString("result", "B "..record.options[0])
        BtnB:setUserString("result", "corect")
        BtnC:setUserString("result", "B "..record.options[0])
        BtnD:setUserString("result", "B "..record.options[0])
    elseif random == 3 then
        answerA:setText(record.options[2])
        answerC:setText(record.options[0])
        BtnA:setUserString("result", "C "..record.options[0])
        BtnB:setUserString("result", "C "..record.options[0])
        BtnC:setUserString("result", "corect")
        BtnD:setUserString("result", "C "..record.options[0])
    elseif random == 4 then
        answerA:setText(record.options[3])
        answerD:setText(record.options[0])
        BtnA:setUserString("result", "D "..record.options[0])
        BtnB:setUserString("result", "D "..record.options[0])
        BtnC:setUserString("result", "D "..record.options[0])
        BtnD:setUserString("result", "corect")
    end

    BtnA:subscribeEvent("Clicked", JinglingDlg.doAnswerChoose, self)
    BtnB:subscribeEvent("Clicked", JinglingDlg.doAnswerChoose, self)
    BtnC:subscribeEvent("Clicked", JinglingDlg.doAnswerChoose, self)
    BtnD:subscribeEvent("Clicked", JinglingDlg.doAnswerChoose, self)

    self.m_FrameZhiyin:addChildWindow(cellWnd)
    cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 5), CEGUI.UDim(0, 5)))
end

function JinglingDlg:doAnswerChoose(arg)
    local e = CEGUI.toWindowEventArgs(arg)
    local result = e.window:getUserString("result")
    if result == "over" then
        return
    end
    local winMgr = CEGUI.WindowManager:getSingleton()
    local wrong = winMgr:getWindow("dashidati/di/di/cuo")
    local right = winMgr:getWindow("dashidati/di/di/zhengque")
    local wrongText = winMgr:getWindow("dashidati/di/di/dacuo")
    local wrongText2 = winMgr:getWindow("dashidati/di/di/zhengquedaan")
    local rightText = winMgr:getWindow("dashidati/di/di/dadui")

    local BtnA = winMgr:getWindow("dashidati/di/di/xuan1")
    local BtnB = winMgr:getWindow("dashidati/di/di/xuan2")
    local BtnC = winMgr:getWindow("dashidati/di/di/xuan3")
    local BtnD = winMgr:getWindow("dashidati/di/di/xuan4")
    BtnA:setUserString("result", "over")
    BtnB:setUserString("result", "over")
    BtnC:setUserString("result", "over")
    BtnD:setUserString("result", "over")
        
    if result == "corect" then
        right:setVisible(true)
        rightText:setVisible(true)
    else
        wrong:setVisible(true)
        wrongText:setVisible(true)
        wrongText2:setVisible(true)
        wrongText2:setText(result)
    end
end

function JinglingDlg:showRenwenTest()
    self:enterPage(PAGE_TYPE_ZHIHUI)

    renwenQuestIDs = BeanConfigManager.getInstance():GetTableByName("mission.answerquestion"):getAllID()

    self:showNextRenwen()
end

function JinglingDlg:getNextRenwenQuestID()
    local count = require "utils.tableutil".tablelength(renwenQuestIDs)
    local id = math.random(count)
    if not id or self:checkAlreadyExistRenwen(id) then
        self:getNextRenwenQuestID()
    end
    return id
end

function JinglingDlg:checkAlreadyExistRenwen(id)
    local count = require "utils.tableutil".tablelength(renwenIDSaved)
    if count > 40 then
        renwenIDSaved = {}
        return false
    end
    for k, v in pairs (renwenIDSaved) do
        if v == id then
            return true
        end
    end
    return false
end

function JinglingDlg:showNextRenwen(arg)
    if arg then
        local e = CEGUI.toWindowEventArgs(arg)
        e.window:setEnabled(false)
    end

    self.m_FrameZhiyin:cleanupNonAutoChildren()

    local cID = self:getNextRenwenQuestID()
    table.insert(renwenIDSaved, cID)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local cellWnd = winMgr:loadWindowLayout("daticell5.layout")
    local quest = winMgr:getWindow("daticell5/di/wenben1")
    
    local BtnA = CEGUI.Window.toPushButton(winMgr:getWindow("daticell5/di/di/tu1"))
    local BtnB = CEGUI.Window.toPushButton(winMgr:getWindow("daticell5/di/di/tu2"))
    local BtnC = CEGUI.Window.toPushButton(winMgr:getWindow("daticell5/di/di/tu3"))
    BtnA:EnableClickAni(false)
    BtnB:EnableClickAni(false)
    BtnC:EnableClickAni(false)
    local answerAImage = winMgr:getWindow("daticell5/di/di/tu1/tu")
    local answerBImage = winMgr:getWindow("daticell5/di/di/tu2/tu")
    local answerCImage = winMgr:getWindow("daticell5/di/di/tu3/tu")
    local anserAName = winMgr:getWindow("daticell5/di/di/tu1/mingzi")
    local anserBName = winMgr:getWindow("daticell5/di/di/tu2/mingzi")
    local anserCName = winMgr:getWindow("daticell5/di/di/tu3/mingzi")
    local anserARight = winMgr:getWindow("daticell5/di/di/tu1/dui")
    local anserBRight = winMgr:getWindow("daticell5/di/di/tu2/dui")
    local anserCRight = winMgr:getWindow("daticell5/di/di/tu3/dui")
    local anserAWrong = winMgr:getWindow("daticell5/di/di/tu1/cuo")
    local anserBWrong = winMgr:getWindow("daticell5/di/di/tu2/cuo")
    local anserCWrong = winMgr:getWindow("daticell5/di/di/tu3/cuo")
    local nextButton = winMgr:getWindow("daticell5/di/qiuzhu")
    nextButton:subscribeEvent("Clicked", JinglingDlg.showNextRenwen, self)
 
    anserARight:setVisible(false)
    anserBRight:setVisible(false)
    anserCRight:setVisible(false)
    anserAWrong:setVisible(false)
    anserBWrong:setVisible(false)
    anserCWrong:setVisible(false)

    local record = BeanConfigManager.getInstance():GetTableByName("mission.answerquestion"):getRecorder(cID)
    quest:setText(record.title)

    answerAImage:setProperty("Image",gGetIconManager():GetImagePathByID(record.image1):c_str())
    answerBImage:setProperty("Image",gGetIconManager():GetImagePathByID(record.image2):c_str())
    answerCImage:setProperty("Image",gGetIconManager():GetImagePathByID(record.image3):c_str())
    anserAName:setText(record.object1)
    anserBName:setText(record.object2)
    anserCName:setText(record.object3)
    BtnA:setID(1)
    BtnB:setID(2)
    BtnC:setID(3)
    if record.trueanswer == 1 then
        BtnA:setUserString("result", "right")
        BtnB:setUserString("result", "wrong")
        BtnC:setUserString("result", "wrong")
    elseif record.trueanswer == 2 then
        BtnA:setUserString("result", "wrong")
        BtnB:setUserString("result", "right")
        BtnC:setUserString("result", "wrong")
    elseif record.trueanswer == 3 then
        BtnA:setUserString("result", "wrong")
        BtnB:setUserString("result", "wrong")
        BtnC:setUserString("result", "right")
    end
    BtnA:subscribeEvent("Clicked", JinglingDlg.doRenwenAnswerChoose, self)
    BtnB:subscribeEvent("Clicked", JinglingDlg.doRenwenAnswerChoose, self)
    BtnC:subscribeEvent("Clicked", JinglingDlg.doRenwenAnswerChoose, self)
    self.m_FrameZhiyin:addChildWindow(cellWnd)
    cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 40), CEGUI.UDim(0, 5)))
end

function JinglingDlg:doRenwenAnswerChoose(arg)
    local e = CEGUI.toWindowEventArgs(arg)
    local result = e.window:getUserString("result")
    local id = e.window:getID()
    if result == "over" then
        return
    end
    local winMgr = CEGUI.WindowManager:getSingleton()
    local anserARight = winMgr:getWindow("daticell5/di/di/tu1/dui")
    local anserBRight = winMgr:getWindow("daticell5/di/di/tu2/dui")
    local anserCRight = winMgr:getWindow("daticell5/di/di/tu3/dui")
    local anserAWrong = winMgr:getWindow("daticell5/di/di/tu1/cuo")
    local anserBWrong = winMgr:getWindow("daticell5/di/di/tu2/cuo")
    local anserCWrong = winMgr:getWindow("daticell5/di/di/tu3/cuo")
    local BtnA = winMgr:getWindow("daticell5/di/di/tu1")
    local BtnB = winMgr:getWindow("daticell5/di/di/tu2")
    local BtnC = winMgr:getWindow("daticell5/di/di/tu3")
    local anserARight = winMgr:getWindow("daticell5/di/di/tu1/dui")
    local anserBRight = winMgr:getWindow("daticell5/di/di/tu2/dui")
    local anserCRight = winMgr:getWindow("daticell5/di/di/tu3/dui")
    local anserAWrong = winMgr:getWindow("daticell5/di/di/tu1/cuo")
    local anserBWrong = winMgr:getWindow("daticell5/di/di/tu2/cuo")
    local anserCWrong = winMgr:getWindow("daticell5/di/di/tu3/cuo")
    BtnA:setUserString("result", "over")
    BtnB:setUserString("result", "over")
    BtnC:setUserString("result", "over")

    if result == "right" then
        if id == 1 then
            anserARight:setVisible(true)
            anserBRight:setVisible(false)
            anserCRight:setVisible(false)
            anserAWrong:setVisible(false)
            anserBWrong:setVisible(false)
            anserCWrong:setVisible(false)
        elseif id == 2 then
            anserARight:setVisible(false)
            anserBRight:setVisible(true)
            anserCRight:setVisible(false)
            anserAWrong:setVisible(false)
            anserBWrong:setVisible(false)
            anserCWrong:setVisible(false)
        elseif id == 3 then
            anserARight:setVisible(false)
            anserBRight:setVisible(false)
            anserCRight:setVisible(true)
            anserAWrong:setVisible(false)
            anserBWrong:setVisible(false)
            anserCWrong:setVisible(false)
        end
    else
        if id == 1 then
            anserARight:setVisible(false)
            anserBRight:setVisible(false)
            anserCRight:setVisible(false)
            anserAWrong:setVisible(true)
            anserBWrong:setVisible(false)
            anserCWrong:setVisible(false)
        elseif id == 2 then
            anserARight:setVisible(false)
            anserBRight:setVisible(false)
            anserCRight:setVisible(false)
            anserAWrong:setVisible(false)
            anserBWrong:setVisible(true)
            anserCWrong:setVisible(false)
        elseif id == 3 then
            anserARight:setVisible(false)
            anserBRight:setVisible(false)
            anserCRight:setVisible(false)
            anserAWrong:setVisible(false)
            anserBWrong:setVisible(false)
            anserCWrong:setVisible(true)
        end
    end
end

function JinglingDlg:doRequestQuestByID(id)
    if id == QUEST_SPECIAL_KEJU_1 or id == QUEST_SPECIAL_KEJU_2 or id == QUEST_SPECIAL_KEJU_3 then
        currentKejuTIndex = math.abs(id) - 66660
        self:showKejuTest()
        return
    end

    if id == QUEST_SPECIAL_RENWEN then
        self:showRenwenTest()
        return
    end

    self.currentRequireID = id

    if not JinglingDlg.checkDataSaved(id) then
        GetServerInfo():doRequestJingLingQuest(id)
    else
        if id ~= LANMU_REDIAN_ID and id ~= LANMU_TUIJIAN_ID and id ~= LANMU_KEFU_ID then
            self:insertJingLingWND(id)
        end
    end
end

function JinglingDlg:fillZhihuishilianTable()
    local table1AllId = BeanConfigManager.getInstance():GetTableByName("game.wisdomtrialvill"):getAllID()
    for _, v in pairs(table1AllId) do
        local record = BeanConfigManager.getInstance():GetTableByName("game.wisdomtrialvill"):getRecorder(v)
        table.insert(self.m_ZHI_HUI_SHI_LIAN, record.jinglingid)
    end

    local table2AllId = BeanConfigManager.getInstance():GetTableByName("game.wisdomtrialstate"):getAllID()
    for _, v in pairs(table2AllId) do
        local record = BeanConfigManager.getInstance():GetTableByName("game.wisdomtrialstate"):getRecorder(v)
        table.insert(self.m_ZHI_HUI_SHI_LIAN, record.jinglingid)
    end
end

function JinglingDlg:randomGetQuest()
    local tSize = require "utils.tableutil".tablelength(self.m_ZHI_HUI_SHI_LIAN)
    if tSize > 0 then
        return table.remove(self.m_ZHI_HUI_SHI_LIAN, math.random(1, tSize))
    else
        self:fillZhihuishilianTable()
        return self:randomGetQuest()
    end
end

function JinglingDlg:checkQuestImageShow()
    if self.alreadyAsk then
        self.m_BigImg:setVisible(false)
        self.m_BigImg_kuang:setVisible(false)
        self.m_BigImg_text:setVisible(false)
    end
end

function JinglingDlg:handleSendAskContent(arg)
    local text = self.m_inputBox:GetPureText()
    if text ~= "" then
        self:sendSearchText(text)
        self.m_inputBox:Clear()

        self:AddHistoryRecord(text)
    end
end

function JinglingDlg:checkHistoryClick()
    if self.m_hisFrame:isVisible() then
        local guiSystem = CEGUI.System:getSingleton()
        local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()
        local wndPos = self.m_hisFrame:GetScreenPos()
        local tw = self.m_hisFrame:getPixelSize().width
        local th = self.m_hisFrame:getPixelSize().height
        if mousePos.x > wndPos.x and mousePos.x < wndPos.x + tw and mousePos.y > wndPos.y and mousePos.y < wndPos.y + th then
        else
            self.m_hisFrame:setVisible(false)
            self.m_hisFrameScroll:cleanupNonAutoChildren()
        end
    end
end

function JinglingDlg:handleHistoryCellClicked(arg)
    local e = CEGUI.toWindowEventArgs(arg)
    local btnID = e.window:getID()

    self.m_inputBox:Clear()
    self.m_inputBox:AppendText(CEGUI.String(questHistory[btnID]))
    self.m_inputBox:Refresh()
    self.m_hisFrame:setVisible(false)
    self.m_hisFrameScroll:cleanupNonAutoChildren()
end

function JinglingDlg:handleHistoryClicked(arg)
    self.m_hisFrame:setVisible(true)
    local cellCount = 0
    local winMgr = CEGUI.WindowManager:getSingleton()
    for k, v in pairs(questHistory) do
        local cellWnd = winMgr:loadWindowLayout("lishiwenticell.layout", cellCount)
        local text = winMgr:getWindow(cellCount.."lishiwenticell/text")
        text:subscribeEvent("MouseClick", JinglingDlg.handleHistoryCellClicked, self)
        text:setID(k)
        text:setText(v)
        self.m_hisFrameScroll:addChildWindow(cellWnd)
        local cellHeight = cellWnd:getPixelSize().height
        cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 5), CEGUI.UDim(0, 5 + cellHeight * cellCount)))
        cellCount = cellCount + 1
    end
end

function JinglingDlg:sendSearchText(text)
    if self.currentPageType ~= PAGE_TYPE_WENDA then
        self:enterPage(PAGE_TYPE_WENDA)
    end
    self:insertUserWND(-1, text)
    self.alreadyAsk = true
    self:checkQuestImageShow()
    GetServerInfo():doRequestSearchData(text)
end

function JinglingDlg.globalSetSearchText(text)
    if _instance and string.len(text) > 0 then
        local sText = string.gsub(text, "。", "")
        _instance.m_inputBox:Clear()
        _instance.m_inputBox:AppendText(CEGUI.String(sText))
        _instance.m_inputBox:Refresh()
    end
end

-- 插入模糊查询的多个答案按钮
function JinglingDlg:insertJinglingWndByList(q)
    local winMgr = CEGUI.WindowManager:getSingleton()
    layoutPrfix = layoutPrfix + 1
    local titleVector = std.vector_stQuestTitleID_()
    GetServerInfo():getSearchResultList(q, titleVector)

    local wnd = winMgr:loadWindowLayout("jinglinganswer.layout", layoutPrfix)
    local pWnd = winMgr:getWindow(layoutPrfix .. "JinglingQuest")
    local headIconWnd = CEGUI.Window.toItemCell(winMgr:getWindow(layoutPrfix .. "JinglingQuest/headimg"))
    local nameWnd = winMgr:getWindow(layoutPrfix .. "JinglingQuest/nametext")
    local contentBase = winMgr:getWindow(layoutPrfix .. "JinglingQuest/questbg")
    local contentEdit = CEGUI.toRichEditbox(winMgr:getWindow(layoutPrfix .. "JinglingQuest/questbg/edit"))
    contentEdit:getVertScrollbar():EnbalePanGuesture(false)

    local feedback = winMgr:getWindow(layoutPrfix .. "JinglingQuest/questbg/feedback")
    local feedbackBtnYes = CEGUI.toPushButton(winMgr:getWindow(layoutPrfix .. "JinglingQuest/questbg/feedback/btnYes"))
    local feedbackBtnNo = CEGUI.toPushButton(winMgr:getWindow(layoutPrfix .. "JinglingQuest/questbg/feedback/btnno"))
    feedbackBtnYes:subscribeEvent("Clicked", JinglingDlg.handleFeedBtnClick, self)
    feedbackBtnNo:subscribeEvent("Clicked", JinglingDlg.handleFeedBtnClick, self)
    feedbackBtnYes:setID(layoutPrfix)
    feedbackBtnNo:setID(layoutPrfix)

    if withoutFeed then
        feedback:setVisible(false)
    end

    local IconWidth = 180
    local IconHeight = 60
    local offsetW = 10
    local offsetH = 5
    local totalCount = titleVector:size()
    local btnOneRow = 3
    local BtnStartY = 40
    for index = 0, totalCount - 1 do
        -- 一行三个
        local col = math.floor(index % btnOneRow)
        local row = math.floor(index / btnOneRow)
        local stQuest = titleVector[index]
        local faqid = stQuest.qid
        local faqtitle = stQuest.qtitle

        local pButton = CEGUI.toPushButton(winMgr:createWindow("TaharezLook/common_ty", q .. layoutPrfix .. index))
        pButton:setProperty("NormalImage", "set:common image:tujian3")
        pButton:setProperty("PushedImage", "set:common image:tujian4")
        pButton:setText(faqtitle)
        pButton:setWidth(CEGUI.UDim(0, IconWidth))
        pButton:setHeight(CEGUI.UDim(0, IconHeight))
        pButton:setPosition(CEGUI.UVector2(CEGUI.UDim(0, col *(IconWidth + offsetW)), CEGUI.UDim(0, BtnStartY + row *(IconHeight + offsetH))))
        pButton:setID(tonumber(faqid))
        pButton:setUserString("title", faqtitle)
        pButton:subscribeEvent("Clicked", JinglingDlg.handleListBtnClick, self)
        contentEdit:addChildWindow(pButton)
    end
    local tipStr = MHSD_UTILS.get_msgtipstring(190033)
    contentEdit:AppendParseText(CEGUI.String(tipStr))
    contentEdit:Refresh()

    local textSize = contentEdit:GetExtendSize()
    local bgSize = contentBase:getPixelSize()
    local bgPos = contentBase:getPosition()
    local newBgSizeHeight = textSize.height + 50 + math.ceil(totalCount / btnOneRow) *(IconHeight + offsetH)

    if withoutFeed then
        newBgSizeHeight = textSize.height + 50 + math.ceil(totalCount / btnOneRow) *(IconHeight + offsetH)
    else
        newBgSizeHeight = textSize.height + 180 + math.ceil(totalCount / btnOneRow) *(IconHeight + offsetH)
    end

    local pWndPos = pWnd:getPosition()
    contentBase:setSize(CEGUI.UVector2(CEGUI.UDim(0, bgSize.width), CEGUI.UDim(0, BtnStartY + newBgSizeHeight)))
    contentBase:setPosition(bgPos)
    contentEdit:setYPosition(CEGUI.UDim(0, 20))

    if not withoutFeed then
        feedback:setYPosition(CEGUI.UDim(0, newBgSizeHeight - 120))
    end

    local selfShape = gGetDataManager():GetMainCharacterShape()
    local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(selfShape)
    headIconWnd:SetImage(gGetIconManager():GetItemIconByID(JINGLING_HEAD_ID))
    self.m_questScrollPane:addChildWindow(wnd)

    pWnd:setSize(CEGUI.UVector2(CEGUI.UDim(0, pWnd:getPixelSize().width), CEGUI.UDim(0, newBgSizeHeight + 90)))
    pWnd:setPosition(pWndPos)
    wnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, self.m_questOffsetY)))

    self.m_questOffsetY = self.m_questOffsetY + newBgSizeHeight + 50 + BtnStartY
    -- 背景框距离父控件的topoffset值
    self.m_questScrollPane:setVerticalScrollPosition(self.m_lastAskOffsetY /(self.m_questScrollPane:getVertScrollbar():getDocumentSize()))
end

function JinglingDlg.doGotResponseList(q)
    if _instance then
        _instance:insertJinglingWndByList(q)
    end
end

function JinglingDlg:handleListBtnClick(arg)
    if self.currentPageType ~= PAGE_TYPE_WENDA then
        self:enterPage(PAGE_TYPE_WENDA)
    end

    local e = CEGUI.toWindowEventArgs(arg)
    local title = e.window:getUserString("title")
    local id = e.window:getID()
    self:insertUserWND(nil, title)
    self:doRequestQuestByID(id)
    self.alreadyAsk = true
    self:checkQuestImageShow()
end

function JinglingDlg.doGotResponseMatch(content)
    if _instance then
        _instance:insertJingLingWND(nil, content, false)
    end
end

function JinglingDlg.doGotResponseNoMatch()
    if _instance then
        local content = MHSD_UTILS.get_msgtipstring(190034)
        _instance:insertJingLingWND(nil, content, false)
    end
end

function JinglingDlg:enterPage(pageType)
    self.m_FrameZhiyin:cleanupNonAutoChildren()
    if pageType == PAGE_TYPE_REDIAN then
        self.currentPageType = PAGE_TYPE_REDIAN
        self:doRequestQuestByID(LANMU_REDIAN_ID)
        self.m_pageRedian:setVisible(true)
        self.m_pageWneda:setVisible(false)
        self.m_FrameTuijian:setVisible(false)
        self.m_FrameZhiyin:setVisible(false)
        self.m_questScrollPane:setVisible(false)
        self.m_FrameKefu:setVisible(false)
        self.m_BTN_redian:setSelected(true, false)
    elseif pageType == PAGE_TYPE_TUIJIAN then
        self.currentPageType = PAGE_TYPE_TUIJIAN
        self:doRequestQuestByID(LANMU_TUIJIAN_ID)
        self.m_pageRedian:setVisible(false)
        self.m_pageWneda:setVisible(false)
        self.m_questScrollPane:setVisible(false)
        self.m_FrameTuijian:setVisible(true)
        self.m_FrameKefu:setVisible(false)
        self.m_FrameZhiyin:setVisible(false)
        self.m_BTN_tuijian:setSelected(true, false)
    elseif pageType == PAGE_TYPE_WENDA then
        self.currentPageType = PAGE_TYPE_WENDA
        self.m_pageRedian:setVisible(false)
        self.m_FrameTuijian:setVisible(false)
        self.m_FrameZhiyin:setVisible(false)
        self.m_pageWneda:setVisible(true)
        self.m_questScrollPane:setVisible(true)
        self.m_FrameKefu:setVisible(false)
        self.m_BTN_wenda:setSelected(true, false)
    elseif pageType == PAGE_TYPE_KEFU then
        self.currentPageType = PAGE_TYPE_KEFU
        self:doRequestQuestByID(LANMU_KEFU_ID)
        self.m_FrameKefu:setVisible(true)
        self.m_FrameZhiyin:setVisible(false)
        self.m_pageRedian:setVisible(false)
        self.m_pageWneda:setVisible(false)
        self.m_FrameTuijian:setVisible(false)
        self.m_questScrollPane:setVisible(false)
        self.m_BTN_kefu:setSelected(true, false)
    elseif pageType == PAGE_TYPE_ZHIHUI then
        self.currentPageType = PAGE_TYPE_ZHIHUI
        self.m_FrameKefu:setVisible(false)
        self.m_FrameZhiyin:setVisible(true)
        self.m_pageRedian:setVisible(false)
        self.m_pageWneda:setVisible(false)
        self.m_FrameTuijian:setVisible(false)
        self.m_questScrollPane:setVisible(false)
        self.m_BTN_redian:setSelected(true, false)
    end
end

return JinglingDlg