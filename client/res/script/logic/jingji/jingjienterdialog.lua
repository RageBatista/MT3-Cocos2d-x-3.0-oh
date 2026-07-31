require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

Jingjienterdialog = {}
setmetatable(Jingjienterdialog, Dialog)
Jingjienterdialog.__index = Jingjienterdialog
local _instance;

--//===============================
function Jingjienterdialog:OnCreate()
    Dialog.OnCreate(self)
    --SetPositionOfWindowWithLabel(self:GetWindow())

    local winMgr = CEGUI.WindowManager:getSingleton()
   
    self.btnChangeHero = CEGUI.toPushButton(winMgr:getWindow("PVPentrance/button"))
    self.btnChangeHero:subscribeEvent("MouseButtonUp", Jingjienterdialog.clickEnterJingji, self)

    self.labelName = winMgr:getWindow("PVPentrance/name") 
    self.imageWait = winMgr:getWindow("PVPentrance/pi1") 
    
    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    local nReady = jjManager.nPiPei1
    self:refreshReady(nReady)

    
    local strTextColor = "fffdf4a0"
    local nSpaceX = 0
    local strBorderColor = "FF003454"
    self.aniDlg = require("logic.jingji.jingjipipeianidialog").create(self.imageWait,nSpaceX,strTextColor)
    self.aniDlg:setTextBorderColor(strBorderColor)
    self.btnChangeHero:setRiseOnClickEnabled(false)
end



function Jingjienterdialog.clickEnterJingji()
    require("logic.jingji.jingjidialog").getInstanceAndShow()
end

function Jingjienterdialog:refreshReady(nReady)
    if nReady==1 then
        self.labelName:setVisible(false)
        self.imageWait:setVisible(true)
        
    else
        self.imageWait:setVisible(false)
        self.labelName:setVisible(true)
        
    end
end


--//=========================================
function Jingjienterdialog.getInstance()
    if not _instance then
        _instance = Jingjienterdialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function Jingjienterdialog.getInstanceAndShow()
    if not _instance then
        _instance = Jingjienterdialog:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function Jingjienterdialog.getInstanceNotCreate()
    return _instance
end

function Jingjienterdialog.getInstanceOrNot()
	return _instance
end
	
function Jingjienterdialog.GetLayoutFileName()
    return "pvpentrance.layout"
end

function Jingjienterdialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Jingjienterdialog)
	self:resetData()
    return self
end

function Jingjienterdialog.DestroyDialog()
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

function Jingjienterdialog:resetData()

end

function Jingjienterdialog:ClearDataInClose()
	
end

function Jingjienterdialog:ClearCellAll()
	
end


function Jingjienterdialog:OnClose()
    if self.aniDlg then
        self.aniDlg:DestroyDialog()
    end

	self:ClearCellAll()
	Dialog.OnClose(self)
	self:ClearDataInClose()
	_instance = nil
end

return Jingjienterdialog
