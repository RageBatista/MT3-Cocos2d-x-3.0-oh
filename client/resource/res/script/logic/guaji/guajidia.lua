require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

Guajidia = {}
setmetatable(Guajidia, Dialog)
Guajidia.__index = Guajidia
local _instance;

--//===============================
function Guajidia:OnCreate()
    Dialog.OnCreate(self)
    --SetPositionOfWindowWithLabel(self:GetWindow())

    local winMgr = CEGUI.WindowManager:getSingleton()

    self.btnChangeHero = CEGUI.toPushButton(winMgr:getWindow("Gaojiguaji/button"))
    self.btnChangeHero:subscribeEvent("MouseButtonUp", Guajidia.clickEnterJingji, self)

    self.labelName = winMgr:getWindow("Gaojiguaji/name")
    self.imageWait = nil
    if winMgr:isWindowPresent("Gaojiguaji/imageWait") then
        self.imageWait = winMgr:getWindow("Gaojiguaji/imageWait")
    end

    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    local nReady = jjManager.nPiPei3
    self:refreshReady(nReady)



    local strTextColor = "ffff0000"
    local nSpaceX = 0
    local strBorderColor = "FF003454"
    if self.imageWait then
        self.aniDlg = require("logic.jingji.jingjipipeianidialog").create(self.imageWait,nSpaceX,strTextColor)
        self.aniDlg:setTextBorderColor(strBorderColor)
    end
    self.btnChangeHero:setRiseOnClickEnabled(false)

end

function Guajidia.clickEnterJingji()
   require("logic.guaji.guaji").getInstanceAndShow()
    local p = require("protodef.fire.pb.mission.activelist.crefreshactivitylistfinishtimes"):new()
	LuaProtocolManager:send(p)	
end


function Guajidia.createDlg(activities, activevalue, chests, recommend, closeids)

	if HuoDongManager.getInstanceNotCreate() then
		local huodongManager = HuoDongManager.getInstanceNotCreate()
 
		huodongManager.m_activities = activities

		huodongManager.m_activevalue = activevalue
  
		huodongManager.m_chests = chests
 
		huodongManager.m_recommend = recommend

        huodongManager.m_closeids = closeids

		huodongManager.hasHongdianAll = false
  
        local p = require("protodef.fire.pb.mission.cgetactivityinfo"):new()
	    LuaProtocolManager:send(p)
	end	
	

end
function Guajidia.zhuangtai(xx)
    return self.labelName:setText(xx)
end

function Guajidia:refreshReady(nReady)
    local hasWaitIcon = (self.imageWait ~= nil)
    if nReady==1 then
        self.labelName:setVisible(not hasWaitIcon)
        if hasWaitIcon then
            self.imageWait:setVisible(true)
        end

    else
        if hasWaitIcon then
            self.imageWait:setVisible(false)
        end
        self.labelName:setVisible(true)

    end
end

--//=========================================
function Guajidia.getInstance()
    if not _instance then
        _instance = Guajidia:new()
        _instance:OnCreate()
    end
    return _instance
end

function Guajidia.getInstanceAndShow()
    if not _instance then
        _instance = Guajidia:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Guajidia.getInstanceNotCreate()
    return _instance
end

function Guajidia.getInstanceOrNot()
    return _instance
end

function Guajidia.GetLayoutFileName()
    return "guajianniu.layout"
end

function Guajidia:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Guajidia)
    self:resetData()
    return self
end

function Guajidia.DestroyDialog()
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

function Guajidia:resetData()
end

function Guajidia:ClearDataInClose()
end

function Guajidia:ClearCellAll()
end


function Guajidia:OnClose()
    if self.aniDlg then
        self.aniDlg:DestroyDialog()
    end

    Dialog.OnClose(self)
    self:ClearDataInClose()
    _instance = nil
end

return Guajidia
