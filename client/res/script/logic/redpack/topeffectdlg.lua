require "logic.dialog"

TopEffectDlg = {}
setmetatable(TopEffectDlg, Dialog)
TopEffectDlg.__index = TopEffectDlg

local _instance
function TopEffectDlg.getInstance()
	if not _instance then
		_instance = TopEffectDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function TopEffectDlg.getInstanceAndShow()
	if not _instance then
		_instance = TopEffectDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function TopEffectDlg.getInstanceNotCreate()
	return _instance
end

function TopEffectDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function TopEffectDlg.ToggleOpenClose()
	if not _instance then
		_instance = TopEffectDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function TopEffectDlg.GetLayoutFileName()
	return "topeffet.layout"
end

function TopEffectDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, TopEffectDlg)
	return self
end

function TopEffectDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.bg = winMgr:getWindow("topeffet")
    self:GetWindow():setTopMost(true)
    

end
function TopEffectDlg:startRedPackAll()
    local flagEffect = gGetGameUIManager():AddUIEffect(self.bg, MHSD_UTILS.get_effectpath(11075), false, 0, 0, false)
end
function TopEffectDlg:startRedPackOpen(num)
    local realsize = 1
    realsize = realsize - tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(365).value) / 100
    if num >= 1000 * realsize then
        local flagEffect = gGetGameUIManager():AddUIEffect(self.bg, "spine/hongbao/hongbao", false, 0, 0, false)
    else
        local flagEffect = gGetGameUIManager():AddUIEffect(self.bg, "spine/hongbao/hongbao", false, 0, 0, false)
        flagEffect:SetDefaultActName("play2")
    end
end
return TopEffectDlg