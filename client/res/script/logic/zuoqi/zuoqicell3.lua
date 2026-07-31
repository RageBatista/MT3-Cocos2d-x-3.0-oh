

local super = require "logic.singletondialog";
local _instance
local sCellNum = 12;
local index = 0;
local _item1id = 0;
local clid =0;
ZuoQiCell3 = { };
setmetatable(ZuoQiCell3, super);
ZuoQiCell3.__index = ZuoQiCell3;

function ZuoQiCell3_GetItemCellByPos(pos)
	local dlg = ZuoQiCell3:getInstanceOrNot();
	if dlg then
		return dlg:GetItemCellByPos(pos);
	end
	return nil;
end

function ZuoQiCell3_IsVisible()
	local dlg = ZuoQiCell3:getInstanceOrNot();
	if dlg then
		return dlg:IsVisible();
	end
	return false;
end

function ZuoQiCell3_GetSingleton()
	if ZuoQiCell3:getInstanceOrNot() then
		return 1;
	else
		return 0;
	end
end

function ZuoQiCell3:HandleConfirmGetBack(e)

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



function ZuoQiCell3:HandleGetBack(e)


	if clid~=0 then
	  require "logic.zuoqi.wenshihc".getInstanceNotCreate():UpdateWenShi1(index,clid)
		self:DestroyDialog();
	end

	--	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(150147);
	--	if (tip.id ~= -1) then
	--		GetCTipsManager():AddMessageTip(tip.msg, false);
	--	end
	--	return true;



	return true;
end
function ZuoQiCell3:HandleBack(e)
	self:DestroyDialog();
	return true;
end
function ZuoQiCell3:HandleCloseBtnClick(e)
	self:DestroyDialog();
	return true;
end

function ZuoQiCell3:SetVisible(bVisible)
	super.SetVisible(self, bVisible);
	if (bVisible) then
		MainControl.ShowBtnInFirstRow(MainControlBtn_TmpBag)
	else
		MainControl.ShowBtnInFirstRow(MainControlBtn_TmpBag, false)
	end
end

function ZuoQiCell3:HandleTableClick(e)
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



function ZuoQiCell3:HandleItemCellClickShowSel(e)
	if (self.m_pOldItemCell) then
		self.m_pOldItemCell:SetSelected(false);
	end
	local MouseArgs = CEGUI.toMouseEventArgs(e);

	local pCell = CEGUI.toItemCell(MouseArgs.window);
	self.m_pOldItemCell = pCell;

	pCell:SetSelected(true);

	return true;
end

function ZuoQiCell3:HandleConfirmClearPack(e)
	local windowargs = CEGUI.toWindowEventArgs(e);
	local pConfirmBoxInfo = tostConfirmBoxInfo(windowargs.window:getUserData());
	gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo);

	require "protodef.fire.pb.item.ccleantemppack";
	local clearitems = CCleanTempPack.Create();
	LuaProtocolManager.getInstance():send(clearitems);
	return true;
end

function ZuoQiCell3:HandleClearPack(e)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	if (roleItemManager:IsTemporyPackEmpty() == true) then
		self:DestroyDialog();
		return true;
	end

	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(120058);
	if (tip.id ~= -1) then
		gGetMessageManager():AddConfirmBox(eConfirmCleanTempBag, tip.msg,
		ZuoQiCell3.HandleConfirmClearPack, self,
		MessageManager.HandleDefaultCancelEvent, MessageManager);

	end

	return true;
end


function ZuoQiCell3:HandleItemCellDoubleClick(e)
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


function ZuoQiCell3:GetItemCellByPos(pos)
	if (pos >= 0 and pos < sCellNum) then
		return self.m_pItemCells[pos];
	end
	return nil;

end

function ZuoQiCell3:GetItemTableByPos(pos)
	if (pos >= 0 and pos < sCellNum) then
		return nil;
	end
	return nil;

end

function ZuoQiCell3:OnCreate()
	super.OnCreate(self);
	--self:SetCloseIsHide(true);
	local winMgr = CEGUI.WindowManager:getSingleton();
	--self.hecheng = CEGUI.toPushButton(winMgr:getWindow("zuoqicell3/btnyi1"));
	--self.hecheng:subscribeEvent(CEGUI.PushButton.EventClicked, ZuoQiCell3.HandleGetBack, self);
	self.m_pBtnGetBack = CEGUI.toPushButton(winMgr:getWindow("zuoqicell3/btnyi"));
	self.m_pBtnGetBack:subscribeEvent(CEGUI.PushButton.EventClicked, ZuoQiCell3.HandleGetBack, self);
	--self.editbox = CEGUI.toRichEditbox(winMgr:getWindow("zuoqicell3/xiantips"))
	self.pane = CEGUI.toScrollablePane(winMgr:getWindow("zuoqicell3/scrolllabelpane"));
	self.m_table = CEGUI.toItemTable(winMgr:getWindow("zuoqicell3/table"));
	self.m_table:subscribeEvent(CEGUI.ItemTable.EventTableDoubleClick, ZuoQiCell3.HandleItemCellDoubleClick, self);


	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local baginfo=roleItemManager:GetBagInfo()
	local list={}
	local list2={}
	if baginfo then
		list= baginfo[1]
	end
	--local ItemCfg = BeanConfigManager.getInstance():GetTableByName("item.cwenshiitemshuxing"):getRecorder(v:GetBaseObject().id)
	if index==1 then
		for k, v in pairs(list) do
			local ItemCfg = BeanConfigManager.getInstance():GetTableByName("item.cwenshiitemshuxing"):getRecorder(v:GetBaseObject().id)

			if 182==v:GetItemTypeID() and ItemCfg.level < 3   then
				list2[k]=v
			end
		end
	elseif index==2 then
		local pItem = roleItemManager:getItem(_item1id, 1)
		for k, v in pairs(list) do
			local ItemCfg1 = BeanConfigManager.getInstance():GetTableByName("item.cwenshiitemshuxing"):getRecorder(pItem:GetBaseObject().id)
			local ItemCfg2 = BeanConfigManager.getInstance():GetTableByName("item.cwenshiitemshuxing"):getRecorder(v:GetBaseObject().id)
			if 182==v:GetItemTypeID() and ItemCfg2.level < 3 and ItemCfg1.wenshitype==ItemCfg2.wenshitype and k~=_item1id   then
				list2[k]=v
			end
		end
	end

	local column = self.m_table:GetColCount()
	self.m_table:setVisible(true)
	local row = math.ceil(40 / column)
	self.m_table:SetRowCount(row)
	local h = self.m_table:GetCellHeight()
	local spaceY = self.m_table:GetSpaceY()
	self.m_table:setHeight(CEGUI.UDim(0, (h+spaceY)*row))
	self.pane:EnableAllChildDrag(self.pane)

	local i=1
	local ss = "zuoqicell3/table_ItemCell_" .. 0;
	self.m_pItemCells[i] = CEGUI.toItemCell(winMgr:getWindow(ss));
	self.m_pItemCells[i]:SetCellTypeMask(1);
	self.m_pItemCells[i]:SetHaveSelectedState(true);
	self.m_pItemCells[i]:setID(0)
	self.m_pItemCells[i]:subscribeEvent(CEGUI.Window.EventMouseClick, ZuoQiCell3.HandleShowTootips, self);

	self.m_pItemCells[i]:SetImage("my_zuoqi", "jia")

    local i=1
	for k, v in pairs(list2) do
		local ss = "zuoqicell3/table_ItemCell_" .. i;
		self.m_pItemCells[i] = CEGUI.toItemCell(winMgr:getWindow(ss));
		self.m_pItemCells[i]:SetCellTypeMask(1);
		self.m_pItemCells[i]:SetHaveSelectedState(true);
		local needItemCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(v:GetBaseObject().id)
		if needItemCfg then
			self.m_pItemCells[i]:SetImage(gGetIconManager():GetItemIconByID(needItemCfg.icon))
			SetItemCellBoundColorByQulityItemWithId(self.m_pItemCells[i],needItemCfg.id)
			self.m_pItemCells[i]:setID(k)
			--self.m_pItemCells[i]:setID(needItemCfg.id)
		end
		--self.m_pItemCells[i]:subscribeEvent("TableClick", ZuoQiCell3.HandleClickItemCell, self)
		--self.m_pItemCells[i]:subscribeEvent(CEGUI.ItemCell.EventCellDoubleClick, ZuoQiCell3.HandleTableClick, self);
		self.m_pItemCells[i]:subscribeEvent(CEGUI.ItemCell.EventCellClick, ZuoQiCell3.HandleItemCellClickShowSel, self);
		self.m_pItemCells[i]:subscribeEvent(CEGUI.Window.EventMouseClick, ZuoQiCell3.HandleShowTootips, self);
		i=i+1
	end

end
function ZuoQiCell3:HandleShowTootips(e)
	local MouseArgs = CEGUI.toMouseEventArgs(e);
	local pCell = CEGUI.toItemCell(MouseArgs.window);
	local Commontipdlg = require "logic.tips.commontipdlg"
	if Commontipdlg.getInstanceNotCreate() then
		Commontipdlg.getInstanceNotCreate().DestroyDialog()
	end
	clid=0
	if pCell:getID()==0 then
		local e = CEGUI.toMouseEventArgs(e)
		local touchPos = e.position
		--ÎÆÊÎ½á¾§»ñÈ¡Í¾¾¶
		local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(550).value))
		if not itemAttrCfg then
			return
		end
		local nPosX = touchPos.x
		local nPosY = touchPos.y
		local Commontipdlg = require "logic.tips.commontipdlg"
		local commontipdlg = Commontipdlg.getInstanceAndShow()
		local nType = Commontipdlg.eType.eComeFrom
		--nType = Commontipdlg.eType.eNormal

		commontipdlg:RefreshItem(nType,tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(550).value),nPosX,nPosY)
		commontipdlg.nComeFromItemId = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(550).value)
		return
	else
		local roleItemManager = require("logic.item.roleitemmanager").getInstance()
		local pItem = roleItemManager:FindItemByBagAndThisID(pCell:getID(),1)
		--if nil ~= roleItemManager:getItem(pCell:getID(), 1) then
		local Pos = pCell:GetScreenPos();
		--local pItem = roleItemManager:getItem(pCell:getID(), 1)
		--local bLuaHandleSuccess = false;

		local nPosX = Pos.x;
		local nPosY = Pos.y;
		--local nItemKey = pItem:GetThisID();
		--local nBagId = pItem:GetLocation().tableType;

		local screenSize = GetScreenSize();
		if (nPosX > screenSize.width / 2) then
			nPosX = screenSize.width / 8;
		else
			nPosX = screenSize.width - screenSize.width / 8;
		end

		local nType = Commontipdlg.eType.eNormal
		local commontipdlg = Commontipdlg.getInstanceAndShow()
		commontipdlg:RefreshItem(nType,pItem:GetBaseObject().id,nPosX,nPosY,pItem:GetObject())


		clid=pCell:getID()
	end

		--local ret = LuaShowItemTip(nBagId, nItemKey, nPosX, nPosY);
		--if (ret == 1) then
		--	bLuaHandleSuccess = true;
		--end

	--end

	return true;
end
--function Commontiphelper.appendText(richBox,strChat)
--
--	local nIndex = string.find(strChat, "<T")
--	if nIndex then
--		richBox:AppendParseText(CEGUI.String(strChat))
--	else
--		local defaultColor = nil
--		local colorStr = richBox:GetColourString():c_str()
--		if colorStr == "FFFFFFFF" then
--			--fff2df
--			defaultColor = Commontiphelper.defaultColor()
--		else
--			defaultColor = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(colorStr))
--		end
--		richBox:AppendText(CEGUI.String(strChat),defaultColor)
--	end
--end
function Workshopmanager:HandleClickItemCell(args)

	local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position

	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y

end
function ZuoQiCell3:GetLayoutFileName()
	return "ZuoQiCell3.layout";
end
function ZuoQiCell3.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end
function ZuoQiCell3.ToggleOpenClose()
	if not _instance then
		_instance = ZuoQiCell3:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
--function ZuoQiCell3:OnClose()
--	if (self.m_pMainFrame) then
--		self.m_pMainFrame:setVisible(false);
--
--		if (gGetMessageManager()) then
--			gGetMessageManager():CloseConfirmBox(eConfirmCleanTempBag);
--		end
--
--	end
--
--end

function ZuoQiCell3.new()
	local obj = { };
	setmetatable(obj, ZuoQiCell3);

    obj.m_eDialogType = obj.m_eDialogType or {};
	obj.m_eDialogType[DialogTypeTable.eDialogType_InScreenCenter] = 1;

	obj.m_pItemCells = { };
	for i = 0, sCellNum - 1 do
		obj.m_pItemCells[i] = nil;
	end

	return obj;
end

function ZuoQiCell3:getInstance()

	if not _instance then
		_instance = ZuoQiCell3.new();
		_instance:OnCreate();
	end
	return _instance;
end

function ZuoQiCell3:GetSingletonDialogAndShowIt(xindex,item1id)
	index=xindex
	_item1id=item1id
	if not _instance then
		_instance = ZuoQiCell3.new();
		_instance:OnCreate();
	end
	if not _instance:IsVisible() then
		_instance:SetVisible(true);
	end
	return _instance;
end


return ZuoQiCell3;
