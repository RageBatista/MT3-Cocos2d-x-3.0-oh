ContinueDayCell = {}

setmetatable(ContinueDayCell, Dialog)
ContinueDayCell.__index = ContinueDayCell
local prefix = 0

function ContinueDayCell.CreateNewDlg(parent)
	local newDlg = ContinueDayCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function ContinueDayCell.GetLayoutFileName()
	return "qiriqiandaocell.layout"
end

function ContinueDayCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ContinueDayCell)
	return self
end

function ContinueDayCell:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.5)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function ContinueDayCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.m_bg = winMgr:getWindow(prefixstr .. "qiriqiandaocell")
	self.m_itemcellItemA = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "qiriqiandaocell/daoju1"))
	self.m_itemcellItemB = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "qiriqiandaocell/daoju2"))
	self.m_itemcellItemC = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "qiriqiandaocell/daoju3"))

    self.vItemCell = {}
    self.vItemCell[#self.vItemCell +1] = self.m_itemcellItemA
    self.vItemCell[#self.vItemCell +1] = self.m_itemcellItemB
    self.vItemCell[#self.vItemCell +1] = self.m_itemcellItemC

	self.m_imgDay = winMgr:getWindow(prefixstr .."qiriqiandaocell/tu")
		
	self.m_btnGot = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "qiriqiandaocell/lingqu"))
	self:addButtonAnimation(self.m_btnGot, "studyBtnPress")	
	self.m_btnGot:subscribeEvent("Clicked",ContinueDayCell.HandleGotBtnClick,self)
	self.m_imgGot = winMgr:getWindow(prefixstr .. "qiriqiandaocell/lingqu/yilingqu")
	
	for i = 1 , 3 do
		local n =  CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "qiriqiandaocell/daoju"..i))
		n:setID( i )
		n:subscribeEvent("MouseClick",ContinueDayCell.HandleItemClicked,self)
	end
	
	self.m_id = 0
	self.m_flag = -1
end

function ContinueDayCell:SetID( id )
	self.m_id = id	
end

function ContinueDayCell:SetFlag( bFlag )
	self.m_flag = bFlag	
end

function ContinueDayCell:getArrayItem(vItemId,nDay)
	local itemDayTable = BeanConfigManager.getInstance():GetTableByName("game.cloginaward"):getRecorder(nDay)
    if not itemDayTable then
        return
    end
    local nCurRoleId = -1
    local nCurCareer = -1
    if gGetDataManager() then
          local nModelId = gGetDataManager():GetMainCharacterShape()
          nCurRoleId = nModelId%100
          nCurCareer = gGetDataManager():GetMainCharacterSchoolID()
    end
    local nRoleIndex = nCurRoleId-1
    local nIndex = #vItemId +1
    vItemId[nIndex] = {}
    local nItemId1,nItemNum1 = self:getItemIdAndNumWithIdAndNum(itemDayTable.item1id, itemDayTable.item1num, itemDayTable.pet1id, nRoleIndex, nCurCareer)
    vItemId[nIndex].nItemId = nItemId1
    vItemId[nIndex].nItemNum = nItemNum1

    nIndex = #vItemId +1
    vItemId[nIndex] = {}
    local nItemId2,nItemNum2 = self:getItemIdAndNumWithIdAndNum(itemDayTable.item2id, itemDayTable.item2num, itemDayTable.pet2id, nRoleIndex, nCurCareer)
    vItemId[nIndex].nItemId = nItemId2
    vItemId[nIndex].nItemNum = nItemNum2
   
    nIndex = #vItemId +1
    vItemId[nIndex] = {}
    local nItemId3,nItemNum3 = self:getItemIdAndNumWithIdAndNum(itemDayTable.item3id, itemDayTable.item3num, itemDayTable.pet3id, nRoleIndex, nCurCareer)
    vItemId[nIndex].nItemId = nItemId3
    vItemId[nIndex].nItemNum = nItemNum3
end

function ContinueDayCell:getItemIdAndNumWithIdAndNum(vcItemId, vcItemNum, vcPetId, nRoleIndex, nCurCareer)
    
    local nItemId = -1
    local nItemNum = -1
    if nRoleIndex <= vcItemId:size() then
        local nItemData = vcItemId[nRoleIndex]
        local nItems = StringBuilder.Split(nItemData,";")
        for _ , v in ipairs(nItems) do
            local itemAndId = StringBuilder.Split(v,",")
            if tonumber(itemAndId[1]) == 0 then
                nItemId = tonumber(itemAndId[2])
                break
            else
                if tonumber(itemAndId[1]) == nCurCareer then
                    nItemId =  tonumber(itemAndId[2])
                    break
                end
            end
        end
    end

    --nItemId = vcItemId[nRoleIndex]

    if nRoleIndex <= vcItemNum:size() then
        nItemNum = vcItemNum[nRoleIndex]
    end

    if nItemId == 0 and nRoleIndex <= vcPetId:size() then
        nItemId = vcPetId[nRoleIndex]
        nItemNum = 1
    end

    return nItemId,nItemNum
end


function ContinueDayCell:RefreshShow()
	local parentTimes = ContinueDayReward.getInstanceNotCreate().m_continueDays
	
	self.m_imgGot:setVisible(false)
	self.m_btnGot:setVisible( true )
	
	if  self.m_id <=  parentTimes then --判断是否已经领
		if self.m_flag == 0 then
			self.m_btnGot:setEnabled( true )
		elseif self.m_flag > 0  then
			self.m_btnGot:setVisible( false )
			self.m_imgGot:setVisible( true )			
		end
	else
		self.m_btnGot:setVisible( true )
		self.m_btnGot:setEnabled( false )
	end
    local itemDayTable = BeanConfigManager.getInstance():GetTableByName("game.cloginaward"):getRecorder( self.m_id )
    if not itemDayTable then
        return
    end

	local vItemId = {}
    self:getArrayItem(vItemId, self.m_id)
    for nIndex=1, #vItemId do
        local oneData = vItemId[nIndex]
        local nItemId = oneData.nItemId
        local nItemNum = oneData.nItemNum
        local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
        local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nItemId)
        local itemCellNode = self.vItemCell[nIndex]
        if itemTable then
            itemCellNode:SetImage(gGetIconManager():GetItemIconByID( itemTable.icon ))
            SetItemCellBoundColorByQulityItemWithId(itemCellNode,nItemId)
            if nItemNum> 1 then
                itemCellNode:SetTextUnitText(CEGUI.String(""..nItemNum))
            end
	         refreshItemCellTypeForHuoban(itemCellNode,nItemId)
             itemCellNode:setVisible(true)
             itemCellNode:setID(nItemId)
        elseif petAttr then 
                local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttr.modelid)
	            local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
                itemCellNode:SetImage(image)
                SetItemCellBoundColorByQulityPet(itemCellNode, petAttr.quality)
                if nItemNum> 1 then
                    itemCellNode:SetTextUnitText(CEGUI.String(""..nItemNum))
                end
	            refreshItemCellTypeForHuoban(itemCellNode,nItemId)
                itemCellNode:setVisible(true)
                itemCellNode:setID(nItemId)
        else
            itemCellNode:setVisible(false)
        end
    end

	self.m_imgDay:setProperty("Image",  itemDayTable.dayimg)
end

function ContinueDayCell:HandleItemClicked(args)

	local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
        if BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nItemId) then
            require "logic.pet.firstchargegiftpetdlg".getInstanceAndShow(nItemId)
        end
        return
	end

	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	local nType = Commontipdlg.eType.eNormal 
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end

function ContinueDayCell:HandleGotBtnClick(args)
	local p = require "protodef.fire.pb.item.cgetmuldaylogingift":new()
	p.rewardid = self.m_id
	require "manager.luaprotocolmanager":send(p)
end

return ContinueDayCell
