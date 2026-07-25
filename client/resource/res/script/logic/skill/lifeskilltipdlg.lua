require "logic.dialog"

LifeSkillTipDlg = {}

setmetatable(LifeSkillTipDlg,Dialog)
LifeSkillTipDlg.__index = LifeSkillTipDlg

local _instance

function LifeSkillTipDlg.getInstance(itemID, posX, posY, param) 
	if not _instance then
		_instance = LifeSkillTipDlg.new()
		_instance:OnCreate(itemID, posX, posY)
	end
	return _instance
end



function LifeSkillTipDlg.getInstanceAndShow(itemID, posX, posY, param)
	if not _instance then
		_instance = LifeSkillTipDlg.new()
		_instance:OnCreate(itemID, posX, posY)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function LifeSkillTipDlg.getInstanceNotCreate()
	return _instance
end


function LifeSkillTipDlg.DestroyDialog()
	if _instance then
		_instance:OnClose()
	end
end

function LifeSkillTipDlg:OnClose()
	Dialog.OnClose(self)
	_instance = nil
end

function LifeSkillTipDlg.GetLayoutFileName()
	return "itemtips_mtg.layout"
end

function LifeSkillTipDlg.new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, LifeSkillTipDlg)
	return self	
end

function LifeSkillTipDlg:OnCreate(itemID, posX, posY)
	Dialog.OnCreate(self)
	self.m_itemID = itemID
	self.m_posX = posX
	self.m_posY = posY

	-- 判断是烹饪炼药道具还是制造符道具
	self.m_itemType = 1 -- 制造符
	if (itemID >= 320000 and itemID <= 320007) or (itemID >= 320100 and itemID <= 320105) then
		self.m_itemType = 0 -- 烹饪炼药
	end

	local winMgr = CEGUI.WindowManager:getSingleton()
	local itemCell = CEGUI.toItemCell(winMgr:getWindow("itemtips_mtg/item"))
	local itemBean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemID)
    if not itemBean then
        return
    end
	itemCell:SetImage(gGetIconManager():GetImageByID(itemBean.icon))
	itemCell:setID(itemID)

	local itemName_st = winMgr:getWindow("itemtips_mtg/names")
	itemName_st:setText(itemBean.name)
	-- 类型名
	local itemTypeRecord = BeanConfigManager.getInstance():GetTableByName("item.citemtype"):getRecorder(itemBean.itemtypeid)
	if itemTypeRecord then
		local typeName_st = winMgr:getWindow("itemtips_mtg/leixingming")
		typeName_st:setText(itemTypeRecord.name)
	end
	
	if self.m_itemType == 0 then
		local qualitystr_st = winMgr:getWindow("itemtips_mtg/pinzhi")
		local quality_st = winMgr:getWindow("itemtips_mtg/pinzhiming")
		quality_st:setText(MHSD_UTILS.get_resstring(2461))
	elseif self.m_itemType == 1 then 
		local level_st = winMgr:getWindow("itemtips_mtg/pinzhi")
		level_st:setText(MHSD_UTILS.get_resstring(1))
		local levelValue_st = winMgr:getWindow("itemtips_mtg/pinzhiming")
		levelValue_st:setText(itemBean.needlevel)
	end
	

	-- 描述
	local editBox = CEGUI.toRichEditbox(winMgr:getWindow("itemtips_mtg/editbox"))
	editBox:SetLineSpace(3.0)
	editBox:setReadOnly(true)
	
	editBox:AppendText(CEGUI.String(itemBean.destribe))
	editBox:Refresh()
	
	local fontHeight = editBox:getFont():getFontHeight()
	local extendHeight = editBox:GetExtendSize().height
	local editBoxPosY = editBox:getYPosition()
	local topWnd = winMgr:getWindow("itemtips_mtg")
	topWnd:setHeight(CEGUI.UDim(editBoxPosY.scale, editBoxPosY.offset + extendHeight + fontHeight))

	-- 设置窗口位置
	SetPositionOfWindowWithLabel(topWnd)

end


function LifeSkillTipDlg:HandleHideTip(args)
	self:DestroyDialog()
end

return LifeSkillTipDlg
