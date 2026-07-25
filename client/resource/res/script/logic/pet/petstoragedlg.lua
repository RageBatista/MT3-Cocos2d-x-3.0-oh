require "logic.dialog"
require "logic.pet.petstoragecell"


petstoragedlg = {}
setmetatable(petstoragedlg, Dialog)
petstoragedlg.__index = petstoragedlg
petstoragedlg.npckey = 0


local _instance
function petstoragedlg.getInstance()
	if not _instance then
		_instance = petstoragedlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function petstoragedlg.getInstanceAndShow( colunmSize )
	if not _instance then
		_instance = petstoragedlg:new()
		_instance:OnCreate(colunmSize)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function petstoragedlg.getInstanceNotCreate()
	return _instance
end

function petstoragedlg.DestroyDialog()
	if _instance then
		for i = 1, #_instance.storageCell do
			_instance.storageCell[i]:OnClose()
			_instance.storageCell[i] = nil
		end
		for i = 1, #_instance.carryCell do
			_instance.carryCell[i]:OnClose()
			_instance.carryCell[i] = nil
		end
		
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function petstoragedlg.ToggleOpenClose()
	if not _instance then
		_instance = petstoragedlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function petstoragedlg.GetLayoutFileName()
	return "petdepot_mtg.layout"
end

function petstoragedlg.HandleNextPageClick(args)
    _instance:cleanupCurrentPage()
	_instance.storageIndex = _instance.storageIndex - 1
	if _instance.storageIndex < 1 then
		_instance.storageIndex = _instance.pageNum
	end
	_instance:createNextorLastPageCell()
end

function petstoragedlg.HandleLastPageClick(args)
	_instance:cleanupCurrentPage()
	_instance.storageIndex = _instance.storageIndex + 1
	if _instance.storageIndex > _instance.pageNum then
		_instance.storageIndex = 1
	end
	_instance:createNextorLastPageCell()
end
-- 自身宠物双击事件
function petstoragedlg:HandleCarryPetDoubleClick(args)
	local id = CEGUI.toWindowEventArgs(args).window:getID()
	local petInfo = MainPetDataManager.getInstance():getPet(id)
	if petInfo.key == gGetDataManager():GetBattlePetID() then --出战
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(160021).msg)
		return
	end
--	if petInfo.flag == 2 then --绑定
--		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(160026).msg)
--		return 
--	end
--[[	if self.curStoragePet >= 4 then -- 当前仓库已满
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(160028).msg)
		return 
	end--]]
	if self.curStoragePet >= self.storageCanUseNum then -- 当前仓库已满
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(160028).msg)
		return 
	end
	local p = require("protodef.fire.pb.pet.cmovepetcolumn"):new()
    p.srccolumnid = 1 -- 人物身上的宠物背包
    p.dstcolumnid = 2 -- 仓库
    p.petkey = petInfo.key
    p.npckey = petstoragedlg.npckey
	LuaProtocolManager:send(p)
end
-- 仓库宠物双击事件
function petstoragedlg:HandleStoragePetDoubleClick(args)
	local id = CEGUI.toWindowEventArgs(args).window:getID()
	if id == self.colunmSize + 1 then
	else
		if MainPetDataManager.getInstance():IsMyPetFull() then
			GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(160108).msg)
			return
		end
		local petInfo = MainPetDataManager.getInstance():getDeportPet(id)

        local p = require("protodef.fire.pb.pet.cmovepetcolumn"):new()
        p.srccolumnid = 2  -- 仓库
        p.dstcolumnid = 1  -- 人物身上的宠物背包
        p.petkey = petInfo.key
        p.npckey = petstoragedlg.npckey
	    LuaProtocolManager:send(p)
	end
end

function petstoragedlg:tobuyStorage()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
	local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetdepotprice"):getRecorder(self.colunmSize + 1 - 2)
	local nNeedMoney = conf.nextneedmoney
	local nUserMoney = roleItemManager:GetPackMoney()
    local p = require("protodef.fire.pb.pet.cpetdepotcolumnaddcapacity").Create()
	if nUserMoney < nNeedMoney then
		local nMoneyType = fire.pb.game.MoneyType.MoneyType_SilverCoin
		local nShowNeed = nNeedMoney - nUserMoney
		CurrencyManager.handleCurrencyNotEnough(nMoneyType, nShowNeed, nNeedMoney, p)
		return 
	end
	LuaProtocolManager:send(p)
end

function petstoragedlg:cancal()
	gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

function petstoragedlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, petstoragedlg)
	return self
end

function petstoragedlg:OnCreate( colunmSize )
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.storageIndex = 1    -- 记录当前仓库页数
	self.colunmSize = colunmSize -- 宠物栏数量
	self.storagePetNum = MainPetDataManager.getInstance():GetDeportPetNum() -- 仓库宠物数量
	if self.colunmSize < 25 then
		self.pageNum = math.ceil((self.colunmSize + 1)/5)      -- 仓库总页数
	else
		self.pageNum = math.ceil((self.colunmSize)/5)
	end
	self.curStoragePet = 0   --  当前仓库宠物数量
	self.storageCell = {}
	self.storageSelectItem = 0
	self.carrySelectItem = 0
	self.storageCanUseNum = 0
	
	self.textCurPage = winMgr:getWindow("petdepot_mtg/txt1")
	self.btnLastPage = CEGUI.toPushButton(winMgr:getWindow("petdepot_mtg/btnleft"))
	self.btnNextPage = CEGUI.toPushButton(winMgr:getWindow("petdepot_mtg/btnright"))
	self.btnStorage1 = CEGUI.toPushButton(winMgr:getWindow("petdepot_mtg/tips/btncangk1"))
	self.btnStorage1:setID(1)
	self.btnStorage2 = CEGUI.toPushButton(winMgr:getWindow("petdepot_mtg/tips/btncangk2"))
	self.btnStorage2:setID(2)
	self.btnStorage3 = CEGUI.toPushButton(winMgr:getWindow("petdepot_mtg/tips/btncangk3"))
	self.btnStorage3:setID(3)
    --self.btnStorage4 = CEGUI.toPushButton(winMgr:getWindow("petdepot_mtg/tips/btncangk4"))
	--self.btnStorage4:setID(4)
	self.storageList = CEGUI.toScrollablePane(winMgr:getWindow("petdepot_mtg/textbg/list2"))
	self.carryList = CEGUI.toScrollablePane(winMgr:getWindow("petdepot_mtg/itemscrollpane"))
	self.btnPetStorage = CEGUI.toPushButton(winMgr:getWindow("petdepot_mtg/btnmianfei"))
	self.btnSave = CEGUI.toPushButton(winMgr:getWindow("petdepot_mtg/jicun"))
	self.btnTakeout = CEGUI.toPushButton(winMgr:getWindow("petdepot_mtg/quchu"))
	self.tips = winMgr:getWindow("petdepot_mtg/tips")
	self.imageDown = winMgr:getWindow("petdepot_mtg/btnmianfei/imagedown")
	self.imageUp = winMgr:getWindow("petdepot_mtg/btnmianfei/imageup")
	self.imageUp:setVisible(false)
	self.imageDown:setVisible(true)

	self.tipsHeight = self.tips:getPixelSize().height
	self.btnLastPage:subscribeEvent("Clicked", petstoragedlg.HandleLastPageClick, self)
	self.btnNextPage:subscribeEvent("Clicked", petstoragedlg.HandleNextPageClick, self)
	self.btnPetStorage:subscribeEvent("Clicked", petstoragedlg.HandleStorageSelectClick, self)
	self.btnSave:subscribeEvent("Clicked", petstoragedlg.HandleSaveClick, self)
	self.btnTakeout:subscribeEvent("Clicked", petstoragedlg.HandleTakeoutClick, self)
	self.btnStorage1:subscribeEvent("Clicked", petstoragedlg.HandleStorageselectedClick, self)
	self.btnStorage2:subscribeEvent("Clicked", petstoragedlg.HandleStorageselectedClick, self)
	self.btnStorage3:subscribeEvent("Clicked", petstoragedlg.HandleStorageselectedClick, self)
    --self.btnStorage4:subscribeEvent("Clicked", petstoragedlg.HandleStorageselectedClick, self)
	self.everyPageNum = 5
	if self.pageNum <= 1 then
		self.everyPageNum = self.colunmSize + 1
	end
	self:createStorageList(1, self.everyPageNum)
	self:initCarryList()
	self.textCurPage:setText(tostring(self.storageIndex).."/"..tostring(self.pageNum))
end
-- 初始化仓库宠物list
function petstoragedlg:createStorageList(index, num)
	self.storageCell = nil
	self.curStoragePet = 0
	self.storageCanUseNum = num - index + 1
	self.storageCell = {}
	local i = 1
	local curIndex = 0
	local petInfo
	for j = index, num do
		self.storageCell[i] = petstoragecell.CreateNewDlg(self.storageList)
		self.storageCell[i]:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim( 0,  1 ), CEGUI.UDim(0,  (i-1)*self.storageCell[i]:GetWindow():getPixelSize().height)))
		self.storageCell[i].window:setID(j)
		if j <= self.storagePetNum then
			petInfo = MainPetDataManager.getInstance():getDeportPet(j)
			self.storageCell[i]:reloadData(petInfo, 2)
			--self.storageCell[i].petCell:subscribeEvent("MouseClick", self.HandleDeportCellClicked, self)
			self.curStoragePet = self.curStoragePet + 1
		else
			self.storageCell[i].petCell:SetBackGroundImage("ccui", "petckcell")
			self.storageCell[i]:setAllWeightVisible(false)
		end
		if j == self.colunmSize + 1 then
			self.storageCanUseNum = self.storageCanUseNum - 1
			self.storageCell[i].petCell:setVisible(false)
			self.storageCell[i].lock:setVisible(true)
		end
		self.storageCell[i].window:EnableClickAni(false)
		self.storageCell[i].window:subscribeEvent("MouseClick", petstoragedlg.HandleStorageCellClicked, self)
		self.storageCell[i].window:setWantsMultiClickEvents(true)
		self.storageCell[i].window:subscribeEvent("MouseDoubleClick", petstoragedlg.HandleStoragePetDoubleClick, self)
		
		i = i + 1
	end
end
-- 初始化携带宠物list
function petstoragedlg:initCarryList( )
	local carryPetNum = MainPetDataManager.getInstance():GetPetNum()
	self.carryCell = nil
	self.carryCell = {}
	for i = 1, carryPetNum do
		local petInfo = MainPetDataManager.getInstance():getPet(i)
		self.carryCell[i] = petstoragecell.CreateNewDlg(self.carryList)
		self.carryCell[i].window:setID(i)
		self.carryCell[i].window:EnableClickAni(false)
		self.carryCell[i]:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim( 0,  1 ), CEGUI.UDim(0,  (i-1)*self.carryCell[i]:GetWindow():getPixelSize().height )))
		self.carryCell[i]:reloadData(petInfo, 1)
		self.carryCell[i].window:setWantsMultiClickEvents(true)
		self.carryCell[i].window:subscribeEvent("MouseDoubleClick", petstoragedlg.HandleCarryPetDoubleClick, self)
		self.carryCell[i].window:subscribeEvent("MouseClick", petstoragedlg.HandleCarryCellClicked, self)
	end
end
-- 自身宠物cell单击事件
function petstoragedlg:HandleCarryCellClicked(args)
	local id = CEGUI.toWindowEventArgs(args).window:getID()
	self.carrySelectItem = id
end
-- 商店宠物cell单击事件
function petstoragedlg:HandleStorageCellClicked(args)
	local id = CEGUI.toWindowEventArgs(args).window:getID()
	self.storageSelectItem = id
	if id == self.colunmSize + 1 then
		local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetdepotprice"):getRecorder(self.colunmSize + 1 - 2)
		local strbuilder = StringBuilder:new()
		strbuilder:Set("parameter1", conf.nextneedmoney)
		local tipMsg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(160027))
        strbuilder:delete()
		gGetMessageManager():AddConfirmBox(eConfirmNormal,tipMsg,self.tobuyStorage,self,self.cancal,self)
	end
end
-- 单击寄存
function petstoragedlg:HandleSaveClick(args)
	if self.carrySelectItem == 0 then
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(160032).msg)
		return
	end
	local petInfo = MainPetDataManager.getInstance():getPet(self.carrySelectItem)
	if petInfo.key == gGetDataManager():GetBattlePetID() then --出战
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(160021).msg)
		return
	end
--	if petInfo.flag == 2 then --绑定
--		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(160026).msg)
--		return 
--	end		
	if self.curStoragePet >= self.storageCanUseNum then
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(160028).msg)
		return 
	end
    local p = require("protodef.fire.pb.pet.cmovepetcolumn"):new()
    p.srccolumnid = 1  -- 人物身上的宠物背包
    p.dstcolumnid = 2  -- 仓库
    p.petkey = petInfo.key
    p.npckey = petstoragedlg.npckey
	LuaProtocolManager:send(p)
end
-- 单击取出
function petstoragedlg:HandleTakeoutClick(args)
	if self.storageSelectItem == 0 then
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(160025).msg)
		return
	end	
	local petInfo = MainPetDataManager.getInstance():getDeportPet(self.storageSelectItem)
	if petInfo == nil then
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(160025).msg)
		return
	end
	if MainPetDataManager.getInstance():IsMyPetFull() then
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(160108).msg)
		return
	end

    local p = require("protodef.fire.pb.pet.cmovepetcolumn"):new()
    p.srccolumnid = 2  -- 仓库
    p.dstcolumnid = 1  -- 人物身上的宠物背包
    p.petkey = petInfo.key
    p.npckey = petstoragedlg.npckey
	LuaProtocolManager:send(p)
end
-- 宠物仓库按钮
function petstoragedlg:HandleStorageSelectClick(args)
	if self.tips:isVisible() then
		self.tips:setVisible(false)
		self.btnStorage1:setVisible(false)
		if self.pageNum > 1 then
			self.btnStorage2:setVisible(true)
		end
		if self.pageNum > 2 then
			self.btnStorage3:setVisible(true)
		end
      --  if self.pageNum > 3 then
      --      self.btnStorage4:setVisible(true)
      --  end

        if self.pageNum > 2 then
            self.tips:setSize(CEGUI.UVector2(CEGUI.UDim(0.0, self.tips:getPixelSize().width), CEGUI.UDim(0.0, self.tipsHeight)))
        else
            self.tips:setSize(CEGUI.UVector2(CEGUI.UDim(0.0, self.tips:getPixelSize().width), CEGUI.UDim(0.0, self.tipsHeight*0.80)))
        end

		self.imageUp:setVisible(false)
		self.imageDown:setVisible(true)
	else
		self.tips:setVisible(true)
		self.tips:moveToFront()
		self.btnStorage1:setVisible(true)
        if self.pageNum > 1 then
			self.btnStorage2:setVisible(true)
		end
		if self.pageNum > 2 then
			self.btnStorage3:setVisible(true)
		end
      --  if self.pageNum > 3 then
      --      self.btnStorage4:setVisible(true)
      --  end

		if self.pageNum < 2 then
			self.btnStorage2:setVisible(false)
		end
		if self.pageNum < 3 then
			self.btnStorage3:setVisible(false)
		end
     --   if self.pageNum < 4 then
      --      self.btnStorage4:setVisible(false)
      --  end
        if self.pageNum > 2 then
            self.tips:setSize(CEGUI.UVector2(CEGUI.UDim(0.0, self.tips:getPixelSize().width), CEGUI.UDim(0.0, self.tipsHeight)))
        else
            self.tips:setSize(CEGUI.UVector2(CEGUI.UDim(0.0, self.tips:getPixelSize().width), CEGUI.UDim(0.0, self.tipsHeight*0.80)))
        end
		self.imageUp:setVisible(true)
		self.imageDown:setVisible(false)
	end
end
-- 清空当前页面仓库
function petstoragedlg:cleanupCurrentPage()
	self.storageList:cleanupNonAutoChildren()
	self:closeCell(_instance.storageCell)
end
-- 重新创建宠物列表
function petstoragedlg:createNextorLastPageCell()
	self.textCurPage:setText(tostring(self.storageIndex).."/"..tostring(self.pageNum))
	local num = self.colunmSize + 1 - (self.storageIndex-1) * 5
	local index = (self.storageIndex - 1) * 5 + 1
	if num > 5 then
		num = 5
	end
	num = index + num - 1
	self:createStorageList(index, num)
end

function petstoragedlg.updateStorageCapacity( capacity )
	_instance:addStorageCapacity(capacity)
end

function petstoragedlg:closeCell(list)
	for i = 1, #list do
		list[i]:OnClose()
		list[i] = nil
	end
end
-- 删除宠物(服务器回消息回调)
function petstoragedlg.removePet(columnid)
	if _instance then
		if columnid == 1 then  -- 人物
			_instance.carrySelectItem = 0
			_instance.carryList:cleanupNonAutoChildren()
			_instance:closeCell(_instance.carryCell)
			_instance:initCarryList( )
		elseif columnid == 2 then --  仓库
			_instance.storageSelectItem = 0
			_instance.storageList:cleanupNonAutoChildren()
			_instance:closeCell(_instance.storageCell)
			_instance.storagePetNum = MainPetDataManager.getInstance():GetDeportPetNum()
			_instance:createNextorLastPageCell()
		end
	end
end
-- 添加宠物(服务器回消息回调)
function petstoragedlg.addPet(columnid, key)
	if _instance then
		local petInfo = MainPetDataManager.getInstance():FindMyPetByID(key, columnid)
		local strbuilder = StringBuilder:new()
		local tipMsg
		if columnid == 1 then -- 人物
			strbuilder:Set("parameter1", petInfo.name)
			tipMsg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(160023))
			GetCTipsManager():AddMessageTip(tipMsg);
			_instance.carryList:cleanupNonAutoChildren()
			_instance:closeCell(_instance.carryCell)
			_instance:initCarryList( )
		elseif columnid == 2 then  -- 仓库
			strbuilder:Set("parameter1", petInfo.name)
			tipMsg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(160022))
			GetCTipsManager():AddMessageTip(tipMsg);
			_instance.storageList:cleanupNonAutoChildren()
			_instance:closeCell(_instance.storageCell)
			_instance.storagePetNum = MainPetDataManager.getInstance():GetDeportPetNum()
			_instance:createNextorLastPageCell()	
		end
        strbuilder:delete()
	end
end
-- 更新仓库最大容量
function petstoragedlg:addStorageCapacity(capacity)
	GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(160024).msg)
	self.colunmSize = capacity
	self.storageCell[#self.storageCell].lock:setVisible(false)
	self.storageCell[#self.storageCell].petCell:setVisible(true)
	self.storageCell[#self.storageCell].petCell:SetBackGroundImage("ccui", "petckcell")
	self.storageCanUseNum = self.storageCanUseNum + 1
	if #self.storageCell < 5 then
		self.storageCell[#self.storageCell+1] = petstoragecell.CreateNewDlg(self.storageList)
		self.storageCell[#self.storageCell]:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim( 0,  1 ), CEGUI.UDim(0,  (#self.storageCell-1)*self.storageCell[#self.storageCell]:GetWindow():getPixelSize().height)))
		self.storageCell[#self.storageCell].window:setID(capacity + 1)
		self.storageCell[#self.storageCell].window:EnableClickAni(false)
		self.storageCell[#self.storageCell]:setAllWeightVisible(false)
		self.storageCell[#self.storageCell].lock:setVisible(true)
		self.storageCell[#self.storageCell].petCell:setVisible(false)
		self.storageCell[#self.storageCell].window:subscribeEvent("MouseClick", petstoragedlg.HandleStorageCellClicked, self)
	elseif #self.storageCell == 5 then
		if self.pageNum < 3 then
			self.pageNum = math.ceil((self.colunmSize + 1)/5)
			self.textCurPage:setText(tostring(self.storageIndex).."/"..tostring(self.pageNum))
		end
	end	
end
-- 仓库选择
function petstoragedlg:HandleStorageselectedClick(args)
	self.tips:setVisible(false)
	self.imageUp:setVisible(false)
	self.imageDown:setVisible(true)
	local id = CEGUI.toWindowEventArgs(args).window:getID()
	self.storageIndex = id
	self.storageList:cleanupNonAutoChildren()
	self:closeCell(_instance.storageCell)
	self:createNextorLastPageCell()
end

return petstoragedlg
