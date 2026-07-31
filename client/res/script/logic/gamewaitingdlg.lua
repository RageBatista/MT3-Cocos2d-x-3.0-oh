require "logic.dialog"

GameWaitingDlg = {}
setmetatable(GameWaitingDlg, Dialog)
GameWaitingDlg.__index = GameWaitingDlg

local _instance
function GameWaitingDlg.getInstance()
	if not _instance then
		_instance = GameWaitingDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function GameWaitingDlg.getInstanceAndShow()
	if not _instance then
		_instance = GameWaitingDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function GameWaitingDlg.getInstanceNotCreate()
	return _instance
end

function GameWaitingDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function GameWaitingDlg.ToggleOpenClose()
	if not _instance then
		_instance = GameWaitingDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function GameWaitingDlg.GetLayoutFileName()
	return "chongzhi.layout"
end

function GameWaitingDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, GameWaitingDlg)
	return self
end

function GameWaitingDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.effectWnd = winMgr:getWindow("chongzhi/effet")

    gGetGameUIManager():AddUIEffect(self.effectWnd,  MHSD_UTILS.get_effectpath(11081), true)
    
    self.m_time = 15 * 1000 

end
function GameWaitingDlg:Update(delta)
    if self.m_time > 0 then
        self.m_time = self.m_time - delta
    else
        GameWaitingDlg.DestroyDialog()
    end
end
return GameWaitingDlg