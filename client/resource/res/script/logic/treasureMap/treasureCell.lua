treasureCell = {}

setmetatable(treasureCell, Dialog)
treasureCell.__index = treasureCell
local prefix = 0

function treasureCell.CreateNewDlg(parent)
	local newDlg = treasureCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function treasureCell.GetLayoutFileName()
	return "wabaocell_mtg.layout"
end

function treasureCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, treasureCell)
	return self
end

function treasureCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.image = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "wabaocell_mtg/item"))
	self.name = winMgr:getWindow(prefixstr .. "wabaocell_mtg/text")
	self.back = winMgr:getWindow(prefixstr .. "wabaocell_mtg/image")
	self.back:setVisible(false)
end
-- 加载道具或时间图标与名字
function treasureCell:reloadDataById(id)
	local awardInfo
	if id < 100 and id > 0 then -- 加载事件
		awardInfo = BeanConfigManager.getInstance():GetTableByName(CheckTableName("treasuremap.ceventconfig")):getRecorder(id)
		self.image:SetImage(gGetIconManager():GetImageByID(awardInfo.iconId))
		self.name:setText(awardInfo.name)
	else  -- 加载道具
		awardInfo = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(id)
		if awardInfo and awardInfo.name ~= "" then
			self.image:SetImage(gGetIconManager():GetItemIconByID(awardInfo.icon))
			self.name:setText(awardInfo.name)
		else
			local conf = BeanConfigManager.getInstance():GetTableByName("shop.ccurrencyiconpath"):getRecorder(fire.pb.game.MoneyType.MoneyType_SilverCoin)
			local set, image = string.match(conf.iconpath, "set%:(.*) image%:(.*)")
			self.image:SetImage(set, image)
			self.name:setText(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11122).msg) 
		end
        if id ~= 0 then
            self.image:setID(id)
            self.image:subscribeEvent("TableClick", GameItemTable.HandleShowToolTipsWithItemID)
        end
	end
    SetItemCellBoundColorByQulityItemWithId(self.image, id)

    if awardInfo then
        ShowItemTreasureIfNeed(self.image, awardInfo.id)
    end
end

function treasureCell:setBackVisible( visible )
	self.back:setVisible(visible)
end


return treasureCell
