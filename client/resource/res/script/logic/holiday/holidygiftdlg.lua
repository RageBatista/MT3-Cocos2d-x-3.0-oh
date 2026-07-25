require "logic.dialog"

HolidyGiftDlg = {}
setmetatable(HolidyGiftDlg, Dialog)
HolidyGiftDlg.__index = HolidyGiftDlg

local _instance
function HolidyGiftDlg.getInstance()
	if not _instance then
		_instance = HolidyGiftDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function HolidyGiftDlg.getInstanceAndShow()
	if not _instance then
		_instance = HolidyGiftDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function HolidyGiftDlg.getInstanceNotCreate()
	return _instance
end

function HolidyGiftDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function HolidyGiftDlg.ToggleOpenClose()
	if not _instance then
		_instance = HolidyGiftDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function HolidyGiftDlg.GetLayoutFileName()
	return "jierijiangli.layout"
end

function HolidyGiftDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, HolidyGiftDlg)
	return self
end

function HolidyGiftDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_bg = winMgr:getWindow("jierijiangli")
	self.m_scrollCellScro = CEGUI.toScrollablePane(winMgr:getWindow("jierijiangli/di1/liebiao"))
    self.m_Cells = {}
    self.m_text = winMgr:getWindow("jierijiangli/hongdi/text")

    self:refreshUI()
end
function HolidyGiftDlg.remove()
     _instance = nil
end
function HolidyGiftDlg:refreshUI()

    self.m_text:setText(LoginRewardManager.getInstance().m_freshHolidayText)

	for index in pairs( self.m_Cells ) do
		local cell = self.m_Cells[index]
		if cell then
			cell:OnClose(false, false)
			cell = nil
		end
	end
    self.m_Cells = {}

    local i = 1
    local tableAllId = BeanConfigManager.getInstance():GetTableByName("fushi.cholidaygiftconfig"):getAllID()
    for _, v in pairs(tableAllId) do
        local record = BeanConfigManager.getInstance():GetTableByName("fushi.cholidaygiftconfig"):getRecorder(v)
        if math.floor(LoginRewardManager.getInstance().m_freshHolidayId) == math.floor(record.id / 100) then
		    local cell = require "logic.holiday.holidygiftcell".CreateNewDlg(self.m_scrollCellScro)
		    local x = CEGUI.UDim(0, 5)
		    local y = CEGUI.UDim(0, cell:GetWindow():getPixelSize().height*(i-1) + (i - 1)*8)
		    local pos = CEGUI.UVector2(x,y)
		    cell:GetWindow():setPosition(pos)
		    cell:setData(record.id)
		    table.insert(self.m_Cells, cell )
            i = i+ 1
        end
    end
end
return HolidyGiftDlg