------------------------------------------------------------------
-- 神兽兑换商店
------------------------------------------------------------------

require "logic.dialog"
require "protodef.rpcgen.fire.pb.shop.shopbuytype"

NpcShenShouShop = {}
setmetatable(NpcShenShouShop, Dialog)
NpcShenShouShop.__index = NpcShenShouShop

local _instance
function NpcShenShouShop.getInstance()
	if not _instance then
		_instance = NpcShenShouShop:new()
		_instance:OnCreate()
	end
	return _instance
end

local function playWindowEnterAnimation(windowName, animationName) 
    local winMgr = CEGUI.WindowManager:getSingleton()
    local targetWindow = winMgr:getWindow(windowName)
    targetWindow:setVisible(false)  
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation(animationName)  
    local instance = aniMan:instantiateAnimation(animationOpen)  
    instance:setTargetWindow(targetWindow) 
    instance:start() 
    --targetWindow:setVisible(true)  
end

function NpcShenShouShop.getInstanceAndShow()
	if not _instance then
		_instance = NpcShenShouShop:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function NpcShenShouShop.getInstanceNotCreate()
	return _instance
end

function NpcShenShouShop.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
            gGetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.eventItemNumChange)
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function NpcShenShouShop.ToggleOpenClose()
	if not _instance then
		_instance = NpcShenShouShop:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function NpcShenShouShop.GetLayoutFileName()
	return "npcshopshenshou_mtg.layout"
end

function NpcShenShouShop:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, NpcShenShouShop)
	return self
end

function NpcShenShouShop:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

--  
    playWindowEnterAnimation("npcshopshenshou_mtg/ccck1", "xunhuan1") 
    playWindowEnterAnimation("npcshopshenshou_mtg/ccck2", "xunhuan2") 
    playWindowEnterAnimation("npcshopshenshou_mtg/ccck3", "xunhuan3") 
	
	self.ownMoneyText = winMgr:getWindow("npcshopshenshou_mtg/textdan")
	self.priceText = winMgr:getWindow("npcshopshenshou_mtg/textdan1")
	self.buyBtn = CEGUI.toPushButton(winMgr:getWindow("npcshopshenshou_mtg/btngoumai"))
	self.goodsListBg = winMgr:getWindow("npcshopshenshou_mtg/textbg/goodslist")
	self.btnlist = CEGUI.toScrollablePane(winMgr:getWindow("npcshopshenshou_mtg/btnlist"))
    
	self.buyBtn:subscribeEvent("Clicked", NpcShenShouShop.handleBuyClicked, self)

    local s = self.goodsListBg:getPixelSize()
	self.goodsTableView = TableView.create(self.goodsListBg)
	self.goodsTableView:setViewSize(s.width, s.height+10)
	self.goodsTableView:setPosition(0, 0)
	self.goodsTableView:setColumCount(3)
	self.goodsTableView:setCellInterval(nil, 5)
	self.goodsTableView:setDataSourceFunc(self, NpcShenShouShop.tableViewGetCellAtIndex)

    self.price = 0
    self.ownMoney = 0
    self.curPetType = -1
    self.selectedGoodsId = -1
    self:loadBtnList()

    local zhenHunShiCount = RoleItemManager.getInstance():GetItemNumByBaseID(ZhenHunShiItemId)
    self.ownMoneyText:setText(MoneyFormat(zhenHunShiCount))
    self.ownMoney = zhenHunShiCount

    self.eventItemNumChange = gGetRoleItemManager():InsertLuaItemNumChangeNotify(NpcShenShouShop.onEventBagItemNumChange)
end


function NpcShenShouShop:loadBtnList()
    local winMgr = CEGUI.WindowManager:getSingleton()
    local rolelv = gGetDataManager():GetMainCharacterLevel()
    local ids = BeanConfigManager.getInstance():GetTableByName("shop.cshenshoushop"):getAllID()
    local btnw = self.btnlist:getPixelSize().width
    local btnh = 85
	local n = 0
    for _,id in pairs(ids) do
		local conf = BeanConfigManager.getInstance():GetTableByName("shop.cshenshoushop"):getRecorder(id)
		if conf.visiblelevel <= rolelv then
			local btn = CEGUI.toGroupButton(winMgr:createWindow("TaharezLook/GroupButtoncc1"))
			btn:setGroupID(0)
			btn:setProperty("Font", "simhei-14")
			btn:setID(id)
			btn:setText(conf.name)
			btn:setSize(CEGUI.UVector2(CEGUI.UDim(0, btnw), CEGUI.UDim(0, btnh)))
			btn:EnableClickAni(false)
			self.btnlist:addChildWindow(btn)
			btn:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, n*(btnh+0))))
			btn:subscribeEvent("SelectStateChanged", NpcShenShouShop.handlePetTypeBtnClicked, self)
			if n == 0 then
				btn:setSelected(true, false)
                self:loadGoodsList(id)
			end
			n = n+1
		end
	end
end

function NpcShenShouShop:loadGoodsList(pettype)
    self.curPetType = pettype
    if self.curPetType == -1 then
        return
    end

    local conf = BeanConfigManager.getInstance():GetTableByName("shop.cshenshoushop"):getRecorder(self.curPetType)
    if not conf then
        return
    end

    self.goodslist = conf.goodsids
	self.goodsTableView:setCellCount(conf.goodsids:size())
	self.goodsTableView:reloadData()
end

function NpcShenShouShop:tableViewGetCellAtIndex(tableView, idx, cell)
    if not cell then
		cell = GoodsCell.CreateNewDlg(tableView.container)
        cell.itemName:setProperty("TextColours", "FFFFFFFF")
        cell.window:subscribeEvent("SelectStateChanged", NpcShenShouShop.handleGoodsCellClicked, self)
	end
    
	cell.window:setID(self.goodslist[idx])
	cell:setGoodsDataById(self.goodslist[idx], false)
    cell.window:setSelected(self.goodslist[idx] == self.selectedGoodsId, false)

	return cell
end

function NpcShenShouShop:handlePetTypeBtnClicked(args)
    local petTypeId = CEGUI.toWindowEventArgs(args).window:getID()
    if petTypeId ~= self.curPetType then
        self.price = 0
        self.priceText:setText(0)
        self.selectedGoodsId = -1
        self.ownMoneyText:setProperty("BorderEnable", "False")
        self:loadGoodsList(petTypeId)
    end
end

function NpcShenShouShop:handleGoodsCellClicked(args)
    self.selectedGoodsId = CEGUI.toWindowEventArgs(args).window:getID()
    local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(self.selectedGoodsId)
	if not conf then
		return
	end

    self.price = conf.prices[0]
    self.priceText:setText(conf.prices[0])
    if self.price > self.ownMoney then
        self.ownMoneyText:setProperty("BorderEnable", "True")
    else
        self.ownMoneyText:setProperty("BorderEnable", "False")
    end
end

function NpcShenShouShop:handleBuyClicked(args)
    if self.selectedGoodsId == -1 then
        return
    end

    if self.price > self.ownMoney then
        local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(ZhenHunShiItemId)
        if itemAttr then
            local str = MHSD_UTILS.get_msgtipstring(140638) --你身上的"$parameter1$数量不足。
            str = string.gsub(str, "%$parameter1%$", itemAttr.name)
            GetCTipsManager():AddMessageTip(str)
        end
        return
    end

    local p = require("protodef.fire.pb.shop.cbuynpcshop").Create()
	p.shopid = SHOP_TYPE.SHENSHOU
	p.goodsid = self.selectedGoodsId
	p.num = 1
	p.buytype = ShopBuyType.SHENSHOU_SHOP

    LuaProtocolManager:send(p)
end

function NpcShenShouShop.onEventBagItemNumChange(bagid, itemkey, itembaseid)
	if not _instance or bagid ~= fire.pb.item.BagTypes.BAG or itembaseid ~= ZhenHunShiItemId then
		return
	end

    local zhenHunShiCount = RoleItemManager.getInstance():GetItemNumByBaseID(ZhenHunShiItemId)
    _instance.ownMoneyText:setText(MoneyFormat(zhenHunShiCount))
    _instance.ownMoney = zhenHunShiCount

    if _instance.price > _instance.ownMoney then
        _instance.ownMoneyText:setProperty("BorderEnable", "True")
    else
        _instance.ownMoneyText:setProperty("BorderEnable", "False")
    end
end

function NpcShenShouShop:OnClose()
  
    local winMgr = CEGUI.WindowManager:getSingleton()
    for i = 1, 3 do
        local windowName = "npcshopshenshou_mtg/ccck" .. i
        local window = winMgr:getWindow(windowName)
        if window then
            window:setVisible(false) 
        end
    end

    -- 之前的停止动画代码
    --  local aniMan = CEGUI.AnimationManager:getSingleton()
    --  if aniMan then
    --     for i = 1, 3 do
    --         local windowName = "npcshopshenshou_mtg/ccck" .. i
    --         aniMan:destroyAllInstancesAtTargetWindow(windowName)
    --     end
    -- end

    Dialog.OnClose(self)
end

return NpcShenShouShop