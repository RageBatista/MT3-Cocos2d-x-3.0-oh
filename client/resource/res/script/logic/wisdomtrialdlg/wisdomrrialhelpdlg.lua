require "logic.dialog"

WisdomTrialHelpDlg = {}
setmetatable(WisdomTrialHelpDlg, Dialog)
WisdomTrialHelpDlg.__index = WisdomTrialHelpDlg

local _instance
function WisdomTrialHelpDlg.getInstance()
	if not _instance then
		_instance = WisdomTrialHelpDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function WisdomTrialHelpDlg.getInstanceAndShow()
	if not _instance then
		_instance = WisdomTrialHelpDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function WisdomTrialHelpDlg.getInstanceNotCreate()
	return _instance
end

function WisdomTrialHelpDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function WisdomTrialHelpDlg.ToggleOpenClose()
	if not _instance then
		_instance = WisdomTrialHelpDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function WisdomTrialHelpDlg.GetLayoutFileName()
	return "kejuqiuzhu.layout"
end

function WisdomTrialHelpDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, WisdomTrialHelpDlg)
	return self
end

function WisdomTrialHelpDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_nameEditbox = CEGUI.toRichEditbox(winMgr:getWindow("kejuqiuzhu/renming"))
    self.m_title = winMgr:getWindow("kejuqiuzhu/di/timu")
    self.m_answer1 = winMgr:getWindow("kejuqiuzhu/di/daan1")
    self.m_answer2 = winMgr:getWindow("kejuqiuzhu/di/daan2")
    self.m_answer3 = winMgr:getWindow("kejuqiuzhu/di/daan3")
    self.m_answer4 = winMgr:getWindow("kejuqiuzhu/di/daan4")
    self.m_answer1:subscribeEvent("MouseClick",WisdomTrialHelpDlg.HandleHelpClicked,self)
    self.m_answer1:setID(1)
    self.m_answer2:subscribeEvent("MouseClick",WisdomTrialHelpDlg.HandleHelpClicked,self)
    self.m_answer2:setID(2)
    self.m_answer3:subscribeEvent("MouseClick",WisdomTrialHelpDlg.HandleHelpClicked,self)
    self.m_answer3:setID(3)
    self.m_answer4:subscribeEvent("MouseClick",WisdomTrialHelpDlg.HandleHelpClicked,self)
    self.m_answer4:setID(4)
    self.m_questionid = 0
    self.m_name= ""
end
function WisdomTrialHelpDlg:HandleHelpClicked(e)
    require("logic.openui").OpenUI(44)
    local eventargs = CEGUI.toWindowEventArgs(e)
    local id = eventargs.window:getID()
    local record = BeanConfigManager.getInstance():GetTableByName("game.wisdomtrialvill"):getRecorder(self.m_questionid)
    local strAnswer = record.options[id - 1]
    CChatOutputDialog:getInstance():ChangeOutChannel(4)
    CChatOutputDialog:getInstance():RefreshOpenedDlgChannel()
    --往公会频道里面文字
    local p = require "protodef.fire.pb.talk.ctranschatmessage2serv".Create()
    p.messagetype = 4
    p.message = "<T t=\""..self.m_name.."[" ..strAnswer.."]\" c=\"FFFFFF00\"></T>"

	LuaProtocolManager.getInstance():send(p)

    WisdomTrialHelpDlg.DestroyDialog()
end
function WisdomTrialHelpDlg.ShowUI(questionid, name, roleid, temp2)
    
    if tonumber(roleid) == gGetDataManager():GetMainCharacterID() then
        GetCTipsManager():AddMessageTipById(190029)
        return
    end
    local manager = require"logic.wisdomtrialdlg.wisdomtrialmanager".getInstance()
    if manager then
        for k, v in ipairs(manager.m_Helps) do
            if tonumber(v.id) == tonumber(roleid) and tonumber(v.ques) == tonumber(questionid) then
                GetCTipsManager():AddMessageTipById(190028)
                return
            end
            
        end
        local help = {id = roleid, ques = questionid}
        table.insert(manager.m_Helps,1,help)
    end
    local dlg = require "logic.wisdomtrialdlg.wisdomrrialhelpdlg".getInstance()
    dlg:setID(tonumber(questionid))
    dlg:setName(name)
    dlg:refreshUI()
end

function WisdomTrialHelpDlg:setID(questionid)
    self.m_questionid = questionid
end
function WisdomTrialHelpDlg:refreshUI()
    local record = BeanConfigManager.getInstance():GetTableByName("game.wisdomtrialvill"):getRecorder(self.m_questionid)
    self.m_answer1:setText("A:"..record.options[0])
    self.m_answer2:setText("B:"..record.options[1])
    self.m_answer3:setText("C:"..record.options[2])
    self.m_answer4:setText("D:"..record.options[3])

    local random = math.random(1, 4)
    if random == 2 then
        self.m_answer1:setText("B:"..record.options[1])
        self.m_answer2:setText("A:"..record.options[0])
        self.m_answer1:setID(2)
        self.m_answer2:setID(1)
    elseif random == 3 then
        self.m_answer1:setText("C:"..record.options[2])
        self.m_answer3:setText("A:"..record.options[0])
        self.m_answer1:setID(3)
        self.m_answer3:setID(1)
    elseif random == 4 then
        self.m_answer1:setText("D:"..record.options[3])
        self.m_answer4:setText("A:"..record.options[0])
        self.m_answer1:setID(4)
        self.m_answer4:setID(1)
    end

    local strbuilder = StringBuilder:new()
    local msgqing = require "utils.mhsdutils".get_resstring(11438)
    strbuilder:Set("parameter1", tostring(self.m_name))
    local content = strbuilder:GetString(msgqing)
    strbuilder:delete()
    self.m_nameEditbox:AppendParseText(CEGUI.String(content))
    self.m_nameEditbox:Refresh()
    
    local msgtimu = require "utils.mhsdutils".get_resstring(11440)
    self.m_title:setText(msgtimu..record.name)
end
--玩家名称
function WisdomTrialHelpDlg:setName(name)
    self.m_name = name
end
return WisdomTrialHelpDlg