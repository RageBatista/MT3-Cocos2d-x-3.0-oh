local super = require "logic.singletondialog";

local sCellNum = 15;

CTemporaryPack = { };
setmetatable(CTemporaryPack, super);
CTemporaryPack.__index = CTemporaryPack;

function CTemporaryPack_GetItemCellByPos(pos)
	local dlg = CTemporaryPack:getInstanceOrNot();
	if dlg then
		return dlg:GetItemCellByPos(pos);
	end
	return nil;
end

function CTemporaryPack_IsVisible()
	local dlg = CTemporaryPack:getInstanceOrNot();
	if dlg then
		return dlg:IsVisible();
	end
	return false;
end

function CTemporaryPack_GetSingleton()
	if CTemporaryPack:getInstanceOrNot() then
		return 1;
	else
		return 0;
	end
end

function CTemporaryPack:HandleConfirmGetBack(e)

	local windowargs = CEGUI.toWindowEventArgs(e);
	local pConfirmBoxInfo = tostConfirmBoxInfo(windowargs.window:getUserData());
	gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo);


	require "protodef.fire.pb.item.conekeymovetemptobag";
	local requestGetBack = COneKeyMoveTempToBag.Create();
	requestGetBack.srckey = 1;
	requestGetBack.number = -1;
	requestGetBack.dstpos = -1;

	LuaProtocolManager.getInstance():send(requestGetBack);

	return true;
end



function CTemporaryPack:HandleGetBack(e)

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	if (roleItemManager:IsTemporyPackEmpty() == true) then
		return true;
	end

	local emptyIndex = roleItemManager:GetFirstEmptyCellIndex(fire.pb.item.BagTypes.BAG);

	if (emptyIndex == -1) then
		local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(150147);
		if (tip.id ~= -1) then
			GetCTipsManager():AddMessageTip(tip.msg, false);
		end
		return true;
	end
	require "protodef.fire.pb.item.conekeymovetemptobag";
	local requestGetBack = COneKeyMoveTempToBag.Create();
	requestGetBack.srckey = 1;
	requestGetBack.number = -1;
	requestGetBack.dstpos = -1;
	LuaProtocolManager.getInstance():send(requestGetBack);

	return true;
end

function CTemporaryPack:HandleCloseBtnClick(e)
	self:OnClose();
	return true;
end

function CTemporaryPack:SetVisible(bVisible)
	super.SetVisible(self, bVisible);
	if (bVisible) then
		MainControl.ShowBtnInFirstRow(MainControlBtn_TmpBag)
	else
		MainControl.ShowBtnInFirstRow(MainControlBtn_TmpBag, false)
	end
end

function CTemporaryPack:HandleTableClick(e)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	local MouseArgs = CEGUI.toMouseEventArgs(e);
	local pCell = CEGUI.toItemCell(MouseArgs.window);
	if (pCell == nil or roleItemManager:getItem(pCell:getID2(), fire.pb.item.BagTypes.TEMP) == nil) then
		return true;
	end
	if (roleItemManager:IsBagFull()) then
		GetCTipsManager():AddMessageTipById(141413);
		return true;
	end

	if ((MouseArgs.button == CEGUI.LeftButton or MouseArgs.button == CEGUI.RightButton) and((1 == GetMainPackDlg()))) then
		local pItem = roleItemManager:getItem(pCell:getID2(), fire.pb.item.BagTypes.TEMP)
		roleItemManager:MoveItem(pItem, pItem:GetNum(), fire.pb.item.BagTypes.BAG, -1);
		return true;
	end

	return true;
end

function CTemporaryPack:HandleShowTootips(e)
	local MouseArgs = CEGUI.toMouseEventArgs(e);
	local pCell = CEGUI.toItemCell(MouseArgs.window);

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	if nil ~= roleItemManager:getItem(pCell:getID2(), fire.pb.item.BagTypes.TEMP) then
		local Pos = pCell:GetScreenPos();
		local pItem = roleItemManager:getItem(pCell:getID2(), fire.pb.item.BagTypes.TEMP)
		local bLuaHandleSuccess = false;

		local nPosX = Pos.x;
		local nPosY = Pos.y;
		local nItemKey = pItem:GetThisID();
		local nBagId = pItem:GetLocation().tableType;

		local screenSize = GetScreenSize();
		if (nPosX > screenSize.width / 2) then
			nPosX = screenSize.width / 8;
		else
			nPosX = screenSize.width - screenSize.width / 8;
		end


		local ret = LuaShowItemTip(nBagId, nItemKey, nPosX, nPosY);
		if (ret == 1) then
			bLuaHandleSuccess = true;
		end

	end

	return true;
end

function CTemporaryPack:HandleItemCellClickShowSel(e)
	if (self.m_pOldItemCell) then
		self.m_pOldItemCell:SetSelected(false);
	end
	local MouseArgs = CEGUI.toMouseEventArgs(e);

	local pCell = CEGUI.toItemCell(MouseArgs.window);
	self.m_pOldItemCell = pCell;

	pCell:SetSelected(true);

	return true;
end

function CTemporaryPack:HandleConfirmClearPack(e)
	local windowargs = CEGUI.toWindowEventArgs(e);
	local pConfirmBoxInfo = tostConfirmBoxInfo(windowargs.window:getUserData());
	gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo);

	require "protodef.fire.pb.item.ccleantemppack";
	local clearitems = CCleanTempPack.Create();
	LuaProtocolManager.getInstance():send(clearitems);
	return true;
end

function CTemporaryPack:HandleClearPack(e)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	if (roleItemManager:IsTemporyPackEmpty() == true) then
		self:OnClose();
		return true;
	end

	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(120058);
	if (tip.id ~= -1) then
		gGetMessageManager():AddConfirmBox(eConfirmCleanTempBag, tip.msg,
		CTemporaryPack.HandleConfirmClearPack, self,
		MessageManager.HandleDefaultCancelEvent, MessageManager);

	end

	return true;
end


function CTemporaryPack:HandleItemCellDoubleClick(e)
	local MouseArgs = CEGUI.toMouseEventArgs(e);
	local pCell = CEGUI.toItemCell(MouseArgs.window);

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	if (nil ~= roleItemManager:getItem(pCell:getID2(), fire.pb.item.BagTypes.TEMP)) then
		local pItem = roleItemManager:getItem(pCell:getID2(), fire.pb.item.BagTypes.TEMP)
		local nItemKey = pItem:GetThisID();

		require "protodef.fire.pb.item.ctransitem"
		local p = CTransItem.Create()
		p.srckey = nItemKey;
		p.srcpackid = fire.pb.item.BagTypes.TEMP;
		p.dstpackid = fire.pb.item.BagTypes.BAG;
		p.number = -1;
		p.dstpos = -1;
		p.page = -1;
		p.npcid = -1;
		LuaProtocolManager.getInstance():send(p)

		local tipDlg = require 'logic.tips.commontipdlg'.getInstanceNotCreate();
		if (tipDlg) then
			tipDlg:DestroyDialog();
		end
	end
	return true;
end


function CTemporaryPack:GetItemCellByPos(pos)
	if (pos >= 0 and pos < sCellNum) then
		return self.m_pItemCells[pos];
	end
	return nil;

end

function CTemporaryPack:GetItemTableByPos(pos)
	if (pos >= 0 and pos < sCellNum) then
		return nil;
	end
	return nil;

end

function CTemporaryPack:OnCreate()
	super.OnCreate(self);
	self:SetCloseIsHide(true);


	local winMgr = CEGUI.WindowManager:getSingleton();

	self.m_pBtnGetBack = CEGUI.toPushButton(winMgr:getWindow("linshibag/btnyi"));
	self.m_pBtnGetBack:subscribeEvent(CEGUI.PushButton.EventClicked, CTemporaryPack.HandleGetBack, self);
	self.m_table = CEGUI.toItemTable(winMgr:getWindow("linshibag/table"));
	self.m_table:subscribeEvent(CEGUI.ItemTable.EventTableDoubleClick, CTemporaryPack.HandleItemCellDoubleClick, self);

	for i = 0, sCellNum - 1 do
		local ss = "linshibag/table_ItemCell_" .. i;
		self.m_pItemCells[i] = CEGUI.toItemCell(winMgr:getWindow(ss));
		self.m_pItemCells[i]:SetCellTypeMask(1);
		self.m_pItemCells[i]:SetHaveSelectedState(true);
		self.m_pItemCells[i]:subscribeEvent(CEGUI.ItemCell.EventCellDoubleClick, CTemporaryPack.HandleTableClick, self);
		self.m_pItemCells[i]:subscribeEvent(CEGUI.ItemCell.EventCellClick, CTemporaryPack.HandleItemCellClickShowSel, self);
		self.m_pItemCells[i]:subscribeEvent(CEGUI.Window.EventMouseClick, CTemporaryPack.HandleShowTootips, self);
	end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	roleItemManager:InitBagItem(fire.pb.item.BagTypes.TEMP);
end

function CTemporaryPack:GetLayoutFileName()
	return "linshibag.layout";
end

function CTemporaryPack:OnClose()
	if (self.m_pMainFrame) then
		self.m_pMainFrame:setVisible(false);

		if (gGetMessageManager()) then
			gGetMessageManager():CloseConfirmBox(eConfirmCleanTempBag);
		end

	end

end

function CTemporaryPack.new()
	local obj = { };
	setmetatable(obj, CTemporaryPack);

    obj.m_eDialogType = obj.m_eDialogType or {};
	obj.m_eDialogType[DialogTypeTable.eDialogType_InScreenCenter] = 1;

	obj.m_pItemCells = { };
	for i = 0, sCellNum - 1 do
		obj.m_pItemCells[i] = nil;
	end

	return obj;
end

function CTemporaryPack:getInstance()
	if not self._instance then
		self._instance = CTemporaryPack.new();
		self._instance:OnCreate();
	end
	return self._instance;
end

function CTemporaryPack:GetSingletonDialogAndShowIt()
	if not self._instance then
		self._instance = CTemporaryPack.new();
		self._instance:OnCreate();
	end
	if not self._instance:IsVisible() then
		self._instance:SetVisible(true);
	end
	return self._instance;
end


return CTemporaryPack;
