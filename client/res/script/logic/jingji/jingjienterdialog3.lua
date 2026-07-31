require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

Jingjienterdialog3 = {}
setmetatable(Jingjienterdialog3, Dialog)
Jingjienterdialog3.__index = Jingjienterdialog3
local _instance;

--//===============================
function Jingjienterdialog3:OnCreate()
    Dialog.OnCreate(self)
    --SetPositionOfWindowWithLabel(self:GetWindow())

    local winMgr = CEGUI.WindowManager:getSingleton()
   
    self.btnChangeHero = CEGUI.toPushButton(winMgr:getWindow("PVPentrance3/button"))
    self.btnChangeHero:subscribeEvent("MouseButtonUp", Jingjienterdialog3.clickEnterJingji, self)

    self.labelName = winMgr:getWindow("PVPentrance3/name")     
    self.imageWait = winMgr:getWindow("PVPentrance3/pi1") 

    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    local nReady = jjManager.nPiPei3
    self:refreshReady(nReady)

    

    local strTextColor = "fffdf4a0"
    local nSpaceX = 0
    local strBorderColor = "FF003454"
    self.aniDlg = require("logic.jingji.jingjipipeianidialog").create(self.imageWait,nSpaceX,strTextColor)
    self.aniDlg:setTextBorderColor(strBorderColor)
    self.btnChangeHero:setRiseOnClickEnabled(false)

end

function Jingjienterdialog3.clickEnterJingji()
    require("logic.jingji.jingjidialog3").getInstanceAndShow()
end

function Jingjienterdialog3:refreshReady(nReady)
     if nReady==1 then
        self.labelName:setVisible(false)
        self.imageWait:setVisible(true)
        
    else
        self.imageWait:setVisible(false)
        self.labelName:setVisible(true)
        
    end
end

--//=========================================
function Jingjienterdialog3.getInstance()
    if not _instance then
        _instance = Jingjienterdialog3:new()
        _instance:OnCreate()
    end
    return _instance
end

function Jingjienterdialog3.getInstanceAndShow()
    if not _instance then
        _instance = Jingjienterdialog3:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function Jingjienterdialog3.getInstanceNotCreate()
    return _instance
end

function Jingjienterdialog3.getInstanceOrNot()
	return _instance
end
	
function Jingjienterdialog3.GetLayoutFileName()
    return "pvpentrance3.layout"
end

function Jingjienterdialog3:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Jingjienterdialog3)
	self:resetData()
    return self
end

function Jingjienterdialog3.DestroyDialog()
	if not _instance then
		return
	end
	if not _instance.m_bCloseIsHide then
		_instance:OnClose()
		_instance = nil
	else
		_instance:ToggleOpenClose()
	end
	
end

function Jingjienterdialog3:resetData()
end

function Jingjienterdialog3:ClearDataInClose()
end

function Jingjienterdialog3:ClearCellAll()
end


function Jingjienterdialog3:OnClose()
    if self.aniDlg then
        self.aniDlg:DestroyDialog()
    end

	Dialog.OnClose(self)
	self:ClearDataInClose()
	_instance = nil
end

return Jingjienterdialog3
