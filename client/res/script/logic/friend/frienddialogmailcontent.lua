FriendDialogMailContent = {}

setmetatable(FriendDialogMailContent, Dialog)
FriendDialogMailContent.__index = FriendDialogMailContent

function FriendDialogMailContent.CreateNewDlg(parent, prefix)
	local newDlg = FriendDialogMailContent:new()
	newDlg:OnCreate(parent, prefix)
	return newDlg
end

function FriendDialogMailContent.GetLayoutFileName()
	return "friendmailcontent.layout"
end

function FriendDialogMailContent:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, FriendDialogMailContent)
	return self
end

function FriendDialogMailContent:OnCreate(parent, prefix)
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local namePrefix = tostring(prefix)

	self.m_TextOutput = CEGUI.Window.toRichEditbox(winMgr:getWindow(namePrefix .. "friendmailcontent/textoutput"))
	self.m_TextOutput:setReadOnly(true)

	self.m_ItemOutput = CEGUI.Window.toScrollablePane(winMgr:getWindow(namePrefix .. "friendmailcontent/itemoutput"))
	self.m_ItemOutput:EnableHorzScrollBar(true)

	self.m_GetBtn = winMgr:getWindow(namePrefix .. "friendmailcontent/get")
	self.m_GetBtn:subscribeEvent("Clicked", FriendDialogMailContent.HandleClickGetBtn, self)
    self.m_index = 0
end

function FriendDialogMailContent:HandleClickGetBtn(args)

	if self.isGotoNpc == false then
		self.m_GetBtn:setText(MHSD_UTILS.get_resstring(2940))
		self.m_GetBtn:setEnabled(false)
		local kind = self.kind
		local id = self.id
		local req = require "protodef.fire.pb.item.cmailgetaward".Create()
		req.kind = kind
		req.id = id
		LuaProtocolManager.getInstance():send(req)
	else
		local npcID = self.npcID
		require("logic.task.taskhelper").gotoNpc(npcID)
	end

end
--������һЩ���ң�������ͨ�ĵ��ߺ���
function FriendDialogMailContent:AddMoneyItem(awardmoney,awardexp,awardgold,awardfushi,awardvipexp)
    if awardmoney > 0 then
        self:AddItem(tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(313).value), awardmoney, self.m_index, false)
        self.m_index = self.m_index + 1
    end
    if awardexp > 0 then
        self:AddItem(tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(314).value), awardexp, self.m_index, false)
        self.m_index = self.m_index + 1
    end
    if awardgold > 0 then
        self:AddItem(tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(312).value), awardgold, self.m_index, false)
        self.m_index = self.m_index + 1
    end
    if awardfushi > 0 then
        self:AddItem(tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(315).value), awardfushi, self.m_index, false)
        self.m_index = self.m_index + 1
    end
    if awardvipexp > 0 then
        self:AddItem(tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(345).value), awardvipexp, self.m_index, false)
        self.m_index = self.m_index + 1
    end
end
function FriendDialogMailContent:Init(kind, id, strContent, awardID, items, isGotoNpc, npcID, isAlreadyGet)
	self.kind = kind
	self.id = id
	self.isGotoNpc = isGotoNpc
	self.npcID = npcID
    self.m_index = 0
	self.m_TextOutput:Clear()
	--dumpT(strContent,"strContent")
	--strContent = "<T t=\"尊敬的【】玩家: \" c=\"ff261407\" /><B></B>"
	               
	              -- "<T t=\"尊敬的【】玩家: \" c=\"ff580D1D\" /><B></B>"
				    
	--  local searchTerm = "<T"
	--  if string.find(strContent, searchTerm) then
	-- 	print("strContent 中包含 <", searchTerm, "> 子字符串")
	-- 	strContent = strContent
	-- else
	-- 	print("strContent 中不包含 <", searchTerm, "> 子字符串")
	-- 	strContent = "<T c=\"ff00BF00\" t=\"" .. strContent .. "\"></T>"
	-- end

    if string.find(strContent, "<T") then
        self.m_TextOutput:AppendParseText(CEGUI.String(strContent), false)
		--dumpT("strContent有")
    else
		---dumpT("strContent无")
        local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF7F4601"))
	    self.m_TextOutput:AppendText(CEGUI.String(strContent), color)
    end


	--self.m_TextOutput:AppendParseText(CEGUI.String(strContent), false)
	self.m_TextOutput:Refresh()

	if self.isGotoNpc == false then
		if isAlreadyGet then
			self.m_GetBtn:setText(MHSD_UTILS.get_resstring(2940))
			self.m_GetBtn:setEnabled(false)
		else
			self.m_GetBtn:setText(MHSD_UTILS.get_resstring(2939))
			self.m_GetBtn:setEnabled(true)
		end
	else
		self.m_GetBtn:setText(MHSD_UTILS.get_resstring(2780))
	end

	self.m_ItemOutput:cleanupNonAutoChildren()

	if kind == 0 then-- ��ʱ�ʼ�
		local awardConf = BeanConfigManager.getInstance():GetTableByName("game.cactivityaward"):getRecorder(awardID)
		if awardConf then
			local index = 0
			for i = 1, 4 do
				index = (i - 1) * 4
				local itemTypeLibID = awardConf.firstClassAward[index]
				local itemNum = awardConf.firstClassAward[index + 1]
                if itemTypeLibID~= nil and itemNum ~= nil then
				    if itemTypeLibID > 0 and itemNum > 0 then
					    local itemID = BeanConfigManager.getInstance():GetTableByName("item.citemtypenamelist"):getRecorder(itemTypeLibID).items[0]
					    self:AddItem(itemID, itemNum, i - 1, true)
                        self.m_index = self.m_index + 1
				    end
                end
			end
		end
	elseif kind == 1 then-- GM�ʼ�
		local index = 0
		for k, v in pairs(items) do
			local itemID = k
			local itemNum = v
			self:AddItem(itemID, itemNum, index, true)
			index = index + 1
		end
        self.m_index = index
	end
end

function FriendDialogMailContent:checkGetButtonShow()
    if self.m_index == 0 then
        self.m_GetBtn:setVisible(false)
    else
        self.m_GetBtn:setVisible(true)
    end
end

function FriendDialogMailContent:AddItem(itemID, itemNum, index, showNum)

	local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemID)
	if itemAttr then
		local namePrefix = "FMailContentItem" .. tostring(index)
		local winMgr = CEGUI.WindowManager:getSingleton()
		local itemCell = CEGUI.toItemCell(winMgr:createWindow("TaharezLook/ItemCell", namePrefix))
		self.m_ItemOutput:addChildWindow(itemCell)
		local cellSize = self.m_ItemOutput:getPixelSize()
		itemCell:setSize(CEGUI.UVector2(CEGUI.UDim(0, cellSize.height - 10), CEGUI.UDim(0, cellSize.height - 10)))

		local width = itemCell:getPixelSize().width
		local xPos = 0.0 + (width + 10.0) * index
		local yPos = 0.0
		itemCell:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, xPos), CEGUI.UDim(0.0, yPos)))

		self:AddTip(itemCell, itemAttr, itemNum, showNum)
	end
end

function FriendDialogMailContent:AddTip(itemCell, itemAttr, itemNum, showNum)
	itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttr.icon))
	itemCell:setID(itemAttr.id)
    if showNum then
        itemCell:SetTextUnit(itemNum)
        itemCell:setID2(0)
    else
        itemCell:setID2(itemNum)
    end
	itemCell:subscribeEvent("TableClick", GameItemTable.HandleShowToolTipsWithItemID)
end

return FriendDialogMailContent
