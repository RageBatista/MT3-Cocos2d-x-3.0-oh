------------------------------------------------------------------
-- ��̯��Ʒ��Ʒ����Ķ���ȷ�Ͻ���
------------------------------------------------------------------
require "logic.dialog"
require "logic.shop.stallpettip"

StallBuyConfirmDlg = {}
setmetatable(StallBuyConfirmDlg, Dialog)
StallBuyConfirmDlg.__index = StallBuyConfirmDlg

local _instance
function StallBuyConfirmDlg.getInstance()
	if not _instance then
		_instance = StallBuyConfirmDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function StallBuyConfirmDlg.getInstanceAndShow(parent)
	if not _instance then
		_instance = StallBuyConfirmDlg:new()
		_instance:OnCreate(parent)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function StallBuyConfirmDlg.getInstanceNotCreate()
	return _instance
end

function StallBuyConfirmDlg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
            if _instance.goods.itemtype == STALL_GOODS_T.ITEM then
		        local dlg = Commontipdlg.getInstanceNotCreate()
		        if dlg then
				    dlg.DestroyDialog()
			    end
		
	        elseif _instance.goods.itemtype == STALL_GOODS_T.PET then
		        local dlg = StallPetTip.getInstanceNotCreate()
			    if dlg then
				    dlg.DestroyDialog()
			    end
	        end
			
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function StallBuyConfirmDlg.ToggleOpenClose()
	if not _instance then
		_instance = StallBuyConfirmDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function StallBuyConfirmDlg.GetLayoutFileName()
	return "baitangoumai.layout"
end

function StallBuyConfirmDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, StallBuyConfirmDlg)
	return self
end

function StallBuyConfirmDlg:OnCreate(parent)
	Dialog.OnCreate(self, parent)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self:GetWindow():setRiseOnClickEnabled(false)

	self.itemcell = CEGUI.toItemCell(winMgr:getWindow("baitangoumai/goumai/di/wupin"))
	self.name = winMgr:getWindow("baitangoumai/goumai/di/mingzi")
	self.priceText = winMgr:getWindow("baitangoumai/goumai/di/huobizhi")
	self.priceText:setProperty("TextColours", "FFFFFFFF")
	self.okBtn = CEGUI.toPushButton(winMgr:getWindow("baitangoumai/goumai/queren"))
	self.closeBtn = CEGUI.toPushButton(winMgr:getWindow("baitangoumai/goumai/guanbi"))

	self.okBtn:subscribeEvent("Clicked", StallBuyConfirmDlg.handleOkClicked, self)
	self.closeBtn:subscribeEvent("Clicked", StallBuyConfirmDlg.DestroyDialog, nil)
	self.itemcell:subscribeEvent("TableClick", StallBuyConfirmDlg.handleItemCellClicked, self)
end

function StallBuyConfirmDlg:showTip()
	if not self.goods then
		return
	end
	------摆摊购买弹出TIPS界面
	local tip = nil
	if self.goods.itemtype == STALL_GOODS_T.ITEM  then
		local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.goods.itemid)
		if itemAttr and (itemAttr.itemtypeid == 1288 or itemAttr.itemtypeid == 154 or itemAttr.itemtypeid == 3080 or itemAttr.itemtypeid == 4360 or itemAttr.itemtypeid == 4104 or itemAttr.itemtypeid == 4360 or itemAttr.itemtypeid == 2824 or itemAttr.itemtypeid == 312 or itemAttr.itemtypeid == 568 or itemAttr.itemtypeid == 1640 or itemAttr.itemtypeid == 1384 or itemAttr.itemtypeid == 40 or itemAttr.itemtypeid == 72 or itemAttr.itemtypeid == 88 or itemAttr.itemtypeid == 664 or itemAttr.itemtypeid == 616 or itemAttr.itemtypeid == 648 or itemAttr.itemtypeid == 632 or itemAttr.itemtypeid == 392 or itemAttr.itemtypeid == 376 or itemAttr.itemtypeid == 680) then
		local p = require("protodef.fire.pb.item.cotheritemtips"):new()
        p.roleid = self.goods.saleroleid
        p.packid = fire.pb.item.BagTypes.MARKET
        p.keyinpack = self.goods.key
	    LuaProtocolManager:send(p)
		
		local roleItem = RoleItem:new()
	    roleItem:SetItemBaseData(self.goods.itemid, 0)
        roleItem:SetObjectID(self.goods.itemid)
		local tip = Commontiphelper.showItemTip(self.goods.itemid, roleItem:GetObject(), true, false, 0, 0)
		tip:showSwitchPageArrow(false)
        tip.isStallTip = true
        tip.roleid = self.goods.saleroleid
        tip.roleItem = roleItem
        tip.itemkey = self.goods.key
		else
			tip = Commontipdlg.getInstanceAndShow()
		    tip:RefreshItem(Commontipdlg.eType.eNormal, self.goods.itemid, 0, 0)
		end
		
		
	elseif self.goods.itemtype == STALL_GOODS_T.PET then
		tip = StallPetTip.getInstanceAndShow(self:GetWindow())
		tip:setGoodsData(self.goods)
	end
	
	if tip then
		local p = GetScreenSize()
		SetPositionOffset(tip:GetWindow(), p.width*0.5+20, p.height*0.5, 0, 0.5) 
	end
end

function StallBuyConfirmDlg:setGoodsData(goods)
	self.goods = goods
	if goods.itemtype == STALL_GOODS_T.ITEM then
		local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(goods.itemid)
		if itemAttr then
			self.name:setText(itemAttr.name)
			local image = gGetIconManager():GetImageByID(itemAttr.icon)
			self.itemcell:SetImage(image)
		end
	elseif goods.itemtype == STALL_GOODS_T.PET then
		local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(goods.itemid)
        if petAttr then
		    self.name:setText(petAttr.name)
		    local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttr.modelid)
		    local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
		    self.itemcell:SetImage(image)
        end
	end
	
	self.priceText:setText(MoneyFormat(goods.price))
	
	--��ʾ��Ʒ�Ǳ�
	if ShopManager:needShowRarityIcon(goods.itemtype, goods.itemid) then
		self.itemcell:SetCornerImageAtPos("ccui1", "newzp", 0, 1)
	else
		self.itemcell:SetCornerImageAtPos(nil, 0, 0)
	end
	
	self:showTip()
end

function StallBuyConfirmDlg:setCallBack(target, func)
	self.callfunc = {target=target, func=func}
end

function StallBuyConfirmDlg:handleOkClicked(args)
	if self.callfunc then
		self.callfunc.func(self.callfunc.target, self.goods)
	end
	StallBuyConfirmDlg.DestroyDialog()
end

function StallBuyConfirmDlg:handleItemCellClicked(args)
	self:showTip()
end

return StallBuyConfirmDlg
