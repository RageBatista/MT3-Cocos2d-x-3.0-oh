
require "logic.dialog"

Spacesetaddresscell = {}
setmetatable(Spacesetaddresscell, Dialog)
Spacesetaddresscell.__index = Spacesetaddresscell

local nPrefix = 1

function Spacesetaddresscell.create(pParant)
	local newCell = Spacesetaddresscell:new()
    local strPrefix = tostring(nPrefix)
    nPrefix = nPrefix + 1
    newCell:OnCreate(pParant,strPrefix)
    return newCell
end

function Spacesetaddresscell:clearData()
    self.nId = 0
    self.mapCallBack = {}
end

function Spacesetaddresscell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Spacesetaddresscell)
    self:clearData()
	return self
end

function Spacesetaddresscell:OnClose()
    Dialog.OnClose(self)
end

function Spacesetaddresscell:OnCreate(parent,strPrefix)
    Dialog.OnCreate(self,parent,strPrefix)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.btnAddress =  CEGUI.toPushButton(winMgr:getWindow(strPrefix.."addresscell"))
    self.labelTitle =  winMgr:getWindow(strPrefix.."addresscell/11")
    self.labelTitle:setMousePassThroughEnabled(true)
end

function Spacesetaddresscell:initInfo(nId,strName)
    self.nId = nId
    self.labelTitle:setText(strName)
end

function Spacesetaddresscell:GetLayoutFileName()
	return "addresscell.layout"
end


return Spacesetaddresscell