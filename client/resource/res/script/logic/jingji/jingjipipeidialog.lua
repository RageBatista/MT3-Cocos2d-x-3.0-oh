require "utils.mhsdutils"
require "logic.dialog"
require "utils.commonutil"


Jingjipipeidialog = {}
setmetatable(Jingjipipeidialog, Dialog)
Jingjipipeidialog.__index = Jingjipipeidialog
local _instance;


Jingjipipeidialog.eState= 
{
    normal =1,
   -- waitToSend = 2,
    randRole = 3,
    beginToBattle = 4,
}
--//===============================
function Jingjipipeidialog:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())

    local winMgr = CEGUI.WindowManager:getSingleton()
  
    
    local strPreName = "jingjichangpipeidialog/hero" --jingjichangpipeidialog/hero1
    for nIndex=1,2 do
        self.vRole[nIndex] = {}
        self.vRole[nIndex].itemcell = CEGUI.toItemCell(winMgr:getWindow(strPreName..nIndex.."/icon"))
        self.vRole[nIndex].labelLv = winMgr:getWindow(strPreName..nIndex.."/level/text")


        self.vRole[nIndex].imageJob = winMgr:getWindow(strPreName..nIndex.."/icon/tubiao")
        --jingjichangpipeidialog/hero1/icon/tubiao
        --jingjichangpipeidialog/hero2/icon/tubia2
    end
    self.imageWait = winMgr:getWindow("jingjichangpipeidialog/pipei") 

    self.btnClose = CEGUI.toPushButton(winMgr:getWindow("jingjichangpipeidialog/zuixiaohua"))
    self.btnClose:subscribeEvent("MouseButtonUp",Jingjipipeidialog.clicClose, self)

    self.btnCancel = CEGUI.toPushButton(winMgr:getWindow("jingjichangpipeidialog/quxiao"))
    self.btnCancel:subscribeEvent("MouseButtonUp",Jingjipipeidialog.clickCancel, self)

    self.iamgeTimeCount = winMgr:getWindow("jingjichangpipeidialog/daojishi") --jingjichangpipeidialog/daojishi
    self.iamgeTimeCount:setVisible(false)

    self:refreshMyItemcell()

    self:GetWindow():subscribeEvent("WindowUpdate", Jingjipipeidialog.HandleWindowUpate, self)

    self.nState = Jingjipipeidialog.eState.waitToSend

    self:resetCellTarget()
    math.randomseed(os.time())

    --self:sendReady()
    self:addPipeiani()
end

function Jingjipipeidialog:addPipeiani()
    local nSpaceX = 20
    local strTextColor = "FF693F00" 
    self.aniDlg = require("logic.jingji.jingjipipeianidialog").create(self.imageWait,nSpaceX,strTextColor)
end



function Jingjipipeidialog:resetCellTarget()
    local nLevel =0
    local nShape =0
    local nJob =0
    self:refreshCell(2,nLevel,nShape,nJob)
end

function Jingjipipeidialog:sendReady()
    local p = require "protodef.fire.pb.battle.pvp1.cpvp1readyfight":new()
    p.ready = 1
	require "manager.luaprotocolmanager":send(p)
end

function Jingjipipeidialog:HandleWindowUpate(args)

--[[
 self.fWaitToSendCd = 5.0
    self.fWaitToSendDt = 0
--]]
    local ue = CEGUI.toUpdateEventArgs(args)
    local fdt = ue.d_timeSinceLastFrame  --√Î

    if self.nState == Jingjipipeidialog.eState.waitToSend then
        self.fRoleDt = self.fRoleDt + fdt
        if self.fRoleDt >= self.fChangeRoleCd then
            self:rendomChangeTargetRole()
            self.fRoleDt = 0
        end

        self.fWaitToSendDt = self.fWaitToSendDt + fdt
        if self.fWaitToSendDt >= self.fWaitToSendCd then
            self.fWaitToSendDt = 0
            self.nState = Jingjipipeidialog.eState.randRole 
            --self.fRoleDt = 0 
            --self:sendReady()
        end

    elseif  self.nState == Jingjipipeidialog.eState.randRole  then
        self.fRoleDt = self.fRoleDt + fdt
        if self.fRoleDt >= self.fChangeRoleCd then
            self:rendomChangeTargetRole()
            self.fRoleDt = 0
        end
    elseif self.nState == Jingjipipeidialog.eState.beginToBattle  then
        self.fRoleDt = self.fRoleDt + fdt
       
        if self.fRoleDt >= 1.0 then
            self.nBeginBattleImage = self.nBeginBattleImage + 1
            self.fRoleDt = 0
            self:refreshBeginImage()
        end

        if self.nBeginBattleImage == 4 then
           --Jingjipipeidialog.DestroyDialog()
        end
    end
end

function Jingjipipeidialog:rendomChangeTargetRole()
    
    local jjManager = require("logic.jingji.jingjimanager").getInstance()

     if not gGetDataManager() then
        return
    end

    local nLevel = gGetDataManager():GetMainCharacterLevel()
    local nShape = gGetDataManager():GetMainCharacterShape()
    local nHeadIdRand ,nJobId = jjManager:getRandomHeadId()

    local Jingjimanager = require("logic.jingji.jingjimanager")
    local pvpType = Jingjimanager.eJingjiType.oneVOne

    local nLevelRand = jjManager:getRandomLevel(pvpType)
    local nIndex = 2
    local image = gGetIconManager():GetImageByID(nHeadIdRand)
    if image then
        self.vRole[nIndex].itemcell:SetImage(image)
    end
    
    local strLvzi = require "utils.mhsdutils".get_resstring(11330)
    local strLv = strLvzi..tostring(nLevelRand)
    self.vRole[nIndex].labelLv:setText(strLv)

    local schoolTable=BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(nJobId)
    if schoolTable  then
        self.vRole[nIndex].imageJob:setVisible(true)
	    self.vRole[nIndex].imageJob:setProperty("Image", schoolTable.schooliconpath)
    else
        self.vRole[nIndex].imageJob:setVisible(false)
    end

end

function Jingjipipeidialog:clickCancel(arg)
    local p = require "protodef.fire.pb.battle.pvp1.cpvp1readyfight":new()
    p.ready = 0 --»°œ˚∆•≈‰
	require "manager.luaprotocolmanager":send(p)
end

function Jingjipipeidialog:clicClose(arg)
    Jingjipipeidialog.DestroyDialog()
end

function Jingjipipeidialog:RefreshUI()
end


function Jingjipipeidialog:refreshMyItemcell()
    if not gGetDataManager() then
        return
    end

    local nLevel = gGetDataManager():GetMainCharacterLevel()
    local nShape = gGetDataManager():GetMainCharacterShape()
    local nJob =  gGetDataManager():GetMainCharacterSchoolID()

    self:refreshCell(1,nLevel,nShape,nJob)
end

function Jingjipipeidialog:refreshOther(nLevel,nShape,nJob)
    self:refreshCell(2,nLevel,nShape,nJob)
end

function Jingjipipeidialog:refreshCell(nIndex,nLevel,nShape,nJobId)
    local shapeTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(nShape)
    if shapeTable  then
          local image = gGetIconManager():GetImageByID(shapeTable.littleheadID)
          if image then
             self.vRole[nIndex].itemcell:SetImage(image)
          end
    else
        self.vRole[nIndex].itemcell:SetImage(nil)
    end
    local strLvzi = require "utils.mhsdutils".get_resstring(11330)
    local strLv = strLvzi..tostring(nLevel)
    self.vRole[nIndex].labelLv:setText(strLv)

    local schoolTable=BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(nJobId)
    if schoolTable and schoolTable.id ~= -1 then
            self.vRole[nIndex].imageJob:setVisible(true)
	        self.vRole[nIndex].imageJob:setProperty("Image", schoolTable.schooliconpath)
    else
        self.vRole[nIndex].imageJob:setVisible(false)
    end
end


function Jingjipipeidialog:setPipeiState(nState)
    self.nState = nState --Jingjipipeidialog.eState.normal
    self.fRoleDt = 0
end


function Jingjipipeidialog:refreshBeginImage()
    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    local strImageName =  jjManager:getRefreshTiemimageName(self.nBeginBattleImage)
    
    self.iamgeTimeCount:setProperty("Image",strImageName)

    self.iamgeTimeCount:setVisible(true)
    self.imageWait:setVisible(false)

    --table.maxn
end

function Jingjipipeidialog:beginToBattle()
   self:setPipeiState(Jingjipipeidialog.eState.beginToBattle)
   self:lockBtn()
   self.nBeginBattleImage = 1
   self:refreshBeginImage()

end

function Jingjipipeidialog:lockBtn()
    self.btnClose:setEnabled(false)
    self.btnCancel:setEnabled(false)
end


--//=========================================
function Jingjipipeidialog.getInstance()
    if not _instance then
        _instance = Jingjipipeidialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function Jingjipipeidialog.getInstanceAndShow()
    if not _instance then
        _instance = Jingjipipeidialog:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function Jingjipipeidialog.getInstanceNotCreate()
    return _instance
end

function Jingjipipeidialog.getInstanceOrNot()
	return _instance
end
	
function Jingjipipeidialog.GetLayoutFileName()
    return "jingjichangpipeidialog.layout" 
end

function Jingjipipeidialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Jingjipipeidialog)
	self:resetData()
    return self
end

function Jingjipipeidialog.DestroyDialog()
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

function Jingjipipeidialog:resetData()
    self.vRole = {}

    self.fRoleDt = 0
    self.fChangeRoleCd = 0.5
    self.nState = Jingjipipeidialog.eState.normal
    self.nBeginBattleImage = 0
    self.fWaitToSendCd = 5.0
    self.fWaitToSendDt = 0
    
end

function Jingjipipeidialog:ClearDataInClose()
    for k,v in pairs(self.vRole) do 
        v = nil
    end
    self.vRole = nil
    self:resetData()
end

function Jingjipipeidialog:ClearCellAll()

end


function Jingjipipeidialog:OnClose()
    
    if self.aniDlg then
        self.aniDlg:DestroyDialog()
    end
	Dialog.OnClose(self)
	self:ClearDataInClose()
	_instance = nil
end

return Jingjipipeidialog
