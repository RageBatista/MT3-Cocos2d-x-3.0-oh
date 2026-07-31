require "logic.dialog"

Spacenpcgivedialog = {}
setmetatable(Spacenpcgivedialog, Dialog)
Spacenpcgivedialog.__index = Spacenpcgivedialog


local _instance
function Spacenpcgivedialog.getInstance()
	if not _instance then
		_instance = Spacenpcgivedialog:new()
		_instance:OnCreate()
        _instance:registerEvent()
	end
	return _instance
end

function Spacenpcgivedialog.getInstanceAndShow()
	if not _instance then
		_instance = Spacenpcgivedialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Spacenpcgivedialog.getInstanceNotCreate()
	return _instance
end

function Spacenpcgivedialog.DestroyDialog()
    if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Spacenpcgivedialog:OnClose()
    gGetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)

    self:clearData()
    self:removeEvent()
	Dialog.OnClose(self)
	_instance = nil
end

function Spacenpcgivedialog.ToggleOpenClose()
	if not _instance then
		_instance = Spacenpcgivedialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function Spacenpcgivedialog.GetLayoutFileName()
	return "kongjianzengsongliuyan.layout"
end

function Spacenpcgivedialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Spacenpcgivedialog)
    self:clearData()
	return self
end

function Spacenpcgivedialog:clearData()
    self.nTargetItemNum  =0
    self.vItemCell = {}
end

function Spacenpcgivedialog:removeEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
end

function Spacenpcgivedialog:registerEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
  
end


function Spacenpcgivedialog:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    SetPositionScreenCenter(self:GetWindow())

	self.scrollItem = CEGUI.toScrollablePane(winMgr:getWindow("kongjianzengsongliuyan/ditu/textbg2/list"))
    self.scrollItem:EnableVertScrollBar(false)

	self.itemCellTarget = CEGUI.toItemCell(winMgr:getWindow("kongjianzengsongliuyan/ditu/textbg1/itecmcell"))
    self.itemCellTarget:subscribeEvent("MouseClick", Spacenpcgivedialog.clickItemCellTarget, self)
	
    self.labelPlaceholder = winMgr:getWindow("kongjianzengsongliuyan/ditu/di/text") 
    self.labelPlaceholder:setMousePassThroughEnabled(true)
    
    self.richEditBox = CEGUI.toRichEditbox(winMgr:getWindow("kongjianzengsongliuyan/ditu/di/rich"))
    self.richEditBox:setWordWrapping(false)
    self.richEditBox:subscribeEvent("TextChanged", Spacenpcgivedialog.TextContentChanged, self)
    self.richEditBox:subscribeEvent("KeyboardTargetWndChanged", Spacenpcgivedialog.OnKeyboardTargetWndChanged, self)


    self.btnGive = CEGUI.toPushButton(winMgr:getWindow("kongjianzengsongliuyan/ditu/btn"))
    self.btnGive:subscribeEvent("MouseClick", Spacenpcgivedialog.clickGive, self)

    local frameWnd=CEGUI.toFrameWindow(winMgr:getWindow("kongjianzengsongliuyan/ditu"))
	local closeBtn=CEGUI.toPushButton(frameWnd:getCloseButton())
	closeBtn:subscribeEvent("MouseClick",Spacenpcgivedialog.clickClose,self)
    
    self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(Spacenpcgivedialog.OnItemNumChange)
    self:initScrollItem()
end

function Spacenpcgivedialog:clickClose(args)
    Spacenpcgivedialog.DestroyDialog()
end

function  Spacenpcgivedialog:TextContentChanged()
     local tw = self.richEditBox:GetExtendSize().width
	local rw = self.richEditBox:getWidth().offset

	if tw > rw and m_PrevContentWidth > tw then
		self.richEditBox:getHorzScrollbar():setScrollPosition(rw - tw)
		self.richEditBox:Refresh()
		self.richEditBox:activate()
	end

	m_PrevContentWidth = tw
end

function Spacenpcgivedialog:OnKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.richEditBox then
        self.labelPlaceholder:setVisible(false)
    elseif self.richEditBox:GenerateParseText() == "" then
        self.labelPlaceholder:setVisible(true)
    end
end



function Spacenpcgivedialog.OnItemNumChange(eBagType, nItemKey, nItemId)
    if not _instance then
		return
	end
	_instance:refreshScrollItemNum()
	

end


function Spacenpcgivedialog:refreshScrollItemNum()
    local nTargetItemId = self.itemCellTarget:getID()

    for nIndex=1, #self.vItemCell do
        local itemCell = self.vItemCell[nIndex]
        local nItemId = itemCell:getID()
        local nItemNum = require("logic.item.roleitemmanager").getInstance():GetItemNumByBaseID(nItemId)

        if nItemId==nTargetItemId then
             nItemNum = nItemNum - self.nTargetItemNum
        end
        if nItemNum < 0 then
            nItemNum = 0
        end

        itemCell:SetTextUnit(tostring(nItemNum))
    end
end

function Spacenpcgivedialog:refreshTarget()
    local nTargetItemId = self.itemCellTarget:getID()
    self.itemCellTarget:SetImage(nil)
    local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nTargetItemId)
	if itemTable then
        self.itemCellTarget:SetImage(gGetIconManager():GetItemIconByID(itemTable.icon))
    end
    local nItemNum = self.nTargetItemNum --require("logic.item.roleitemmanager").getInstance():GetItemNumByBaseID(nTargetItemId)
    self.itemCellTarget:SetTextUnit(tostring(nItemNum))

end

function Spacenpcgivedialog:openBuy(nItemId)

     ShopManager:tryQuickBuy(nItemId, 1)
    --[[
    require("logic.shop.quickbuydlg")
    local dlg = QuickBuyDlg.getInstanceAndShow()
    local nCount = 1
    dlg:setItemBaseId(nItemId, nCount)
    --]]
end

function Spacenpcgivedialog:clickItemCellTarget(args)
    local mouseArgs = CEGUI.toMouseEventArgs(args)
	local clickWin = mouseArgs.window
	local nItemId = args.window:getID()

    if nItemId <= 0 then
        return
    end
    self.nTargetItemNum = self.nTargetItemNum -1
    if self.nTargetItemNum <= 0 then
        self.nTargetItemNum =0
        self.itemCellTarget:setID(0)
    end

    self:refreshScrollItemNum()
    self:refreshTarget()

end


function Spacenpcgivedialog:clickItemCell(args)
    local mouseArgs = CEGUI.toMouseEventArgs(args)
	local clickWin = mouseArgs.window
	local nItemId = args.window:getID()

    local nItemNum = require("logic.item.roleitemmanager").getInstance():GetItemNumByBaseID(nItemId)
    if nItemNum > 0 then
         local nTargetItemId = self.itemCellTarget:getID()
         if nItemId==nTargetItemId then
            if nItemNum > self.nTargetItemNum then
                self.nTargetItemNum = self.nTargetItemNum +1
            else
                self:openBuy(nItemId)
            end
         else
            self.nTargetItemNum = 1
            self.itemCellTarget:setID(nItemId)
         end
    else
        self:openBuy(nItemId)
        self.itemCellTarget:setID(0)
        self.nTargetItemNum = 0
    end
    self:refreshScrollItemNum()
    self:refreshTarget()

end


function Spacenpcgivedialog:initScrollItem()
    self.scrollItem:cleanupNonAutoChildren()
	local winMgr = CEGUI.WindowManager:getSingleton()
	local nOriginX = 20
	local nOriginY = 5
	local nItemCellW = 94
	local nItemCellH = 94
	local nSpaceX = 10
	local nSpaceY = 5
	local nRowCount = 100

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
		
    local vAllId = BeanConfigManager.getInstance():GetTableByName("item.cdashispacegift"):getAllID()
	for nIndex = 1, #vAllId do
		local nItemId = vAllId[nIndex]
        local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	    if itemTable then
            local strPrefixName = "Spacenpcgivedialog"..tostring(nIndex)
		    local itemCell =  CEGUI.toItemCell(winMgr:createWindow("TaharezLook/ItemCell",strPrefixName))
			local nPosX,nPosY = require("logic.task.taskhelper").GetPos(nIndex-1,nRowCount,nOriginX,nOriginY,nItemCellW,nItemCellH,nSpaceX,nSpaceY)
			itemCell:setSize(CEGUI.UVector2(CEGUI.UDim(0,nItemCellW), CEGUI.UDim(0,nItemCellH)))
			itemCell:setPosition(CEGUI.UVector2(CEGUI.UDim(0,nPosX),CEGUI.UDim(0,nPosY)))
            local nQuality = itemTable.nquality
            SetItemCellBoundColorByQulityItem(itemCell, nQuality, itemTable.itemtypeid)
            itemCell:setID(nItemId)
            itemCell:SetImage(gGetIconManager():GetItemIconByID(itemTable.icon))
            itemCell:subscribeEvent("MouseClick", Spacenpcgivedialog.clickItemCell, self)

            self.scrollItem:addChildWindow(itemCell)

            local nItemNum = roleItemManager:GetItemNumByBaseID(nItemId)
            itemCell:SetTextUnit(tostring(nItemNum))

            self.vItemCell[#self.vItemCell + 1] = itemCell
	    end

    end
	
end



function Spacenpcgivedialog:clickGive(args)
    local strContent = self.richEditBox:GenerateParseText(false)

    if strContent =="" then
        local strShowTip = require("utils.mhsdutils").get_resstring(11531)
		GetCTipsManager():AddMessageTip(strShowTip)
        return 
    end

    local nLen = self.richEditBox:GetCharCount() --string.len(strContent)
    local nMaxLen = 20
    if nLen >= nMaxLen then
        local strShowTip = require("utils.mhsdutils").get_resstring(11544)
        local sb = StringBuilder.new()
        sb:Set("parameter1",nMaxLen)
        strShowTip = sb:GetString(strShowTip)
        sb:delete()

		GetCTipsManager():AddMessageTip(strShowTip)
        return 
    end


    local nTargetItemId = self.itemCellTarget:getID()
    local nItemNum = self.nTargetItemNum 

    if nItemNum <= 0 then
        local strShowTip = require("utils.mhsdutils").get_resstring(11590)
        GetCTipsManager():AddMessageTip(strShowTip)
        return
    end

    local p = require "protodef.fire.pb.friends.cxshgivegift":new()
	p.itemid = nTargetItemId
    p.itemnum = nItemNum
    p.content = strContent
	require "manager.luaprotocolmanager":send(p)

    Spacenpcgivedialog.DestroyDialog()

end





return Spacenpcgivedialog