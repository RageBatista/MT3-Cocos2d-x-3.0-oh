require "logic.dialog"

require "protodef.fire.pb.npc.cdonefortunewheel"

Lotteryjifendlg = {}
Lotteryjifendlg.__index = Lotteryjifendlg

Lotteryjifendlg.ACTION_NONE = 0
Lotteryjifendlg.UP_TIME = 0.5
Lotteryjifendlg.LINE_TIME = 3
Lotteryjifendlg.LINE_SPEED = 4*math.pi
Lotteryjifendlg.nAllNum = 8
Lotteryjifendlg.fSpeed_max = 605
Lotteryjifendlg.fSpeed_min = 10
Lotteryjifendlg.fActionTime = 3.0
Lotteryjifendlg.nRotateNum = 5
Lotteryjifendlg.state_normal = 1
Lotteryjifendlg.state_rotate = 2
Lotteryjifendlg.state_wait = 3
Lotteryjifendlg.fWaitTime = 2.0

local _instance;
function Lotteryjifendlg.sbeginschoolwheel_process(protocol)
    if not _instance then
        return
    end
    _instance.m_itemindex =  protocol.wheelindex +1

    _instance:beginRotate()
end

function Lotteryjifendlg.getInstance(parent)
	print("enter get Lotteryjifendlg dialog instance")
    if not _instance then
        _instance = Lotteryjifendlg:new()
        _instance:OnCreate(parent)
    end
    
    return _instance
end

function Lotteryjifendlg.getInstanceAndShow(parent)
	print("enter Lotteryjifendlg dialog instance show")
    if not _instance then
        _instance = Lotteryjifendlg:new()
        _instance:OnCreate(parent)
	else
		print("set Lotteryjifendlg dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function Lotteryjifendlg.getInstanceNotCreate()
    return _instance
end

function Lotteryjifendlg.GetLayoutFileName()
end

function Lotteryjifendlg:GetWindow()
    return self.m_pMainFrame
end

function Lotteryjifendlg:SetVisible(bVisible)
    self.m_pMainFrame:setVisible(bVisible)
end


function Lotteryjifendlg:OnCreate(parent)
    
    self.bLockStar = false

    self.parent = parent
	print("Lotteryjifendlg dialog oncreate begin")
    self.strPrefix = "Lotteryjifendlg"
	local layoutName = "lotterydialog.layout"
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName,self.strPrefix)

    --local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_itemcells = {}
	self.m_itemtxts = {}
	for i=1,Lotteryjifendlg.nAllNum do -- all = 8
		self.m_itemcells[i] = CEGUI.Window.toItemCell(winMgr:getWindow(self.strPrefix.."LotteryDialog/diban/card/item" .. i))
        self.m_itemcells[i].nCellId = i
        self.m_itemcells[i]:subscribeEvent("TableClick", Lotteryjifendlg.HandleClickItemCell, self)

	end

    -- subscribe event
    self.m_start = CEGUI.toPushButton(winMgr:getWindow(self.strPrefix.."LotteryDialog/diban/start"))
    self:setAnchorPoint(self.m_start,0.5,0.5)
    self.m_start:subscribeEvent("MouseClick", Lotteryjifendlg.HandleStartClicked, self) 


    self.fSpaceDegree = 360 / Lotteryjifendlg.nAllNum
	self:GetWindow():subscribeEvent("WindowUpdate", Lotteryjifendlg.HandleWindowUpdate, self)

	print("Lotteryjifendlg dialog oncreate end") --LotteryDialog/diban/card/item0
    self.itemCellTarget =  CEGUI.Window.toItemCell(winMgr:getWindow(self.strPrefix.."LotteryDialog/diban/card/item0"))
    self.itemCellTarget:subscribeEvent("TableClick", Lotteryjifendlg.HandleClickItemCellTarget, self)

    self:setAnchorPoint(self.itemCellTarget,0.5,0.5)
  
    self.imageBg = winMgr:getWindow(self.strPrefix.."LotteryDialog/back")
    self:setAnchorPoint(self.imageBg,0.5,0.5)

    self.imageZhizhen = winMgr:getWindow(self.strPrefix.."LotteryDialog/zhizhen")  
    self:setAnchorPoint(self.imageZhizhen,0.5,0.5)

    self:initAllItemCellRotation()

    self:setAnchorPoint(self:GetWindow(),0.5,0.5)
    ---------------------------------
    self.nR = 175+6

    self.fActionDegree = 0
    self.fActionDegreeDt = 0.0
    self.fCurSpeed = 0

    self.state = Lotteryjifendlg.state_normal 
    self.fWaitTimeDt = 0

    --void setScale(const VecsetScaletor3& scale);
	--void setGeomScale(const Vector3& scale);
    
    self:setScale(0.8) 
    self:refreshAllItemCellRotationAndPos(0)
    self:initItemForTable()
    -----------------------------------------
    if parent then
        parent:addChildWindow(self.m_pMainFrame)
    end
    self.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0,1),CEGUI.UDim(0, -70)))

end

function Lotteryjifendlg:HandleClickItemCellTarget(args)

    local e = CEGUI.toWindowEventArgs(args)
	local idx = e.window:getID()
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
    

    local nItemId = idx 
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	--local nType = Commontipdlg.eType.eComeFrom
	local nType = Commontipdlg.eType.eNormal 
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end

function Lotteryjifendlg:HandleClickItemCell(args)
    if self.fCurSpeed > 0 then
        return
    end
	
	local e = CEGUI.toWindowEventArgs(args)
	local idx = e.window:getID()
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
	
    local delta = (math.floor(self.fActionDegreeDt) % 360) / 45

    idx = (idx + delta) % 8
    if idx == 0 then
        idx = 8
    end

    if not self.m_itemcells[idx] then
        return
    end

    local nItemId = self.m_itemcells[idx].nItemId
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	--local nType = Commontipdlg.eType.eComeFrom
	local nType = Commontipdlg.eType.eNormal 
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end

function Lotteryjifendlg:resetData()

    self.fActionDegree = 0
    self.fCurSpeed = 0

    self.bLockStar = false
    self.m_start:setEnabled(true)
    self.state = Lotteryjifendlg.state_normal 
    self.fWaitTimeDt = 0
    --self:refreshAllItemCellRotationAndPos(0)
    --self:initItemForTable()
end

function Lotteryjifendlg:resetAllCell()
    self.fActionDegreeDt = self.fActionDegreeDt % 360
    self:refreshAllItemCellRotationAndPos(0)
    self:initItemForTable()
    self:refreshAllUIRotate(self.fActionDegreeDt)
end

function Lotteryjifendlg:initItemForTable()
    
    local wheelTable = BeanConfigManager.getInstance():GetTableByName("game.cschoolwheel"):getRecorder(1)
    if not wheelTable then
         return
    end
    local nMaxNum = 8
    local vItemData = {}

    local vcItemString = wheelTable.items
    for nIndex = 0, vcItemString:size() - 1 do
        local strStringData = vcItemString[nIndex]
        local strSeparate = ";"
        local vstrData = StringBuilder.Split(strStringData, strSeparate)

        vItemData[nIndex + 1] = {}
        local nItemId = 0
        local nItemNum = 0
        if #vstrData >= 1 then
             nItemId = tonumber( vstrData[1])
        end
        if #vstrData >= 2 then
             nItemNum = tonumber( vstrData[2])
        end
        vItemData[nIndex + 1].nItemId = nItemId
        vItemData[nIndex + 1].nItemNum = nItemNum
    end
    ---------------------------------------------------
    for nIndex =1,#vItemData do
        if nIndex > nMaxNum then
            break
        end
        local nItemId = vItemData[nIndex].nItemId
        local nItemNum = vItemData[nIndex].nItemNum
        local nItemType = 1
        self:initItem(nIndex, nItemType, nItemId, nItemNum, 0)
        self.m_itemcells[nIndex]:setID(nIndex)
    end

    self:initNeedRotateDegree()
    self:refreshTarget()
end

function Lotteryjifendlg:setScale(fScale)
    local vecScale = CEGUI.Vector3(fScale,fScale, 1)
    self.imageBg:setGeomScale(vecScale)

    for nIndex = 1, Lotteryjifendlg.nAllNum do
		local itemCell = self.m_itemcells[nIndex]
        --itemCell:setGeomScale(vecScale)
    end

    self.nR = self.nR * fScale

    self.imageZhizhen:setGeomScale(vecScale)
    self.itemCellTarget:setGeomScale(vecScale)

    local vecScaleStart = CEGUI.Vector3(fScale*0.8,fScale*0.8, 1)
    self.m_start:setGeomScale(vecScaleStart)

    local posZhenBg = self.imageZhizhen:getPosition()
    local nPosX = posZhenBg.x.offset + 80
    local nPosY = posZhenBg.y.offset + 40
    self.imageZhizhen:setPosition(CEGUI.UVector2(CEGUI.UDim(0,nPosX),CEGUI.UDim(0, nPosY)))

end

function Lotteryjifendlg:setPos(nPosX,nPosY)
    self:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0,nPosX),CEGUI.UDim(0, nPosY)))
end

-- shun zhi 90
function Lotteryjifendlg:initAllItemCellRotation()
    for nIndex = 1, Lotteryjifendlg.nAllNum do
		local itemCell = self.m_itemcells[nIndex]
        local fDegree = 90 + -(nIndex * self.fSpaceDegree - (self.fSpaceDegree*0.5))
        itemCell.fInitDegree = fDegree

        local fLineDegree = nIndex * self.fSpaceDegree - (self.fSpaceDegree*0.5)

        itemCell.fInitDegreePos = fLineDegree
        --local fRadion = self:toRadion(fDegree)
        local vec = CEGUI.Vector3(0, 0, fDegree)
       
       -- itemCell:SetTextUnit(tostring(nIndex))
        self:setAnchorPoint(itemCell,0.5,0.5)
        itemCell:setGeomRotation(vec)
	end
end

function Lotteryjifendlg:setAnchorPoint(pWin,fAnchorX,fAnchorY)
     local nWidth = pWin:getPixelSize().width
	 local nHeight = pWin:getPixelSize().height
     local anchorPos =  CEGUI.Vector3(nWidth * fAnchorX, nHeight * fAnchorY, 0)
     pWin:setGeomPivot(anchorPos)
end


function Lotteryjifendlg:updateSpeed(dt)
   local fPercent = self.fActionDegreeDt / self.fActionDegree
   local fLeaveDegree = self.fActionDegree - self.fActionDegreeDt

   local fAddSpaceDegree =   Lotteryjifendlg.fSpeed_max -  Lotteryjifendlg.fSpeed_min

   if self.fActionDegreeDt < 360 then
        self.fCurSpeed =  Lotteryjifendlg.fSpeed_min + fAddSpaceDegree * self.fActionDegreeDt / 360
        return
   elseif fLeaveDegree < 360 then
        self.fCurSpeed =   Lotteryjifendlg.fSpeed_min + fAddSpaceDegree * fLeaveDegree / 360
        return
   else
       self.fCurSpeed = Lotteryjifendlg.fSpeed_max
   end

end


function Lotteryjifendlg:updateRotate(dt)
   
     self:updateSpeed(dt)
     self.fActionDegreeDt = self.fActionDegreeDt +  self.fCurSpeed  * dt
     if self.fActionDegreeDt >= self.fActionDegree then
          
          self:refreshAllUIRotate(self.fActionDegree)
          self.state = Lotteryjifendlg.state_wait
          self:sendGetItem()
          return
    end
    self:refreshAllUIRotate(self.fActionDegreeDt)
end

function Lotteryjifendlg:HandleWindowUpdate(args)
    local ue = CEGUI.toUpdateEventArgs(args)
    local dt = ue.d_timeSinceLastFrame 

    if self.state == Lotteryjifendlg.state_wait then
         self.fWaitTimeDt = self.fWaitTimeDt + dt
         if self.fWaitTimeDt >= Lotteryjifendlg.fWaitTime then
            --Lotteryjifendlg.DestroyDialog()
         end
    elseif self.state == Lotteryjifendlg.state_rotate then
        self:updateRotate(dt)
    end

end

function Lotteryjifendlg:refreshAllUIRotate(fActionDegreeDt)
    local vec = CEGUI.Vector3(0, 0, self.fActionDegreeDt)
    self.imageBg:setGeomRotation(vec)
    --self:refreshAllItemCellRotationAndPos(self.fActionDegreeDt)
    self:refreshTarget()
end

function Lotteryjifendlg:refreshAllItemCellRotationAndPos(fRotateRightDegree)
    local cellWidth = self.m_itemcells[1]:getPixelSize().width
    local cellHeight = self.m_itemcells[1]:getPixelSize().height
    local nWidth =  self.imageBg:getPixelSize().width 
	local nHeight =  self.imageBg:getPixelSize().height 

    for nIndex = 1, Lotteryjifendlg.nAllNum do
		local itemCell = self.m_itemcells[nIndex]
        local fOldDegree = itemCell.fInitDegree
        local fNewDegree = fOldDegree + fRotateRightDegree
        
        local vec = CEGUI.Vector3(0, 0, fNewDegree)
        itemCell:setGeomRotation(vec)
        
        local fNewDegreePos = itemCell.fInitDegreePos - fRotateRightDegree
        local fRadion = self:toRadion(fNewDegreePos)
        local nPosX = self.nR * math.cos(fRadion)
        local nPosY = self.nR * math.sin(fRadion)
        
        nPosX = nPosX + nWidth* 0.5 - cellWidth*0.5
        nPosY = -nPosY + nHeight*0.5 - cellHeight*0.5
        --itemCell:setPosition(CEGUI.UVector2(CEGUI.UDim(0, nPosX) , CEGUI.UDim(0, nPosY)))
	end
end

function Lotteryjifendlg:isInArrow(fCurDegree)
    fCurDegree = fCurDegree - math.floor( fCurDegree / 360) * 360
    if fCurDegree >= 135 and 
      fCurDegree <= 180 then
      return true
    end
    if fCurDegree >= -225 and --//-180 --- -225
       fCurDegree <= -180 then
       return true
    end
    return false
end

function Lotteryjifendlg:getCorrectDegree(fCurDegree)
  local  fCurDegree = fCurDegree - math.floor( fCurDegree / 360) * 360
  return fCurDegree
end

function Lotteryjifendlg:refreshTarget()
    for nIndex = 1, Lotteryjifendlg.nAllNum do
		local itemCell = self.m_itemcells[nIndex]
       
        local fRotateDegree = self:getCorrectDegree(self.fActionDegreeDt)
        local fCurDegree = itemCell.fInitDegreePos - fRotateDegree
        local bInArrow = self:isInArrow(fCurDegree)
        if bInArrow then
            local nCellId = itemCell.nCellId
            --self.itemCellTarget:SetTextUnit(tostring(nCellId))
            local nItemType = itemCell.nItemType 
            local nItemId = itemCell.nItemId
            local nNum =itemCell.nNum 
            self:refreshItemCellContent(self.itemCellTarget,nItemType,nItemId,nNum)
        end
	end
end


function Lotteryjifendlg:HandleClickStop(e)

end
------------------- private: -----------------------------------

function Lotteryjifendlg:new()
    local dlg = {}
    --self = Dialog:new()
    setmetatable(dlg, Lotteryjifendlg)

	dlg.m_action = Lotteryjifendlg.ACTION_NONE
	dlg.m_speed = 0
	dlg.m_angle = 0
	dlg.m_upspeed = Lotteryjifendlg.LINE_SPEED/Lotteryjifendlg.UP_TIME
	dlg.m_linetime = Lotteryjifendlg.LINE_TIME
	dlg.m_itemindex = 1
    return dlg
end


function Lotteryjifendlg:initNeedRotateDegree()

    local itemCellResult = self.m_itemcells[self.m_itemindex]
    if not itemCellResult then
        return
    end
    local fArrowDegree = self.fSpaceDegree * 3 + self.fSpaceDegree*0.5
    if  itemCellResult.fInitDegreePos >= fArrowDegree then
        self.fActionDegree =  itemCellResult.fInitDegreePos -  fArrowDegree
    else
        self.fActionDegree =  itemCellResult.fInitDegreePos -  fArrowDegree + 360
    end

    self.fActionDegree = self.fActionDegree + Lotteryjifendlg.nRotateNum  * 360
end

 function Lotteryjifendlg:toDegree(fRadion)
    local fDegree = fRadion / math.pi * 180
    return fDegree
end

 function Lotteryjifendlg:toRadion(fDegree)
    local fRadion = fDegree / 180 * math.pi
    return fRadion
end

function Lotteryjifendlg:refreshItemCellContent(itemCell,nItemType,nItemId,nNum)
    if nItemType == 1 or nItemType == 5 then
		local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
        if itembean then
		    itemCell:SetImage(gGetIconManager():GetItemIconByID(itembean.icon))
        end
		--itemCell:SetTextUnit(nNum)
        itemCell:setID(nItemId)

        SetItemCellBoundColorByQulityItemWithIdtm(itemCell,nItemId)
        if nNum > 1 then
		     itemCell:SetTextUnit(nNum)
        end

	end
  
end

function Lotteryjifendlg:initItem(i, itemtype, baseid, num, times)
    if i > Lotteryjifendlg.nAllNum then
        return
    end
    
	--self.m_itemcells[i]:SetBackGroundEnable(false)

    self.m_itemcells[i].nItemType = itemtype
    self.m_itemcells[i].nItemId = baseid
    self.m_itemcells[i].nNum = num

    local itemCell = self.m_itemcells[i]
    itemCell:setID(baseid)
    self:refreshItemCellContent(itemCell,itemtype,baseid,num)
    
end

function Lotteryjifendlg:beginRotate()
    if self.state == Lotteryjifendlg.state_normal then
        self:resetAllCell()
        self.state = Lotteryjifendlg.state_rotate
        --self.m_start:setVisible(false)
        self.m_start:setEnabled(false)
    end
end

function Lotteryjifendlg:HandleStartClicked(args)
    
    if self.bLockStar == true then
        return
    end

    local nNeedJobScore =  0 
    local commonTable = GameTable.common.GetCCommonTableInstance():getRecorder(237)
    if commonTable.id ~= -1 then
        nNeedJobScore = tonumber(commonTable.value)
    end

    
    
    local nJobScoreOwn = 0
    if  gGetDataManager() then
        local data = gGetDataManager():GetMainCharacterData()
	    nJobScoreOwn = data:GetScoreValue(fire.pb.attr.RoleCurrency.PROF_CONTR)
    end
    if nJobScoreOwn < nNeedJobScore then
        
        local strShowTip = require "utils.mhsdutils".get_resstring(11359) --MHSD_UTILS.get_resstring(11018) 
		GetCTipsManager():AddMessageTip(strShowTip)
        return
    end
    
    local p = require "protodef.fire.pb.game.cbeginschoolwheel":new()
	require "manager.luaprotocolmanager":send(p)

    self.bLockStar = true

end

function Lotteryjifendlg:sendGetItem()
   
    local p = require "protodef.fire.pb.game.cendschoolwheel":new()
	require "manager.luaprotocolmanager":send(p)
		
    
     self:resetData()
end

function Lotteryjifendlg:run(delta)
end

function Lotteryjifendlg:DestroyDialog()
    if _instance then
	    self:OnClose()
        _instance = nil
    end
end

function Lotteryjifendlg:OnClose()
    self.bLockStar = false
	if self.parent then
		self.parent:removeChildWindow(self.m_pMainFrame)
	end
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end

return Lotteryjifendlg
