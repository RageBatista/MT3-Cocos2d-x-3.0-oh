Familyhuodongdiacell = { }

setmetatable(Familyhuodongdiacell, Dialog)
Familyhuodongdiacell.__index = Familyhuodongdiacell
local prefix = 0

function Familyhuodongdiacell.CreateNewDlg(parent)
    local newDlg = Familyhuodongdiacell:new()
    newDlg:OnCreate(parent)
    return newDlg
end

function Familyhuodongdiacell.GetLayoutFileName()
    return "familyhuodongdiacell.layout"
end

function Familyhuodongdiacell:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyhuodongdiacell)
    return self
end

function Familyhuodongdiacell:OnCreate(parent)
    prefix = prefix + 1
    Dialog.OnCreate(self, parent, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(prefix)

    self.m_Icon = winMgr:getWindow(prefixstr .. "familyhuodongdiacell/dikuang/icon")
    self.m_Name = winMgr:getWindow(prefixstr .. "familyhuodongdiacell/huodongname")
    self.m_Number = winMgr:getWindow(prefixstr .. "familyhuodongdiacell/text")
     
    self.m_Level = winMgr:getWindow(prefixstr .. "familyhuodongdiacell/dengjiyaoqiu")
    self.m_TimeText = winMgr:getWindow(prefixstr .. "familyhuodongdiacell/kaifangshijian")
	
	self.m_Btn = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "familyhuodongdiacell/open"))
	self.m_Btn1 = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "familyhuodongdiacell/open1"))
	self.m_Btn2 = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "familyhuodongdiacell/open2"))
    self.m_mange = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "familyhuodongdiacell/guanli"))
 
 
end
-- …Ë÷√–≈œ¢
function Familyhuodongdiacell:SetInfor(infor)
    if not infor then
        return
    end
    self.m_Btn:setID(infor.id)
	self.m_Btn1:setID(infor.id)
	self.m_Btn2:setID(infor.id)
    self.m_mange:setID(infor.id)
    self.m_ID = infor.id
    self.m_Name:setText(infor.name)
    self.m_Icon:setProperty("Image", infor.icon)
    self.m_Level:setText(infor.leveldesc)
    self.m_TimeText:setText(infor.opentimedesc)
    self.m_Number:setText(infor.huodongdesc)
    local datamanager = require "logic.faction.factiondatamanager"
	
	 if infor.id == 3 then
		self.m_Btn:setVisible(false)
		self.m_Btn1:setVisible(false)
		self.m_Btn2:setVisible(true)
        self.m_mange:setVisible(false) 
    elseif infor.id == 2 then
		self.m_Btn:setVisible(false)
		self.m_Btn1:setVisible(true)
		self.m_Btn2:setVisible(false)
        self.m_mange:setVisible(true) 
	else
		self.m_Btn:setVisible(true)
		self.m_Btn1:setVisible(false)
		self.m_Btn2:setVisible(false)
        self.m_mange:setVisible(false)
    end
end

return Familyhuodongdiacell
