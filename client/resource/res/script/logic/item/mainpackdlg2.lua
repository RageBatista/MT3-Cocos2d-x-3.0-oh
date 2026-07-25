local super = require "logic.singletondialog"
require "logic.item.EquipDialog"
require "logic.dialog"

local Guider_TrumpetID = 36701;
local MiHunXiangID = 36019;
local PetCompose_ItemType = 81;
local BaoChan_ID = 36124;

function formatMoneyString(num)
	local s = tostring(num);
	local len = string.len(s);
	if (len > 3) then
		local s2 = "";
		for i = len, 1, -3 do

			local segLen = i;
			if segLen >= 3 then
				segLen = 3;
			end

			local segStr = string.sub(s, i - segLen + 1, i);
			s2 = segStr .. s2;

			if i - 3 >= 1 then
				s2 = "," .. s2;
			end
		end
		return s2;
	else
		return s;
	end
end

CMainPackDlg = {
	m_bShowEquipDialog = true,
	m_dwLastTidyTime = 0
};
setmetatable(CMainPackDlg, super);
CMainPackDlg.__index = CMainPackDlg;

local pagenum = 25;

function CMainPackDlg:GetItemSelectCellNew()
	return self.m_pSelectCellNew;
end


function CMainPackDlg:SetItemSelectCellNew(n)
	self.m_pSelectCellNew = n;
end

function CMainPackDlg:GetQuestItemPage()
	return self.m_pQuestTable;
end

function CMainPackDlg:GetFirstPage()
	return self.m_pFirstTable;
end

function CMainPackDlg:SetEquipDialogState(bVisible)
	self.m_bShowEquipDialog = bVisible;
end

function CMainPackDlg:ClearItemTable()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	local cellCount = self.m_pFirstTable:GetCellCount();
	for i = 0, cellCount - 1 do
		local cell = self.m_pFirstTable:GetCell(i);
		if (cell and roleItemManager:getItem(cell:getID2(), fire.pb.item.BagTypes.BAG)) then
			cell:Clear();
			gGetGameUIManager():RemoveUIEffect(cell);
		end
	end

	cellCount = self.m_pQuestTable:GetCellCount();
	for i = 0, cellCount - 1 do
		local cell = self.m_pQuestTable:GetCell(i);
		if (cell and roleItemManager:getItem(cell:getID2(), fire.pb.item.BagTypes.QUEST)) then
			cell:Clear();
			gGetGameUIManager():RemoveUIEffect(cell);
		end
	end

	for i = 0, eEquipType_MAXTYPE - 1 do
		local cell = self.m_pEquipDialog:GetItemCellByPos(i);
		if (cell and roleItemManager:getItem(cell:getID2(), fire.pb.item.BagTypes.EQUIP)) then
			cell:Clear();
			gGetGameUIManager():RemoveUIEffect(cell);

			if i == eEquipType_CUFF then
				cell:SetBackGroundImage("chongwuui1", "kuang16");
			elseif i == eEquipType_ADORN then
				cell:SetImage("renwuui", "shipin");
			elseif i == eEquipType_LORICAE then
				cell:SetImage("renwuui", "yifu");
			elseif i == eEquipType_ARMS then
				cell:SetImage("renwuui", "wuqi");
			elseif i == eEquipType_TIRE then
				cell:SetImage("renwuui", "toubu");
			elseif i == eEquipType_CLOAK then
				cell:SetBackGroundImage("chongwuui1", "kuang16");
			elseif i == eEquipType_BOOT then
				cell:SetImage("renwuui", "jiao");
			elseif i == eEquipType_WAISTBAND then
				cell:SetImage("renwuui", "yaodai");
			elseif i == eEquipType_EYEPATCH then
				cell:SetBackGroundImage("chongwuui1", "kuang16");
			elseif i == eEquipType_RESPIRATOR then
				cell:SetBackGroundImage("chongwuui1", "kuang16");
			elseif i == eEquipType_VEIL then
				cell:SetBackGroundImage("chongwuui1", "kuang16");
			elseif i == eEquipType_FASHION then
				cell:SetBackGroundImage("chongwuui1", "kuang16");
			elseif i == eEquipType_jingmai1 then
				cell:SetBackGroundImage("chongwuui1", "kuang90");
			else
				--其他槽位都是默认
				cell:SetBackGroundImage("chongwuui1", "kuang90");
			end
		end
	end
end

function CMainPackDlg:GetEquipDialog()
	return self.m_pEquipDialog;
end


function CMainPackDlg:SetVisible(visible)
	super.SetVisible(self, visible);
	if (visible and self.m_pEquipDialog) then
		self.m_pEquipDialog:SetFootprint(gGetDataManager():GetMainCharacterData().footprint);
	end
end

function CMainPackDlg:ShowLabel()
	CMainPackLabelDlg:GetSingletonDialogAndShowIt();
end

function CMainPackDlg:GetEquipItemTableByPos(pos)
	if (self.m_pEquipDialog) then
		return self.m_pEquipDialog:GetItemTableByPos(pos);
	end
	return nil;
end

function CMainPackDlg:UpdateTotalScore()
	if (self.m_pEquipDialog) then
		self.m_pEquipDialog:UpdateTotalScore();
	end
end

function CMainPackDlg:UpdateEquipTotalScore()

	if (self.m_pEquipDialog) then
		self.m_pEquipDialog:UpdateEquipTotalScore();
	end

end

function CMainPackDlg:HandleWindowPosChange(e)
	if (self.m_pEquipDialog) then
		self.m_pEquipDialog:HandleWindowPosChange(e);
	end
	return true;
end

function CMainPackDlg:GetEquipTabBackImage(loc)
	if loc == eEquipType_CUFF then
		return "shipin";

	elseif loc == eEquipType_ADORN then
		return "shipin";
	elseif loc == eEquipType_LORICAE then
		return "yifu";
	elseif loc == eEquipType_ARMS then
		return "wuqi";
	elseif loc == eEquipType_TIRE then

		return "toubu";
	elseif loc == eEquipType_CLOAK then

		return "toubu";
	elseif loc == eEquipType_BOOT then
		return "jiao";
	elseif loc == eEquipType_WAISTBAND then
		return "yaodai";
	elseif loc == eEquipType_EYEPATCH then
	elseif loc == eEquipType_RESPIRATOR then
	elseif loc == eEquipType_VEIL then
		return "shipin";

	elseif loc == eEquipType_FASHION then
		return "yaodai";

	elseif loc == eEquipType_jingmai1 then
	end

end

function CMainPackDlg:GetNormalBackImage(loc)
	return "kuang95";
end

--[[
function CMainPackDlg:HandleEquipShiftClickItem(pItem)
	if (GetChatManager()) then
		local ItemColor = pItem:GetLinkTipsColor();
		local bind = pItem:GetObject().data.flags;
		local loseeffecttime = pItem:GetObject().data.loseeffecttime;
		GetChatManager():AddObjectTipsLinkToCurInputBox(pItem:GetName(), gGetDataManager():GetMainCharacterID(),
		fire.pb.talk.ShowInfo.SHOW_ITEM, pItem:GetThisID(), pItem:GetBaseObject().id, 0, fire.pb.item.BagTypes.EQUIP, true, bind, loseeffecttime, ItemColor);


	end
	return true;
end
--]]

function CMainPackDlg:HandleDrawSprite()
	if (self.m_pEquipDialog and CMainPackDlg:GetSingleton() and CMainPackDlg:GetSingleton():GetWindow():getEffectiveAlpha() > 0.95) then
		self.m_pEquipDialog:HandleDrawSprite();
	end
end

function CMainPackDlg:GetEquipItemCellByPos(pos)
	if (self.m_pEquipDialog == nil) then
		return nil;
	end
	return self.m_pEquipDialog:GetItemCellByPos(pos);
end

function CMainPackDlg:OpenProtectMoneyDlg()
	return false;
end

function CMainPackDlg:HandleSelectTable(e)
	local pCell = nil;

	local equipid = self.m_pTabControl:getID();
	if (equipid > 0) then
	end
	return true;
end

function CMainPackDlg:SetSchoolMasterGiveEquip(equipid)
	self.m_pTabControl:setID(equipid);
end


function CMainPackDlg:HandleConfirmBuyCapcity(e)
	local windowargs = CEGUI.toWindowEventArgs(e);
	local pConfirmBoxInfo = tostConfirmBoxInfo(windowargs.window:getUserData());
	gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo);

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	local needMoney = roleItemManager:getUnlockBagNeedMoney();

	require "protodef.fire.pb.item.cextpacksize";

	local nUserMoney = roleItemManager:GetPackMoney();
	if (nUserMoney < needMoney) then

		local pProtocol = CExtPackSize.Create();
		pProtocol.packid = fire.pb.item.BagTypes.BAG;

		Depot_ShowSilverCurrency(needMoney, pProtocol, self.m_pMoneyNum, false);
	else
		local send = CExtPackSize.Create();
		send.packid = fire.pb.item.BagTypes.BAG;
		LuaProtocolManager.getInstance():send(send);
	end
	return true;
end


function CMainPackDlg:HandleItemCellLockClick(e)

	local roleItemManager = require("logic.item.roleitemmanager").getInstance();
	local needMoney = roleItemManager:getUnlockBagNeedMoney();

	require 'utils.stringbuilder';

	local sb = StringBuilder:new();
	sb:Set("Parameter1", needMoney);

	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(150144);
	local tips = sb:GetString(tip.msg);

	sb:delete();

	if (tip.id ~= -1) then
		gGetMessageManager():AddConfirmBox(eConfirmCleanTempBag, tips,
		CMainPackDlg.HandleConfirmBuyCapcity, self,
		MessageManager.HandleDefaultCancelEvent, MessageManager);

	end

	return true;
end


function CMainPackDlg:HandleBuyExpandCapacityItem(e)
	return false;
end

function CMainPackDlg:HandleHideBagGuide(e)
	local windowargs = CEGUI.toWindowEventArgs(e);
	local pCell = CEGUI.toItemCell(windowargs.window);
	local rowindex = math.floor(pCell:GetIndex() / 5);
	for i = 0, 5 - 1 do
		local cell = self.m_pSecondTable:GetCell(rowindex * 5 + i);
		cell:setMouseOnThisCell(false);
	end
	return true;
end

function CMainPackDlg:HandleShowBagGuide(e)
	local windowargs = CEGUI.toWindowEventArgs(e);
	local pCell = CEGUI.toItemCell(windowargs.window);
	local rowindex = math.floor(pCell:GetIndex() / 5);
	for i = 0, 5 - 1 do
		local cell = self.m_pSecondTable:GetCell(rowindex * 5 + i);
		cell:setMouseOnThisCell(true);
	end
	return true;
end

function CMainPackDlg:SetCanSellEquipSelect(bSelect)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local capacity = roleItemManager:GetBagCapacity(fire.pb.item.BagTypes.BAG);
	self:SetTableEquipSelectedState(self.m_pFirstTable, bSelect);
	if (capacity > 25 and capacity <= 50) then
		self:SetTableEquipSelectedState(self.m_pSecondTable, bSelect);
	elseif (capacity > 50 and capacity <= 75) then
		self:SetTableEquipSelectedState(self.m_pSecondTable, bSelect);
		self:SetTableEquipSelectedState(self.m_pThirdTable, bSelect);
	elseif (capacity > 75 and capacity <= 100) then
		self:SetTableEquipSelectedState(self.m_pSecondTable, bSelect);
		self:SetTableEquipSelectedState(self.m_pThirdTable, bSelect);
		self:SetTableEquipSelectedState(self.m_pFourthlyTable, bSelect);
	end
end

function CMainPackDlg:SetTableEquipSelectedState(pTable, bSelect)
	for index = 0, 25 - 1 do

		local itemCell = pTable:GetCell(index);
		if (itemCell:IsLock()) then
			break;
		end

		if (not bSelect) then
			if (itemCell:isSelected()) then
				itemCell:SetMutiSelected(false);
			end
		else
			local roleItemManager = require("logic.item.roleitemmanager").getInstance()
			local pItem = roleItemManager:getItem(itemCell:getID2(), fire.pb.item.BagTypes.EQUIP)
			if (pItem ~= nil and not pItem:isLock() and pItem:GetBaseObject().bCanSaleToNpc) then
				if (pItem:isWuJueLingEquip()) then
					itemCell:SetMutiSelected(self.m_eState == eMainPackState_NpcSellWuJue);
				else
					itemCell:SetMutiSelected(self.m_eState == eMainPackState_NpcSell);
				end
			end
		end

	end
end

function CMainPackDlg:OnSaveAntiqueConfirmOk(e)

	local windowargs = CEGUI.toWindowEventArgs(e);
	local pConfirmBoxInfo = tostConfirmBoxInfo(windowargs.window:getUserData());
	if (pConfirmBoxInfo) then
		local itemkey = pConfirmBoxInfo.userID;
		self:RequestSaveAntique(itemkey);
	end

	gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo);
	return true;
end

function CMainPackDlg:RequestSaveAntique(itemKey)

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local pItem = roleItemManager:FindItemByBagAndThisID(itemKey);
	if (pItem) then
		local page = gGetAntiqueType(pItem:GetBaseObject().itemtypeid);

	end

end

function CMainPackDlg:AddSaveAntiqueConfirm(pItem)

	if (pItem:isAntique()) then
		if (not pItem:isWordPuzzleAntique()) then
			local pObject = pItem:GetObject()
			if (pObject ~= nil) then
				if (pObject.antiqueLevel >= 4) then
					local TipsMsg = GameTable.message:GetCMessageTipTableInstance():getRecorder(142027);
					if (TipsMsg.id ~= -1) then
						local sb = STRB.CStringBuilderW();
						local msg = TipsMsg.msg;

						if (pItem and not msg:empty()) then
							sb:SetFormat("parameter1", "%s", pItem:GetName());
							local strLevel = MHSD_UTILS.get_resstring(2462 + 7 - pObject.antiqueLevel);
							sb:SetFormat("parameter2", "%s", strLevel);
							gGetMessageManager():AddConfirmBox(eConfirmSaveAntique, sb:GetString(msg),
							CMainPackDlg.OnSaveAntiqueConfirmOk, self,
							MessageManager.HandleDefaultCancelEvent, MessageManager,
							pItem:GetThisID());
						end

					end

				end
			end
		end
	end

end

function CMainPackDlg:HandleHideMoneyGuide(e)
	return true;
end

function CMainPackDlg:HandleShowMoneyGuide(e)
	local windowargs = CEGUI.toWindowEventArgs(e);
	if (self.m_pMoneyFlashEffect) then
	end
	return true;
end

function CMainPackDlg:HandleDrawMoneyBackFlash()


	if (self.m_pMoneyBack and self.m_pMoneyFlashEffect ~= nil) then
		local Pos = self.m_pMoneyBack:GetScreenPosOfCenter();
		local pt = Nuclear.NuclearPoint((Pos.x),(Pos.y));

		self.m_pMoneyFlashEffect:SetLocation(pt);
		Nuclear.GetEngine():DrawEffect(self.m_pMoneyFlashEffect);
	end

end

function CMainPackDlg:SetMoneyLimit(moneylimit)
	if (self.m_pMoneyFlashEffect == nil) then

	end

	self:UpdateMoneyNum();


end

function CMainPackDlg:SetMoneyBackFlash(bFlash)
	if (self.m_pMoneyBack) then
		local bIsFlashing = self.m_pMoneyBack:isFlash();
		if (bFlash and not bIsFlashing) then
			self.m_pMoneyBack:StartFlash();
			if (self.m_pMoneyFlashEffect == nil) then
				self.m_pMoneyFlashEffect = Nuclear.GetEngine():CreateEffect(MHSD_UTILS.get_effectpath(10203));
			end
			self.m_pMoneyIcon:setTooltipText("");
			self.m_pMoneyNum:setTooltipText("");


		elseif (not bFlash and bIsFlashing) then
			self.m_pMoneyBack:StopFlash();
			if (self.m_pMoneyFlashEffect ~= nil) then
				Nuclear.GetEngine():ReleaseEffect(self.m_pMoneyFlashEffect);
				self.m_pMoneyFlashEffect = nil;
			end

			if (self.m_pMoneyIcon:getTooltipText():empty()) then
			end

		end
	end


end

function CMainPackDlg:AddExpendCapacityEffect(capacity)
	local pPlayEffectCell = nil;

	if (pPlayEffectCell == nil) then
		return;
	end

	gGetGameUIManager():AddUIEffect(pPlayEffectCell, MHSD_UTILS.get_effectpath(10193), false);

end

function CMainPackDlg:CheckMaBuXingNangCellState()
	local index = 0;
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local capacity = roleItemManager:GetBagCapacity(fire.pb.item.BagTypes.BAG);

	for index = 0, 25 - 1 do

		local itemCell = self.m_pFirstTable:GetCell(index);

		if (itemCell:getID() == MaBuXingNangID and not itemCell:HasFloodLight()) then
			gGetGameUIManager():AddUIEffect(itemCell, MHSD_UTILS.get_effectpath(10221));
			itemCell:SetFloodLight(true);
		end
	end

	if (capacity > 25 and capacity <= 50) then
		while index < capacity do
			local itemCell = self.m_pSecondTable:GetCell(math.modf(index, 25));
			if (itemCell:getID() == MaBuXingNangID and not itemCell:HasFloodLight()) then
				gGetGameUIManager():AddUIEffect(itemCell, MHSD_UTILS.get_effectpath(10221));
				itemCell:SetFloodLight(true);
			end
			index = index + 1;
		end
	end
end

function CMainPackDlg:IsPageFull(pageindex)
	local pTable = nil;
	if (pageindex == 1) then
		pTable = self.m_pFirstTable;
	elseif (pageindex == 2) then
		pTable = self.m_pSecondTable;
	elseif (pageindex == 3) then
		pTable = self.m_pThirdTable;
	elseif (pageindex == 4) then
		pTable = self.m_pFourthlyTable;
	end

	if (pTable == nil) then
		return true;
	end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	local index = 0;
	for index = 0, 25 - 1 do

		local itemCell = pTable:GetCell(index);
		if (itemCell:IsLock()) then
			return true;
		end

		if (roleItemManager:getItem(itemCell:getID2(), fire.pb.item.BagTypes.BAG) == nil) then
			return false;
		end
	end


	return true;
end

function CMainPackDlg:EndUseTaskItem()
	self.m_eState = eMainPackState_Null;

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for index = 0, 25 - 1 do
		local itemCell = self.m_pQuestTable:GetCell(index);

		local pItem = roleItemManager:getItem(itemCell:getID2(), fire.pb.item.BagTypes.QUEST)
		if (pItem and pItem:IsAshy() == true) then
			pItem:SetAshy(false);
			return;
		end
	end

	local index = 0;
	local capacity = roleItemManager:GetBagCapacity(fire.pb.item.BagTypes.BAG);

	for index = 0, 25 - 1 do

		local itemCell = self.m_pFirstTable:GetCell(index);
		local pItem = roleItemManager:getItem(itemCell:getID2(), fire.pb.item.BagTypes.BAG)
		if (pItem and pItem:IsAshy() == true) then
			pItem:SetAshy(false);
			return;
		end
	end

	if (capacity > 25 and capacity <= 50) then
		while index < capacity do
			local itemCell = self.m_pSecondTable:GetCell(math.modf(index, 25));
			local pItem = roleItemManager:getItem(itemCell:getID2(), fire.pb.item.BagTypes.BAG)
			if (pItem and pItem:IsAshy() == true) then
				pItem:SetAshy(false);
				return;
			end
            index = index + 1
		end
	end

end


function CMainPackDlg:OnBattleEnd()
	self.m_pTidyBtn:setEnabled(true);
end

function CMainPackDlg:OnBattleBegin()
	self.m_pTidyBtn:setEnabled(false);
end


function CMainPackDlg:UpdataYuanBaoNum()

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local numStr = CEGUI.PropertyHelper:int64_tToString(roleItemManager:GetGold());
	self.m_pYuanBaoNum:setText(numStr);

end


function CMainPackDlg:SetNoneEquipItemCellEnable(benable)
	local index = 0;
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local capacity = roleItemManager:GetBagCapacity(fire.pb.item.BagTypes.BAG);
	for index = 0, 25 - 1 do
		local itemCell = self.m_pFirstTable:GetCell(index);
		if (itemCell) then
			if (benable) then
				itemCell:setEnabled(benable);
			else
				local pItem = roleItemManager:getItem(itemCell:getID2(), fire.pb.item.BagTypes.BAG)
				if (pItem and not pItem:CanRepair()) then
					itemCell:setEnabled(benable);
				end
			end
		end
	end

	while index < capacity do
		local itemCell = self.m_pSecondTable:GetCell(math.modf(index, 25));
		if (itemCell) then
			if (benable) then
				itemCell:setEnabled(benable);
			else
				local pItem = roleItemManager:getItem(itemCell:getID2(), fire.pb.item.BagTypes.BAG)
				if (pItem and not pItem:CanRepair()) then
					itemCell:setEnabled(benable);
				end
			end
		end
		index = index + 1;
	end
end

function CMainPackDlg:SetNoneFlyFlagItemCellEnable(benable)
	local index = 0;
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local capacity = roleItemManager:GetBagCapacity(fire.pb.item.BagTypes.BAG);
	for index = 0, 25 - 1 do
		local itemCell = self.m_pFirstTable:GetCell(index);
		if (itemCell) then
			if (benable) then
				itemCell:setEnabled(benable);
			else
				local pItem = roleItemManager:getItem(itemCell:getID2(), fire.pb.item.BagTypes.BAG)
				if (pItem and not pItem:CanSupplyFly()) then
					itemCell:setEnabled(benable);
				end
			end
		end
	end

	while index < capacity do
		local itemCell = self.m_pSecondTable:GetCell(math.modf(index, 25));

		if (itemCell) then
			if (benable) then
				itemCell:setEnabled(benable);
			else
				local pItem = roleItemManager:getItem(itemCell:getID2(), fire.pb.item.BagTypes.BAG)
				if (pItem and not pItem:CanSupplyFly()) then
					itemCell:setEnabled(benable);
				end
			end
		end
		index = index + 1;
	end
end

function CMainPackDlg:GetDialogType()
    return self.m_eState
end


function CMainPackDlg:SetDialogType(state)

	if (state == eMainPackState_Pearlrepair) then

		self:SetNoneEquipItemCellEnable(false);

	elseif (state == eMainPackState_FlyFlagSupply) then
		self:SetNoneFlyFlagItemCellEnable(false);
	elseif (self.m_eState == eMainPackState_Pearlrepair and state ~= eMainPackState_Pearlrepair) then
		self:SetNoneEquipItemCellEnable(true);
	elseif (self.m_eState == eMainPackState_FlyFlagSupply and state ~= eMainPackState_FlyFlagSupply) then
		self:SetNoneFlyFlagItemCellEnable(true);
	elseif (state == eMainPackState_UpgradePetXueMai or state == eMainPackState_ImportStarToPet) then

	elseif (state == eMainPackState_NpcSell) then
		self.m_eState = state;
		self:SetCanSellEquipSelect();

	elseif (state == eMainPackState_NpcSellWuJue) then
		self.m_eState = state;

		self:SetCanSellEquipSelect();


	elseif ((self.m_eState == eMainPackState_NpcSell or self.m_eState == eMainPackState_NpcSellWuJue) and state == eMainPackState_Null) then
		self:SetCanSellEquipSelect(false);
	end
	self.m_eState = state;
end

--[[
function CMainPackDlg:HandleShiftClickItem(pItem)
	if (GetChatManager()) then
		GetChatManager():HandleShiftClickItem(pItem);
	end
	return true;
end
--]]

function CMainPackDlg:HandleRightClickItem(pItem)
	if (self.m_eState == eMainPackState_NpcSell or self.m_eState == eMainPackState_NpcSellWuJue) then
		return true;

	elseif (self.m_eState == eMainPackState_GemLevelup) then
		if (true) then
			return true;

		else

			if (GetChatManager()) then
				GetChatManager():AddTipsMsg(141430);

			end
			return false;
		end
	elseif (self.m_eState == eMainPackState_ImportStarToPet) then


		if (pItem:GetItemTypeID() == PetCompose_ItemType)
		then
			return true;
		end
		return true;
	end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	if (roleItemManager:RightClickItem(pItem)) then
		return true;
	end
	return false;
end


function CMainPackDlg:HandleSpliteItem(pItem)
	if (pItem:GetNum() == 1) then

		local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(141176);
		if (tip.id ~= -1) then
			GetCTipsManager():AddMessageTip(tip.msg);
		end
	end

	return true;
end

function CMainPackDlg:HandleTableDoubleClick(e)
	local MouseArgs = CEGUI.toMouseEventArgs(e);

	local pCell = CEGUI.toItemCell(MouseArgs.window);

	if (pCell == nil) then
		return true;
	end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local pItem = roleItemManager:getItem(pCell:getID2(), fire.pb.item.BagTypes.BAG)
	if (pItem == nil or pItem:IsAshy() == true) then
		return true;
	end
	local nItemKey = pItem:GetThisID();
	local nBagId = pItem:GetLocation().tableType;
	--TODO 使用包里道具
	local status = Commontipdlg.UseItemCommon(nBagId, nItemKey, 0, 0);

	local dlg = require 'logic.tips.commontipdlg'.getInstanceNotCreate();
	if dlg then
		dlg:DestroyDialog();
	end

	if (status == 1) then
		return true;
	else
		return false;
	end
end

function CMainPackDlg:HandleUseItem(item)
	if (self:executeLuaUseItem(item)) then
		return true;
	end
	if (item:GetBaseObject().id == TurpetID or item:GetBaseObject().id == Guider_TrumpetID) then
		if (item:isLock()) then
			if (GetChatManager()) then
				GetChatManager():AddTipsMsg(141078);
			end
		else
		end
		return true;
	end

	if (item:GetBaseObject().id == BaoChan_ID) then
		self:OnClose();
		return true;
	end

	if (item:isAntique() and not item:isWordPuzzleAntique()) then
		self:AddSaveAntiqueConfirm(item);
	end

	return self:HandleRightClickItem(item);
end

function CMainPackDlg:executeLuaUseItem(item)
	local ret = UseItemHandler.useItem(item:GetLocation().tableType, item:GetThisID());
	return ret;
end

function CMainPackDlg:HandleUnequip(item)
	if (self.m_pEquipDialog) then
		self.m_pEquipDialog:Unequip(item);
		return true;
	end
	return false;
end

function CMainPackDlg:HandleTableClick(e)
	local MouseArgs = CEGUI.toMouseEventArgs(e);

	local pCell = CEGUI.toItemCell(MouseArgs.window);

	if (pCell == nil) then
		return true;
	end

	local pTable = CEGUI.toItemTable(pCell:getParent());
	if (pTable == nil) then
		return true;
	end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local cellID2 = pCell:getID2();
	local pItem = roleItemManager:getItem(cellID2, fire.pb.item.BagTypes.BAG)
	-- 判断是否需要移除引导
    if pItem then
        local id = pItem:GetBaseObject().id
        local equipAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(id)
        if equipAttrCfg == nil or (equipAttrCfg and equipAttrCfg.nautoeffect ~= 1) then
            NewRoleGuideManager.getInstance():removeEquipGuide()
        end
    end
	if (MouseArgs.button == CEGUI.LeftButton) then

		if (self.m_eState == eMainPackState_Pearlrepair) then
			if (pItem == nil) then
				if (GetChatManager()) then
					GetChatManager():AddTipsMsg(140509);
				end
				return true;
			elseif (not pItem:CanRepair()) then
				if (GetChatManager()) then
					GetChatManager():AddTipsMsg(143143);

				end
				return true;
			elseif (not pItem:IsIdentified()) then
				if (GetChatManager()) then
					GetChatManager():AddTipsMsg(142290);

				end
				return true;
			else
			end
		elseif (self.m_eState == eMainPackState_FlyFlagSupply) then
			if (pItem == nil) then
				GetCTipsManager():AddMessageTip(MHSD_UTILS.GETSTRING(1960));
				return true;
			elseif (not pItem:CanSupplyFly()) then
				GetCTipsManager():AddMessageTip(MHSD_UTILS.GETSTRING(1961));
				return true;
			else
				local pObject = pItem:GetObject()

				if (pObject.replenishtime <= 0) then
					if (GetChatManager()) then
						GetChatManager():AddTipsMsg(142864);

					end
					return true;
				else
				end
			end
		end
	end



	return true;
end

function CMainPackDlg:HandleShow(e)

	self:StartEquipItemGuide();

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	if (roleItemManager:GetBagCapacity(fire.pb.item.BagTypes.BAG) < 50 and self:GetFirstEmptyCell() == -1) then
		self:CheckMaBuXingNangCellState();
	end

	if (roleItemManager:GetItemNumByBaseID(MiHunXiangID) > 0) then

	end

	if (self.m_pTabControl:getSelectedTabIndex() == self.m_pTabControl:getTabCount() -1) then
		self.m_pTabControl:setSelectedTabAtIndex((0));
	end

	MainControl.SetPackBtnFlash();
	return true;
end

function CMainPackDlg:HandleHide(e)

	if (gGetDataManager():GetMainCharacterLevel() <= 15) then
	end

	if (self.m_pSelectCell) then
		self.m_pSelectCell:SetSelected(false);
		self.m_pSelectCell = nil;
	end
	return true;
end

function CMainPackDlg:HandleShopBtnClick(e)
    if IsPointCardServer() then
		require "handler.fire_pb_fushi"

		if b_fire_pb_fushi_OpenTrading == 1 then
			require("logic.shop.stalllabel").show(3)
		else
			GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(300011))
		end
                
        return true
    end

	ShopLabel.showCommerce();
	return true;
end

--点击清理背包
function CMainPackDlg:HandleCleanBagBtnClick()
	--1.判断背包里是否有物品
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local isEmpty = roleItemManager:IsMainPackEmpty()
	if isEmpty then
		GetCTipsManager():AddMessageTipById(191102)
		return true
	end
	--2.弹出确认框
	local function onConfirm(self, args)
		gGetMessageManager():CloseCurrentShowMessageBox()

		require "protodef.fire.pb.item.ccleantemppack";
		local clearitems = CCleanMainPack.Create();
		LuaProtocolManager.getInstance():send(clearitems);
		return true
	end

	local function onCancel(self, args)
		if CEGUI.toWindowEventArgs(args).handled ~= 1 then
			gGetMessageManager():CloseCurrentShowMessageBox()
		end
	end

	if gGetMessageManager() then
		gGetMessageManager():AddMessageBox(
				"", MHSD_UTILS.get_msgtipstring(191103),
				onConfirm, self, onCancel, self,
				eMsgType_Normal, 30000, 0, 0, nil,
				MHSD_UTILS.get_resstring(2037),
				MHSD_UTILS.get_resstring(2038))
	end
end

function CMainPackDlg:HandleTidyBtnClick(e)
	if ((self.m_eState ~= nil and self.m_eState ~= eMainPackState_Null and self.m_eState ~= eMainPackState_Deport and self.m_eState ~= eMainPackState_BuyNpcItem)) then

		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(141565).msg);
		return true;
	end

	if (os.time() - self.m_dwLastTidyTime > 3) then
		self.m_dwLastTidyTime = os.time();
		require "protodef.fire.pb.item.clistpack";
		local tidy = CListPack.Create();
		if self.m_pTabControl and 0 == self.m_pTabControl:getSelectedTabIndex() then
			tidy.packid = fire.pb.item.BagTypes.BAG;
		else
			tidy.packid = fire.pb.item.BagTypes.QUEST;
		end
		tidy.npcid = 0;
		LuaProtocolManager.getInstance():send(tidy);
	else
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(142109).msg);
	end
	return true;
end

function CMainPackDlg:UpdateMoneyNum()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	self.m_pMoneyNum:setText(formatMoneyString(roleItemManager:GetPackMoney()));
	self.m_pYuanBaoNum:setText(formatMoneyString(roleItemManager:GetGold()));
end

function CMainPackDlg:SwitchShowHideWindow()
	CMainPackDlg:ToggleOpenHide();
end

function CMainPackDlg:StartEquipItemGuide()
	local equipid = self.m_pTabControl:getID();
	if (equipid > 0) then

	end
end

function CMainPackDlg:SetQuestTabSelected()

	self.m_pTabControl:setSelectedTabAtIndex(self.m_pTabControl:getTabCount() -1);

end

function CMainPackDlg:GetFirstEmptyCell()
	local index = 0;
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local capacity = roleItemManager:GetBagCapacity(fire.pb.item.BagTypes.BAG);

	for index = 0, capacity - 1 do

		local itemCell = self.m_pFirstTable:GetCell(index);

		if (roleItemManager:getItem(itemCell:getID2(), fire.pb.item.BagTypes.BAG) == nil) then
			return index;
		end
	end

	return -1;
end

function CMainPackDlg:InitPageCellEvent(capactiy)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local capacityNew = roleItemManager:GetBagCapacity(fire.pb.item.BagTypes.BAG);
	local totalNum = roleItemManager:GetBagShowNum(fire.pb.item.BagTypes.BAG);
	for index = capacityNew, totalNum - 1 do
		local cellindex = index;
		local pCell = self.m_pFirstTable:GetCell(cellindex);

		pCell:subscribeEvent(CEGUI.ItemCell.EventLockCellClick, CMainPackDlg.HandleItemCellLockClick, self);

	end
end

function CMainPackDlg:ExpendPackCapacity()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local capacity = roleItemManager:GetBagCapacity(fire.pb.item.BagTypes.BAG);
	local totalNum = roleItemManager:GetBagShowNum(fire.pb.item.BagTypes.BAG);
	
	local tableSize = CalTableSize(self.m_pFirstTable, totalNum);
	self.m_pFirstTable:setSize(tableSize);

	self:InitPageCellEvent(capacity);

	GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(142307).msg);
	roleItemManager:InitTabCellLockState(self.m_pFirstTable, totalNum, totalNum - capacity);
	roleItemManager:InitBagItem(fire.pb.item.BagTypes.BAG);
	roleItemManager:InitBagItem(fire.pb.item.BagTypes.QUEST);
end

function CMainPackDlg:InitTabPos()
	local winMgr = CEGUI.WindowManager:getSingleton();
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local capacity = roleItemManager:GetBagCapacity(fire.pb.item.BagTypes.BAG);
	local totalNum = roleItemManager:GetBagShowNum(fire.pb.item.BagTypes.BAG);

	--任务物品栏
	self.m_pQuestTable = CEGUI.toItemTable(winMgr:getWindow("MainPackDlg/tabpanle/Table2"));
	self:AddTab(self.m_pQuestTable, fire.pb.item.BagTypes.QUEST);

	local rows = self.m_pQuestTable:GetRowCount();
	local cols = self.m_pQuestTable:GetColCount();
	self.m_Table2:SetItemTable(self.m_pQuestTable, rows, cols);

	local tableSize = CalTableSize(self.m_pQuestTable, rows * cols);
	self.m_pQuestTable:setSize(tableSize);

	self.m_pQuestTable:subscribeEvent(CEGUI.ItemCell.EventCellClick, CMainPackDlg.HandleShowSelect, self);

	--处理未解锁格子
	if (true) then
		self:InitPageCellEvent(capacity);
		roleItemManager:InitTabCellLockState(self.m_pFirstTable, totalNum, totalNum - capacity);
	end

	roleItemManager:InitBagItem(fire.pb.item.BagTypes.QUEST);

end

function CMainPackDlg:SwitchTab(next)
	local index = self.m_pTabControl:getSelectedTabIndex();
	if (next) then
		if (index < self.m_mTabBtnPageMap.size()) then
			index = index + 1;
			self.m_pTabControl:setSelectedTabAtIndex(index);
		end
	else
		if (index > 0) then
			index = index - 1;
			self.m_pTabControl:setSelectedTabAtIndex(index);
		end
	end
	LogInfo("switch index=" .. index);
end

function CMainPackDlg:HandleDrag(e)
	local gestureArgs = CEGUI.toGestureEventArgs(e);
	local panGesture = gestureArgs.d_Recognizer;
	if (panGesture:GetState() ~= CEGUI.Gesture.GestureRecognizerState.GestureRecognizerStateEnded) then
		return true;
	end
	local direction = panGesture:GetPanDirection();

	if direction == CEGUI.Gesture.UIPanGestureRecognizerDirection.UIPanGestureRecognizerDirectionLeft then
		SwitchTab(false);

	elseif direction == CEGUI.Gesture.UIPanGestureRecognizerDirection.UIPanGestureRecognizerDirectionRight then
		SwitchTab(true);

	else
	end

	return true;
end

function CMainPackDlg:AddTab(tab, ntype)
	tab:setMousePassThroughEnabled(true);
	tab:SetMulitySelect(false);
	tab:SetType(ntype);
	tab:subscribeEvent(CEGUI.ItemTable.EventTableClick, CMainPackDlg.HandleTableClick, self);
	tab:subscribeEvent(CEGUI.ItemTable.EventTableDoubleClick, CMainPackDlg.HandleTableDoubleClick, self);

	return true;
end

function CMainPackDlg:SetCellLockStateAfterExpand(capacity)
end

function CMainPackDlg:GetItemCellByPos(nPos, tableType)
	if (tableType == fire.pb.item.BagTypes.QUEST) then
		return self.m_pQuestTable:GetCell(nPos);
	end

	return self.m_pFirstTable:GetCell(nPos);
end


function CMainPackDlg:setScrollPosByCell(baseid)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local cell = roleItemManager:GetItemCellAtBag(baseid);
	if (cell) then
		local role = roleItemManager:GetItemByBaseID(baseid);
		local pos = role:GetLocation().position + 1;
		local count = GetNumberValueForStrKey("BAG_ITEMCELL_COUNT");
		if (pos > count) then
			local height = cell:getPixelSize().height;
			if (self.m_pTabControl.pane0) then
				self.m_pTabControl.pane0:getVertScrollbar():setScrollPosition(cell:getYPosition().offset - height / 2);
			end
		end
	end
end

function CMainPackDlg:SetMainPackItemSelect()

	local nColCount = self.m_pFirstTable:GetColCount();
	local nRowCount = self.m_pFirstTable:GetRowCount();
	for row = 0, nRowCount - 1 do
		for col = 0, nColCount - 1 do
			local index = row * nColCount + col;
			local pCell = self.m_pFirstTable:GetCell(index);
			pCell:SetHaveSelectedState(true);
		end
	end
end

function CMainPackDlg:OnCreate()
	super.OnCreate(self);
	self:InsertScriptFunctor(
	function()
		if gGetRoleItemManager() then
			return gGetRoleItemManager().m_EventPackMoneyChange;
		end
	end ,
	function()
		self:UpdateMoneyNum();
	end
	);

	self:InsertScriptFunctor(
	function()
		if gGetRoleItemManager() then
			return gGetRoleItemManager().m_EventDeportMoneyChange;
		end
	end ,
	function()
		self:UpdateMoneyNum();
	end );

	self:InsertScriptFunctor(
	function()
		if gGetScene() then
			return gGetScene().EventMapChange;
		end
	end ,
	function()
		self:OnMapChange();
	end );

	self:InsertScriptFunctor(
	function()
		if gGetRoleItemManager() then
			return gGetRoleItemManager().m_EventPackGoldChange;
		end
	end ,
	function()
		self:UpdateMoneyNum();
	end );

	local winMgr = CEGUI.WindowManager:getSingleton();
	self.m_pEquipDialog = CEquipDialog.new(self:GetWindow());
	self.m_pEquipDialog:OnCreate();
	--self.m_pTabControl = CEGUI.toTabControl(winMgr:getWindow("MainPackDlg/tabpanle"));
	--self.m_pTabControl:subscribeEvent(CEGUI.TabControl.EventSelectionChanged, CMainPackDlg.HandleSelectTable, self);

	self:loadTabPane()


	self.m_pMoneyNum = CEGUI.toWindow(winMgr:getWindow("MainPackDlg/money"));
	self.m_pMoneyIcon = CEGUI.toWindow(winMgr:getWindow("MainPackDlg/money1"));
	self.m_pMoneyBack = CEGUI.toWindow(winMgr:getWindow("MainPackDlg/Back3"));
	self.m_pMoneyNum:subscribeEvent(CEGUI.Window.EventMouseEnters, CMainPackDlg.HandleShowMoneyGuide, self);
	self.m_pMoneyNum:subscribeEvent(CEGUI.Window.EventMouseLeaves, CMainPackDlg.HandleHideMoneyGuide, self);

	self.m_pTidyBtn = CEGUI.toPushButton(winMgr:getWindow("MainPackDlg/tidy"));
	self.m_pSellToNpcBtn = CEGUI.toPushButton(winMgr:getWindow("MainPackDlg/tidy1"));
	self.m_pShopBtn = CEGUI.toPushButton(winMgr:getWindow("MainPackDlg/tidy2"));
	self.m_pCleanBagBtn = CEGUI.toPushButton(winMgr:getWindow("MainPackDlg/tidy3"));

	local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            self.m_pShopBtn:setText(MHSD_UTILS.get_resstring(11508))
            local funopenclosetype = require("protodef.rpcgen.fire.pb.funopenclosetype"):new()
            local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
            if manager then
                if manager.m_OpenFunctionList.info then
                    for i,v in pairs(manager.m_OpenFunctionList.info) do
                        if v.key == funopenclosetype.FUN_CHECKPOINT then
                            if v.state == 1 then
                                self.m_pShopBtn:setVisible(false)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
	--背包table
	self.m_pFirstTable = CEGUI.toItemTable(winMgr:getWindow("MainPackDlg/tabpanle/Table1"));
	local nRowCount = self.m_pFirstTable:GetRowCount();
	local nColCount = self.m_pFirstTable:GetColCount();

	self:AddTab(self.m_pFirstTable, fire.pb.item.BagTypes.BAG);
	--self.m_Table1 -> GameItemTable
	self.m_Table1:SetItemTable(self.m_pFirstTable, nRowCount, nColCount, true);
	
	for row = 0, nRowCount - 1 do
		for col = 0, nColCount - 1 do
			local index = row * nColCount + col;
			local pCell = self.m_pFirstTable:GetCell(index);
			if (nil ~= pCell) then
				pCell:subscribeEvent(CEGUI.ItemCell.EventCellClick, CMainPackDlg.HandleShowSelect, self);
			end
		end
	end

	--背包格点击事件
	self.m_pFirstTable:subscribeEvent(CEGUI.ItemCell.EventCellClick, CMainPackDlg.HandleShowSelect, self);

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	--背包格数
	local capacity = roleItemManager:GetBagCapacity(fire.pb.item.BagTypes.BAG);
	local totalNum = roleItemManager:GetBagShowNum(fire.pb.item.BagTypes.BAG);

	--计算背包尺寸
	local tableSize = CalTableSize(self.m_pFirstTable, totalNum);
	self.m_pFirstTable:setSize(tableSize);

	--操作按钮s
	self.m_pTidyBtn:subscribeEvent(CEGUI.PushButton.EventClicked, CMainPackDlg.HandleTidyBtnClick, self);
	self.m_pShopBtn:subscribeEvent(CEGUI.PushButton.EventClicked, CMainPackDlg.HandleShopBtnClick, self);
	self.m_pCleanBagBtn:subscribeEvent(CEGUI.PushButton.EventClicked, CMainPackDlg.HandleCleanBagBtnClick, self);

	--貌似是处理任务背包
	self:InitTabPos();

	self:GetWindow():subscribeEvent(CEGUI.Window.EventHidden, CMainPackDlg.HandleHide, self);
	self:GetWindow():subscribeEvent(CEGUI.Window.EventShown, CMainPackDlg.HandleShow, self);

    self.m_AddMoney = CEGUI.toPushButton(winMgr:getWindow("MainPackDlg/jia1"))
    self.m_AddMoney:subscribeEvent("MouseClick", CMainPackDlg.handleAddMoneyClicked, self)

    self.m_AddMoney2 = CEGUI.toPushButton(winMgr:getWindow("MainPackDlg/jia2"))
    self.m_AddMoney2:subscribeEvent("MouseClick", CMainPackDlg.HandleExchangeBtnClicked, self)

    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            self.m_AddMoney:setVisible(false)
        end
    end

	self.m_pTabControl:setSelectedTabAtIndex(0);
	--初始化背包item
	roleItemManager:InitBagItem(fire.pb.item.BagTypes.BAG);

	self.m_pYuanBaoNum = CEGUI.toWindow(winMgr:getWindow("MainPackDlg/yuanbao"));
	self:InsertScriptFunctor(
	function()
		if gGetDataManager() then
			return gGetDataManager().m_EventYuanBaoNumberChange;
		end
	end ,
	function()
		self:UpdataYuanBaoNum();
	end );

	self:UpdataYuanBaoNum();

	self.m_pMoneyBack:SetEnableFlash(false);
	local pMoneyEffect = GameUImanager:createXPRenderEffect(0, function(id)
		local pMainPackDlg = CMainPackDlg:getInstanceOrNot();
		if pMainPackDlg then
			pMainPackDlg:HandleDrawMoneyBackFlash();
		end
	end );
	self.m_pMoneyBack:getGeometryBuffer():setRenderEffect(pMoneyEffect);

	local tabBtn = self.m_pTabControl:getTabButtonAtIndex(0);
	self.m_mTabBtnPageMap[tabBtn] = 1;


	local level = gGetDataManager():GetMainCharacterLevel();
	local limit = BeanConfigManager.getInstance():GetTableByName("role.cresmoneyconfig"):getRecorder(level).resmoney;
	self:SetMoneyLimit(limit);

	self:GetWindow():subscribeEvent(CEGUI.Window.EventMoved, CMainPackDlg.HandleWindowPosChange, self);

	self.m_pTabControl.pane0:EnableAllChildDrag(self.m_pTabControl.pane0);
	self.m_pTabControl.pane1:EnableAllChildDrag(self.m_pTabControl.pane1);

	LuaNotifyMainPackDlgCreated();

	SetPositionOfWindowWithLabel(self.m_pMainFrame);

    -- 背包不足引导
    
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    if roleItemManager:GetBagEmptyNum(fire.pb.item.BagTypes.BAG) < 5 then
        local guideId = GetNumberValueForStrKey("NEW_GUIDE_PACK")
        if not NewRoleGuideManager.getInstance():isGuideFinish(guideId) and roleItemManager:GetBagIsEmpty(fire.pb.item.BagTypes.DEPOT) == true then
            NewRoleGuideManager.getInstance():AddToWaitingList(guideId)
        end
    end
end
function CMainPackDlg:handleAddMoneyClicked(e)
	local dlg = StoneExchangeGoldDlg.getInstanceAndShow()
	dlg:GetWindow():setAlwaysOnTop(true)
end
function CMainPackDlg:HandleExchangeBtnClicked(e)
	local dlg = require "logic.currency.stonegoldexchangesilverdlg".getInstanceAndShow()
	dlg:GetWindow():setAlwaysOnTop(true)
end

function CMainPackDlg:SetMBagOffset()
       if  self.m_pTabControl then
            local offset = self.m_pTabControl.pane0:getVertScrollbar():getScrollPosition()
            SetBagOffset(offset) 
       end
end

function CMainPackDlg:GetMBagOffset()
     return GetBagOffset()
end

function CMainPackDlg:loadTabPane()
	local winMgr = CEGUI.WindowManager:getSingleton();
	local tabCtrl = { id = 0, selectedIdx = 0 }
	self.m_pTabControl = tabCtrl

	tabCtrl.window = winMgr:getWindow("MainPackDlg/tabpanle")
	tabCtrl.button0 = CEGUI.toGroupButton(winMgr:getWindow("MainPackDlg/tabpanle/bagbtn"))
	tabCtrl.button1 = CEGUI.toGroupButton(winMgr:getWindow("MainPackDlg/tabpanle/taskbtn"))

	tabCtrl.pane0 = CEGUI.toScrollablePane(winMgr:getWindow("MainPackDlg/scrolllabelpane"));
	tabCtrl.pane1 = CEGUI.toScrollablePane(winMgr:getWindow("MainPackDlg/scrolllabelpane2"));
	tabCtrl.pane0:setVisible(true)

    if (tabCtrl.pane0) then
		tabCtrl.pane0:getVertScrollbar():setScrollPosition(CMainPackDlg.GetSingleton():GetMBagOffset())
	end

	function tabCtrl:handleGroupButtonClicked(args)
		local btn = CEGUI.toWindowEventArgs(args).window
		self.pane0:setVisible( btn == self.button0 )
		self.pane1:setVisible( btn == self.button1 )
		if(btn == self.button0)then
			self.selectedIdx = 0;
		elseif(btn == self.button1)then
			self.selectedIdx = 1;
		end
        CMainPackDlg.GetSingleton():SetMBagOffset()
	end

	tabCtrl.button0:subscribeEvent("SelectStateChanged", tabCtrl.handleGroupButtonClicked, tabCtrl)
	tabCtrl.button1:subscribeEvent("SelectStateChanged", tabCtrl.handleGroupButtonClicked, tabCtrl)

	function tabCtrl:getTabButtonAtIndex(idx)
		return self["button" .. idx]
	end

	function tabCtrl:getSelectedTabIndex()
		return self.selectedIdx
	end

	function tabCtrl:getTabCount()
		return 2
	end

	function tabCtrl:setSelectedTabAtIndex(idx)
		if self["button" .. idx] then
			self["button" .. idx]:setSelected(true)
		end
		self.selectedIdx = idx;
	end

	function tabCtrl:setID(id)
		self.id = id
	end

	function tabCtrl:getID()
		return self.id
	end
end

function CMainPackDlg:showEffectOnEquipCell(nSecondType, nEffectId)
	if (self.m_pEquipDialog) then
		self.m_pEquipDialog:showEffectOnEquipCell(nSecondType, nEffectId);
	end

end

function CMainPackDlg:OnMapChange()
end

function CMainPackDlg:GetLayoutFileName()
	return "mainpackdlg1.layout";
end

function CMainPackDlg:OnClose()
    CMainPackDlg.GetSingleton():SetMBagOffset()
	if (self.m_pMoneyFlashEffect ~= nil) then
		Nuclear.GetEngine():ReleaseEffect(self.m_pMoneyFlashEffect);
		self.m_pMoneyFlashEffect = nil;
	end
	if (self.m_pEquipDialog) then
		self.m_pEquipDialog:DestroyDialog();
		self.m_pEquipDialog:delete();
		self.m_pEquipDialog = nil;
	end

	if (gGetMessageManager()) then
		gGetMessageManager():CloseConfirmBox(eConfirmDropItem);
		gGetMessageManager():CloseConfirmBox(eConfirmPearlRepair);
		gGetMessageManager():CloseConfirmBox(eConfirmSupplyFlag);
	end

	super.OnClose(self);

	LuaNotifyMainPackDlgDestory();
end

function CMainPackDlg:addEquipEffect(effectId)
	self.m_pEquipDialog:addEquipEffect(effectId);
end

function CMainPackDlg:removeEquipEffect()
	self.m_pEquipDialog:removeEquipEffect();
end

function CMainPackDlg:showEffectOnCell(nEffectId, nBagId, nItemKey)
end

function CMainPackDlg.new()
	local obj = { };
	setmetatable(obj, CMainPackDlg);

	obj.m_bShowEquipDialog = true;
	obj.m_pSecondTable = nil;
	obj.m_pThirdTable = nil;
	obj.m_pFourthlyTable = nil;
	obj.m_pQuestTable = nil;
	obj.m_eState = enil;
	obj.m_dwLastTidyTime = 0;
	obj.m_pMoneyBack = nil;
	obj.m_pMoneyFlashEffect = nil;
	obj.m_pSelectCell = nil;
	obj.m_pSelectCellNew = nil;
	obj.m_eDialogType = { }
	obj.m_eDialogType[DialogTypeTable.eDialogType_BattleClose] = 1;

	obj.m_Table1 = GameItemTable:new(fire.pb.item.BagTypes.BAG);
	obj.m_Table2 = GameItemTable:new(fire.pb.item.BagTypes.QUEST);

	obj.m_mTabBtnPageMap = { };

	return obj;
end

function CMainPackDlg:UpdataModel()
	if (self.m_pEquipDialog) then
		self.m_pEquipDialog:UpdataModel();
	end
end

function CMainPackDlg:HandleShowSelect(e)
	local MouseArgs = CEGUI.toMouseEventArgs(e);

    NewRoleGuideManager.getInstance():removeEquipGuide()
	local pCellOld = CMainPackDlg.GetSingleton():GetItemSelectCellNew();
	if (pCellOld ~= nil) then
		pCellOld:SetSelected(false);
	end
	local pCell = CEGUI.toItemCell(MouseArgs.window);

	if (pCell == nil) then
		return false;
	else
		pCell:SetSelected(true);
		CMainPackDlg.GetSingleton():SetItemSelectCellNew(pCell);
	end
	return true;
end

function CMainPackDlg.GetSingleton()
	return CMainPackDlg:getInstance();
end

function CMainPackDlg:getInstance()
	if not self._instance then
		self._instance = CMainPackDlg.new();
		self._instance:OnCreate();
	end
	return self._instance;
end

function CMainPackDlg:GetSingletonDialogAndShowIt()
	if not self._instance then
		self._instance = CMainPackDlg.new();
		self._instance:OnCreate();
	end
	if not self._instance:IsVisible() then
		self._instance:SetVisible(true);
	end
	return self._instance;
end



return CMainPackDlg;
