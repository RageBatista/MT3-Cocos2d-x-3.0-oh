require "logic.dialog"

InsertDlg = { }
setmetatable(InsertDlg, Dialog)
InsertDlg.__index = InsertDlg

local _instance

local YeQian_x = 353
local YeQian_y = 276

InsertDlg.eFunType=
{
    emotion=1,
    normalChat=2,
    sell = 3,
    history=4,
    item=5,
    pet=6,
    task=7

}

function InsertDlg.getInstance()
	if not _instance then
		_instance = InsertDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function InsertDlg.getInstanceAndShow()
	if not _instance then
		_instance = InsertDlg:new()

		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function InsertDlg.getInstanceNotCreate()
	return _instance
end

function InsertDlg:clearData()
    self.pTarget = nil
    self.callBack = nil
    self.mapFunBtn = {}

end

function InsertDlg.DestroyDialog()
    if _instance then
	    if not _instance.m_bCloseIsHide then
            _instance:clearData()
		    _instance:OnClose()
		    _instance = nil
	    else
		    _instance:ToggleOpenClose()
	    end
    end
end

function InsertDlg.ToggleOpenClose()
	if not _instance then
		_instance = InsertDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function InsertDlg.GetLayoutFileName()
	return "insetdialog.layout"
end

function InsertDlg:new()
	local self = { }
	self = Dialog:new()
	setmetatable(self, InsertDlg)
    self:clearData()
	return self
end



function InsertDlg:OnCreate()
	Dialog.OnCreate(self)
    self:GetWindow():setRiseOnClickEnabled(false)

	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_pInsetdialog = winMgr:getWindow("insetdialog");


	self.m_pInsetPane_main = CEGUI.toScrollablePane(winMgr:getWindow("insetdialog/scorllview"))
	local s = self.m_pInsetPane_main:getPixelSize()
	self.m_ContentPaneWidth = s.width
	self.m_pInsetPane_main:EnableHorzScrollBar(true)
	self.m_pInsetPane_main:EnableVertScrollBar(false)
	self.m_pInsetPane_main:EnablePageScrollMode(true)
	self.m_pInsetPane_main:setContentPaneAutoSized(false)
	self.m_pInsetPane_main:setContentPaneArea(CEGUI.Rect(0, 0, s.width * 5, s.height))


	self.m_pInsetPane_main:subscribeEvent("PrePage", InsertDlg.HandlePrevPage, self)
	self.m_pInsetPane_main:subscribeEvent("ContentPaneScrolled", InsertDlg.HandleNextPage, self)

	
	self.m_pInsetdialog_GroupButton1 = CEGUI.toGroupButton(winMgr:getWindow("insetdialog/GroupButton1"))
	self.m_pInsetdialog_GroupButton2 = CEGUI.toGroupButton(winMgr:getWindow("insetdialog/GroupButton2"))
    self.m_pInsetdialog_GroupButton3 = CEGUI.toGroupButton(winMgr:getWindow("insetdialog/GroupButton3"))
	self.m_pInsetdialog_GroupButton4 = CEGUI.toGroupButton(winMgr:getWindow("insetdialog/GroupButton4"))
	self.m_pInsetdialog_GroupButton5 = CEGUI.toGroupButton(winMgr:getWindow("insetdialog/GroupButton7"))
	self.m_pInsetdialog_GroupButton6 = CEGUI.toGroupButton(winMgr:getWindow("insetdialog/GroupButton5"))
    self.m_pInsetdialog_GroupBtnStall = CEGUI.toGroupButton(winMgr:getWindow("insetdialog/GroupButtonbaitan"))

    self.mapFunBtn[InsertDlg.eFunType.emotion] ={}
    self.mapFunBtn[InsertDlg.eFunType.emotion].btn = self.m_pInsetdialog_GroupButton1
    self.mapFunBtn[InsertDlg.eFunType.emotion].label = winMgr:getWindow("insetdialog/name1")

    self.mapFunBtn[InsertDlg.eFunType.normalChat] = {}
    self.mapFunBtn[InsertDlg.eFunType.normalChat].btn = self.m_pInsetdialog_GroupButton4
    self.mapFunBtn[InsertDlg.eFunType.normalChat].label = winMgr:getWindow("insetdialog/name2")

    self.mapFunBtn[InsertDlg.eFunType.sell] = {} 
    self.mapFunBtn[InsertDlg.eFunType.sell].btn = self.m_pInsetdialog_GroupBtnStall
    self.mapFunBtn[InsertDlg.eFunType.sell].label = winMgr:getWindow("insetdialog/name7")

    self.mapFunBtn[InsertDlg.eFunType.history] = {}
    self.mapFunBtn[InsertDlg.eFunType.history].btn = self.m_pInsetdialog_GroupButton3
    self.mapFunBtn[InsertDlg.eFunType.history].label = winMgr:getWindow("insetdialog/name3")

    self.mapFunBtn[InsertDlg.eFunType.item] = {}
    self.mapFunBtn[InsertDlg.eFunType.item].btn = self.m_pInsetdialog_GroupButton2
    self.mapFunBtn[InsertDlg.eFunType.item].label = winMgr:getWindow("insetdialog/name4")

    self.mapFunBtn[InsertDlg.eFunType.pet] = {} 
    self.mapFunBtn[InsertDlg.eFunType.pet].btn = self.m_pInsetdialog_GroupButton6
    self.mapFunBtn[InsertDlg.eFunType.pet].label = winMgr:getWindow("insetdialog/name6")

    self.mapFunBtn[InsertDlg.eFunType.task] = {}
    self.mapFunBtn[InsertDlg.eFunType.task].btn = self.m_pInsetdialog_GroupButton5
    self.mapFunBtn[InsertDlg.eFunType.task].label = winMgr:getWindow("insetdialog/name5")


	self.m_pInsetdialog_xiala = CEGUI.toPushButton(winMgr:getWindow("insetdialog/xiala"))


	self.m_pInsetdialog_GroupButton3:subscribeEvent("SelectStateChanged", InsertDlg.HandleSelectHistoryTab, self)
	self.m_pInsetdialog_GroupButton2:subscribeEvent("SelectStateChanged", InsertDlg.HandleSelectItemTab, self)
	self.m_pInsetdialog_GroupButton1:subscribeEvent("SelectStateChanged", InsertDlg.HandleSelectEmotionTab, self)
	self.m_pInsetdialog_GroupButton4:subscribeEvent("SelectStateChanged", InsertDlg.HandleSelectExpression, self)
	self.m_pInsetdialog_GroupButton5:subscribeEvent("SelectStateChanged", InsertDlg.HandleSelectMission, self)
	self.m_pInsetdialog_GroupButton6:subscribeEvent("SelectStateChanged", InsertDlg.HandleSelectPet, self)
    self.m_pInsetdialog_GroupBtnStall:subscribeEvent("SelectStateChanged", InsertDlg.HandleSelectStall, self)
	self.m_pInsetdialog_xiala:subscribeEvent("Clicked", InsertDlg.HandleDialogXiaLa, self)

	-- 页签的实现----杨斌
	self.m_pYeqianImg = winMgr:createWindow("TaharezLook/StaticImage", "OnlyName")
	self.m_pYeqianImg:setProperty("Image", "set:ccui1 image:tm")
	self.m_pYeqianImg:setWidth(CEGUI.UDim(0, 20))
	self.m_pYeqianImg:setHeight(CEGUI.UDim(0, 20))

	self.m_pInsetdialog:addChildWindow(self.m_pYeqianImg)

	self.m_pYeqianImg:setXPosition(CEGUI.UDim(20, YeQian_x))
	self.m_pYeqianImg:setYPosition(CEGUI.UDim(20, YeQian_y))

	self.m_pYeqianDi = { }
	self.m_pYeqianDi[0] = winMgr:getWindow("insetdialog/lightback/1")
	self.m_pYeqianDi[0]:setVisible(true)
	self.m_pYeqianDi[1] = winMgr:getWindow("insetdialog/lightback/2")
	self.m_pYeqianDi[1]:setVisible(true)
	self.m_pYeqianDi[2] = winMgr:getWindow("insetdialog/lightback/3")
	self.m_pYeqianDi[2]:setVisible(true)
	self.m_pYeqianDi[3] = winMgr:getWindow("insetdialog/lightback/4")
	self.m_pYeqianDi[3]:setVisible(true)
	self.m_pYeqianDi[4] = winMgr:getWindow("insetdialog/lightback/5")
	self.m_pYeqianDi[4]:setVisible(true)

	self.pageId = 0

	self.m_pInsetdialog_GroupButton1:setSelected(true)
	self.m_pInsetdialog:activate()


	self.m_PrveStr = ""
	self.willCheckTipsWnd = false


end


function InsertDlg:refreshFunctionBtn(vShowType)
        
    for nType,funData  in pairs(self.mapFunBtn) do
        funData.btn:setVisible(false)
        funData.label:setVisible(false)
    end

    for k,nType in pairs(vShowType) do
       local funData = self.mapFunBtn[nType]
       if funData then
             funData.btn:setVisible(true)
            funData.label:setVisible(true)
       end
    end    
end



function InsertDlg:setDelegate(pTarget,callBack)
    self.pTarget = pTarget
    self.callBack = callBack

end


--清理子控件
function InsertDlg:Clear(isUseRichEditBox)
	self.m_pInsetPane_main:setVisible(not isUseRichEditBox)
	self.m_pInsetPane_main:cleanupNonAutoChildren()
	self.m_pInsetPane_main:activate()
end

function InsertDlg:HandleNextPage(e)
	local pos = self.m_pInsetPane_main:getHorizontalScrollPosition()
	local PreW = 1 / (self.pageId + 1)
	for i = 0, 4 do
		if pos > 0 + i * PreW and pos < PreW + i * PreW then
			self.m_pYeqianImg:setXPosition(CEGUI.UDim(0, YeQian_x + 38 * i))
			self.m_pYeqianImg:setYPosition(CEGUI.UDim(0, YeQian_y))
		end
	end
end

function InsertDlg:HandlePrevPage(e)

end

--关闭对话框按钮----杨斌
function InsertDlg:HandleDialogXiaLa(e)
	self:Clear(false)
	InsertDlg.DestroyDialog()
end

-- 表情标签
function InsertDlg:HandleSelectEmotionTab(e)
	self:Clear(false)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local count = gGetEmotionManager():GetEmotionsCount() - 100 + 1
	local index = 0
	local colCount = 8
	local rowCount = 4

	local sz = self.m_pInsetPane_main:getPixelSize()
	local wndWidth = sz.width / colCount
	local wndHeight = sz.height / rowCount

	for i = 0, count - 1 do
		local is = gGetEmotionManager():GetImageSetIndexByIDAndFrame(100 + index, 0)
		local name = "set:emotionicon" .. is .. " image:" ..(100000 + index * 100)

		local pButton = CEGUI.toPushButton(winMgr:createWindow("TaharezLook/ImageButton", "" .. index))
		pButton:setProperty("NormalImage", name)
		pButton:setProperty("PushedImage", name)

		UseImageSourceSize(pButton, name)
		pButton:setID(index)

		pButton:subscribeEvent("Clicked", InsertDlg.OnClickEmotion, self)

		self.m_pInsetPane_main:addChildWindow(pButton)

		self.pageId = math.floor(index / (colCount*rowCount))

		local colId = math.floor(index % colCount)
		local rowId = math.floor(index / colCount)

		local xPos = colId * wndWidth
		local yPos =(rowId % rowCount) * wndHeight

		xPos = xPos + self.pageId * sz.width

		local offsetX = pButton:getPixelSize().width/2;

		pButton:setXPosition(CEGUI.UDim(0, xPos - offsetX + 40))
		pButton:setYPosition(CEGUI.UDim(0, yPos + 5))

		index = index + 1
	end

	for i = 0, 4 do
		if i <= self.pageId then
			self.m_pYeqianDi[i]:setVisible(true)
		else
			self.m_pYeqianDi[i]:setVisible(false)
		end
	end

	local s = self.m_pInsetPane_main:getPixelSize()
	self.m_pInsetPane_main:setContentPaneArea(CEGUI.Rect(0, 0, self.m_ContentPaneWidth + self.m_ContentPaneWidth * self.pageId, s.height))

end

-- //道具标签
function InsertDlg:HandleSelectItemTab(e)

	self:Clear(false)

	local colCount = 8
	local rowCount = 3

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	if roleItemManager then
		local winMgr = CEGUI.WindowManager:getSingleton()
		local itemVec = roleItemManager:GetItemListByBag(fire.pb.item.BagTypes.BAG)
		local sz = self.m_pInsetPane_main:getPixelSize()
		local wndWidth = sz.width / colCount
		local wndHeight = sz.height / rowCount
		local index = 0

		for i = 0, itemVec:size() -1 do
			local pItem = itemVec[i]

			if pItem then
				local pBox = CEGUI.toItemCell(winMgr:loadWindowLayout("insetcell.layout", "" .. index))
				self.m_pInsetPane_main:addChildWindow(pBox)
				pBox:setID(pItem:GetThisID())
				pBox:subscribeEvent("MouseButtonDown", InsertDlg.PreOnClickItem, self)
				pBox:subscribeEvent("MouseButtonUp", InsertDlg.OnClickItem, self)
				pBox:SetImage(gGetIconManager():GetImageByID(pItem:GetIcon()))

				SetItemCellBoundColorByQulityItem(pBox, pItem:GetBaseObject().nquality)

				if pItem:isTreasure() then
					pBox:SetCornerImageAtPos("ccui1", "newzp", 0, 1)
				end

				self.pageId = math.floor(index / (colCount*rowCount))

				local colId = math.floor(index % colCount)
				local rowId = math.floor(index / colCount)

				local xPos = colId * wndWidth
				local yPos =(rowId % rowCount) * wndHeight

				xPos = xPos + self.pageId * sz.width

				pBox:setXPosition(CEGUI.UDim(0, xPos + 3))
				pBox:setYPosition(CEGUI.UDim(0, yPos + 5))

				index = index + 1

			end
		end

		for i = 0, 4 do
			if i <= self.pageId then
				self.m_pYeqianDi[i]:setVisible(true)
			else
				self.m_pYeqianDi[i]:setVisible(false)
			end
		end

		local s = self.m_pInsetPane_main:getPixelSize()
		self.m_pInsetPane_main:setContentPaneArea(CEGUI.Rect(0, 0, self.m_ContentPaneWidth + self.m_ContentPaneWidth * self.pageId, s.height))
	end
end

-- //历史消息标签
function InsertDlg:HandleSelectHistoryTab(e)
	self:Clear(false)

	local colCount = 3
	local rowCount = 3

	local vecHistory = CChatOutputDialog.getInstanceNotCreate():GetChatHistory()
	local sz = self.m_pInsetPane_main:getPixelSize()
	local wndWidth = sz.width / colCount
	local wndHeight = sz.height / rowCount
	local index = 0

	local winMgr = CEGUI.WindowManager:getSingleton()
	for i = #vecHistory, 1, -1 do
		local pButton = CEGUI.toPushButton(winMgr:loadWindowLayout("insetchatcell.layout", "" .. index))
		self.m_pInsetPane_main:addChildWindow(pButton)
		pButton:setID(index)
		pButton:setWidth(CEGUI.UDim(0, wndWidth - 6))
		pButton:setHeight(CEGUI.UDim(0, wndHeight - 10))
		pButton:subscribeEvent("Clicked", InsertDlg.OnClickHistory, self)
		local richText = CEGUI.toRichEditbox(winMgr:getWindow("" .. index .. "insetchatcell/main"))
		richText:SetEmotionScale(CEGUI.Vector2(1, 1))

		richText:setWordWrapping(false)
		richText:AppendParseText(CEGUI.String(vecHistory[i].str), false)
		if vecHistory[i].links then
			richText:setUserString("name", vecHistory[i].links.name)
			richText:setUserString("link", vecHistory[i].links.link)
			if vecHistory[i].links.key then
				richText:setUserString("key", vecHistory[i].links.key)
			else
				richText:setUserString("key", nil)
			end
			
		end
		richText:Refresh()
		richText:setMousePassThroughEnabled(true)
		richText:setReadOnly(true)

		self.pageId = math.floor(index / (colCount*rowCount))

		local colId = math.floor(index % colCount)
		local rowId = math.floor(index / colCount)

		local xPos = colId * wndWidth
		local yPos =(rowId % rowCount) * wndHeight

		xPos = xPos + self.pageId * sz.width

		pButton:setXPosition(CEGUI.UDim(0, xPos + 3))
		pButton:setYPosition(CEGUI.UDim(0, yPos + 5))

		index = index + 1
	end

	for i = 0, 4 do
		if i <= self.pageId then
			self.m_pYeqianDi[i]:setVisible(true)
		else
			self.m_pYeqianDi[i]:setVisible(false)
		end
	end

	local s = self.m_pInsetPane_main:getPixelSize()
	self.m_pInsetPane_main:setContentPaneArea(CEGUI.Rect(0, 0, self.m_ContentPaneWidth + self.m_ContentPaneWidth * self.pageId, s.height))
end

-- //常用语
function InsertDlg:HandleSelectExpression(e)
	self:Clear(false)

	local colCount = 3
	local rowCount = 3

	local ids = std.vector_int_()
	GameTable.chat.GetCquickchatTableInstance():getAllID(ids)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local sz = self.m_pInsetPane_main:getPixelSize()
	local wndWidth = sz.width / colCount
	local wndHeight = sz.height / rowCount
	local index = 0
	for id = 0, ids:size() -1 do
		local oneText = GameTable.chat.GetCquickchatTableInstance():getRecorder(ids[id]).tips

		local pushBtn = CEGUI.toPushButton(winMgr:loadWindowLayout("insetchatcell.layout", "" .. index))
		self.m_pInsetPane_main:addChildWindow(pushBtn)
		pushBtn:setID(index)
		pushBtn:subscribeEvent("Clicked", InsertDlg.OnExpression, self)
		pushBtn:setWidth(CEGUI.UDim(0, wndWidth - 6))
		pushBtn:setHeight(CEGUI.UDim(0, wndHeight - 10))
		local richText = CEGUI.toRichEditbox(winMgr:getWindow("" .. index .. "insetchatcell/main"))
		local text = "<T t=\"" .. oneText .. "\" c=\"ff8c5e2a\"></T>"
		richText:setWordWrapping(false)
		richText:AppendParseText(CEGUI.String(text))
		richText:Refresh()
		richText:setMousePassThroughEnabled(true)
		richText:setReadOnly(true)

		self.pageId = math.floor(index / (colCount*rowCount))

		local colId = math.floor(index % colCount)
		local rowId = math.floor(index / colCount)

		local xPos = colId * wndWidth
		local yPos =(rowId % rowCount) * wndHeight

		xPos = xPos + self.pageId * sz.width

		pushBtn:setXPosition(CEGUI.UDim(0, xPos + 3))
		pushBtn:setYPosition(CEGUI.UDim(0, yPos + 5))

		index = index + 1
	end

	for i = 0, 4 do
		if i <= self.pageId then
			self.m_pYeqianDi[i]:setVisible(true)
		else
			self.m_pYeqianDi[i]:setVisible(false)
		end
	end

	local s = self.m_pInsetPane_main:getPixelSize()
	self.m_pInsetPane_main:setContentPaneArea(CEGUI.Rect(0, 0, self.m_ContentPaneWidth + self.m_ContentPaneWidth * self.pageId, s.height))
end

-- //任务标签
function InsertDlg:HandleSelectMission(e)
	self:Clear(false)

	local colCount = 3
	local rowCount = 3

	local winMgr = CEGUI.WindowManager:getSingleton()
	local sz = self.m_pInsetPane_main:getPixelSize()
	local wndWidth = sz.width / colCount;
	local wndHeight = sz.height / rowCount;

	local tracequestids, tracequests = GetTaskManager():GetTraceQuestListForLua()

	local index = 0
	for i = 0, tracequestids:size() -1 do
		local continue = false
		local SpecialQuest = GetTaskManager():GetSpecialQuest(tracequestids[i])
		local missionInfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(tracequestids[i])

		local text = "<T t=\""
		if SpecialQuest then
			text = text .. SpecialQuest.name
		elseif missionInfo.id >= 0 then
			text = text .. missionInfo.MissionName
		else
			continue = true
		end

		if continue == false then
			local pButton = CEGUI.toPushButton(winMgr:loadWindowLayout("insetchatcell.layout", "" .. index))
			self.m_pInsetPane_main:addChildWindow(pButton)
			pButton:setID(tracequestids[i])
			pButton:subscribeEvent("Clicked", InsertDlg.OnClickMission, self)
			pButton:setWidth(CEGUI.UDim(0, wndWidth - 6))
			pButton:setHeight(CEGUI.UDim(0, wndHeight - 10))
			local richText = CEGUI.toRichEditbox(winMgr:getWindow("" .. index .. "insetchatcell/main"))

			text = text .. "\" c=\"ff8c5e2a\"></T>"

			richText:setWordWrapping(false)
			richText:AppendParseText(CEGUI.String(text))
			richText:Refresh()
			richText:setMousePassThroughEnabled(true)
			richText:setReadOnly(true)

			self.pageId = math.floor(index / (colCount*rowCount))

			local colId = math.floor(index % colCount)
			local rowId = math.floor(index / colCount)

			local xPos = colId * wndWidth
			local yPos =(rowId % rowCount) * wndHeight

			xPos = xPos + self.pageId * sz.width

			pButton:setXPosition(CEGUI.UDim(0, xPos + 3))
			pButton:setYPosition(CEGUI.UDim(0, yPos + 5))

			index = index + 1
		end
	end

	for i = 0, 4 do
		if i <= self.pageId then
			self.m_pYeqianDi[i]:setVisible(true)
		else
			self.m_pYeqianDi[i]:setVisible(false)
		end
	end

	local s = self.m_pInsetPane_main:getPixelSize()
	self.m_pInsetPane_main:setContentPaneArea(CEGUI.Rect(0, 0, self.m_ContentPaneWidth + self.m_ContentPaneWidth * self.pageId, s.height))
end

-- //宠物标签
function InsertDlg:HandleSelectPet(e)
	self:Clear(false)

	local colCount = 3
	local rowCount = 3

	local winMgr = CEGUI.WindowManager:getSingleton()
	local sz = self.m_pInsetPane_main:getPixelSize()
	local wndWidth = sz.width / colCount
	local wndHeight = sz.height / rowCount

	for i = 0, MainPetDataManager.getInstance():GetPetNum() -1 do
		local petData = MainPetDataManager.getInstance():getPet(i + 1)
		local pCell = CEGUI.toPushButton(winMgr:loadWindowLayout("insetpetcell.layout", "" .. i))
		pCell:setID(petData.key)
		pCell:setWidth(CEGUI.UDim(0, wndWidth - 6))
		--pCell:setHeight(CEGUI.UDim(0, wndHeight - 20))
		pCell:subscribeEvent("Clicked", InsertDlg.OnClickPet, self)
		self.m_pInsetPane_main:addChildWindow(pCell)
		local iconWnd = CEGUI.toItemCell(winMgr:getWindow("" .. i .. "insetpetcell/itemcell"));
		iconWnd:setMousePassThroughEnabled(true)
		local nameWnd = winMgr:getWindow("" .. i .. "insetpetcell/text/name")
		nameWnd:setMousePassThroughEnabled(true) 
		local levelWnd = winMgr:getWindow("" .. i .. "insetpetcell/text/dengji")
		levelWnd:setMousePassThroughEnabled(true)
		local scordWnd = winMgr:getWindow("" .. i .. "insetpetcell/text/fenshu")
		scordWnd:setMousePassThroughEnabled(true)

		local table = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petData:GetShapeID())
		iconWnd:SetImage(gGetIconManager():GetImageByID(table.littleheadID))
		setPetItemCellBackgroundByQuality(iconWnd, petData.baseid)

		--nameWnd:setProperty("TextColours", "FFFFFFFF")
		--nameWnd:setProperty("TextColours", "ff743a0f")
		--nameWnd:setText(petData:GetPetNameTextColour() .. petData.name)
		nameWnd:setProperty("TextColours", "ff553923")
        nameWnd:setText(petData.name)
		local levelString = tostring(petData:getAttribute(fire.pb.attr.AttrType.LEVEL))
		levelWnd:setText(levelString)
		local scoreString = tostring(petData.score)
		scordWnd:setText(scoreString)

		self.pageId = math.floor(i / (colCount*rowCount))

		local colId = math.floor(i % colCount)
		local rowId = math.floor(i / colCount)

		local xPos = colId * wndWidth;
		local yPos =(rowId % rowCount) * wndHeight;

		xPos = xPos + self.pageId * sz.width;

		pCell:setXPosition(CEGUI.UDim(0, xPos + 3))
		pCell:setYPosition(CEGUI.UDim(0, yPos + 0))

	end

	for i = 0, 4 do
		if i <= self.pageId then
			self.m_pYeqianDi[i]:setVisible(true)
		else
			self.m_pYeqianDi[i]:setVisible(false)
		end
	end

	local rt = self.m_pInsetPane_main:getContentPaneArea()
	self.m_pInsetPane_main:setContentPaneArea(CEGUI.Rect(0, 0, self.m_ContentPaneWidth + self.m_ContentPaneWidth * self.pageId, rt.bottom))
end

-- //摆摊
function InsertDlg:HandleSelectStall(e)
    self:Clear(false)

    --request data
    --attention goods
    local p = require("protodef.fire.pb.shop.cmarketattentionbrowse"):new()
	p.attentype = 1 --GROUP_BUY
	LuaProtocolManager:send(p)

    if not IsPointCardServer() then
	    p = require("protodef.fire.pb.shop.cmarketattentionbrowse"):new()
	    p.attentype = 2 --GROUP_SHOW
	    LuaProtocolManager:send(p)
    end

    --on sell goods
    local p = require("protodef.fire.pb.shop.cmarketcontainerbrowse"):new()
	LuaProtocolManager:send(p)

    self.stallGoods = {}
    self.curStallGoodsCount = 0 --已经排布的商品序号
end

function InsertDlg:PreOnClickItem(e)
	local tipsdlg = require("logic.tips.commontipdlg").getInstanceNotCreate()
	if tipsdlg then
		tipsdlg:GetWindow():moveToFront()
	end

	self.willCheckTipsWnd = true
end

function InsertDlg:OnClickItem(e)

    local wndArg = CEGUI.toWindowEventArgs(e)
    if not wndArg.window then
        return
    end
    self:GetWindow():moveToFront()
    local nId = wndArg.window:getID()
    local nType = InsertDlg.eFunType.item
    if self.pTarget and self.callBack then
        self.callBack(self.pTarget,self,nType,nId)
    end	
	
--[[
	local wndArg = CEGUI.toWindowEventArgs(e)

	local richText = GetChatManager():GetEmotionTargetBox()

--	richText:Clear()
--	richText:getHorzScrollbar():setScrollPosition(0)
--	richText:Refresh()

	if wndArg.window then
		local key = wndArg.window:getID()
		if key > 0 then
			local roleItemManager = require("logic.item.roleitemmanager").getInstance()
			local pItem = roleItemManager:GetBagItem(key)
			if pItem then
				local strName = pItem:GetName()
				local roleID = gGetDataManager():GetMainCharacterID()
				local baseID = pItem:GetBaseObject().id
				if GetChatManager() then

					local color = pItem:GetNameColour()
					if pItem:GetBaseObject().nquality == 1 then
						color = "ff50321a"
					end

					local str = richText:GenerateParseText()

					local aaa = string.len(strName)/3
					local bbb = richText:GetCharCount()
					local ccc = string.len("\"[" .. strName .. "]\"")
					if richText:GetCharCount() + string.len(strName)/3 + 2 >= CHAT_INPUT_CHAR_COUNT_MAX then
						local tips = MHSD_UTILS.get_resstring(1449)
						GetCTipsManager():AddMessageTip(tips)
						return
					end

					local text =
					"<P t=\"[" .. strName ..
					"]\" roleid=\"" .. roleID ..
					"\" type=\"" .. tonumber(1) ..
					"\" key=\"" .. key ..
					"\" baseid=\"" .. baseID ..
					"\" shopid=\"" .. tonumber(0) ..
					"\" counter=\"" .. tonumber(1) ..
					"\" bind=\"" .. tonumber(0) ..
					"\" loseefftime=\"" .. tonumber(0) ..
					"\" TextColor=\"" .. color .. "\"></P>"

					local n = 0
					str, n = string.gsub(str, "<P[^<>]+></P>", text)
					if n == 0 then
						str = str .. text
					end

					richText:Clear()
					richText:AppendParseText(CEGUI.String(str))
					richText:Refresh()

					-- GetChatManager():AddObjectTipsLinkToCurInputBox(strName, roleID, 1, key, baseID, 0, 1, true, 0, 0, CEGUI.PropertyHelper:stringToColour(color))

					self:GetWindow():moveToFront()

					local tipsdlg = require("logic.tips.commontipdlg").getInstanceNotCreate()
					if tipsdlg then
						tipsdlg:GetWindow():moveToFront()
					end
					-- 请求物品tips
					GetChatManager():HandleTipsLinkClick(strName, roleID, 1, key, baseID, 0, 1, CEGUI.PropertyHelper:stringToColour(color), 0, 0)
				end
			end
		end
	end
--]]
end

function InsertDlg:OnClickHistory(e)

    local wndArg = CEGUI.toWindowEventArgs(e)
    if not wndArg.window then
        return
    end
    local nId = wndArg.window:getID()
    local nType = InsertDlg.eFunType.history
    if self.pTarget and self.callBack then
        self.callBack(self.pTarget,self,nType,nId)
    end	
--[[
	local wndArg = CEGUI.toWindowEventArgs(e)
	if wndArg.window then
		local key = wndArg.window:getID()
		local winMgr = CEGUI.WindowManager:getSingleton();
		local pBox = CEGUI.toRichEditbox(winMgr:getWindow(key .. "insetchatcell/main"))
		local parseText = pBox:GenerateParseText()
		local richText = GetChatManager():GetEmotionTargetBox()
		if richText then
			-- 防止字符过长崩溃的问题-----杨斌
			local la = pBox:GetCharCount() + pBox:GetEmotionNum()
			local lb = richText:GetCharCount() + richText:GetEmotionNum()
			if la + lb > CHAT_INPUT_CHAR_COUNT_MAX then
				GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1449));
			else
				richText:AppendParseText(CEGUI.String(parseText))
				richText:Refresh()
				richText:SetCaratEnd()
			end

			self:HandleDialogXiaLa(e)
		end
	end
--]]
end

function InsertDlg:OnExpression(e)

    local wndArg = CEGUI.toWindowEventArgs(e)
    if not wndArg.window then
        return
    end
    local nId = wndArg.window:getID()
    local nType = InsertDlg.eFunType.normalChat
    if self.pTarget and self.callBack then
        self.callBack(self.pTarget,self,nType,nId)
    end
--[[
	local wndArg = CEGUI.toWindowEventArgs(e)
	if wndArg.window then
		local key = wndArg.window:getID()
		local winMgr = CEGUI.WindowManager:getSingleton()
		local richButton = CEGUI.toRichEditbox(winMgr:getWindow(key .. "insetchatcell/main"))
		local parseText = richButton:GetPureText()
		local richText = GetChatManager():GetEmotionTargetBox()
		if richText then
			-- 重新着色
			local text = "<T t=\"" .. parseText .. "\"" .. " c=\"" .. CEGUI.PropertyHelper:colourToString(richText:GetColourRect().top_left) .. "\"></T>"

			-- 防止字符过长崩溃的问题-----杨斌
			local la = richButton:GetCharCount() + richButton:GetEmotionNum()
			local lb = richText:GetCharCount() + richText:GetEmotionNum()
			if la + lb > richText:getMaxTextLength() then
				GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1449).c_str());
			else
				richText:AppendParseText(CEGUI.String(text))
				richText:Refresh()
				richText:SetCaratEnd()
			end

			self:HandleDialogXiaLa(e)
		end
	end
--]]
end

function InsertDlg:OnClickMission(e)
    local wndArg = CEGUI.toWindowEventArgs(e)
    if not wndArg.window then
        return
    end
    local nId = wndArg.window:getID()
    local nType = InsertDlg.eFunType.task
    if self.pTarget and self.callBack then
        self.callBack(self.pTarget,self,nType,nId)
    end
end

function InsertDlg:OnClickPet(e)

    local wndArg = CEGUI.toWindowEventArgs(e)
    if not wndArg.window then
        return
    end


    local nId = wndArg.window:getID()
    local nType = InsertDlg.eFunType.pet
    if self.pTarget and self.callBack then
        self.callBack(self.pTarget,self,nType,nId)
    end
--[[
						local richText = GetChatManager():GetEmotionTargetBox()

						if richText:GetCharCount() + string.len(tbl.name) / 3 + 2 >= CHAT_INPUT_CHAR_COUNT_MAX then
							local tips = MHSD_UTILS.get_resstring(1449)
							GetCTipsManager():AddMessageTip(tips)
							return
						end

						local str = richText:GenerateParseText()

						local text =
						"<P t=\"[" .. tbl.name ..
						"]\" roleid=\"" .. roleID ..
						"\" type=\"" .. DI.DISPLAY_PET ..
						"\" key=\"" .. id ..
						"\" baseid=\"" .. petData.baseid ..
						"\" shopid=\"" .. 0 ..
						"\" counter=\"" .. 1 ..
						"\" bind=\"" .. 0 ..
						"\" loseefftime=\"" .. 0 ..
						"\" TextColor=\"" .. tbl.colour .. "\"></P>"

						local n = 0
						str, n = string.gsub(str, "<P[^<>]+></P>", text)
						if n == 0 then
							str = str .. text
						end

						richText:Clear()
						richText:AppendParseText(CEGUI.String(str))
						richText:Refresh()

						-- GetChatManager():AddObjectTipsLinkToCurInputBox(tbl.name, roleID, DI.DISPLAY_PET, id, petData.baseid, 0, 1, true, 0, 0, nameColour)
					end
				end
			end

			self:HandleDialogXiaLa(e)
		end
	end

	DI = nil
--]]
end

function InsertDlg:OnClickEmotion(e)

	local wndArg = CEGUI.toWindowEventArgs(e)
    if not wndArg.window then
        return
    end


    local nId = wndArg.window:getID()
    local nType = InsertDlg.eFunType.emotion
    if self.pTarget and self.callBack then
        self.callBack(self.pTarget,self,nType,nId)
    end
--[[
			local id = wndArg.window:getID()

			if pTargetBox:GetEmotionNum() >= EMOTION_NUM_MAX and id ~= -1 then
				GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1449))
			else
				pTargetBox:InserEmotionInCarat(900 + id)
			end
		end
	end
--]]
end

function InsertDlg:OnClickStallGoods(e)
    
    local wndArg = CEGUI.toWindowEventArgs(e)
    if not wndArg.window then
        return
    end

    local nId = wndArg.window:getID()
    local nType = InsertDlg.eFunType.sell
    if self.pTarget and self.callBack then
        self.callBack(self.pTarget,self,nType,nId)
    end

--[[
    local richBox = GetChatManager():GetEmotionTargetBox()
    -- 防止字符过长崩溃的问题-----杨斌
	if richBox:GetCharCount() + string.len(goods.name) > richBox:getMaxTextLength() then
		GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1449)) --你输入的字数太多
		return false
	end
--]]


end

--//聊天插入摆摊
function InsertDlg:refreshStallGoods()
    if #self.stallGoods == 0 then
        return
    end

    local pageWidth = self.m_pInsetPane_main:getPixelSize().width

    for i=self.curStallGoodsCount+1, #self.stallGoods do
        local goods = self.stallGoods[i]

        local prefix = "chat" .. i

        local winMgr = CEGUI.WindowManager:getSingleton()
        local wnd = CEGUI.toGroupButton(winMgr:loadWindowLayout("insetbaitancell.layout", prefix))
        local itemcell = CEGUI.toItemCell(winMgr:getWindow(prefix .. "insetbaitancell/wupin"))
        local name = winMgr:getWindow(prefix .. "insetbaitancell/mingzi")
        local price = winMgr:getWindow(prefix .. "insetbaitancell/di")

        wnd:EnableClickAni(false)
        wnd:setID(i) --index of goods data in self.stallGoods
        wnd:subscribeEvent("MouseClick", InsertDlg.OnClickStallGoods, self)

        self.m_pInsetPane_main:addChildWindow(wnd)
        local page = math.floor((i-1)/4)
        local row = math.floor((i-1)/2) % 2
        local col = (i-1) % 2
        local s = wnd:getPixelSize()
        SetPositionOffset(wnd, pageWidth*page+col*(s.width*col+5), 15+row*(s.height+10))

	    
        price:setText(MoneyFormat(goods.price))

        if goods.itemtype == STALL_GOODS_T.ITEM then
            local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(goods.itemid)
			if itemAttr then
                goods.name = itemAttr.name

                local firstType = itemAttr.itemtypeid % 16
                if (firstType == eItemType_EQUIP or itemAttr.colour ~= "") and string.lower(itemAttr.colour) ~= "fffff2df" then
                    goods.namecolour = itemAttr.colour
                else
                    goods.namecolour = "ff50321a"
                end

                name:setProperty("TextColours", goods.namecolour)
			    name:setText(itemAttr.name)
                local image = gGetIconManager():GetImageByID(itemAttr.icon)
                SetItemCellBoundColorByQulityItem(itemcell, itemAttr.nquality, itemAttr.itemtypeid)
                itemcell:SetStyle(CEGUI.ItemCellStyle_IconInside)
				itemcell:SetImage(image)
                if itemAttr.maxNum > 1 then --可堆叠的物品
					itemcell:SetTextUnit(goods.num>1 and goods.num or "")
				elseif goods.level > 0 then
					itemcell:SetTextUnit("Lv." .. goods.level)
                else
                    itemcell:SetTextUnit("")
				end
            end
        elseif goods.itemtype == STALL_GOODS_T.PET then
			local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(goods.itemid)
            if petAttr then
                goods.name = petAttr.name
                goods.namecolour = petAttr.colour

                name:setProperty("TextColours", "FFFFFFFF")
			    name:setText("[colour=\'" .. petAttr.colour .. "\']" .. petAttr.name)
			    local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttr.modelid)
			    local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
                itemcell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
			    itemcell:SetImage(image)
                SetItemCellBoundColorByQulityPet(itemcell, petAttr.quality)
			    itemcell:SetTextUnit("")
            end
		end

        if goods.isAttentioned then
			itemcell:SetCornerImageAtPos("ccui1", "newgz", 0, 1) --显示关注角标
			
		elseif goods.itemtype == STALL_GOODS_T.PET or ShopManager:needShowRarityIcon(goods.itemtype, goods.itemid) then
			itemcell:SetCornerImageAtPos("ccui1", "newzp", 0, 1) --显示珍品角标
		else
			itemcell:SetCornerImageAtPos(nil, 0, 0)
		end
    end

    self.curStallGoodsCount = #self.stallGoods

    self.pageId = math.floor((self.curStallGoodsCount-1)/4)
    print("pageId " .. self.pageId)
    for i = 0, 4 do
		if i <= self.pageId then
			self.m_pYeqianDi[i]:setVisible(true)
		else
			self.m_pYeqianDi[i]:setVisible(false)
		end
	end

    local rt = self.m_pInsetPane_main:getContentPaneArea()
	self.m_pInsetPane_main:setContentPaneArea(CEGUI.Rect(0, 0, self.m_ContentPaneWidth + self.m_ContentPaneWidth * self.pageId, rt.bottom))
end

--检查摊位上和关注里的商品是否有重复
function InsertDlg:isStallGoodsRepeat(goods)
    local winMgr = CEGUI.WindowManager:getSingleton()
    for i=1, #self.stallGoods do
        if self.stallGoods[i].id == goods.id then
            if goods.isAttentioned then
                local prefix = "chat" .. i
                local itemcell = CEGUI.toItemCell(winMgr:getWindow(prefix .. "insetbaitancell/wupin"))
                if itemcell then
                    itemcell:SetCornerImageAtPos("shopui", "guanzhu", 0, 1) --显示关注角标
                end
            end
            return true
        end
    end
    return false
end

function InsertDlg:recvStallAttentionGoods(goodslist)
    if not self.m_pInsetdialog_GroupBtnStall:isSelected() or not self.stallGoods then
        return
    end

    for _,v in pairs(goodslist) do
        v.isAttentioned = true
        if not self:isStallGoodsRepeat(v) then
            table.insert(self.stallGoods, v)
        end
    end

    self:refreshStallGoods()
end

function InsertDlg:recvStallOnSellGoods(goodslist)
    if not self.m_pInsetdialog_GroupBtnStall:isSelected() or not self.stallGoods then
        return
    end

    for _,v in pairs(goodslist) do
        if not self:isStallGoodsRepeat(v) then
            table.insert(self.stallGoods, v)
        end
    end

    self:refreshStallGoods()
end

return InsertDlg