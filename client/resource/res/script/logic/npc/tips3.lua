require "utils.mhsdutils"
require "logic.dialog"



Tips3 = {}
setmetatable(Tips3, Dialog)
Tips3.__index = Tips3
local _instance;

function Tips3:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Tips3)
    return self
end

function Tips3:clearList()
end

function Tips3:HandleCellClicked(args)
end

function Tips3:RefreshData(title1,title2,title3,title4,title5,title6)
    local winMgr = CEGUI.WindowManager:getSingleton()
    	self.bg = winMgr:getWindow("tips3") 
    self.m_pNpcIcon1 = winMgr:getWindow("tips3/tiao2")
    self.m_pNpcIcon2 = winMgr:getWindow("tips3/tiao3")
	if title1 then
		self.title_st = winMgr:getWindow("tips3/text11")
		self.title_st:setVisible(true)
		self.title_st:setText(title1)
	end
	if title2 then
		self.title_st = winMgr:getWindow("tips3/text22")
		self.title_st:setVisible(true)
		self.title_st:setText(title2)
	end
	if title3 then
		self.title_st = winMgr:getWindow("tips3/text33")
		self.title_st:setVisible(true)
		self.title_st:setText(title3)
	end
	if title4 then
		self.title_st = winMgr:getWindow("tips3/text44")
		self.title_st:setVisible(true)
		self.title_st:setText(title4)
	end
	if title5 then
		self.title_st = winMgr:getWindow("tips3/text55")
		self.title_st:setVisible(true)
		self.title_st:setText(title5)
	end
	if title6 == 0 then
		self.m_pNpcIcon1:setVisible(true)
		self.m_pNpcIcon2:setVisible(false)
		else
		self.m_pNpcIcon1:setVisible(false)
		self.m_pNpcIcon2:setVisible(true)
	end
end

function Tips3:OnCreate(title1,title2,title3,title4,title5,title6)
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_btnguanbi = CEGUI.toPushButton(winMgr:getWindow("tips3/guanbi"))
	self.m_btnguanbi:subscribeEvent("Clicked", Npctiaozhan.handguanbi, self)
    Dialog.OnCreate(self)
	self:RefreshData(title1,title2,title3,title4,title5,title6)
end

--//========================================
function Tips3.getInstance(title1,title2,title3,title4,title5,title6)
    if not _instance then
        _instance = Tips3:new()
        _instance:OnCreate(title1,title2,title3,title4,title5,title6)
    end
    return _instance
end

function Tips3.getInstanceAndShow(title1,title2,title3,title4,title5,title6)
    if not _instance then
        _instance = Tips3:new()
        _instance:OnCreate(title1,title2,title3,title4,title5,title6)
	else
		_instance:SetVisible(true)
        _instance:RefreshData(title1,title2,title3,title4,title5,title6)
    end
    return _instance
end

function Tips3.getInstanceNotCreate()
    return _instance
end

function Tips3.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end
function Tips3.closeDialog()
	if not _instance then 
		return
	end
	_instance:OnClose()
	_instance = nil
end

function Tips3:OnClose()
	Dialog.OnClose(self)
	_instance = nil
end

function Tips3.getInstanceOrNot()
	return _instance
end

function Tips3.GetLayoutFileName()
    return "tips3.layout"
end

function Npctiaozhan:handguanbi(e)
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

return Tips3
