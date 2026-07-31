familyduizhencell = {}

setmetatable(familyduizhencell, Dialog)
familyduizhencell.__index = familyduizhencell
local prefix = 0

function familyduizhencell.CreateNewDlg(parent,id)
	local newDlg = familyduizhencell:new()
	newDlg:OnCreate(parent,id)
	return newDlg
end

function familyduizhencell.GetLayoutFileName()
	return "familyduizhencell3.layout"
end

function familyduizhencell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, familyduizhencell)
	return self
end


function familyduizhencell:OnCreate(parent, id)
    Dialog.OnCreate(self, parent, id)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(id)
    self.m_ID = 0
	self.m_Btn = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "familyduizhencell3/dibang"))
    self.m_Btn:EnableClickAni(false)
	self.m_ID1 = winMgr:getWindow(prefixstr .. "familyduizhencell3/dibang/ID1")
	self.m_ID2 = winMgr:getWindow(prefixstr .. "familyduizhencell3/dibang/ID2")
	self.m_img2 = winMgr:getWindow(prefixstr .. "familyduizhencell3/dibang/shengfu2")
	self.m_img1 = winMgr:getWindow(prefixstr .. "familyduizhencell3/dibang/shengfu1")
	self.m_Name1 = winMgr:getWindow(prefixstr .. "familyduizhencell3/dibang/name1")
	self.m_Name2 = winMgr:getWindow(prefixstr .. "familyduizhencell3/dibang/name2")
end

function familyduizhencell:SetMyZhanRankData(data,index)
    if data then
        self.m_ID1:setText(data.clanid1)
        self.m_ID2:setText(data.clanid2)
        if data.winner == -1 then
            self.m_img1:setVisible(false)
            self.m_img2:setVisible(false)
        elseif data.winner == 0 then
            self.m_img1:setVisible(true)
            self.m_img2:setVisible(true)
            self.m_img1:setProperty("Image","set:huobanui image:sheng")
            self.m_img2:setProperty("Image","set:huobanui image:fu")
        elseif data.winner == 1 then
            self.m_img1:setVisible(true)
            self.m_img2:setVisible(true)
            self.m_img1:setProperty("Image","set:huobanui image:fu")
            self.m_img2:setProperty("Image","set:huobanui image:sheng")
        else
            --
        end
        self.m_Name1:setText(data.clanname1)
        self.m_Name2:setText(data.clanname2)
    end
end

return familyduizhencell