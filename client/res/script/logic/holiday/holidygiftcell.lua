HolidyGiftCell = {}

setmetatable(HolidyGiftCell, Dialog)
HolidyGiftCell.__index = HolidyGiftCell
local prefix = 0

function HolidyGiftCell.CreateNewDlg(parent)
	local newDlg = HolidyGiftCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function HolidyGiftCell.GetLayoutFileName()
	return "jierijianglicell.layout"
end

function HolidyGiftCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, HolidyGiftCell)
	return self
end

function HolidyGiftCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.m_bg = winMgr:getWindow(prefixstr .. "jiarijianglicell")
	self.m_itemcellItemA = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "jiarijianglicell/daoju1"))
    self.m_itemcellItemA:subscribeEvent("MouseClick",HolidyGiftCell.HandleItemClicked,self)
	self.m_itemcellItemB = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "jiarijianglicell/daoju2"))
    self.m_itemcellItemB:subscribeEvent("MouseClick",HolidyGiftCell.HandleItemClicked,self)
	self.m_itemcellItemC = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "jiarijianglicell/daoju3"))
    self.m_itemcellItemC:subscribeEvent("MouseClick",HolidyGiftCell.HandleItemClicked,self)
	self.m_btnGot = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "jiarijianglicell/lingqu"))
	self.m_imgGot = winMgr:getWindow(prefixstr .. "jiarijianglicell/lingqu/yilingqu")
    self.m_text = winMgr:getWindow(prefixstr.. "jiarijianglicell/text")
    self.m_btnGot:subscribeEvent("Clicked",HolidyGiftCell.HandleGotBtnClick,self)
    self.m_id = 0
end
function HolidyGiftCell:HandleGotBtnClick(e)
	local p = require "protodef.fire.pb.activity.festival.cgetfestivalreward":new()
	p.rewardid = self.m_id
	require "manager.luaprotocolmanager":send(p)    
end
function HolidyGiftCell:HandleItemClicked(args)

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
function HolidyGiftCell:setData(id)
    self.m_id = id
    local record = BeanConfigManager.getInstance():GetTableByName("fushi.cholidaygiftconfig"):getRecorder(id)
    self.m_btnGot:setVisible(true)
    self.m_imgGot:setVisible(false)
    self.m_btnGot:setEnabled(true)
    for _,v in pairs(LoginRewardManager.getInstance().m_freshHolidayHasId) do
        if record.id == v then
            self.m_btnGot:setVisible(false)
            self.m_imgGot:setVisible(true)
            break
        end
    end
    if LoginRewardManager.getInstance().m_HolidayId ~= self.m_id then
        self.m_btnGot:setEnabled(false)
    end
    self.m_text:setText(record.daytext)

    --item
    local items = {}
    table.insert(items, self.m_itemcellItemA)
    table.insert(items, self.m_itemcellItemB)
    table.insert(items, self.m_itemcellItemC)
    
    local ids = {}
    local nums = {}
    table.insert(ids, record.itemid1)
    table.insert(ids, record.itemid2)
    table.insert(ids, record.itemid3)

    table.insert(nums, record.itemnum1)
    table.insert(nums, record.itemnum2)
    table.insert(nums, record.itemnum3)

    for i =1 ,3 do
        local nItemId = ids[i]
        local nItemNum = nums[i]
        local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
        local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nItemId)
        local itemCellNode = items[i]
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

end
return HolidyGiftCell