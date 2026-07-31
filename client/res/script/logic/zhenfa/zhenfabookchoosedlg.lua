require "logic.dialog"
require "logic.team.formationmanager"
require "utils.typedefine"
require "logic.zhenfa.zhenfabookcell"
require "utils.typedefine"

ZhenfaBookChooseDlg = {}
setmetatable(ZhenfaBookChooseDlg, Dialog)
ZhenfaBookChooseDlg.__index = ZhenfaBookChooseDlg


local _instance
function ZhenfaBookChooseDlg.getInstance()
	if not _instance then
		_instance = ZhenfaBookChooseDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function ZhenfaBookChooseDlg.getInstanceAndShow()
	if not _instance then
		_instance = ZhenfaBookChooseDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ZhenfaBookChooseDlg.getInstanceNotCreate()
	return _instance
end

function ZhenfaBookChooseDlg.DestroyDialog()
	if _instance then
		if _instance.bookCells then
			for _,v in pairs(_instance.bookCells) do
				v:OnClose()
			end
		end
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZhenfaBookChooseDlg.ToggleOpenClose()
	if not _instance then
		_instance = ZhenfaBookChooseDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ZhenfaBookChooseDlg.GetLayoutFileName()
	return "zhenfashuxuanze.layout"
end

function ZhenfaBookChooseDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhenfaBookChooseDlg)
	return self
end

function ZhenfaBookChooseDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("zhenfatisheng/framewindow"))
	self.bookScroll = CEGUI.toScrollablePane(winMgr:getWindow("zhenfatisheng/diban/shangxiahuadong"))
	self.itemCell = CEGUI.toItemCell(winMgr:getWindow("zhenfatisheng/diban/zhenfatubiao"))
	self.nameText = winMgr:getWindow("zhenfatisheng/zhenfadengji")
	self.progressBar = CEGUI.toProgressBar(winMgr:getWindow("zhenfatisheng/zhenfajindu"))
	self.useBtn = CEGUI.toPushButton(winMgr:getWindow("zhenfatisheng/shiyong"))

	self.useBtn:subscribeEvent("Clicked", ZhenfaBookChooseDlg.handleUseClicked, self)
	self.frameWindow:getCloseButton():subscribeEvent("Clicked", ZhenfaBookChooseDlg.DestroyDialog, nil)
	
    self.useBtn:setEnabled(false)
	self.itemKey2BaseId = {}
	self:loadBooks()
end

function ZhenfaBookChooseDlg:loadBooks()
	if self.bookCells then
		for _,v in pairs(self.bookCells) do
			v:OnClose()
		end
	end

	self.choosedItems = {}
	self.canjuanID = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(130).value) --光环残卷ID
	self.canjuanExp = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(131).value) --光环残卷增加经验
	self.notMatchBookExp = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(132).value) --不匹配光环书增加经验
	
	local items = {}
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	items = roleItemManager:GetItemKeyListByType(items, ITEM_TYPE.FORMATION_CAN_JUAN)
	items = roleItemManager:GetItemKeyListByType(items, ITEM_TYPE.FORMATION_BOOK)
	
	self.bookCells = {}
	for i=0, items:size()-1 do
		local itemkey = items[i]
		local cell = ZhenfaBookCell.CreateNewDlg(self.bookScroll)
		cell:setItemKey(itemkey)
		local row = math.floor(i/5)
		local col = i%5
		local s = cell:GetWindow():getPixelSize()
		SetPositionOffset(cell:GetWindow(), 20+col*s.width, 1+row*s.height)
		table.insert(self.bookCells, cell)
	end
	items = nil
end

function ZhenfaBookChooseDlg:onChoosedItemNumChanged(itemKey, itemId, num)
	self.choosedItems[itemKey] = (num>0 and num or nil)
	self.itemKey2BaseId[itemKey] = itemId
	self:refreshPreview()

    if TableUtil.tablelength(self.choosedItems) == 0 then
        self.useBtn:setEnabled(false)
    else
        self.useBtn:setEnabled(true)
    end
end

--@return 可升到等级的CZhenFaeffectTable数据，剩余的经验，下级所需经验
function ZhenfaBookChooseDlg:countFinalLevel(effectConf, addExp)
	local nextEffectConf = FormationManager.getInstance():getZhenfaEffectConf(self.conf.id, effectConf.zhenfaLv+1)
	if not nextEffectConf then --到顶级了
		return self:countFinalLevel(nextEffectConf, addExp - nextEffectConf.needexp)
	end

	if addExp >= nextEffectConf.needexp then --可升级
		return self:countFinalLevel(nextEffectConf, addExp - nextEffectConf.needexp)
	end
	
	return effectConf, addExp, nextEffectConf.needexp
end

function ZhenfaBookChooseDlg:refreshPreview()
	local addExp = 0
	for k,v in pairs(self.choosedItems) do
		if self.itemKey2BaseId[k] == self.conf.bookid then
			addExp = addExp + v * self.conf.bookaddexp
		elseif self.itemKey2BaseId[k] == self.canjuanID then
			addExp = addExp + v * self.canjuanExp
		else
			addExp = addExp + v * self.notMatchBookExp
		end
	end
	
	--根据增加的经验判断提升后的等级
	local effectconf = FormationManager.getInstance():getZhenfaEffectConf(self.conf.id, self.level)
	local leftExp = nil
	local nextLevelExp = nil
	effectconf, leftExp, nextLevelExp = self:countFinalLevel(effectconf, self.curExp + addExp)
	
	if nextLevelExp == 0 then
		self.expIsFull = true
		self.progressBar:setText(MHSD_UTILS.get_resstring(2835)) --已满级
		self.progressBar:setProgress(1)
	else
		self.expIsFull = false
		self.progressBar:setText(leftExp .. "/" .. nextLevelExp)
		self.progressBar:setProgress(leftExp/nextLevelExp)
	end
	
	self.nameText:setText(effectconf.zhenfaLv .. MHSD_UTILS.get_resstring(3) .. self.conf.name) --x级xxx

end

function ZhenfaBookChooseDlg:setZhenfaData(conf, level, curexp)
	self.itemCell:SetImage(gGetIconManager():GetImageByID(conf.icon))
	self.nameText:setText(conf.name)
	
	self.conf = conf
	self.level = level
	self.curExp = curexp
	self:refreshPreview()
end

function ZhenfaBookChooseDlg:refresh()
	self:loadBooks()
	
	local data = FormationManager.getInstance():getFormationData(self.conf.id)
	self.level = data.level
	self.curExp = data.exp
	self:refreshPreview()
end

function ZhenfaBookChooseDlg:handleUseClicked(args)
    if TableUtil.tablelength(self.choosedItems) == 0 then
        return
    end
	local hasItem = false
	for k,v in pairs(self.choosedItems) do
		if v then
			hasItem = true
			break
		end
	end
	if not hasItem then
		GetCTipsManager():AddMessageTipById(160041) --你没有选择任何升级材料哦
		return
	end
	
	local p = require("protodef.fire.pb.team.cuseformbook").Create()
	p.formationid = self.conf.id
	for k,v in pairs(self.choosedItems) do
		local book = UseFormBook:new()
		book.bookid = self.itemKey2BaseId[k]
		book.num = v
		table.insert(p.listbook, book)
		print('usebook', k, v)
	end

	LuaProtocolManager:send(p)

    self.choosedItems = {} --reset
    self.useBtn:setEnabled(false)
end

return ZhenfaBookChooseDlg
