FuLiDayReawardCell = {}

setmetatable(FuLiDayReawardCell, Dialog)
FuLiDayReawardCell.__index = FuLiDayReawardCell
local prefix = 0

function FuLiDayReawardCell.CreateNewDlg(parent)
	local newDlg = FuLiDayReawardCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function FuLiDayReawardCell.GetLayoutFileName()
	return "fulidayreawardcell.layout"
end

function FuLiDayReawardCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, FuLiDayReawardCell)
	return self
end

function FuLiDayReawardCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.m_bg = winMgr:getWindow(prefixstr .. "fulidayreawardcell")
	self.m_itemcellItemA = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "fulidayreawardcell/daoju1"))
	self.m_itemcellItemB = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "fulidayreawardcell/daoju2"))
	self.m_itemcellItemC = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "fulidayreawardcell/daoju3"))
	self.m_Text = CEGUI.toProgressBar(winMgr:getWindow(prefixstr .. "fulidayreawardcell/tian"))
	self.m_imgDay = winMgr:getWindow(prefixstr .."fulidayreawardcell/tu")
	self.m_imgDay:setVisible(false)
	self.vItemCell = {}
    self.vItemCell[#self.vItemCell +1] = self.m_itemcellItemA
    self.vItemCell[#self.vItemCell +1] = self.m_itemcellItemB
    self.vItemCell[#self.vItemCell +1] = self.m_itemcellItemC
	self.m_btnGot = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "fulidayreawardcell/lingqu"))
	self.m_btnGot:subscribeEvent("Clicked",FuLiDayReawardCell.HandleGotBtnClick,self)
	self.m_imgGot = winMgr:getWindow(prefixstr .. "fulidayreawardcell/lingqu/yilingqu")
	self.m_id =0
	self.m_flag = -1
	self.m_type = 0
	for i = 1 , 3 do
		local n =  CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "fulidayreawardcell/daoju"..i))
		n:setID(i)
		n:subscribeEvent("MouseClick",FuLiDayReawardCell.HandleItemClicked,self)
	end
end

function FuLiDayReawardCell:setId(id)
	self.m_id =id
end
function FuLiDayReawardCell:getId()
	return self.m_id
end
function FuLiDayReawardCell:setFlag(flag)
	self.m_flag =flag
end
function FuLiDayReawardCell:settype(type)
	self.m_type =type
end

function FuLiDayReawardCell:gettype()
	return self.m_type
end

function FuLiDayReawardCell:getAwardInfo(id,nMoney)
	if id == 1 then
	    return	BeanConfigManager.getInstance():GetTableByName("game.cdayreaward"):getRecorder(nMoney)
	end
	if id == 2 then
			self.m_imgGot:setVisible(false)
	        self.m_btnGot:setVisible( false )
		return	BeanConfigManager.getInstance():GetTableByName("game.conepayaward"):getRecorder(nMoney)
	end
	if id == 3 then
	    return	BeanConfigManager.getInstance():GetTableByName("game.ctotalreaward"):getRecorder(nMoney)
	end
end
function FuLiDayReawardCell:UpdateCellInfo()
	self.m_imgGot:setVisible(false)
			self.m_btnGot:setVisible( true )
			local total = 0
			if self.m_type == 1 then
				total = LoginRewardManager.getInstance():GetPayNum()
			end
			if self.m_type == 3 then
				total = LoginRewardManager.getInstance():GetTotal()
			end
			if  self.m_id <=  total then --�ж��Ƿ��Ѿ���
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
end

function FuLiDayReawardCell:setItemInfo()
			self.m_imgGot:setVisible(false)
			self.m_btnGot:setVisible( true )
			local total = 0
			if self.m_type == 1 then
				total = LoginRewardManager.getInstance():GetPayNum()
			end
			if self.m_type == 3 then
				total = LoginRewardManager.getInstance():GetTotal()
			end
			LogInfo("当前值"..total)
			if  self.m_id <=  total then --�ж��Ƿ��Ѿ���
				if self.m_flag == 0 then
					self.m_btnGot:setEnabled( true )
				end
				if self.m_flag > 0 then
					self.m_btnGot:setVisible( false )
					self.m_imgGot:setVisible( true )			
				end
			else
				self.m_btnGot:setVisible( true )
				self.m_btnGot:setEnabled( false )
			end
	
	-- local itemDayTable = BeanConfigManager.getInstance():GetTableByName("game.cdayreaward"):getRecorder( self.m_id )
    -- if not itemDayTable then
    --     return
    -- end
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
	--self.m_imgDay:setProperty("Image",  itemDayTable.dayimg)
	local str =""
	if self.m_type == 1 then
		str = "每日"..self.m_id.."米"
	end
	if self.m_type == 2 then
		str = "单笔"..self.m_id.."米"
	end
	if self.m_type == 3 then
		str = "累计"..self.m_id.."米"
	end
	self.m_Text:setText(str)
end

function FuLiDayReawardCell:getArrayItem(vItemId,nMoney)
	
	local itemDayTable = self:getAwardInfo(self.m_type,nMoney)
    if not itemDayTable then
        return
    end
    local nCurRoleId = -1
    local nCurCareer = -1
    if gGetDataManager() then
          local nModelId = gGetDataManager():GetMainCharacterShape()
          nCurRoleId = nModelId % 19
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
function FuLiDayReawardCell:getItemIdAndNumWithIdAndNum(vcItemId, vcItemNum, vcPetId, nRoleIndex, nCurCareer)
    
    local nItemId = -1
    local nItemNum = -1
    if vcItemId ~=0 then
		nItemId = vcItemId
		nItemNum=vcItemNum
	else
		nItemId = vcPetId
		nItemNum = 1
	end
    return nItemId,nItemNum
end
function FuLiDayReawardCell:HandleItemClicked(args)

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
function FuLiDayReawardCell:HandleGotBtnClick(args)
	if self.m_type == 1 then
		local p = require "protodef.fire.pb.game.creceivereward":new()
		p.rewardid = self.m_id
		p.reawardtype = self.m_type
	    require "manager.luaprotocolmanager":send(p)
	end
	if self.m_type == 3 then
		local p = require "protodef.fire.pb.game.creceivereward":new()
	    p.rewardid = self.m_id
		p.reawardtype = self.m_type
	    require "manager.luaprotocolmanager":send(p)
	end
	
end

return FuLiDayReawardCell