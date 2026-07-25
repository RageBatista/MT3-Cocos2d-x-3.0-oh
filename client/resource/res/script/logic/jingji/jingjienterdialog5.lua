require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

Jingjienterdialog5 = {}
setmetatable(Jingjienterdialog5, Dialog)
Jingjienterdialog5.__index = Jingjienterdialog5
local _instance;

--//===============================
function Jingjienterdialog5:OnCreate()
  local strPrefix = "Jingjienterdialog5"
    Dialog.OnCreate(self,nil,strPrefix)
    --SetPositionScreenCenter(self:GetWindow())
  
    local winMgr = CEGUI.WindowManager:getSingleton()
   
    self.btnChangeHero = CEGUI.toPushButton(winMgr:getWindow(strPrefix.."PVPentrance/button"))
    self.btnChangeHero:subscribeEvent("MouseButtonUp", Jingjienterdialog5.clickEnterJingji, self)

    self.labelName = winMgr:getWindow(strPrefix.."PVPentrance/name") 
    self.imageWait = winMgr:getWindow(strPrefix.."PVPentrance/pi1") 
    
    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    local nReady = jjManager.nPiPei1
    self:refreshReady(nReady)

    --[[
    local strTextColor = "ffff0000"
    local nSpaceX = 0
    local strBorderColor = "FF003454"
    self.aniDlg = require("logic.jingji.jingjipipeianidialog").create(self.imageWait,nSpaceX,strTextColor)
    self.aniDlg:setTextBorderColor(strBorderColor)
    self.btnChangeHero:setRiseOnClickEnabled(false)
    --]]
    local strActiveName =require("utils.mhsdutils").get_resstring(11813) --5v5¾º¼¼³¡
    self.labelName:setText(strActiveName)
end



function Jingjienterdialog5.clickEnterJingji()
    require("logic.jingji.jingjidialog5").getInstanceAndShow()
end

function Jingjienterdialog5:refreshReady(nReady)
    if nReady==1 then
        self.labelName:setVisible(false)
        self.imageWait:setVisible(true)
        
    else
        self.imageWait:setVisible(false)
        self.labelName:setVisible(true)
        
    end
end


--//=========================================
function Jingjienterdialog5.getInstance()
    if not _instance then
        _instance = Jingjienterdialog5:new()
        _instance:OnCreate()
    end
    return _instance
end

function Jingjienterdialog5.getInstanceAndShow()
    if not _instance then
        _instance = Jingjienterdialog5:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function Jingjienterdialog5.getInstanceNotCreate()
    return _instance
end

function Jingjienterdialog5.GetLayoutFileName()
    return "pvpentrance5.layout"
end

function Jingjienterdialog5:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Jingjienterdialog5)
    return self
end

function Jingjienterdialog5.DestroyDialog()
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


function Jingjienterdialog5:OnClose()
    if self.aniDlg then
        self.aniDlg:DestroyDialog()
    end

	Dialog.OnClose(self)
	_instance = nil
end

return Jingjienterdialog5
