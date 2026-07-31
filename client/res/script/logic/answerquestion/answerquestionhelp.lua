require "logic.dialog"

AnswerQuestionHelp = {}
setmetatable(AnswerQuestionHelp, Dialog)
AnswerQuestionHelp.__index = AnswerQuestionHelp

local _instance
function AnswerQuestionHelp.getInstance()
	if not _instance then
		_instance = AnswerQuestionHelp:new()
		_instance:OnCreate()
	end
	return _instance
end

function AnswerQuestionHelp.getInstanceAndShow()
	if not _instance then
		_instance = AnswerQuestionHelp:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function AnswerQuestionHelp.getInstanceNotCreate()
	return _instance
end

function AnswerQuestionHelp.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function AnswerQuestionHelp.ToggleOpenClose()
	if not _instance then
		_instance = AnswerQuestionHelp:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function AnswerQuestionHelp.GetLayoutFileName()
	return "datiqiuzhu.layout"
end

function AnswerQuestionHelp:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, AnswerQuestionHelp)
	return self
end

function AnswerQuestionHelp:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_txtTop=winMgr:getWindow("datiqiuzhu/tishi")
    self.m_txtTitle=winMgr:getWindow("datiqiuzhu/di/timu")
    self.m_image1=winMgr:getWindow("datiqiuzhu/di/1/tu")
    self.m_image2=winMgr:getWindow("datiqiuzhu/di/2/tu")
    self.m_image3=winMgr:getWindow("datiqiuzhu/di/3/tu")
    self.m_image1:setID(1)
    self.m_image2:setID(2)
    self.m_image3:setID(3)
    self.m_name1=winMgr:getWindow("datiqiuzhu/di/1/mingzi")
    self.m_name2=winMgr:getWindow("datiqiuzhu/di/2/mingzi")
    self.m_name3=winMgr:getWindow("datiqiuzhu/di/3/mingzi") 
    
    
    self.m_image1:subscribeEvent("MouseClick",AnswerQuestionHelp.HandleAnswerClick,self)
    self.m_image2:subscribeEvent("MouseClick",AnswerQuestionHelp.HandleAnswerClick,self)
    self.m_image3:subscribeEvent("MouseClick",AnswerQuestionHelp.HandleAnswerClick,self)

    self.m_questionid = 0

    self.m_name = ""
end
function AnswerQuestionHelp:HandleAnswerClick(e)
    require("logic.openui").OpenUI(44)
    local eventargs = CEGUI.toWindowEventArgs(e)
    local id = eventargs.window:getID()
    local record = BeanConfigManager.getInstance():GetTableByName("mission.answerquestion"):getRecorder(self.m_questionid)
    local strAnswer = record.object1
    if id == 1 then
        strAnswer = record.object1
    elseif id == 2 then
        strAnswer = record.object2
    elseif id == 3 then
        strAnswer = record.object3
    end
    CChatOutputDialog:getInstance():ChangeOutChannel(4)
    CChatOutputDialog:getInstance():RefreshOpenedDlgChannel()
    --往公会频道里面文字
    local p = require "protodef.fire.pb.talk.ctranschatmessage2serv".Create()
    p.messagetype = 4
    p.message = "<T t=\""..self.m_name.."[" ..strAnswer.."]\" c=\"FFFFFF00\"></T>"

	LuaProtocolManager.getInstance():send(p)

    AnswerQuestionHelp.DestroyDialog()
end
function AnswerQuestionHelp:refreshUI()
    local record = BeanConfigManager.getInstance():GetTableByName("mission.answerquestion"):getRecorder(self.m_questionid)
    self.m_image1:setProperty("Image",gGetIconManager():GetImagePathByID(record.image1):c_str())
    self.m_image2:setProperty("Image",gGetIconManager():GetImagePathByID(record.image2):c_str())
    self.m_image3:setProperty("Image",gGetIconManager():GetImagePathByID(record.image3):c_str())

    self.m_name1:setText(record.object1)
    self.m_name2:setText(record.object2)
    self.m_name3:setText(record.object3)

    local strbuilder = StringBuilder:new()
    local msgqing = require "utils.mhsdutils".get_resstring(11438)
    strbuilder:Set("parameter1", tostring(self.m_name))
    local content = strbuilder:GetString(msgqing)
    strbuilder:delete()
    self.m_txtTop:setText(content)
    local msgtimu = require "utils.mhsdutils".get_resstring(11440)

    self.m_txtTitle:setText(msgtimu..record.title)
    
    
end
function AnswerQuestionHelp.ShowUI(questionid, name, roleid, temp2)
    


    if tonumber(roleid) == gGetDataManager():GetMainCharacterID() then
        GetCTipsManager():AddMessageTipById(190029)
        return
    end

    local manager = require"logic.answerquestion.answerquestionmanager".getInstance()
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
    local dlg = require "logic.answerquestion.answerquestionhelp".getInstance()
    dlg:setID(tonumber(questionid))
    dlg:setName(name)
    dlg:refreshUI()
end
--答题id
function AnswerQuestionHelp:setID(questionid)
    self.m_questionid = questionid
end
--玩家名称
function AnswerQuestionHelp:setName(name)
    self.m_name = name
end
return AnswerQuestionHelp
