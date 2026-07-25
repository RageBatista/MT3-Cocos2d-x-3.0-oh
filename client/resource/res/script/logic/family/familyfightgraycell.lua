BangZhanGrayCell = {}

setmetatable(BangZhanGrayCell, Dialog)
BangZhanGrayCell.__index = BangZhanGrayCell
local prefix = 0

function BangZhanGrayCell.CreateNewDlg(parent)
	local newDlg = BangZhanGrayCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function BangZhanGrayCell.GetLayoutFileName()
	return "bangzhancell2.layout"
end

function BangZhanGrayCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, BangZhanGrayCell)
	return self
end

function BangZhanGrayCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr =  tostring(prefix)

	self.m_width = self:GetWindow():getPixelSize().width
	self.m_height = self:GetWindow():getPixelSize().height 
	
    self.m_rank = winMgr:getWindow(prefixstr .. "bangzhancell2/pai")
    self.m_name = winMgr:getWindow(prefixstr .. "bangzhancell2/name")
    self.m_jifen = winMgr:getWindow(prefixstr .. "bangzhancell2/jifen")

    self.m_rank1 = winMgr:getWindow(prefixstr .. "bangzhancell2/pai2")
    self.m_name1 = winMgr:getWindow(prefixstr .. "bangzhancell2/name2")
    self.m_jifen1 = winMgr:getWindow(prefixstr .. "bangzhancell2/jifen2")

end

function BangZhanGrayCell:SetMyZhanRankData(data,EnemyData,idx)
    if data then
        self.m_rank:setVisible(true)
        self.m_name:setVisible(true)
        self.m_jifen:setVisible(true)
		self.m_rank:setText(tostring(idx))
        self.m_name:setText(tostring(data.rolename))
        self.m_jifen:setText(tostring(data.rolescroe))
    else
        self.m_rank:setVisible(false)
        self.m_name:setVisible(false)
        self.m_jifen:setVisible(false)
    end
	
	if EnemyData then
		self.m_rank1:setVisible(true)
        self.m_name1:setVisible(true)
        self.m_jifen1:setVisible(true)
        self.m_rank1:setText(tostring(idx))
        self.m_name1:setText(tostring(EnemyData.rolename))
        self.m_jifen1:setText(tostring(EnemyData.rolescroe))
    else
        self.m_rank1:setVisible(false)
        self.m_name1:setVisible(false)
        self.m_jifen1:setVisible(false)
    end
end

 

return BangZhanGrayCell