require "logic.dialog"

MessageForPointCardnotCashDlg = {}
setmetatable(MessageForPointCardnotCashDlg, Dialog)
MessageForPointCardnotCashDlg.__index = MessageForPointCardnotCashDlg

local _instance
function MessageForPointCardnotCashDlg.getInstance()
	if not _instance then
		_instance = MessageForPointCardnotCashDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function MessageForPointCardnotCashDlg.getInstanceAndShow()
	if not _instance then
		_instance = MessageForPointCardnotCashDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function MessageForPointCardnotCashDlg.getInstanceNotCreate()
	return _instance
end

function MessageForPointCardnotCashDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function MessageForPointCardnotCashDlg.ToggleOpenClose()
	if not _instance then
		_instance = MessageForPointCardnotCashDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function MessageForPointCardnotCashDlg.GetLayoutFileName()
	return "messageboxfuwu1.layout"
end

function MessageForPointCardnotCashDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, MessageForPointCardnotCashDlg)
	return self
end

function MessageForPointCardnotCashDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_btnQuitGame = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu1/Canle"))
    self.m_btnBuyOrSell = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu1/Canle1"))
    self.m_btnAdd = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu1/OK"))
    self.m_btnDec = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu1/Canle11"))
    self.m_btnQuitGame:subscribeEvent("Clicked", MessageForPointCardnotCashDlg.handleQuitBtnClicked, self)
    self.m_btnBuyOrSell:subscribeEvent("Clicked", MessageForPointCardnotCashDlg.handleBuyOrSellBtnClicked, self) 
    self.m_btnAdd:subscribeEvent("Clicked", MessageForPointCardnotCashDlg.handleAddtBtnClicked, self)
    self.m_btnDec:subscribeEvent("Clicked", MessageForPointCardnotCashDlg.handleDecBtnClicked, self)
    
    --self:GetWindow():subscribeEvent("ZChanged", MessageForPointCardnotCashDlg.handleZchange, self)
    self.m_text = winMgr:getWindow("messageboxfuwu1/text")
    self.movingToFront = false
    self:refreshbtn()
    self:initItems()
end
function MessageForPointCardnotCashDlg:handleDecBtnClicked(e)
    require"logic.pointcardserver.firstenterpointmsgdlg".getInstanceAndShow()
    self:GetWindow():setVisible(false)
end
function MessageForPointCardnotCashDlg:initItems()
    local cShapeId = gGetDataManager():GetMainCharacterCreateShape()
    local winMgr = CEGUI.WindowManager:getSingleton()
	for i = 1, 10 do
		local cell = CEGUI.toItemCell(winMgr:getWindow("messageboxfuwu1/bg/di/item" .. i ))
		cell:setID( i )
		cell:subscribeEvent("MouseClick",MessageForPointCardnotCashDlg.HandleItemClicked,self)

        local cfg = BeanConfigManager.getInstance():GetTableByName(CheckTableName("game.cshouchonglibao")):getRecorder(i)
        if cfg.borderpic:size() > 0 then
            local corner = winMgr:getWindow("messageboxfuwu1/bg/di/item/biaoqian"..i)
            corner:setProperty("Image",  cfg.borderpic[cShapeId-1])
        end
		local cfg = BeanConfigManager.getInstance():GetTableByName(CheckTableName("game.cshouchonglibao")):getRecorder(i)


        if i == 1 then
            local petAttrCfg = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(cfg.petid[cShapeId - 1])
            if petAttrCfg then
                local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttrCfg.modelid)
	            local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
                cell:SetImage(image)
            
                SetItemCellBoundColorByQulityPet(cell,petAttrCfg.quality)
                if cfg.petnum[cShapeId - 1] ~= 1 and cfg.petnum[cShapeId - 1] ~= 0 then
                    cell:SetTextUnitText(CEGUI.String(""..cfg.petnum[cShapeId - 1]))
                end
            end
        else
            local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(cfg.itemid[cShapeId - 1])
            if itembean then
		        cell:SetImage(gGetIconManager():GetItemIconByID( itembean.icon))
                SetItemCellBoundColorByQulityItemWithId(cell,itembean.id)
                if cfg.itemnum[cShapeId - 1] ~= 1 and cfg.itemnum[cShapeId - 1] ~= 0 then
		            cell:SetTextUnitText(CEGUI.String(""..cfg.itemnum[cShapeId - 1]))
                end
                ShowItemTreasureIfNeed(cell,itembean.id)
            end
        end
	end
end
function MessageForPointCardnotCashDlg:HandleItemClicked(args)
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position	
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	
	local ewindow = CEGUI.toWindowEventArgs(args)
	local index = ewindow.window:getID()
	
    local cShapeID = gGetDataManager():GetMainCharacterCreateShape()

	local cfg = BeanConfigManager.getInstance():GetTableByName(CheckTableName("game.cshouchonglibao")):getRecorder(index)

    if index == 1 then
        self:GetWindow():setVisible(false)
        FirstChargeGiftPetDlg.getInstanceAndShow(cfg.petid[cShapeID-1])
    else
    	local Commontipdlg = require "logic.tips.commontipdlg"
	    local commontipdlg = Commontipdlg.getInstanceAndShow()
	    local nType = Commontipdlg.eType.eNormal
	    local nItemId = cfg.itemid[cShapeID-1]
	    commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
    end
end
function MessageForPointCardnotCashDlg:refreshbtn()
    local funopenclosetype = require("protodef.rpcgen.fire.pb.funopenclosetype"):new()
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_OpenFunctionList.info then
            for i,v in pairs(manager.m_OpenFunctionList.info) do
                if v.key == funopenclosetype.FUN_CHECKPOINT then
                    if v.state == 1 then
                        self.m_btnBuyOrSell:setVisible(false)
                        self.m_text:setText(MHSD_UTILS.get_resstring(11594))
                        break
                    end
                end
            end
        end
    end
end
function MessageForPointCardnotCashDlg:handleZchange(e)
    if not self.movingToFront then
        self.movingToFront = true
        if self:GetWindow():getParent() then
            local drawList = self:GetWindow():getParent():getDrawList()
            if drawList:size() > 0 then
                local topWnd = drawList[drawList:size()-1]
                local wnd = tolua.cast(topWnd, "CEGUI::Window")
                if wnd:getName() == "NewsWarn" then
                    if drawList:size() > 2 then
                        local secondWnd = drawList[drawList:size()-1]
                        self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), tolua.cast(secondWnd, "CEGUI::Window"))
                    end
                else
                    self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), tolua.cast(topWnd, "CEGUI::Window"))
                end
                
            end
        end
        self.movingToFront = false
    end
end
function MessageForPointCardnotCashDlg:handleQuitBtnClicked(e)
    local p = require("protodef.fire.pb.creturntologin"):new()
	LuaProtocolManager:send(p)
    local huodongmanager = require"logic.huodong.huodongmanager".getInstanceNotCreate()
    if huodongmanager then
        huodongmanager:OpenPush()
    end
end
function MessageForPointCardnotCashDlg:handleBuyOrSellBtnClicked(e)
	
	require "handler.fire_pb_fushi"
	if b_fire_pb_fushi_OpenTrading == 1 then
		self:GetWindow():setVisible(false)
		require("logic.shop.stalllabel").show(3)
	else
		GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(300011))
	end
end
function MessageForPointCardnotCashDlg:handleAddtBtnClicked(e)
    self:GetWindow():setVisible(false)
    require("logic.shop.shoplabel").showRecharge()
end
function MessageForPointCardnotCashDlg:Show()
    self:GetWindow():setVisible(true)
end
return MessageForPointCardnotCashDlg