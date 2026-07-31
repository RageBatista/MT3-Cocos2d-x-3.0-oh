require "logic.dialog"

SendGiftDialog = {}
setmetatable(SendGiftDialog, Dialog)
SendGiftDialog.__index = SendGiftDialog

local buttonSendItemID = 1
local buttonSendGiftID = 2

local ITEM_TYPE_FOOD = -111 --290 --烹饪
local ITEM_TYPE_DRUG_THREE = -111 --307 --三级药
local ITEM_TYPE_UP_ITEM = -111--358  --强化符

local _instance
function SendGiftDialog.getInstance()
	if not _instance then
		_instance = SendGiftDialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function SendGiftDialog.getInstanceAndShow()
	if not _instance then
		_instance = SendGiftDialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function SendGiftDialog.getInstanceNotCreate()
	return _instance
end

function SendGiftDialog.DestroyDialog()
	if _instance then 
	_instance.m_buttonSendGift.animation:stop()
	_instance.m_liuyanSendButton.animation:stop()
		if not _instance.m_bCloseIsHide then
            gGetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.eventItemNumChange)
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function SendGiftDialog.ToggleOpenClose()
	if not _instance then
		_instance = SendGiftDialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function SendGiftDialog.GetLayoutFileName()
	return "friendzengsongdialog.layout"
end

function SendGiftDialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, SendGiftDialog)
	return self
end

function SendGiftDialog:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.5)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function SendGiftDialog:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_contactPane = CEGUI.toScrollablePane(winMgr:getWindow("Frienzengsongdialog/liebiao/diban/friendlist"))

    self.m_buttonSendItem = CEGUI.toGroupButton(winMgr:getWindow("Frienzengsongdialog/chatframe/anniu/daoju"))
    self.m_buttonSendItem:setID(buttonSendItemID)
    self.m_buttonSendItem:setSelected(true, false)
    self.m_buttonSendItem:subscribeEvent("SelectStateChanged", SendGiftDialog.HandleSelectStateChanged, self)
	


    self.m_GroupButtonSendGift = CEGUI.toGroupButton(winMgr:getWindow("Frienzengsongdialog/chatframe/anniu/liwu"))
    self.m_GroupButtonSendGift:setID(buttonSendGiftID)
    self.m_GroupButtonSendGift:subscribeEvent("SelectStateChanged", SendGiftDialog.HandleSelectStateChanged, self)

    self.m_itemPane = CEGUI.toScrollablePane(winMgr:getWindow("Frienzengsongdialog/chatbackgroundtips/scrollframe"))

    self.m_liuyanFujia = winMgr:getWindow("Frienzengsongdialog/chatframe/xinxi/fujia")
    self.m_liuyanFrame = winMgr:getWindow("Frienzengsongdialog/chatframe/xinxi/wzd")
    self.m_liuyanTip = winMgr:getWindow("Frienzengsongdialog/chatframe/xinxi/text")
    self.m_liuyanSendButton = CEGUI.toPushButton(winMgr:getWindow("Frienzengsongdialog/chatframe/xinxi/send"))
	self:addButtonAnimation(self.m_liuyanSendButton, "studyBtnPress")
    self.m_liuyanSendButton:subscribeEvent("Clicked", SendGiftDialog.HandleSendGiftWidthChat, self)
    

    self.m_checkSendNum = CEGUI.Window.toProgressBar(winMgr:getWindow("Frienzengsongdialog/chatframe/jiaohu/jindutiao"))
    self.m_checkSendNum:setProgress(0)
    self.m_sendMax = 5

    self.m_tipImage = winMgr:getWindow("Frienzengsongdialog/chatbackgroundtips/img")
    self.m_tipText = winMgr:getWindow("Frienzengsongdialog/chatbackgroundtips/text")
    self.m_tipTextbg = winMgr:getWindow("Frienzengsongdialog/chatbackgroundtips/textbgimg")

    self.m_buttonSendGift = CEGUI.toPushButton(winMgr:getWindow("Frienzengsongdialog/chatframe/jiaohu/zengsong"))
	self:addButtonAnimation(self.m_buttonSendGift, "studyBtnPress")
    self.m_buttonSendGift:subscribeEvent("Clicked", SendGiftDialog.handleSendItemClick, self)

    self.m_tishiText = winMgr:getWindow("Frienzengsongdialog/chatframe/jiaohu/tishi")

    self.m_pChatInputBox = CEGUI.toRichEditbox(winMgr:getWindow("Frienzengsongdialog/chatframe/xinxi/ri"))

    self.m_contactList = {}

    self.m_sendGiftItemID = -1 --赠送礼物的id
    self.m_sendGiftItemNum = -1 --赠送礼物的数量

    self.m_toSendItem = {} --赠送物品列表 item
    self.m_giftMap = {}  --保存自身的礼物信息 gift
    self.m_dataKeyValue = {}  --roleid 和 赠送数量的 key, value 键值对
    self.m_saveCells = {} --所有的item
    self.m_currentSelectedRoleID = 0
    self.m_currentPageType = 0

    self.m_sendGiftWithMsg = ""
    self.m_sendGiftCDing = false
    self.m_ignoreSex = false
    self.m_ignoreFriendShipe = false
    self.m_ignoreFriend3000value = false

    self.m_allGiftCell = {}

    self.roleItemManager = require("logic.item.roleitemmanager").getInstance()

    self:refreshToSendItem()
    self:setGiftPageButtomVisible(false)

    self.eventItemNumChange = gGetRoleItemManager():InsertLuaItemNumChangeNotify(SendGiftDialog.onEventBagItemNumChange)

    local send = require "protodef.fire.pb.friends.cgiveinfolist":new()
    require "manager.luaprotocolmanager":send(send)
end

function SendGiftDialog.onEventBagItemNumChange(bagid, itemkey, itembaseid)
    if _instance then
        local winMgr = CEGUI.WindowManager:getSingleton()
        for _, v in pairs(_instance.m_allGiftCell) do
            if winMgr:isWindowPresent("text_itemCount_inGift_"..v:getID()) then
                local textWnd = winMgr:getWindow("text_itemCount_inGift_"..v:getID())
                local itemNum = _instance.roleItemManager:GetItemNumByBaseIDWithNoBind(v:getID())
                textWnd:setText("0/"..itemNum)
            end
        end
    end
end

function SendGiftDialog:HandleSelectStateChanged(args)
    local selectID = CEGUI.toWindowEventArgs(args).window:getID()
    if selectID == buttonSendItemID then
        self:setButtomVisible(true)
        self:refreshToSendItem()
        self:setGiftPageButtomVisible(false)
        self.m_currentPageType = 0
        self:refreshCurrentPageOfSendItem()
    elseif selectID == buttonSendGiftID then
        self.m_toSendItem = {}
        self:refreshProcess(0)
        self:refreshToSendGift()
        self:setButtomVisible(false)
        self:setTipImageVisible(false)
        self:setGiftPageButtomVisible(true)
        self.m_currentPageType = 1
    end
end

function SendGiftDialog:showGiftPage(giftId)
    if giftId == -1 then
        return
    end

    self:refreshToSendGift()
    self:setButtomVisible(false)
    self:setTipImageVisible(false)
    self:setGiftPageButtomVisible(true)
    self.m_currentPageType = 1

    self.m_GroupButtonSendGift:setSelected(true, false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    for _, v in pairs(self.m_allGiftCell) do
        v:SetSelected(false)
        local minus = winMgr:getWindow("button_minus_inGift_"..v:getID())
        minus:setVisible(false)
        local textWnd = winMgr:getWindow("text_itemCount_inGift_"..v:getID())
        local itemNum = self.roleItemManager:GetItemNumByBaseIDWithNoBind(v:getID())
        textWnd:setText("0/"..itemNum)
    end

    local pCell = self.m_allGiftCell[giftId]
    local minusWnd = winMgr:getWindow("button_minus_inGift_"..giftId)
    local textWnd = winMgr:getWindow("text_itemCount_inGift_"..giftId)
    local giftNum = self.roleItemManager:GetItemNumByBaseIDWithNoBind(giftId)
    self.m_sendGiftItemID = giftId
    self.m_sendGiftItemNum = 1
    pCell:SetSelected(true)
    minusWnd:setVisible(true)
    textWnd:setText(self.m_sendGiftItemNum.."/"..giftNum)
end

function SendGiftDialog:refreshAfterSendItem(roleid, sendItemNum)
    self.m_dataKeyValue[roleid] = sendItemNum
    self:refreshCurrentPageOfSendItem()
    self:refreshToSendItem()
end

function SendGiftDialog:refreshGiftData(valueMap)
    self.m_dataKeyValue = valueMap
    if self.m_currentSelectedRoleID ~= 0 then
        self:refreshCurrentPageOfSendItem()
    end
end

function SendGiftDialog:refreshCurrentPageOfSendItem()
    if self.m_currentSelectedRoleID ~= 0 and TableUtil.tablelength(self.m_dataKeyValue) > 0 then
        self:refreshProcess(self.m_dataKeyValue[self.m_currentSelectedRoleID])
    end
end

function SendGiftDialog:handleSendItemClick(arg)

    if TableUtil.tablelength(self.m_toSendItem) > 0 and self.m_currentSelectedRoleID ~= 0 then
        local giveItem = require "protodef.fire.pb.friends.cgiveitem":new()
        giveItem.roleid = self.m_currentSelectedRoleID
        giveItem.itemmap = self.m_toSendItem
        require "manager.luaprotocolmanager":send(giveItem)

        for _, itemCell in pairs(self.m_saveCells) do
            itemCell:SetSelected(false)
        end

        self.m_toSendItem = {}

        self:refreshCurrentPageOfSendItem()
        self:refreshToSendItem()

    elseif TableUtil.tablelength(self.m_toSendItem) == 0 then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(180012))
    elseif self.m_currentSelectedRoleID == 0 then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(180010))
    end
end

function SendGiftDialog:createContactList(insertFirstRoleID)
    if insertFirstRoleID then
        table.insert(self.m_contactList, 1, insertFirstRoleID)
    end

    local friendCount = gGetFriendsManager():GetCurFriendNum()
    for i = 1, friendCount do
        local roleID = gGetFriendsManager():GetFriendRoleIDByIdx(i)
        if roleID ~= insertFirstRoleID and roleID > 0 then
            table.insert(self.m_contactList, roleID)
        end
    end
    
    local isInsertRole = false
    local winMgr = CEGUI.WindowManager:getSingleton()
    for k, v in ipairs(self.m_contactList) do
        if v == self.m_insertID then
            isInsertRole = true
        else 
            isInsertRole = false
        end

        local roleInf = gGetFriendsManager():GetContactRole(v)
        local curCell = winMgr:loadWindowLayout("friendzengsongcell.layout", k)
        self.m_contactPane:addChildWindow(curCell)
        local height = curCell:getPixelSize().height
        local yPos = 1.0 +(height + 2.0) * (k - 1)
        local xPos = 0
        curCell:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, xPos), CEGUI.UDim(0.0, yPos)))
        local roleCellBtn = CEGUI.Window.toGroupButton(curCell)
        roleCellBtn:EnableClickAni(false)
        roleCellBtn:setID(v)
        roleCellBtn:subscribeEvent("SelectStateChanged", SendGiftDialog.handleRoleClick, self)
        if v == insertFirstRoleID then
            roleCellBtn:setSelected(true)
        end

        local headWndName = k .. "friendaddcell/icon"
        local headWnd = winMgr:getWindow(headWndName)
        local strHead = ""
        if isInsertRole then
            strHead = gGetIconManager():GetImagePathByID(self.m_roleHeadID):c_str()
        else
            strHead = gGetFriendsManager():GetContactRoleIcon(v)
        end
        
        
        if strHead ~= "" then
            headWnd:setProperty("Image", strHead)
        end

        local nameWndName = k .. "friendaddcell/name"
        local nameWnd = winMgr:getWindow(nameWndName)
        if isInsertRole then
            nameWnd:setText(self.m_insertName)
        else
            nameWnd:setText(roleInf.name)
        end
        

        local levelWndName = k .. "friendaddcell/level"
        local levelWnd = winMgr:getWindow(levelWndName)
        if isInsertRole then
            levelWnd:setText(self.m_insertLevel)
        else
            levelWnd:setText(tostring(roleInf.rolelevel))
        end

        local schoolWndName = k .. "friendaddcell/zhiye"
        local schoolWnd = winMgr:getWindow(schoolWndName)
        local schoolRecordID = 0
        if isInsertRole then
            schoolRecordID = self.m_insertSchool
        else
            schoolRecordID = roleInf.school
        end
        local schoolConf = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(schoolRecordID)
        schoolWnd:setProperty("Image", schoolConf.schooliconpath)
    end
end

function SendGiftDialog:insertCharacterWithParams(roleID, roleName, roleLevel, roleSchool, roleHeadID)
    self.m_insertID = roleID
    self.m_insertName = roleName
    self.m_insertLevel = roleLevel
    self.m_insertSchool = roleSchool
    self.m_roleHeadID = roleHeadID
end

function SendGiftDialog:handleRoleClick(arg)
    local MouseArgs = CEGUI.toMouseEventArgs(arg)
    local pCell = CEGUI.toItemCell(MouseArgs.window)
    local roleID = pCell:getID()
    self.m_currentSelectedRoleID = roleID
    local sendNum = self:getSendItemNumByRoleID(self.m_currentSelectedRoleID) or 0
    self:refreshToSendItem()
    self.m_toSendItem = {}
    self.m_buttonSendItem:setSelected(true, false)
    self:refreshProcess(sendNum)
end

--刷新可赠送礼物列表
function SendGiftDialog:refreshToSendGift()
    self.m_allGiftCell = {}
    self.m_itemPane:cleanupNonAutoChildren()
    local winMgr = CEGUI.WindowManager:getSingleton()
    local colCount = 7
    local cellSize = 78
    local index = 0
    local tableAllId = BeanConfigManager.getInstance():GetTableByName("friends.cfriendgivegift"):getAllID()
    for _, v in pairs(tableAllId) do
        local record = BeanConfigManager.getInstance():GetTableByName("friends.cfriendgivegift"):getRecorder(v)
        local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(record.id)

        local cellName = "SEND_GIFT_CELL_"..v
        local item = self.roleItemManager:GetItemByBaseID(v, fire.pb.item.BagTypes.BAG)
        local itemNum = self.roleItemManager:GetItemNumByBaseID(v)
        local itemCell = CEGUI.toItemCell(winMgr:createWindow("TaharezLook/ItemCell", cellName))
        itemCell:setVisible(true)
        itemCell:setAlpha(1.0)
        itemCell:setSize(CEGUI.UVector2(CEGUI.UDim(0, cellSize), CEGUI.UDim(0, cellSize)))
        self.m_itemPane:addChildWindow(itemCell)

        local row = math.floor(index/colCount)
        local col = index%colCount
        SetPositionOffset(itemCell, 3 + col * (cellSize + 4), row * (cellSize + 4))
        itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttr.icon))
        itemCell:subscribeEvent("MouseClick", SendGiftDialog.handleGiftClick, self)
        itemCell:setID(v)
        SetItemCellBoundColorByQulityItemWithId(itemCell, v)

        local t = winMgr:createWindow("TaharezLook/StaticText", "text_itemCount_inGift_"..v)
        t:setSize(CEGUI.UVector2(CEGUI.UDim(0, cellSize * 0.95), CEGUI.UDim(0, cellSize * 0.95)))
        t:setProperty("BackgroundEnabled", "False")
        t:setProperty("FrameEnabled", "False")
        t:setProperty("HorzFormatting", "RightAligned")
        t:setProperty("VertFormatting", "BottomAligned")
        t:setProperty("MousePassThroughEnabled", "True")
        t:setProperty("TextColours", "FFFFFFFF")
        t:setProperty("Font", "simhei-10")
        t:setProperty("AlwaysOnTop", "True")
        t:setText("0/"..itemNum) 
        itemCell:addChildWindow(t)

        local delBtn = winMgr:createWindow("TaharezLook/ImageButton", "button_minus_inGift_"..v)
        delBtn:setSize(CEGUI.UVector2(CEGUI.UDim(0, cellSize * 0.45), CEGUI.UDim(0, cellSize * 0.45)))
        delBtn:setPosition(CEGUI.UVector2(CEGUI.UDim(0.6, 0), CEGUI.UDim(0.01, 0)))
        delBtn:setProperty("NormalImage", "set:ccui1 image:jianhao")
        delBtn:setProperty("PushedImage", "set:ccui1 image:jianhao")
        delBtn:setID(v)
        delBtn:subscribeEvent("Clicked", SendGiftDialog.handleMinusButtonClick, self)
        delBtn:setVisible(false)
        itemCell:addChildWindow(delBtn)

        table.insert(self.m_allGiftCell, v, itemCell)

        index = index + 1
    end

end

function SendGiftDialog:handleMinusButtonClick(arg)
    if self.m_sendGiftItemID == -1 then
        return
    end

    local winMgr = CEGUI.WindowManager:getSingleton()
    local itemCell = winMgr:getWindow("SEND_GIFT_CELL_"..self.m_sendGiftItemID)
    local textWnd = winMgr:getWindow("text_itemCount_inGift_"..self.m_sendGiftItemID)
    local minusWnd = winMgr:getWindow("button_minus_inGift_"..self.m_sendGiftItemID)
    local itemNum = self.roleItemManager:GetItemNumByBaseIDWithNoBind(self.m_sendGiftItemID)

    if self.m_sendGiftItemNum > 0 then
        self.m_sendGiftItemNum = self.m_sendGiftItemNum - 1
        if self.m_sendGiftItemNum == 0 then
            itemCell:SetSelected(false)
            minusWnd:setVisible(false)
            self.m_sendGiftItemID = -1
        end
        textWnd:setText(self.m_sendGiftItemNum.."/"..itemNum)
    end
end

function SendGiftDialog:handleItemMinusButtonClick(arg)
       local winMgr = CEGUI.WindowManager:getSingleton()
       local itemKey = CEGUI.toWindowEventArgs(arg).window:getID()
       local item = self.roleItemManager:FindItemByBagAndThisID(itemKey, fire.pb.item.BagTypes.BAG)
       local itemCell = winMgr:getWindow("SEND_ITEM_CELL_"..itemKey)
       local textWnd = winMgr:getWindow("text_itemCount_inItem_"..itemKey)
       local minusWnd = winMgr:getWindow("button_minus_inItem_"..itemKey)
       local selectedNum = itemCell:getID2()
       local itemNum = self.roleItemManager:GetItemNumByBaseIDWithNoBind(item:GetBaseObject().id)
       local sendedNum = self:getSendItemNumByRoleID(self.m_currentSelectedRoleID)  or 0

       if selectedNum > 0 then
            selectedNum = selectedNum - 1
            itemCell:setID2(selectedNum)
            self.m_toSendItem[itemKey] = selectedNum
            for k, v in pairs(self.m_toSendItem) do
                if v == 0 then
                    self.m_toSendItem[k] = nil
                    break
                end
            end

            self:refreshProcess(self:getSendItemNum() + sendedNum)
            if selectedNum == 0 then
                itemCell:SetSelected(false)
                minusWnd:setVisible(false)
            end
            if item:GetBaseObject().maxNum > 1 then
                textWnd:setText(selectedNum.."/"..itemNum)
            end
        end
end

function SendGiftDialog:handleGiftClick(arg)
    local MouseArgs = CEGUI.toMouseEventArgs(arg)
    local pCell = CEGUI.toItemCell(MouseArgs.window)
    local itemID = pCell:getID()
    local itemNum = self.roleItemManager:GetItemNumByBaseID(itemID)
    local winMgr = CEGUI.WindowManager:getSingleton()

    local minusWnd = winMgr:getWindow("button_minus_inGift_"..itemID)

    if itemNum > 0 then  --点击的礼物的数量大于0才有选中效果
        if not pCell:isSelected() then
            for _, v in pairs(self.m_allGiftCell) do
                v:SetSelected(false)
                local minus = winMgr:getWindow("button_minus_inGift_"..v:getID())
                minus:setVisible(false)
                local textWnd = winMgr:getWindow("text_itemCount_inGift_"..v:getID())
                local itemNum = self.roleItemManager:GetItemNumByBaseID(v:getID())
                textWnd:setText("0/"..itemNum)
            end
            self.m_sendGiftItemID = itemID
            self.m_sendGiftItemNum = 1
            pCell:SetSelected(true)
            minusWnd:setVisible(true)
        else  --已经选中的礼物再次点击增加数量
            if itemNum > self.m_sendGiftItemNum then
                self.m_sendGiftItemID = itemID
                self.m_sendGiftItemNum = self.m_sendGiftItemNum + 1
            end
        end

        local winMgr = CEGUI.WindowManager:getSingleton()
        if winMgr:isWindowPresent("text_itemCount_inGift_"..itemID) then
            local textWnd = winMgr:getWindow("text_itemCount_inGift_"..itemID)
            textWnd:setText(self.m_sendGiftItemNum.."/"..itemNum)
        end
    else
        ShopManager:tryQuickBuy(itemID)
    end
end

--刷新可赠送物品列表
function SendGiftDialog:refreshToSendItem()
        self.m_saveCells = {}
        self.m_itemPane:cleanupNonAutoChildren()
        
        local hasItemTable = {}

        local allItemKeys = {}
        local items = {}
        items = self.roleItemManager:GetItemKeyListByType(items, ITEM_TYPE_FOOD)
        items = self.roleItemManager:GetItemKeyListByType(items, ITEM_TYPE_DRUG_THREE)
        items = self.roleItemManager:GetItemKeyListByType(items, ITEM_TYPE_UP_ITEM)

        local winMgr = CEGUI.WindowManager:getSingleton()
        local colCount = 7
        local cellSize = 78
        local index = 0
        for i = 0, items:size() - 1 do
            local itemkey = items[i]
            table.insert(allItemKeys, itemkey)
        end

        local tableAllId = BeanConfigManager.getInstance():GetTableByName("friends.cfriendgiveitem"):getAllID()
        for _, v in pairs(tableAllId) do
            local record = BeanConfigManager.getInstance():GetTableByName("friends.cfriendgiveitem"):getRecorder(v)
            local itemKeys = self.roleItemManager:GetAllItemKeyByBaseID(record.id)
            for _, keys in pairs(itemKeys) do
                local pitem = self.roleItemManager:FindItemByBagAndThisID(keys, fire.pb.item.BagTypes.BAG)
                if not pitem:isLock() and not pitem:isBind() then
                    table.insert(allItemKeys, keys)
                end
            end
        end

        for _, v in pairs(allItemKeys) do
            local cellName = "SEND_ITEM_CELL_"..v
            local item = self.roleItemManager:FindItemByBagAndThisID(v, fire.pb.item.BagTypes.BAG)
            
            local blnHasItem = false
            if item:GetBaseObject().maxNum > 1 then
                for _, v in pairs(hasItemTable) do
                    if v == item:GetObjectID() then
                        blnHasItem = true
                    end
                end
                if not blnHasItem then
                    table.insert(hasItemTable, item:GetObjectID())
                end
            end

            if not blnHasItem then
                local itemCell = CEGUI.toItemCell(winMgr:createWindow("TaharezLook/ItemCell", cellName))
                local itemNum = self.roleItemManager:GetItemNumByBaseIDWithNoBind(item:GetObjectID())
                local quality = item:GetObject().qualiaty or item:GetObject().nLevel or 0

                itemCell:setVisible(true)
                itemCell:setAlpha(1.0)
                itemCell:setSize(CEGUI.UVector2(CEGUI.UDim(0, cellSize), CEGUI.UDim(0, cellSize)))
                self.m_itemPane:addChildWindow(itemCell)

                local row = math.floor(index/colCount)
                local col = index%colCount
                SetPositionOffset(itemCell, 3 + col * (cellSize + 4), row * (cellSize + 4))
                itemCell:SetImage(gGetIconManager():GetItemIconByID(item:GetBaseObject().icon))
                itemCell:setID(v)
                itemCell:setID2(0)--用来存储item点击的数量
                itemCell:subscribeEvent("MouseClick", SendGiftDialog.handleClickCellItem, self)
                SetItemCellBoundColorByQulityItemWithId(itemCell, item:GetBaseObject().id)

                local t = winMgr:createWindow("TaharezLook/StaticText", "text_itemCount_inItem_"..v)
                t:setSize(CEGUI.UVector2(CEGUI.UDim(0, cellSize * 0.95), CEGUI.UDim(0, cellSize * 0.95)))
                t:setProperty("BackgroundEnabled", "False")
                t:setProperty("FrameEnabled", "False")
                t:setProperty("HorzFormatting", "RightAligned")
                t:setProperty("VertFormatting", "BottomAligned")
                t:setProperty("MousePassThroughEnabled", "True")
                t:setProperty("TextColours", "FFFFFFFF")
                t:setProperty("Font", "simhei-10")
                t:setProperty("AlwaysOnTop", "True")
                if item:GetBaseObject().maxNum > 1 then
                    t:setText("0/"..itemNum)
                else
                    t:setText("LV."..quality)
      
                end

                itemCell:addChildWindow(t)
                local delBtn = winMgr:createWindow("TaharezLook/ImageButton", "button_minus_inItem_"..v)
                delBtn:setSize(CEGUI.UVector2(CEGUI.UDim(0, cellSize * 0.45), CEGUI.UDim(0, cellSize * 0.45)))
                delBtn:setPosition(CEGUI.UVector2(CEGUI.UDim(0.6, 0), CEGUI.UDim(0.01, 0)))
                delBtn:setProperty("NormalImage", "set:ccui1 image:jianhao")
                delBtn:setProperty("PushedImage", "set:ccui1 image:jianhao")
                delBtn:setID(v)
                delBtn:subscribeEvent("Clicked", SendGiftDialog.handleItemMinusButtonClick, self)
                delBtn:setVisible(false)
                itemCell:addChildWindow(delBtn)
 
                index = index + 1

                table.insert(self.m_saveCells, itemCell)
            end

        end

        if index > 0 then
            self:setTipImageVisible(false)
        else
            self:setTipImageVisible(true)
        end
end

function SendGiftDialog:handleClickCellItem(arg)
    local MouseArgs = CEGUI.toMouseEventArgs(arg)
    local pCell = CEGUI.toItemCell(MouseArgs.window)
    local itemKey = pCell:getID()
    local selectedNum = pCell:getID2()
    local item = self.roleItemManager:FindItemByBagAndThisID(itemKey, fire.pb.item.BagTypes.BAG)
    local itemNum = self.roleItemManager:GetItemNumByBaseIDWithNoBind(item:GetBaseObject().id)
    local winMgr = CEGUI.WindowManager:getSingleton()

    local pos = self.m_contactPane:getPosition()
    local xOffset = self.m_contactPane:getPixelSize().width * 0.35
    local yOffset =  pos.y.offset + self.m_contactPane:getPixelSize().height * 0.35
    local Commontipdlg = require "logic.tips.commontipdlg"
    local commontipdlg = Commontipdlg.getInstanceAndShow()
    local nType = Commontipdlg.eType.eNormal
    commontipdlg:RefreshItem(nType, item:GetObjectID(), xOffset,  yOffset, item:GetObject())

    local sendedNum = self:getSendItemNumByRoleID(self.m_currentSelectedRoleID)  or 0
    if sendedNum >= 5 then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(180013))
        return
    end

    local minusWnd = winMgr:getWindow("button_minus_inItem_"..itemKey)

    local currentSelect = self:getSendItemNum()
    if sendedNum + currentSelect < 5 then
        if not pCell:isSelected() and  item:GetBaseObject().maxNum == 1 then
            pCell:SetSelected(true)
            minusWnd:setVisible(true)
            selectedNum = selectedNum + 1
            pCell:setID2(selectedNum)
            self.m_toSendItem[itemKey] = selectedNum
        else
            if item:GetBaseObject().maxNum > 1 and itemNum > 0 and itemNum > selectedNum then
                pCell:SetSelected(true)
                minusWnd:setVisible(true)
                selectedNum = selectedNum + 1
                pCell:setID2(selectedNum)
                self.m_toSendItem[itemKey] = selectedNum
                if winMgr:isWindowPresent("text_itemCount_inItem_"..itemKey) then
                    local textWnd = winMgr:getWindow("text_itemCount_inItem_"..itemKey)
                    textWnd:setText(selectedNum.."/"..itemNum)
                end
            end
        end
    end

    self:refreshProcess(self:getSendItemNum() + sendedNum)
end

function SendGiftDialog:getSendItemNum()
    local num = 0
    for _, v in pairs(self.m_toSendItem) do
        num = num + v
    end
    return num
end
 
function SendGiftDialog:refreshProcess(alreadySendNum)
    if alreadySendNum then
        self.m_checkSendNum:setProgress(alreadySendNum / self.m_sendMax)
        self.m_checkSendNum:setText(alreadySendNum.."/"..self.m_sendMax)
    end
end

function SendGiftDialog:setTipImageVisible(bValue)
    self.m_tipImage:setVisible(bValue)
    self.m_tipText:setVisible(bValue)
    self.m_tipTextbg:setVisible(bValue)
end

function SendGiftDialog:setButtomVisible(bValue)
    self.m_tishiText:setVisible(bValue)
    self.m_buttonSendGift:setVisible(bValue)
    self.m_checkSendNum:setVisible(bValue)
end

function SendGiftDialog:setGiftPageButtomVisible(bValue)
    self.m_liuyanFrame:setVisible(bValue)
    self.m_liuyanFujia:setVisible(bValue)
    self.m_liuyanSendButton:setVisible(bValue)
end

function SendGiftDialog:getSendItemNumByRoleID(roleID)
    if roleID ~= 0 and TableUtil.tablelength(self.m_dataKeyValue) then
        return self.m_dataKeyValue[roleID]
    end
end

function SendGiftDialog:OnInputBoxFull(e)
	local tips = MHSD_UTILS.get_resstring(1449)
	GetCTipsManager():AddMessageTip(tips)
end

function SendGiftDialog:update(delta)
    if ContactRoleDialog.getInstanceNotCreate() then
        ContactRoleDialog.getInstanceNotCreate().DestroyDialog()
    end

    if self.m_currentPageType == 1 then
        local text1 = self.m_pChatInputBox:GetPureText()
        self.m_liuyanTip:setVisible((text1 == "" and self.m_pChatInputBox:hasInputFocus()))
    end
end

function SendGiftDialog:HandleSendGiftWidthChat(e)
    self:readyForSendGift()
end

function SendGiftDialog:readyForSendGift()
    if self.m_sendGiftCDing then return end

    if self.m_sendGiftItemID == -1 or self.m_sendGiftItemNum < 1 then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(180012))
        return
    end

     if self.m_currentSelectedRoleID == 0 then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(180010))
        return
    end

    local roleInf = gGetFriendsManager():GetContactRole(self.m_currentSelectedRoleID)
    local roleTable = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(roleInf.shape % 17)
    if not roleTable then
        return
    end
    local isSameSex = roleTable.sex == gGetDataManager():GetMainCharacterData().sex
    local isOppositeSexGift = false

    local record = BeanConfigManager.getInstance():GetTableByName("friends.cfriendgivegift"):getRecorder(self.m_sendGiftItemID)
    if record.oppositeSexFriendlyDegrees > 0 then
        isOppositeSexGift = true
    end

    if not self.m_ignoreSex then
        if self.m_currentSelectedRoleID > 0 then  --判断是否是异性送花
            if isOppositeSexGift and isSameSex then --玫瑰花， 异性增加好友都
                gGetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_msgtipstring(180011), SendGiftDialog.makeSureSexYes,self, SendGiftDialog.makeSureSexNO,self)
                return
            end

            if not isOppositeSexGift and not isSameSex then --金兰花 同性增加好友度
                gGetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_msgtipstring(190059), SendGiftDialog.makeSureSexYes,self, SendGiftDialog.makeSureSexNO,self)
                return
            end
        end
    end

    if not self.m_ignoreFriendShipe then  --给陌生人送礼物需确认
        local bMyFriend = gGetFriendsManager():isMyFriend(self.m_currentSelectedRoleID)
        if not bMyFriend then
            gGetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_msgtipstring(180008), SendGiftDialog.makeSureShipYes,self, SendGiftDialog.makeSureShipNo,self)
            return
        end
    end

    local maxFriendLevel = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(341).value)
    if not self.m_ignoreFriend3000value and gGetFriendsManager():GetFriendlyDegrees(self.m_currentSelectedRoleID) >=  maxFriendLevel then 
        --判断好友关系 同性 还是 异性
        --如果是同性判断是否送的是金兰花
        --如果是异性判断是否送的是玫瑰花
        if (isSameSex and not isOppositeSexGift) or (not isSameSex and isOppositeSexGift)  then
            gGetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_msgtipstring(190060), SendGiftDialog.makeSure3000valueYes,self, SendGiftDialog.makeSure3000valueNo,self)
            return
        end
    end

    self:sendGiftToServer(0)
end

function SendGiftDialog:makeSureSexYes(arg)
    gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    self.m_ignoreSex = true
    self:readyForSendGift()
end

function SendGiftDialog:makeSureSexNO(arg)
    gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    self:clearSendGiftCD()
end

function SendGiftDialog:makeSureShipYes(arg)
    gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    self.m_ignoreFriendShipe = true
    self:readyForSendGift()
end

function SendGiftDialog:makeSureShipNo(arg)
    gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    self:clearSendGiftCD()
end

function SendGiftDialog:makeSure3000valueYes(arg)
    gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    self.m_ignoreFriend3000value = true
    self:readyForSendGift()
end

function SendGiftDialog:makeSure3000valueNo(arg)
    gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    self:clearSendGiftCD()
end

function SendGiftDialog:sendGiftToServer(isForce)
    if self.m_sendGiftItemID > 0 and self.m_sendGiftItemNum > 0 then
        
        if self.m_currentSelectedRoleID== gGetDataManager():GetMainCharacterID() then
            local strShowTip = require("utils.mhsdutils").get_msgtipstring(162159)
		    GetCTipsManager():AddMessageTip(strShowTip)
            return 
        end

        if not self.m_pChatInputBox:IsEmpty() then
            self.m_sendGiftWithMsg = self.m_pChatInputBox:GetPureText()
            self.m_pChatInputBox:Clear()
            self.m_pChatInputBox:Refresh()
        end

        self.m_sendGiftCDing = true

        if string.len( self.m_sendGiftWithMsg)==0 then
            local strSendText = require("utils.mhsdutils").get_resstring(11556) --$parameter1$赠送给你$parameter2$朵$parameter3$
            local strUserName = gGetDataManager():GetMainCharacterName()

            local strItemName = ""
            local strDanWei = ""
            local itemAttr1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.m_sendGiftItemID)
            if itemAttr1 then
                strItemName = itemAttr1.name
                strDanWei = itemAttr1.units
            end

            local sb = StringBuilder.new()
            sb:Set("parameter1", strUserName)
            sb:Set("parameter2",tostring(self.m_sendGiftItemNum))
            sb:Set("parameter3",strDanWei)
            sb:Set("parameter4",strItemName )
            strSendText = sb:GetString(strSendText)
            sb:delete()

            self.m_sendGiftWithMsg = strSendText
        end



        local giveGift = require "protodef.fire.pb.friends.cgivegift":new()
        giveGift.roleid = self.m_currentSelectedRoleID
        giveGift.itemid = self.m_sendGiftItemID
        giveGift.itemnum = self.m_sendGiftItemNum
        giveGift.content = self.m_sendGiftWithMsg
        giveGift.force = isForce
        require "manager.luaprotocolmanager":send(giveGift)

        local winMgr = CEGUI.WindowManager:getSingleton()
        for _, v in pairs(self.m_allGiftCell) do
            v:SetSelected(false)
            local itemID = v:getID()
            local textWnd = winMgr:getWindow("text_itemCount_inGift_"..itemID)
            local itemNum = self.roleItemManager:GetItemNumByBaseID(itemID)
            textWnd:setText("0/"..itemNum)
            local minusWnd = winMgr:getWindow("button_minus_inGift_"..itemID)
            minusWnd:setVisible(false)
        end
    end
end

function SendGiftDialog:sendGiftErrTip() --不是双向好友赠送 花 会返回错误， 弹出提示是否强行赠送
    gGetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_msgtipstring(180007), SendGiftDialog.forceSendClickYes,self, SendGiftDialog.forceSendClickNo,self)
end

function SendGiftDialog:forceSendClickYes(arg)
    gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    self:sendGiftToServer(1)
end

function SendGiftDialog:forceSendClickNo(arg)
    gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    self:clearSendGiftCD()
end

function SendGiftDialog:clearSendGiftCD()
    local winMgr = CEGUI.WindowManager:getSingleton()
    for _, v in pairs(self.m_allGiftCell) do
        v:SetSelected(false)
        local itemID = v:getID()
        local textWnd = winMgr:getWindow("text_itemCount_inGift_"..itemID)
        local itemNum = self.roleItemManager:GetItemNumByBaseID(itemID)
        textWnd:setText("0/"..itemNum)
        local minusWnd = winMgr:getWindow("button_minus_inGift_"..itemID)
        minusWnd:setVisible(false)
    end

    self.m_sendGiftCDing = false
    self.m_sendGiftItemID = -1
    self.m_sendGiftItemNum = -1
    self.m_sendGiftWithMsg = ""
    self.m_ignoreSex = false
    self.m_ignoreFriendShipe = false
    self.m_ignoreFriend3000value = false
end

return SendGiftDialog