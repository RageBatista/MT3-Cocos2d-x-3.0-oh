local super = require "logic.singletondialog"
require "logic.item.EquipDialog"
require "logic.dialog"
require "logic.item.cleanbagyzm"
require "logic.item.cleanfjzbyzm"
require "logic.item.cleanfjbsyzm"
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
local function encodeBase64(source_str)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local s64 = ''
    local str = source_str
 
    while #str > 0 do
        local bytes_num = 0
        local buf = 0
 
        for byte_cnt=1,3 do
            buf = (buf * 256)
            if #str > 0 then
                buf = buf + string.byte(str, 1, 1)
                str = string.sub(str, 2)
                bytes_num = bytes_num + 1
            end
        end
 
        for group_cnt=1,(bytes_num+1) do
            local b64char = math.fmod(math.floor(buf/262144), 64) + 1
            s64 = s64 .. string.sub(b64chars, b64char, b64char)
            buf = buf * 64
        end
 
        for fill_cnt=1,(3-bytes_num) do
            s64 = s64 .. '='
        end
    end
 
    return s64
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
				cell:SetBackGroundImage("ccui1", "kuang2");
			elseif i == eEquipType_ADORN then
				cell:SetImage("ccui1", "shipin");
			elseif i == eEquipType_LORICAE then
				cell:SetImage("ccui1", "yifu");
			elseif i == eEquipType_ARMS then
				cell:SetImage("ccui1", "wuqi");
			elseif i == eEquipType_TIRE then
				cell:SetImage("ccui1", "toubu");
			elseif i == eEquipType_KITBAG then
				cell:SetBackGroundImage("ccui1", "kuang2");
			elseif i == eEquipType_BOOT then
				cell:SetImage("ccui1", "jiao");
			elseif i == eEquipType_WAISTBAND then
				cell:SetImage("ccui1", "yaodai");
			elseif i == eEquipType_EYEPATCH then
				cell:SetBackGroundImage("ccui1", "kuang2");
			elseif i == eEquipType_RESPIRATOR then
				cell:SetBackGroundImage("ccui1", "kuang2");
			elseif i == eEquipType_VEIL then
				cell:SetBackGroundImage("ccui1", "kuang2");
			elseif i == eEquipType_FASHION then
				cell:SetBackGroundImage("ccui1", "kuang2");
			else
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
	elseif loc == eEquipType_KITBAG then
		return "toubu";
	elseif loc == eEquipType_BOOT then
		return "jiao";
	elseif loc == eEquipType_WAISTBAND then
		return "yaodai";
	elseif loc == eEquipType_VEIL then
		return "shipin";
	elseif loc == eEquipType_FASHION5 then---坐骑
		return "zuoqi";
	elseif loc == eEquipType_CLOAK then     --星环
	    return "xingying2";
	elseif loc == eEquipType_EYEPATCH then  --星环
	    return "xinghuang";
	elseif loc == eEquipType_RESPIRATOR then--星环
		return "xinghuang";
	elseif loc == eEquipType_FASHION1 then--法宝
	    return "fabao";
	elseif loc == eEquipType_FASHION2 then--法宝
	    return "fabao";
	elseif loc == eEquipType_FASHION3 then--法宝
	    return "fabao";
	elseif loc == eEquipType_FASHION4 then--法宝
		return "fabao";
	elseif loc == eEquipType_FASHION then
		return "shipin";

	else
	end
	return "shipin";

end

function CMainPackDlg:GetNormalBackImage(loc)
	return "tm";
end



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
	local yuanbaonum = gGetDataManager():GetYuanBaoNumber()
	local cash =  MoneyFormat(yuanbaonum)
	local data = gGetDataManager():GetMainCharacterData()
	local Rong = data:GetScoreValue(fire.pb.attr.RoleCurrency.HONOR_SCORE)
	self.m_pYuanBaoNum:setText(numStr);
	self.m_Yuanbaonum:setText(cash);
	self.m_RongYuNum:setText(Rong);
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
	-- �ж��Ƿ���Ҫ�Ƴ�����
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

	self.m_pQuestTable = CEGUI.toItemTable(winMgr:getWindow("MainPackDlg/tabpanle/Table2"));
	self:AddTab(self.m_pQuestTable, fire.pb.item.BagTypes.QUEST);

	local rows = self.m_pQuestTable:GetRowCount();
	local cols = self.m_pQuestTable:GetColCount();
	self.m_Table2:SetItemTable(self.m_pQuestTable, rows, cols);

	local tableSize = CalTableSize(self.m_pQuestTable, rows * cols);
	self.m_pQuestTable:setSize(tableSize);

	self.m_pQuestTable:subscribeEvent(CEGUI.ItemCell.EventCellClick, CMainPackDlg.HandleShowSelect, self);

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

function CMainPackDlg:OnLButtonUp()
    local annUI = self and self.annUI
    if not annUI then
        return
    end

    if not annUI:isVisible() then
        return
    end

    local targetWnd = CheckTipsWnd.GetCursorWindow()
    if not targetWnd or (targetWnd ~= annUI and not targetWnd:isAncestor(annUI)) then
        annUI:setVisible(false)
    end
end

function CMainPackDlg:OnLButtonDown()
    local annUI = self and self.annUI
    if not annUI then
        return
    end

    if not annUI:isVisible() then
        return
    end

    local targetWnd = CheckTipsWnd.GetCursorWindow()
    if not targetWnd or (targetWnd ~= annUI and not targetWnd:isAncestor(annUI)) then
        annUI:setVisible(false)
    end
end

function CMainPackDlg:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.7)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
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

	-- 界面（先初始化，避免事件回调先触发导致 annUI 为空）
	self.annUI = winMgr:getWindow("MainPackDlg/btnmore")
	if self.annUI then
		self.annUI:setVisible(false)
	end

	-- 滑动窗口
	self.cc_scrollPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("MainPackDlg/btnmorecc/hdck"))

	self.m_pEquipDialog = CEquipDialog.new(self:GetWindow());
	self.m_pEquipDialog:OnCreate();

	self:loadTabPane()

	self.m_pMoneyNum = CEGUI.toWindow(winMgr:getWindow("MainPackDlg/money"));
	self.m_pMoneyIcon = CEGUI.toWindow(winMgr:getWindow("MainPackDlg/money1"));
	self.m_pMoneyBack = CEGUI.toWindow(winMgr:getWindow("MainPackDlg/Back3"));
	self.m_pMoneyNum:subscribeEvent(CEGUI.Window.EventMouseEnters, CMainPackDlg.HandleShowMoneyGuide, self);
	self.m_pMoneyNum:subscribeEvent(CEGUI.Window.EventMouseLeaves, CMainPackDlg.HandleHideMoneyGuide, self);

	self.m_pTidyBtn = CEGUI.toPushButton(winMgr:getWindow("MainPackDlg/tidy"));----整理
	    local tidyBtnPressAnimationDef = CEGUI.AnimationManager:getSingleton():getAnimation("studyBtnPress")  --  studyBtnPress
    if tidyBtnPressAnimationDef then
        local tidyBtnPressAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(tidyBtnPressAnimationDef)
        tidyBtnPressAnimation:setTargetWindow(self.m_pTidyBtn)
        tidyBtnPressAnimation:setSpeed(0.7)  -- 设置动画速度

        self.m_pTidyBtn:subscribeEvent("MouseButtonDown", 
            function()
                tidyBtnPressAnimation:start()  -- 播放动画
            end, self)
    end
    self.m_pTidyBtn:subscribeEvent(CEGUI.PushButton.EventClicked, CMainPackDlg.HandleTidyBtnClick, self);
    
	-- 更多按钮
	self.gengduo = CEGUI.toPushButton(winMgr:getWindow("MainPackDlg/gengduo"))
    local gengduoBtnPressAnimationDef = CEGUI.AnimationManager:getSingleton():getAnimation("studyBtnPress") -- studyBtnPress
    if gengduoBtnPressAnimationDef then
        local gengduoBtnPressAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(gengduoBtnPressAnimationDef)
        gengduoBtnPressAnimation:setTargetWindow(self.gengduo)
        gengduoBtnPressAnimation:setSpeed(0.7) -- 设置动画速度

        self.gengduo:subscribeEvent("MouseButtonDown",
        function()
            gengduoBtnPressAnimation:start() -- 播放动画
        end, self)
    end
    
    -- 控制显示和隐藏
    self.gengduo:subscribeEvent("Clicked", 
    function() 
        local expandAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation("annUIExpand") -- 动画
        expandAnimation:setTargetWindow(self.annUI)  -- 窗口
    
        if self.annUI and not self.annUI:isVisible() then
            self.annUI:setVisible(true) -- 显示
			if self.cc_scrollPane then
				self.cc_scrollPane:setVerticalScrollPosition(0) -- 强制回到最上面，防止玩家手贱点击清包
			end
            expandAnimation:start() -- 动画
        elseif self.annUI then
            self.annUI:setVisible(false) -- 隐藏 
        end
    end, self) 
	
    -- 染色按钮
	self.ChongWuBtn = CEGUI.toPushButton(winMgr:getWindow("MainPackDlg/equip"))--外观按钮
    self.ChongWuBtn:subscribeEvent("MouseClick", self.handleCombineTipClicked, self)
	
	-- 法宝进阶按钮
	self.cc_fbjinjie = CEGUI.toPushButton(winMgr:getWindow("EquipDialog/Back/Pattern/ccjiemian2/fabaojinjie"))
	self.cc_fbjinjie:subscribeEvent("MouseClick", CMainPackDlg.handlejinjieClicked, self)
	
	-- 法宝逆转按钮
	self.cc_fbnizhuan = CEGUI.toPushButton(winMgr:getWindow("EquipDialog/Back/Pattern/ccjiemian2/fabaonizhuang"))
	self.cc_fbnizhuan:subscribeEvent("MouseClick", CMainPackDlg.handlenizhuanClicked, self)
	
    self:GetWindow():subscribeEvent("MouseButtonUp", CMainPackDlg.OnLButtonUp, self)
	self:GetWindow():subscribeEvent("MouseButtonDown", CMainPackDlg.OnLButtonDown, self)
	
	-- 出售按钮
	self.cc_chushou = CEGUI.toPushButton(winMgr:getWindow("MainPackDlg/chushou"))
	self.cc_chushou:subscribeEvent("Clicked", function() self.annUI:setVisible(false) end, self)
	self.cc_chushou:subscribeEvent("MouseClick", CMainPackDlg.handlechushouClicked, self)
	
	-- 清空按钮
	self.m_pCleanBagBtn = CEGUI.toPushButton(winMgr:getWindow("MainPackDlg/qingkong")); 
	self.m_pCleanBagBtn:subscribeEvent("Clicked", function() self.annUI:setVisible(false) end, self)
	self.m_pCleanBagBtn:subscribeEvent(CEGUI.PushButton.EventClicked, CMainPackDlg.HandleCleanBagBtnClick, self);
	
	-- 装备分解
	self.m_pFenJieEquipBtn = CEGUI.toPushButton(winMgr:getWindow("MainPackDlg/fenjieequip"));
	self.m_pFenJieEquipBtn:subscribeEvent("Clicked", function() self.annUI:setVisible(false) end, self)
	self.m_pFenJieEquipBtn:subscribeEvent(CEGUI.PushButton.EventClicked, CMainPackDlg.HandleFenJieEquipBtnClick, self);
	
	-- 宝石分解
	self.m_pFenJieGemBtn = CEGUI.toPushButton(winMgr:getWindow("MainPackDlg/fenjiegem")); 
	self.m_pFenJieGemBtn:subscribeEvent("Clicked", function() self.annUI:setVisible(false) end, self)
	self.m_pFenJieGemBtn:subscribeEvent(CEGUI.PushButton.EventClicked, CMainPackDlg.HandleFenJieGemBtnClick, self);
	
	-- 四个按钮组
	local buttons = { self.cc_chushou, self.m_pCleanBagBtn, self.m_pFenJieEquipBtn, self.m_pFenJieGemBtn }
    for _, button in ipairs(buttons) do
        self.cc_scrollPane:addChildWindow(button) 
    end
	
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

	self.m_pFirstTable = CEGUI.toItemTable(winMgr:getWindow("MainPackDlg/tabpanle/Table1"));
	local nRowCount = self.m_pFirstTable:GetRowCount();
	local nColCount = self.m_pFirstTable:GetColCount();

	self:AddTab(self.m_pFirstTable, fire.pb.item.BagTypes.BAG);

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

	self.m_pFirstTable:subscribeEvent(CEGUI.ItemCell.EventCellClick, CMainPackDlg.HandleShowSelect, self);

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	local capacity = roleItemManager:GetBagCapacity(fire.pb.item.BagTypes.BAG);
	local totalNum = roleItemManager:GetBagShowNum(fire.pb.item.BagTypes.BAG);

	local tableSize = CalTableSize(self.m_pFirstTable, totalNum);
	self.m_pFirstTable:setSize(tableSize);

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
	roleItemManager:InitBagItem(fire.pb.item.BagTypes.BAG);

	self.m_pYuanBaoNum = CEGUI.toWindow(winMgr:getWindow("MainPackDlg/yuanbao"));
	self.m_Yuanbaonum = CEGUI.toWindow(winMgr:getWindow("MainPackDlg/xianyu"));--��������
	self.m_RongYuNum = CEGUI.toWindow(winMgr:getWindow("MainPackDlg/rongyuzhi"));--��������ֵ
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
    --黑边

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    if roleItemManager:GetBagEmptyNum(fire.pb.item.BagTypes.BAG) < 5 then
        local guideId = GetNumberValueForStrKey("NEW_GUIDE_PACK")
        if not NewRoleGuideManager.getInstance():isGuideFinish(guideId) and roleItemManager:GetBagIsEmpty(fire.pb.item.BagTypes.DEPOT) == true then
            NewRoleGuideManager.getInstance():AddToWaitingList(guideId)
        end
    end
end

--function CMainPackDlg:handleAddMoneyClicked(e)--兑换金币
	--local dlg = StoneExchangeGoldDlg.getInstanceAndShow()--兑换金币
	--dlg:GetWindow():setAlwaysOnTop(true)--兑换金币
--end--兑换金币

function CMainPackDlg:handleAddMoneyClicked(args)----金币加号跳转到商城页面
require("logic.shop.shoplabel").getInstance():showOnly(2)
end

function CMainPackDlg:HandleExchangeBtnClicked(e)
	local dlg = require "logic.currency.stonegoldexchangesilverdlg".getInstanceAndShow()
	dlg:GetWindow():setAlwaysOnTop(true)
end

function CMainPackDlg:handlechushouClicked(args)----出售界面
	local dlg = require "logic.shop.commerceselldlg".getInstanceAndShow()
	dlg:GetWindow():setAlwaysOnTop(true)
end

function CMainPackDlg:handlejinjieClicked(args)----法宝进阶
    local dlg = require "logic.workshop.workshopaq".getInstanceAndShow()
	dlg:GetWindow():setAlwaysOnTop(true)
end

function CMainPackDlg:handlenizhuanClicked(args)----法宝重铸
    local dlg = require "logic.workshop.zhuangbeichongzhu".getInstanceAndShow()
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

function CMainPackDlg:HandleCleanBagBtnClick()-- 清空包裹 谨慎使用
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local isEmpty = roleItemManager:IsMainPackEmpty()
	if isEmpty then
		GetCTipsManager():AddMessageTipById(191284)
		return true
	end
	CleanBagyzm.getInstanceAndShow()
end

function CMainPackDlg:HandleFenJieEquipBtnClick()-- 分解装备
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local isEmpty = roleItemManager:isHaveEquip()
    -- 分解装备
    if not isEmpty then 
        -- 没有就提示：客户端提示表
        GetCTipsManager():AddMessageTipById(191286) 
        return true 
    else
        -- 有就跳转
        Cleanfjzbyzm.getInstanceAndShow()
    end
end

function CMainPackDlg:HandleFenJieGemBtnClick()-- 分解宝石
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local isEmpty = roleItemManager:isHaveGem()
    --  分解宝石
    if not isEmpty then
	   -- 没有就提示：客户端提示表
        GetCTipsManager():AddMessageTipById(191285)
        return true
    end
	-- 有就跳转
    Cleanfjbsyzm.getInstanceAndShow()
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
function CMainPackDlg:handleCombineTipClicked()--衣橱按钮
    self:DestroyDialog();

debugrequire"logic.ranse.charactershizhuangdlg".getInstanceAndShow()   --时装打开事件
--require("logic.ranse.ranselabel").Show(2)--衣橱
--require"logic.workshop.zhuangbeiqh".getInstanceAndShow()
end


return CMainPackDlg;
