require "logic.dialog"

ScriptNpcTalkDialog = {}
setmetatable(ScriptNpcTalkDialog, Dialog)
ScriptNpcTalkDialog.__index = ScriptNpcTalkDialog

local _instance
function ScriptNpcTalkDialog.getInstance()
	if not _instance then
		_instance = ScriptNpcTalkDialog:new()
        _instance.m_eDialogType[DialogTypeTable.eDialogType_SceneMovieWnd] = 1
		_instance:OnCreate()
	end
	return _instance
end

function ScriptNpcTalkDialog.getInstanceAndShow()
	if not _instance then
		_instance = ScriptNpcTalkDialog:new()
        _instance.m_eDialogType[DialogTypeTable.eDialogType_SceneMovieWnd] = 1
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ScriptNpcTalkDialog.getInstanceNotCreate()
	return _instance
end

function ScriptNpcTalkDialog.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ScriptNpcTalkDialog.ToggleOpenClose()
	if not _instance then
		_instance = ScriptNpcTalkDialog:new()     
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ScriptNpcTalkDialog.GetLayoutFileName()
	return "scenemovienpcspeak.layout"
end

function ScriptNpcTalkDialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ScriptNpcTalkDialog)
	return self
end

function ScriptNpcTalkDialog:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pHeadIcon = winMgr:getWindow("SceneMovieNpcSpeak/Head")
	self.m_pName = winMgr:getWindow("SceneMovieNpcSpeak/Name")
    self.m_pContentBox = CEGUI.Window.toAnimateText(winMgr:getWindow("SceneMovieNpcSpeak/Content"))

end
function ScriptNpcTalkDialog.setNpcSpeakWordsCpp(strheadID, strNpcName, strText, a)
    local dlg = ScriptNpcTalkDialog.getInstanceNotCreate()
    if dlg then
        dlg:SetTalkContent(strheadID, strNpcName, strText)
    end
end
function ScriptNpcTalkDialog:SetTalkContent(strheadID, strNpcName, strText)
	local name = strNpcName
    local headID = tonumber(strheadID)
	if headID==0 then
		name = gGetDataManager():GetMainCharacterName()
		local roleShape=gGetDataManager():GetMainCharacterShape()
		local npcShape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(roleShape)
		if npcShape.id ~= -1 then
			headID=npcShape.headID;
		end
	end
	if self.m_pName then
		self.m_pName:setText(name)
	end

	if headID>0 then
	
		local iconpath = gGetIconManager():GetImagePathByID(headID)
		if iconpath~="" then
			self.m_pHeadIcon:setProperty("Image",iconpath:c_str())
		end
	end
	if self.m_pContentBox then
		self.m_pContentBox:setText(strText)
		self.m_pContentBox:Reset()
	end
end
function ScriptNpcTalkDialog.isCurrentSpeakFinish()
    local dlg = ScriptNpcTalkDialog.getInstanceNotCreate()
    if dlg then
        if dlg.m_pContentBox:isTextEnd() then
            return 1 
        else 
            return 0
        end
    end
end
function ScriptNpcTalkDialog.isTextWaitEnd()
    local dlg = ScriptNpcTalkDialog.getInstanceNotCreate()
    if dlg then
    	if dlg.m_pContentBox:isTextEnd() then
		    local endTime= dlg.m_pContentBox:GetTextEndTime()
		    local bTime = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(198).value)
		    if endTime >= bTime then
			    return 1
		    end
	    end
	    return 0
    end
end

function ScriptNpcTalkDialog.makeAllWordsShow()
    local dlg = ScriptNpcTalkDialog.getInstanceNotCreate()
    if dlg then
        dlg.m_pContentBox:ShowAllText()
    end
end

function ScriptNpcTalkDialog.isShow()
    local dlg = ScriptNpcTalkDialog.getInstanceNotCreate()
    if dlg then
        return 1
    else
        return 0
    end
end
return ScriptNpcTalkDialog
