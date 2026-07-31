

local super = require "logic.singletondialog";
local _instance
local sCellNum = 12;
local index = 0;
local _zuoqiid = 0;
local _data = nil;
local clid =0;
ZuoQiCell2 = { };
setmetatable(ZuoQiCell2, super);
ZuoQiCell2.__index = ZuoQiCell2;

function ZuoQiCell2_GetItemCellByPos(pos)
	local dlg = ZuoQiCell2:getInstanceOrNot();
	if dlg then
		return dlg:GetItemCellByPos(pos);
	end
	return nil;
end

function ZuoQiCell2_IsVisible()
	local dlg = ZuoQiCell2:getInstanceOrNot();
	if dlg then
		return dlg:IsVisible();
	end
	return false;
end

function ZuoQiCell2_GetSingleton()
	if ZuoQiCell2:getInstanceOrNot() then
		return 1;
	else
		return 0;
	end
end

function ZuoQiCell2:HandleConfirmGetBack(e)

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



function ZuoQiCell2:HandleGetBack(e)


	if self.petKey~=0 then
		--if _data.wenshiitems[index]~=nil then
		--	local p = require "logic.zuoqi.czuoqizyshiyong":new()
		--	p.zuoqiid = _zuoqiid --normal
		--	p.idx = 4--normal
		--	p.index = index--normal
		--	p.key = clid--normal
		--	require "manager.luaprotocolmanager":send(p)
		--else
		--	local p = require "logic.zuoqi.czuoqizyshiyong":new()
		--	p.zuoqiid = _zuoqiid --normal
		--	p.idx = 2 --normal
		--	p.index = index--normal
		--	p.key = clid--normal
		--	require "manager.luaprotocolmanager":send(p)
		--end
		if _data.petkey[index]~=nil then
			local p = require "logic.zuoqi.czuoqizyshiyong":new()
			p.zuoqiid = _zuoqiid --normal
			p.idx = 7 --normal
			p.index = index--normal
			p.key = self.petKey--normal
			require "manager.luaprotocolmanager":send(p)
		else
			local p = require "logic.zuoqi.czuoqizyshiyong":new()
			p.zuoqiid = _zuoqiid --normal
			p.idx = 5 --normal
			p.index = index--normal
			p.key = self.petKey--normal
			require "manager.luaprotocolmanager":send(p)
		end

		self:DestroyDialog();
	end

	--	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(150147);
	--	if (tip.id ~= -1) then
	--		GetCTipsManager():AddMessageTip(tip.msg, false);
	--	end
	--	return true;



	return true;
end
function ZuoQiCell2:HandleBack(e)
	self:DestroyDialog();
	return true;
end
function ZuoQiCell2:HandleCloseBtnClick(e)
	self:DestroyDialog();
	return true;
end

function ZuoQiCell2:SetVisible(bVisible)
	super.SetVisible(self, bVisible);
	if (bVisible) then
		MainControl.ShowBtnInFirstRow(MainControlBtn_TmpBag)
	else
		MainControl.ShowBtnInFirstRow(MainControlBtn_TmpBag, false)
	end
end

function ZuoQiCell2:HandleTableClick(e)
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



function ZuoQiCell2:HandleItemCellClickShowSel(e)
	if (self.m_pOldItemCell) then
		self.m_pOldItemCell:SetSelected(false);
	end
	local MouseArgs = CEGUI.toMouseEventArgs(e);

	local pCell = CEGUI.toItemCell(MouseArgs.window);
	self.m_pOldItemCell = pCell;

	pCell:SetSelected(true);

	return true;
end

function ZuoQiCell2:HandleConfirmClearPack(e)
	local windowargs = CEGUI.toWindowEventArgs(e);
	local pConfirmBoxInfo = tostConfirmBoxInfo(windowargs.window:getUserData());
	gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo);

	require "protodef.fire.pb.item.ccleantemppack";
	local clearitems = CCleanTempPack.Create();
	LuaProtocolManager.getInstance():send(clearitems);
	return true;
end

function ZuoQiCell2:HandleClearPack(e)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	if (roleItemManager:IsTemporyPackEmpty() == true) then
		self:DestroyDialog();
		return true;
	end

	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(120058);
	if (tip.id ~= -1) then
		gGetMessageManager():AddConfirmBox(eConfirmCleanTempBag, tip.msg,
		ZuoQiCell2.HandleConfirmClearPack, self,
		MessageManager.HandleDefaultCancelEvent, MessageManager);

	end

	return true;
end


function ZuoQiCell2:HandleItemCellDoubleClick(e)
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


function ZuoQiCell2:GetItemCellByPos(pos)
	if (pos >= 0 and pos < sCellNum) then
		return self.m_pItemCells[pos];
	end
	return nil;

end

function ZuoQiCell2:GetItemTableByPos(pos)
	if (pos >= 0 and pos < sCellNum) then
		return nil;
	end
	return nil;

end

function ZuoQiCell2:OnCreate()
	super.OnCreate(self);
	--self:SetCloseIsHide(true);
	local winMgr = CEGUI.WindowManager:getSingleton();

	self.m_pBtnGetBack = CEGUI.toPushButton(winMgr:getWindow("zuoqicell2/btnyi"));
	self.m_pBtnGetBack:subscribeEvent(CEGUI.PushButton.EventClicked, ZuoQiCell2.HandleGetBack, self);
	--self.editbox = CEGUI.toRichEditbox(winMgr:getWindow("zuoqicell1/xiantips"))
	self.pane = CEGUI.toScrollablePane(winMgr:getWindow("zuoqicell2/scrolllabelpane"));
	self.pane:EnableHorzScrollBar(false)
	if _data.petkey[index]~=nil then
		self.m_pBtnGetBack:setText("替换召唤灵")
	end
	self.petKey=0
	local sx = 2.0;
	local sy = 2.0;
	local indes=0
	for i = 1, MainPetDataManager.getInstance():GetPetNum() do
		local petData = MainPetDataManager.getInstance():getPet(i)
		local sID = "ZuoQiCell2" .. tostring(indes)
		local lyout = winMgr:loadWindowLayout("zuoqipetcell.layout",sID);
		self.pane:addChildWindow(lyout)
		lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx), CEGUI.UDim(0.0, sy + indes * (lyout:getHeight().offset))))
		--lyout:setID(index)
		lyout.key = petData.key

		lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(sID.."zuoqipetcell"));
		lyout.addclick:setID(indes)
		lyout.addclick:subscribeEvent("MouseButtonUp", ZuoQiCell2.handlePetIconSelected, self)

		--if petData.key == self.selectedPetKey then
		--	lyout.addclick:setSelected(true)
		--end

		lyout.NameText = winMgr:getWindow(sID.."zuoqipetcell/name")
		lyout.NameText:setText(petData.name)
		lyout.ZuoQiNameText = winMgr:getWindow(sID.."zuoqipetcell/zuoqiname")

		local zuoqiid=0
		for k,v in pairs(_data.petkeys) do
			for key,value in pairs(v.petkeys) do
				if petData.key==value then
					zuoqiid=key
					break
				end
			end
		end

		local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(zuoqiid)
		if itemattr then
			lyout.ZuoQiNameText:setText(itemattr.name)
		else
			lyout.ZuoQiNameText:setText("未统御")
		end
		lyout.LevelText = winMgr:getWindow(sID.."zuoqipetcell/number")
		lyout.LevelText:setText(petData:getAttribute(fire.pb.attr.AttrType.LEVEL))

		lyout.petCell = CEGUI.toItemCell(winMgr:getWindow(sID.."zuoqipetcell/touxiang"))
		SetPetItemCellInfo2(lyout.petCell, petData)

		--lyout.addtext = winMgr:getWindow(sID.."petcell/name1")
		--lyout.addtext:setVisible(false)

		--if fightid == petData.key then
		--	lyout.chuzhan:setVisible(true)
		--end
		--table.insert(self.m_petList, lyout)
		indes = indes + 1
	end
end
function ZuoQiCell2:handlePetIconSelected(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	local cell = CEGUI.toItemCell(wnd)
	--local idx = cell:GetIndex()
	local idx = wnd:getID()
	self.petKey=0
	print('pet cell idx:', idx)
	if idx < MainPetDataManager.getInstance():GetPetNum() then
		local petData = MainPetDataManager.getInstance():getPet(idx+1)
		self.petKey=petData.key
	end
end
function ZuoQiCell2:HandleShowTootips(e)
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
		--纹饰结晶获取途径
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
function ZuoQiCell2:GetLayoutFileName()
	return "ZuoQiCell2.layout";
end
function ZuoQiCell2.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end
function ZuoQiCell2.ToggleOpenClose()
	if not _instance then
		_instance = ZuoQiCell2:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
--function ZuoQiCell2:OnClose()
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

function ZuoQiCell2.new()
	local obj = { };
	setmetatable(obj, ZuoQiCell2);

    obj.m_eDialogType = obj.m_eDialogType or {};
	obj.m_eDialogType[DialogTypeTable.eDialogType_InScreenCenter] = 1;

	obj.m_pItemCells = { };
	for i = 0, sCellNum - 1 do
		obj.m_pItemCells[i] = nil;
	end

	return obj;
end

function ZuoQiCell2:getInstance()

	if not _instance then
		_instance = ZuoQiCell2.new();
		_instance:OnCreate();
	end
	return _instance;
end

function ZuoQiCell2:GetSingletonDialogAndShowIt(xindex,zuoqiid,data)
	index=xindex
	_zuoqiid=zuoqiid
	_data=data
	if not _instance then
		_instance = ZuoQiCell2.new();
		_instance:OnCreate();
	end
	if not _instance:IsVisible() then
		_instance:SetVisible(true);
	end
	return _instance;
end


return ZuoQiCell2;
