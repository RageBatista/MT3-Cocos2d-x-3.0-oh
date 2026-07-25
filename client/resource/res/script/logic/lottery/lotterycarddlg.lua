require "logic.dialog"

require "protodef.fire.pb.npc.cdonefortunewheel"

LotteryCardDlg = {}
setmetatable(LotteryCardDlg, Dialog)
LotteryCardDlg.__index = LotteryCardDlg


LotteryCardDlg.nUPTIME = 0.5
LotteryCardDlg.LINE_SPEED = 4*math.pi
LotteryCardDlg.nAllNum = 8
LotteryCardDlg.fSpeed_max = 605
LotteryCardDlg.fSpeed_min = 10
LotteryCardDlg.nRotateNum = 5
LotteryCardDlg.state_normal = 1
LotteryCardDlg.state_rotate = 2
LotteryCardDlg.state_wait = 3
LotteryCardDlg.ACTION_NONE = 0
LotteryCardDlg.fWaitTime = 2.0
LotteryCardDlg.LINE_TIME = 3


local _instance;
function LotteryCardDlg.getInstance()
	print("enter get lotterycarddlg dialog instance")
    if not _instance then
        _instance = LotteryCardDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function LotteryCardDlg.getInstanceAndShow()
	print("enter lotterycarddlg dialog instance show")
    if not _instance then
        _instance = LotteryCardDlg:new()
        _instance:OnCreate()
	else
		print("set lotterycarddlg dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function LotteryCardDlg.getInstanceNotCreate()
    return _instance
end

function LotteryCardDlg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function LotteryCardDlg:OnClose()
    Dialog.OnClose(self)
    require("logic.tips.commontipdlg").DestroyDialog()
end

function LotteryCardDlg.ToggleOpenClose()
	if not _instance then 
		_instance = LotteryCardDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function LotteryCardDlg.GetLayoutFileName()
    return "lotterydialog.layout"
end

function LotteryCardDlg:OnCreate()
	print("lotterycarddlg dialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_itemcells = {}
	self.m_itemtxts = {}
	for i=1,LotteryCardDlg.nAllNum do -- all = 8
		self.m_itemcells[i] = CEGUI.Window.toItemCell(winMgr:getWindow("LotteryDialog/diban/card/item" .. i))
        self.m_itemcells[i].nCellId = i
        self.m_itemcells[i]:subscribeEvent("MouseClick",GameItemTable.HandleShowToolTipsWithItemID)
	end
	
    self.m_start = winMgr:getWindow("LotteryDialog/diban/start")
    self.m_start:subscribeEvent("Clicked", LotteryCardDlg.HandleStartClicked, self) 

    self.fSpaceDegree = 360 / LotteryCardDlg.nAllNum
	self:GetWindow():subscribeEvent("WindowUpdate", LotteryCardDlg.HandleWindowUpdate, self)

	print("lotterycarddlg dialog oncreate end") --LotteryDialog/diban/card/item0
    self.itemCellTarget =  CEGUI.Window.toItemCell(winMgr:getWindow("LotteryDialog/diban/card/item0"))
    self.itemCellTarget:subscribeEvent("MouseClick",GameItemTable.HandleShowToolTipsWithItemID)
    --LotteryDialog/back
    self.imageBg = winMgr:getWindow("LotteryDialog/back")
    self:setAnchorPoint(self.imageBg,0.5,0.5)

    self:initAllItemCellRotation()

   
    self.nR = 175+6
    self.bAction = false

    self.fActionDegree = 0
    self.fActionDegreeDt = 0.0
    self.fCurSpeed = 0
    self.state = LotteryCardDlg.state_normal 
    self.fWaitTimeDt = 0
    
end

-- shun zhi 90
function LotteryCardDlg:initAllItemCellRotation()
    for nIndex = 1, LotteryCardDlg.nAllNum do
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

function LotteryCardDlg:setAnchorPoint(pWin,fAnchorX,fAnchorY)
     local nWidth = pWin:getPixelSize().width
	 local nHeight = pWin:getPixelSize().height
     local anchorPos =  CEGUI.Vector3(nWidth * fAnchorX, nHeight * fAnchorY, 0)
     pWin:setGeomPivot(anchorPos)
end


function LotteryCardDlg:updateSpeed(dt)
   local fPercent = self.fActionDegreeDt / self.fActionDegree
   local fLeaveDegree = self.fActionDegree - self.fActionDegreeDt

   local fAddSpaceDegree =   LotteryCardDlg.fSpeed_max -  LotteryCardDlg.fSpeed_min

   if self.fActionDegreeDt < 360 then
        self.fCurSpeed =  LotteryCardDlg.fSpeed_min + fAddSpaceDegree * self.fActionDegreeDt / 360
        return
   elseif fLeaveDegree < 360 then
        self.fCurSpeed =   LotteryCardDlg.fSpeed_min + fAddSpaceDegree * fLeaveDegree / 360
        return
   else
       self.fCurSpeed = LotteryCardDlg.fSpeed_max
   end
end


function LotteryCardDlg:updateRotate(dt)
   
     self:updateSpeed(dt)
     self.fActionDegreeDt = self.fActionDegreeDt +  self.fCurSpeed  * dt
     if self.fActionDegreeDt >= self.fActionDegree then
          self.bAction = false
          self:refreshAllUIRotate(self.fActionDegree)
          self.state = LotteryCardDlg.state_wait
          self:sendGetItem()
          return
    end
    self:refreshAllUIRotate(self.fActionDegreeDt)
end

function LotteryCardDlg:HandleWindowUpdate(args)
    local ue = CEGUI.toUpdateEventArgs(args)
    local dt = ue.d_timeSinceLastFrame 

    if self.state == LotteryCardDlg.state_wait then
         self.fWaitTimeDt = self.fWaitTimeDt + dt
         if self.fWaitTimeDt >= LotteryCardDlg.fWaitTime then
            LotteryCardDlg.DestroyDialog()
         end
    elseif self.state == LotteryCardDlg.state_rotate then
        self:updateRotate(dt)
    end

end

function LotteryCardDlg:refreshAllUIRotate(fActionDegreeDt)
    local vec = CEGUI.Vector3(0, 0, self.fActionDegreeDt)
    self.imageBg:setGeomRotation(vec)
    --self:refreshAllItemCellRotationAndPos(self.fActionDegreeDt)
    self:refreshTarget()
end

function LotteryCardDlg:refreshAllItemCellRotationAndPos(fRotateRightDegree)
    local cellWidth = self.m_itemcells[1]:getPixelSize().width
    local cellHeight = self.m_itemcells[1]:getPixelSize().height
    local nWidth =  self.imageBg:getPixelSize().width 
	local nHeight =  self.imageBg:getPixelSize().height 

    for nIndex = 1, LotteryCardDlg.nAllNum do
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
        itemCell:setPosition(CEGUI.UVector2(CEGUI.UDim(0, nPosX) , CEGUI.UDim(0, nPosY)))
	end
end

function LotteryCardDlg:isInArrow(fCurDegree)
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

function LotteryCardDlg:getCorrectDegree(fCurDegree)
  local  fCurDegree = fCurDegree - math.floor( fCurDegree / 360) * 360
  return fCurDegree
end

function LotteryCardDlg:refreshTarget()
    for nIndex = 1, LotteryCardDlg.nAllNum do
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
            self.itemCellTarget:setID(nItemId)
            self:refreshItemCellContent(self.itemCellTarget,nItemType,nItemId,nNum)
            SetItemCellBoundColorByQulityItemWithId(self.itemCellTarget,nItemId)
        end
	end
end

function LotteryCardDlg:HandleClickStop(e)

end

function LotteryCardDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, LotteryCardDlg)

	self.m_action = LotteryCardDlg.ACTION_NONE
	self.m_speed = 0
	self.m_angle = 0
	self.m_upspeed = LotteryCardDlg.LINE_SPEED/LotteryCardDlg.nUPTIME
	self.m_linetime = LotteryCardDlg.LINE_TIME
	self.m_itemindex = 1
    return self
end

function LotteryCardDlg:initdlg(itemids, index, npckey, serviceid)
	local numReg = #itemids
    for i = 1, numReg, 1 do
		local data = itemids[i]
		self:initItem(i, data.itemtype, data.id, data.num, data.times)
		print("i=" .. i)
		print("itemtype=" .. data.itemtype)
		print("id=" .. data.id)
		print("num=" .. data.num)
		print("times=" .. data.times)
	end
	self.m_itemindex =  index+1 --结果 
	self.m_npckey = npckey
	self.m_serviceid = serviceid
	print("self.m_itemindex= " .. index)
	print("self.m_npckey= " .. npckey)
	print("self.m_serviceid= " .. serviceid)

    self:initNeedRotateDegree()
    self:refreshTarget()
end

function LotteryCardDlg:initNeedRotateDegree()

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

    self.fActionDegree = self.fActionDegree + LotteryCardDlg.nRotateNum  * 360
end

 function LotteryCardDlg:toDegree(fRadion)
    local fDegree = fRadion / math.pi * 180
    return fDegree
end

 function LotteryCardDlg:toRadion(fDegree)
    local fRadion = fDegree / 180 * math.pi
    return fRadion
end

function LotteryCardDlg:refreshItemCellContent(itemCell,nItemType,nItemId,nNum)
    if nItemType == 1 or nItemType == 5 then
		local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
        if  itembean then
		    itemCell:SetImage(gGetIconManager():GetItemIconByID(itembean.icon))
        end
        SetItemCellBoundColorByQulityItemWithId(itemCell,nItemId)

        if nNum > 1 then
		    itemCell:SetTextUnit(nNum)
        end
	end
	
end

function LotteryCardDlg:initItem(i, itemtype, baseid, num, times)
    if i > LotteryCardDlg.nAllNum then
        return
    end
   
    self.m_itemcells[i].nItemType = itemtype
    self.m_itemcells[i].nItemId = baseid
    self.m_itemcells[i].nNum = num

    local itemCell = self.m_itemcells[i]
    itemCell:setID(baseid)
    self:refreshItemCellContent(itemCell,itemtype,baseid,num)
   
end

function LotteryCardDlg:HandleStartClicked(args)

    if self.state == LotteryCardDlg.state_normal then
        self.state = LotteryCardDlg.state_rotate
        self.m_start:setVisible(false)
    end
end

function LotteryCardDlg:sendGetItem()
	print("self.m_npckey= " .. self.m_npckey)
	print("self.m_serviceid= " .. self.m_serviceid)
        
        local actionReg = CDoneFortuneWheel.Create()
        actionReg.npckey = self.m_npckey
        actionReg.taskid = self.m_serviceid
        actionReg.succ = 1
        actionReg.flag = 0
        LuaProtocolManager.getInstance():send(actionReg)
end


function LotteryCardDlg:run(delta)
end

return LotteryCardDlg
