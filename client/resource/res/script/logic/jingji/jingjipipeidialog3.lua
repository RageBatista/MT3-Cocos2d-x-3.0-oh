require "utils.mhsdutils"
require "logic.dialog"
require "utils.commonutil"


Jingjipipeidialog3 = {}
setmetatable(Jingjipipeidialog3, Dialog)
Jingjipipeidialog3.__index = Jingjipipeidialog3
local _instance;

Jingjipipeidialog3.eState= 
{
    normal =1,
    randRole =2,
    beginToBattle = 3,
}
--//===============================
function Jingjipipeidialog3:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()
  
    local strPreName = "jingjichangpipeidialog3v3/hero" 
    for nIndex=1,6 do
        self.vRole[nIndex] = {}
        self.vRole[nIndex].itemcell = CEGUI.toItemCell(winMgr:getWindow(strPreName..nIndex.."/icon"))
        self.vRole[nIndex].labelLv = winMgr:getWindow(strPreName..nIndex.."/level/text")

        strJobName= strPreName..nIndex.."/icon/tubiao"
        self.vRole[nIndex].imageJob = winMgr:getWindow(strJobName)
    end
    self.imageWait =  winMgr:getWindow("jingjichangpipeidialog3v3/pipei")

    self.btnClose = CEGUI.toPushButton(winMgr:getWindow("jingjichangpipeidialog3v3/zuixiaohua"))
    self.btnClose:subscribeEvent("MouseButtonUp",Jingjipipeidialog3.clicClose, self)

    self.btnCancel = CEGUI.toPushButton(winMgr:getWindow("jingjichangpipeidialog3v3/quxiao"))
    self.btnCancel:subscribeEvent("MouseButtonUp",Jingjipipeidialog3.clickCancel, self)

    self.iamgeTimeCount = winMgr:getWindow("jingjichangpipeidialog3v3/daojishi")--jingjichangpipeidialog3v3/daojishi
    self.iamgeTimeCount:setVisible(false)

    self:GetWindow():subscribeEvent("WindowUpdate", Jingjipipeidialog3.HandleWindowUpate, self)

    self.nState = Jingjipipeidialog3.eState.waitToSend

    self:resetAllCell()
    self:refreshMyTeamItemcell()

    local nSpaceX = 20
    local strTextColor = "FF693F00" 
    self.aniDlg = require("logic.jingji.jingjipipeianidialog").create(self.imageWait,nSpaceX,strTextColor)

   
end



function Jingjipipeidialog3:resetAllCell()
    for nIndex=1,#self.vRole do
        --self.vRole[nIndex].itemcell:setImage
        --self.vRole[nIndex].labelLv:setText()

         self.vRole[nIndex].itemcell:SetImage(nil)
          local strLvzi = require "utils.mhsdutils".get_resstring(11330)

          local strLv = strLvzi..tostring(0)
          self.vRole[nIndex].labelLv:setText(strLv)

          self.vRole[nIndex].imageJob:setVisible(false)

    end
end

function Jingjipipeidialog3:resetTargetCell()
    for nIndex=4,6 do
         self.vRole[nIndex].itemcell:SetImage(nil)
         local strLvzi = require "utils.mhsdutils".get_resstring(11330)
         local strLv = strLvzi..tostring(0)
         self.vRole[nIndex].labelLv:setText(strLv)
         self.vRole[nIndex].imageJob:setVisible(false)
    end
end


function Jingjipipeidialog3:HandleWindowUpate(args)

    local ue = CEGUI.toUpdateEventArgs(args)
    local fdt = ue.d_timeSinceLastFrame --秒

     if self.nState == Jingjipipeidialog3.eState.waitToSend then
        self.fRoleDt = self.fRoleDt + fdt
        if self.fRoleDt >= self.fChangeRoleCd then
            self:rendomChangeTargetRole()
            self.fRoleDt = 0
        end

        self.fWaitToSendDt = self.fWaitToSendDt + fdt
        if self.fWaitToSendDt >= self.fWaitToSendCd then
            self.fWaitToSendDt = 0
            self.nState = Jingjipipeidialog3.eState.randRole 
            --self.fRoleDt = 0 
            --self:sendReady()
        end
    -----------------------------------------------------------
    elseif  self.nState == Jingjipipeidialog3.eState.randRole  then
        self.fRoleDt = self.fRoleDt + fdt
        if self.fRoleDt >= self.fChangeRoleCd then
            self:rendomChangeTargetRole()
            self.fRoleDt = 0
        end
    elseif self.nState == Jingjipipeidialog3.eState.beginToBattle  then
        self.fRoleDt = self.fRoleDt + fdt
       
        if self.fRoleDt >= 1.0 then
            self.nBeginBattleImage = self.nBeginBattleImage + 1
            self.fRoleDt = 0
            self:refreshBeginImage()
        end

        if self.nBeginBattleImage == 4 then
            --Jingjipipeidialog3.DestroyDialog()
        end
    end
end

function Jingjipipeidialog3:sendReady()
    local p = require "protodef.fire.pb.battle.pvp3.cpvp3readyfight":new()
    p.ready = 1
	require "manager.luaprotocolmanager":send(p)
end

function Jingjipipeidialog3:clickCancel(arg)

    if GetTeamManager():IsOnTeam() == true then
        if GetTeamManager():IsMyselfLeader()==false then
            local strShowTip = require "utils.mhsdutils".get_msgtipstring(141206) 
		    GetCTipsManager():AddMessageTip(strShowTip)
            return 
        end
    end

    local p = require "protodef.fire.pb.battle.pvp3.cpvp3readyfight":new()
    p.ready = 0
	require "manager.luaprotocolmanager":send(p)
end

function Jingjipipeidialog3:clicClose(arg)
    Jingjipipeidialog3.DestroyDialog()
end

function Jingjipipeidialog3:refreshMyTeamItemcell()
     if GetTeamManager():IsOnTeam() == false then
        
        local nLevel = gGetDataManager():GetMainCharacterLevel()
        local nShape = gGetDataManager():GetMainCharacterShape()
        local nJob =  gGetDataManager():GetMainCharacterSchoolID()
        self:refreshCellWithShape(1,nLevel,nShape,nJob)
        return 
    end


    local nIndexCell = 1
    --self:refreshCell(nIndexCell,nLevel,nShape)

    local vcTeam = GetTeamManager():GetMemberList() --MemberList
	for nIndex=1, #vcTeam do
        if nIndex > 3 then
            break
        end
        local nShapeId = vcTeam[nIndex].shapeID
        local nLevelId = vcTeam[nIndex].level
        local nJob = vcTeam[nIndex].eSchool
          
        self:refreshCellWithShape(nIndexCell,nLevelId,nShapeId,nJob)
        nIndexCell =  nIndexCell +1
    end
end

function Jingjipipeidialog3:setPipeiState(nState)
    self.nState = nState --Jingjipipeidialog.eState.normal
    self.fRoleDt = 0
end

function Jingjipipeidialog3:beginToBattle()
   self:setPipeiState(Jingjipipeidialog3.eState.beginToBattle)
   self:lockBtn()
   self.nBeginBattleImage = 1
   self:refreshBeginImage()

end

function Jingjipipeidialog3:refreshBeginImage()
    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    local strImageName = jjManager:getRefreshTiemimageName(self.nBeginBattleImage) --"set:teamui image:team_1"
    self.iamgeTimeCount:setProperty("Image",strImageName)

    self.iamgeTimeCount:setVisible(true)
    self.imageWait:setVisible(false)
end


function Jingjipipeidialog3:rendomChangeTargetRole()

    local jjManager = require("logic.jingji.jingjimanager").getInstance()

    local nCellIndex = 4 --456 == target
    local vTeamMember = {}
    for nIndex=1,3 do
        local nHeadIdRand,nJobId = jjManager:getRandomHeadId()
          local Jingjimanager = require("logic.jingji.jingjimanager")
        local pvpType = Jingjimanager.eJingjiType.threeVThree
        local nLevelRand = jjManager:getRandomLevel(pvpType)
        
        self:refreshCellWithIcon(nCellIndex,nLevelRand,nHeadIdRand,nJobId)
        nCellIndex = nCellIndex + 1
    end
end
function Jingjipipeidialog3:lockBtn()
    self.btnClose:setEnabled(false)
    self.btnCancel:setEnabled(false)
end

function Jingjipipeidialog3:refreshTargetTeam(vTeamMember)
    if not vTeamMember then
        return 
    end

    local nCellIndex = 4
    for nIndex=1,#vTeamMember do 
        local oneMember = vTeamMember[nIndex]
        local nLevel = oneMember.nLevel
        local nShape =  oneMember.nShape
        local nJob = oneMember.nJob
        self:refreshCellWithShape(nCellIndex,nLevel,nShape,nJob)
        nCellIndex = nCellIndex + 1
    end

end

function Jingjipipeidialog3:refreshCellWithIcon(nIndex,nLevel,nIconId,nJobId)
    
    if nIndex <=0 or nIndex > #self.vRole then
        return
    end

    local image = gGetIconManager():GetImageByID(nIconId)
    if image then
        self.vRole[nIndex].itemcell:SetImage(image)
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


function Jingjipipeidialog3:refreshCellWithShape(nIndex,nLevel,nShape,nJobId)
    if nIndex <=0 or nIndex > #self.vRole then
        return
    end
    local shapeTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(nShape)
    if shapeTable then
          local image = gGetIconManager():GetImageByID(shapeTable.littleheadID)
          self.vRole[nIndex].itemcell:SetImage(image)
          
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



--//=========================================
function Jingjipipeidialog3.getInstance()
    if not _instance then
        _instance = Jingjipipeidialog3:new()
        _instance:OnCreate()
    end
    return _instance
end

function Jingjipipeidialog3.getInstanceAndShow()
    if not _instance then
        _instance = Jingjipipeidialog3:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function Jingjipipeidialog3.getInstanceNotCreate()
    return _instance
end

function Jingjipipeidialog3.getInstanceOrNot()
	return _instance
end
	
function Jingjipipeidialog3.GetLayoutFileName()
    return "jingjichangpipeidialog3v3.layout"  
end

function Jingjipipeidialog3:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Jingjipipeidialog3)
	self:resetData()
    return self
end

function Jingjipipeidialog3.DestroyDialog()
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

function Jingjipipeidialog3:resetData()
    self.vRole = {}

    self.fRoleDt = 0
    self.fChangeRoleCd = 0.5 --随机换人间隔
    self.nState = Jingjipipeidialog3.eState.randRole
    self.nBeginBattleImage = 0
    self.fWaitToSendDt = 0
    self.fWaitToSendCd = 3.0 --假随机时间
end

function Jingjipipeidialog3:ClearDataInClose()
    self:resetData()
end

function Jingjipipeidialog3:ClearCellAll()

end


function Jingjipipeidialog3:OnClose()
    if self.aniDlg then
        self.aniDlg:DestroyDialog()
    end
	Dialog.OnClose(self)
	self:ClearDataInClose()
	_instance = nil
end

return Jingjipipeidialog3
