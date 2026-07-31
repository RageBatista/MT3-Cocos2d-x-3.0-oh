local p = require "logic.zuoqi.szuoqiyongyou"
function p:process()
	local dlg=require "logic.zuoqi.characterzuoqidlg".getInstanceNotCreate()
	if dlg then
		dlg:refreshSzTable2(self.zuoqix)
	end
	local dlg2=require "logic.ranse.zuoqiransedlg".getInstanceNotCreate()
	if dlg2 then
		dlg2:refreshSzTable2(self.zuoqix)
	end
end
local snoticerolegetinfo = require "protodef.fire.pb.item.snoticerolegetinfo"
function snoticerolegetinfo:process()
	
	require "logic.characterinfo.getdatainfomsg"
	GetDataInfoMsg.AddNewInfo(self.roleid, self.rolename)		
end

local pd = require "protodef.fire.pb.item.smuldaylogin"
function pd:process()
	LogInfo("protodef.fire.pb.item.smuldaylogin")
	require "logic.qiandaosongli.loginrewardmanager"
	local mgr = LoginRewardManager.getInstance()
	LoginRewardManager.getInstance():SetLoginDays(self.logindays)
	LoginRewardManager.getInstance():SetLoginMapAwards(self.rewardmap)
end

------------衣橱--------------
local p = require "protodef.fire.pb.shizhuang.syichuyongyou"
function p:process()
	require "logic.ranse.charactershizhuangdlg".getInstanceNotCreate():refreshSzTable2(self.shizhuang)

end

local function getEquipBagWeaponIdForFashion()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    if not roleItemManager then
        return 0, "no_role_item_manager"
    end

    local function findWeaponEquipItemId()
        if roleItemManager.GetCurrentEquip then
            local weaponEquip = roleItemManager:GetCurrentEquip(fire.pb.item.BagTypes.EQUIP, eEquipType_ARMS)
            if weaponEquip and weaponEquip.GetObjectID then
                local itemId = tonumber(weaponEquip:GetObjectID()) or 0
                if itemId > 0 then
                    return itemId, "GetCurrentEquip"
                end
            end
        end

        if roleItemManager.GetBagInfo then
            local bagInfo = roleItemManager:GetBagInfo()
            local function scanList(list, source)
                if not list then
                    return 0, source
                end
                for _, pItem in pairs(list) do
                    if pItem and pItem.GetSecondType and pItem.GetObjectID then
                        local secondType = tonumber(pItem:GetSecondType()) or -1
                        if secondType == eEquipType_ARMS then
                            local loc = pItem.GetLocation and pItem:GetLocation() or nil
                            if (not loc) or loc.tableType == fire.pb.item.BagTypes.EQUIP then
                                local itemId = tonumber(pItem:GetObjectID()) or 0
                                if itemId > 0 then
                                    return itemId, source
                                end
                            end
                        end
                    end
                end
                return 0, source
            end

            if bagInfo then
                local itemId, source = scanList(bagInfo[fire.pb.item.BagTypes.EQUIP], "GetBagInfo[EQUIP]")
                if itemId > 0 then
                    return itemId, source
                end
                for bagId, list in pairs(bagInfo) do
                    itemId, source = scanList(list, "GetBagInfoScan:" .. tostring(bagId))
                    if itemId > 0 then
                        return itemId, source
                    end
                end
            end
        end

        return 0, "not_found"
    end

    local equipItemId, source = findWeaponEquipItemId()
    if equipItemId <= 0 then
        LogInfo("syichushiyong resolve equip weapon item failed")
        return 0, source
    end

    local directWeaponId = 0
    if equipItemId >= 1000000 then
        directWeaponId = equipItemId
    end

    local isPointCardServer = (type(IsPointCardServer) == "function" and IsPointCardServer()) or false
    local mappedWeaponId = 0
    if isPointCardServer then
        local equipEffectTable = BeanConfigManager.getInstance():GetTableByName("item.cequipeffect")
        if equipEffectTable then
            local equipEffectCfg = equipEffectTable:getRecorder(equipItemId)
            if equipEffectCfg and equipEffectCfg.id ~= -1 then
                mappedWeaponId = tonumber(equipEffectCfg.weaponid) or 0
            end
        end
    else
        if GameTable and GameTable.item and GameTable.item.GetCEquipEffectTableInstance then
            local equipEffectTable = GameTable.item.GetCEquipEffectTableInstance()
            if equipEffectTable then
                local equipEffectCfg = equipEffectTable:getRecorder(equipItemId)
                if equipEffectCfg and equipEffectCfg.id ~= -1 then
                    mappedWeaponId = tonumber(equipEffectCfg.weaponid) or 0
                end
            end
        end
    end

    if directWeaponId > 0 then
        if mappedWeaponId > 0 and mappedWeaponId ~= directWeaponId then
            LogInfo(string.format("syichushiyong resolve equip weapon prefer direct item=%s source=%s direct=%s mapped=%s",
                tostring(equipItemId), tostring(source), tostring(directWeaponId), tostring(mappedWeaponId)))
        else
            LogInfo(string.format("syichushiyong resolve equip weapon direct item=%s source=%s direct=%s",
                tostring(equipItemId), tostring(source), tostring(directWeaponId)))
        end
        return directWeaponId, "direct_item_id"
    end

    if mappedWeaponId > 0 then
        LogInfo(string.format("syichushiyong resolve equip weapon mapped item=%s source=%s mapped=%s",
            tostring(equipItemId), tostring(source), tostring(mappedWeaponId)))
        return mappedWeaponId, "equip_effect_map"
    end

    LogInfo(string.format("syichushiyong resolve equip weapon fallback item=%s source=%s",
        tostring(equipItemId), tostring(source)))
    return equipItemId, "direct_item_id_fallback"
end

local function refreshMainCharacterWeaponAfterFashionChanged()
    local mainCharacter = GetMainCharacter()
    if not mainCharacter or not mainCharacter.SetSpriteComponent or not mainCharacter.GetSpriteComponent then
        return
    end

    local currentWeapon = tonumber(mainCharacter:GetSpriteComponent(eSprite_Weapon)) or 0
    if currentWeapon > 0 then
        LogInfo(string.format("syichushiyong keep current weapon component: %s", tostring(currentWeapon)))
        return
    end

    local weaponId, weaponSource = getEquipBagWeaponIdForFashion()
    if weaponId > 0 then
        mainCharacter:SetSpriteComponent(eSprite_Weapon, weaponId)
        LogInfo(string.format("syichushiyong recover weapon from equip: new=%s source=%s",
            tostring(weaponId), tostring(weaponSource)))
    else
        LogInfo("syichushiyong refresh weapon unchanged: no current/equip weapon")
    end
end

local p = require"protodef.fire.pb.shizhuang.syichushiyong"
function p:process()
    local mainCharacter = GetMainCharacter()
    local beforeWeapon = 0
    if mainCharacter and mainCharacter.GetSpriteComponent then
        beforeWeapon = tonumber(mainCharacter:GetSpriteComponent(eSprite_Weapon)) or 0
    end
    LogInfo(string.format("syichushiyong process shape=%s beforeWeapon=%s", tostring(self.shape), tostring(beforeWeapon)))

	gGetDataManager().m_MainCharacterData.shape =self.shape
    refreshMainCharacterWeaponAfterFashionChanged()

    local afterWeapon = 0
    if mainCharacter and mainCharacter.GetSpriteComponent then
        afterWeapon = tonumber(mainCharacter:GetSpriteComponent(eSprite_Weapon)) or 0
    end
    LogInfo(string.format("syichushiyong process done shape=%s afterWeapon=%s", tostring(self.shape), tostring(afterWeapon)))

    local packDlg = require("logic.item.mainpackdlg"):getInstanceOrNot()
    if packDlg and packDlg.UpdataModel then
        packDlg:UpdataModel()
    end
end

local schangegem33 = require("protodef.fire.pb.school.change.schangegem33")
function schangegem33:process()
	ZhuanZhiBaoShi33.getInstance():RefreshAllGemData()
end

local p = require "protodef.fire.pb.item.sbuypackmoney"
local confirmtype
local function confirmAddCapacity()
  if confirmtype then
    gGetMessageManager():CloseConfirmBox(confirmtype, false)
    confirmtype = nil
  end
  local dlg = require "logic.item.depot":getInstanceOrNot()
  if not dlg then
    return
  end
  local p = require "protodef.fire.pb.item.cextpacksize":new()
  require "manager.luaprotocolmanager":send(p)
end
function p:process()
  local formatstr = GameTable.message.GetCMessageTipTableInstance():getRecorder(150143).msg
  local sb = require "utils.stringbuilder":new()
  --sb:Set("parameter1", self.costyuanbao)
	sb:Set("Parameter1", self.money)
  local msg = sb:GetString(formatstr)
  sb:delete()
  
  confirmtype = require "utils.mhsdutils".addConfirmDialog(msg, confirmAddCapacity)
end

local p = require "protodef.fire.pb.item.swishret"
function p:process()

require "logic.shop.NpcBaiChongShop".getInstanceOrNot():result(self.datas)
    -- for k,v in pairs (self.data) do
    -- GetCTipsManager():AddMessageTip(v)
    -- end
end


local zhuanzhiwuqidlg1 = require("protodef.fire.pb.school.change.schangeweapon2")
function zhuanzhiwuqidlg1:process()
	local xlDlg = require "logic.zhuanzhi.zhuanzhiwuqidlg1"
    xlDlg.DestroyDialog()
	xlDlg.getInstance():ShowWeaponProperty()
end

local p = require "protodef.fire.pb.item.sfreshrepairdata"
function p:process()
	print("protodef.fire.pb.item.sfreshrepairdata process")
	local xlDlg = require "logic.workshop.workshopxlnew"
	xlDlg.OnRefreshAllResult(self)
	
	local xilianDlg = require "logic.workshop.workshopxilian"
	xilianDlg.OnRefreshAllResult(self)
	
	local xlDlg2 = require "logic.workshop.Attunement"
	xlDlg2.OnXlResult()

	
	
	local aqDlg = require "logic.workshop.workshopaq"
	aqDlg.OnRefreshAllResult(self)
end

--[[
local p = require "protodef.fire.pb.item.srepaireiteminfo"
function p:process()
	print("protodef.fire.pb.item.srepaireiteminfo process")
	local xlDlg = require "logic.workshop.workshopxlnew"
	xlDlg.OnRefreshOneItemInfoResult(self)
end
--]]


local p = require "protodef.fire.pb.item.srepairresult"
function p:process()

	local xlDlg = require "logic.workshop.workshopxlnew"
	xlDlg.OnXlResult()
	local xilDlg = require "logic.workshop.workshopxilian"
	xilDlg.OnXlResult()
	
	local aqDlg = require "logic.workshop.workshopaq"
	aqDlg.OnXlResult()
	local xlDlg2 = require "logic.workshop.Attunement"
	xlDlg2.OnXlResult()
	local xlDlg = require "logic.workshop.zhuangbeironglian"
	xlDlg.OnXlResult()
	local xlDlg = require "logic.workshop.zhuangbeichongzhu"
	xlDlg.OnXlResult()
	local xl1Dlg = require "logic.workshop.zuoqipinzhi"
	xl1Dlg.OnXlResult()
	local xlDlg = require "logic.workshop.zhuangbeiqh"
	xlDlg.OnXlResult()
	local xlDlg3 = require "logic.workshop.superronglian"
	xlDlg3.OnXlResult()
	local xlDlg3 = require "logic.workshop.zhuangbeifumo"
	xlDlg3.OnXlResult()
	local tjdzDlg = require "logic.workshop.tejidingzhi"
	tjdzDlg.OnXlResult()
	local aq1Dlg = require "logic.workshop.workshopaq1"
	aq1Dlg.OnXlResult()
	require("logic.reminduseitemdlg").CheckCloseAllDialogs()

	
end

local p = require "protodef.fire.pb.item.suseenhancementitem"
function p:process()
	LogInfo("protodef.fire.pb.item.suseenhancementitem process")
	require "logic.item.mainpackhelper".suseenhancementitem_process(self)
	
end


local p = require "protodef.fire.pb.item.sreplacegem"
function p:process()
	LogInfo("protodef.fire.pb.item.sreplacegem process")
    
	require "logic.item.mainpackhelper".sreplacegem_process(self)
	
end

local p = require "protodef.fire.pb.item.smaillist"
function p:process()
	LogInfo("protodef.fire.pb.item.smaillist process")
	require "system.maillistmanager"
	MailListManager.getInstance():RefreshMailList(self.maillist)
	require "logic.friend.maildialog".GlobalOnNewMail()
 
	CChatOutBoxOperatelDlg.RefreshNotify()
end

local p = require "protodef.fire.pb.item.smailinfo"
function p:process()
	LogInfo("protodef.fire.pb.item.smailinfo process")
	require "system.maillistmanager"
	MailListManager.getInstance():RefreshMailInfo(self.mail)
    require "logic.friend.maildialog".GlobalOnNewMail()
	CChatOutBoxOperatelDlg.RefreshNotify()
end

local p = require "protodef.fire.pb.item.smailstate"
function p:process()
	LogInfo("protodef.fire.pb.item.smailstate process")
	require "system.maillistmanager"
	MailListManager.getInstance():RefreshMailState(self.kind, self.id, self.statetype, self.statevalue)
    require "logic.friend.maildialog".GlobalOnNewMail()
	CChatOutBoxOperatelDlg.RefreshNotify()
end

local p = require "protodef.fire.pb.item.sotheritemtips"
function p:process()
    local data = FireNet.Marshal.OctetsStream(self.tips)
    
    if self.packid == fire.pb.item.BagTypes.MARKET then
        --��̯��Ʒtips/�ϼܽ�����������Ʒtips
        local dlg = require("logic.tips.commontipdlg").getInstanceNotCreate()
        if dlg and dlg.roleid == self.roleid and dlg.itemkey == self.keyinpack and dlg.roleItem and (dlg.isStallTip or dlg.isStallUpShelfTip) then
            dlg.roleItem:GetObject():MakeTips(data)
			local x = dlg:GetWindow():getXPosition().offset
            dlg:RefreshItem_normal()
			local y = (GetScreenSize().height-dlg:GetWindow():getPixelSize().height)*0.5
			dlg:GetWindow():setPosition(NewVector2(x, y))

			dlg.willCheckTipsWnd = true

			if dlg.enableSwitch then
				dlg:showSwitchPageArrow(true)
				dlg.enableSwitch = nil
			end
            return
        end

        --��̯�¼�
        dlg = require("logic.shop.stalldownshelf").getInstanceNotCreate()
        if dlg and dlg.roleid == self.roleid and dlg.itemkey == self.keyinpack then
            dlg:recvTipsData(data)
            return
        end

        --��̯�����ϼ�
        dlg = require("logic.shop.stallupshelf").getInstanceNotCreate()
        if dlg and dlg.type == 2 and dlg.roleid == self.roleid and dlg.key == self.keyinpack then --type.2: TYPE_RE_UP
            dlg:recvTipsData(data)
            return
        end
    --װ����
    elseif self.packid == fire.pb.item.BagTypes.EQUIP then
        local dlg = require("logic.tips.commontipdlg").getInstanceNotCreate()
        if dlg and dlg.roleid == self.roleid and dlg.itemkey == self.keyinpack and dlg.roleItem then
            dlg.roleItem:GetObject():MakeTips(data)
            dlg:RefreshItem_normal() 
            local x,y = require("logic.tips.commontiphelper").getTipPosXY(dlg:GetWindow(),true)
	        dlg:RefreshPosCorrect(x,y)
			dlg.willCheckTipsWnd = true
            return
        end
    end
end

--�鿴����װ��
local p = require "protodef.fire.pb.item.sgetroleequip"
function p:process()
    local dlg = debugrequire "logic.chakan.chakan".getInstanceAndShow()
    if dlg then
     dlg:RefreshData(self)
    end
end

local p = require("protodef.fire.pb.item.sgettimeaward")
function p:process()
	local rewardid = self.awardid
	local timewait = self.waittime
	require("logic.qiandaosongli.loginrewardmanager").MTOnlineRewardProcess(rewardid, timewait)
end

-- �����ʱ����
local p = require "protodef.fire.pb.item.scleantemppack";
function p:process()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	roleItemManager:ClearBag(fire.pb.item.BagTypes.TEMP);

	require "logic.item.TemporaryPack";
	if (CTemporaryPack_IsVisible()) then
		local dlg = CTemporaryPack:getInstanceOrNot();
		if dlg then
			dlg:SetVisible(false);
		end
		MainControl.ShowBtnInFirstRow(MainControlBtn_TmpBag, false)
	end
end

local srefreshpacksize = require "protodef.fire.pb.item.srefreshpacksize"
function srefreshpacksize:process()

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	if roleItemManager then
		roleItemManager:SetBagCapacity(self.packid, self.cap);
		require("logic.item.depot"):getInstanceRefresh();
	end

end


local sxiulifailtimes = require "protodef.fire.pb.item.sxiulifailtimes"
function sxiulifailtimes:process()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
   
    local pItem = roleItemManager:FindItemByBagAndThisID(self.keyinpack, self.packid);
	if pItem then
		pItem:SetRepairFailCount(self.failtimes);
    end

    local xlDlg = require "logic.workshop.workshopxlnew"
	xlDlg.OnFailTimesResult(self)
	
	local xilDlg = require "logic.workshop.workshopxilian"
	xilDlg.OnFailTimesResult(self)
	
	local aqDlg = require "logic.workshop.workshopaq"
	aqDlg.OnFailTimesResult(self)
end

local sitemadded = require "protodef.fire.pb.item.sitemadded"
function sitemadded:process()
    for k,oneItem in pairs(self.items) do
       local attr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(oneItem.itemid)
	   if attr then
            local  p1 = attr.icon;
		    local p2 = oneItem.itemnum;
		    local p3 = attr.id;
		    require("logic.addnewitemseffect").PlayAddItemsEffect( p1, p2, p3);
       end
    end
end

local srefreshmaxnaijiu = require "protodef.fire.pb.item.srefreshmaxnaijiu"
function srefreshmaxnaijiu:process()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local pItem = roleItemManager:FindItemByBagAndThisID(self.keyinpack, self.packid);
	if pItem then
		pItem:SetEndureUpperLimit(self.maxendure);
    end
end

local srefreshnaijiu = require "protodef.fire.pb.item.srefreshnaijiu"
function srefreshnaijiu:process()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    for k,oneEndure in pairs(self.data) do
         local pItem = roleItemManager:FindItemByBagAndThisID(oneEndure.keyinpack, self.packid);
	    if pItem then
		    pItem:SetEndure(oneEndure.endure);
            pItem:OnUpdate(pItem:GetLocation(), -1);
        end
    end
    local xlDlg = require "logic.workshop.workshopxlnew"
	xlDlg.OnXlResult()

    require("logic.yangchengnotify.yangchenglistdlg").refreshTixingXiuli()
    
end



local sitemposchange = require "protodef.fire.pb.item.sitemposchange"
function sitemposchange:process()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	local needEventBroadcast = true;
	if roleItemManager:FindItemByBagIDAndPos(self.packid, self.pos) then
		needEventBroadcast = false;
	end
	local item = roleItemManager:FindItemByBagAndThisID(self.keyinpack, self.packid);
	if item then
		item:ChangePos(self.pos);
	end
	if needEventBroadcast then
		roleItemManager:EventPackItemLocationChangeFire();
	end
	require "logic.item.depot":getInstanceRefresh()
end


local sdelitem = require "protodef.fire.pb.item.sdelitem"
function sdelitem:process()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    roleItemManager:RemoveItem(self.packid, self.itemkey);
    local isTemEmpty =  roleItemManager:IsTemporyPackEmpty()
    if self.packid == fire.pb.item.BagTypes.TEMP and isTemEmpty== true then
        require "logic.item.TemporaryPack";
		if CTemporaryPack_IsVisible() then
				require "logic.item.TemporaryPack"
				local dlg = CTemporaryPack:getInstanceOrNot();
				if dlg then
					dlg:SetVisible(false);
				end
		end
		MainControl.ShowBtnInFirstRow(MainControlBtn_TmpBag, false)
	end
	require "logic.item.depot":getInstanceRefresh()

    if self.packid == fire.pb.item.BagTypes.MARKET then
        local dlg = require("logic.shop.stalldlg").getInstanceNotCreate()
        if dlg then
            dlg:recvMyStallItemNumChanged(self.itemkey, 0)
        end
    end

    if self.packid==fire.pb.item.BagTypes.BAG or self.packid==fire.pb.item.BagTypes.EQUIP then
         require("logic.yangchengnotify.yangchenglistdlg").refreshTixingXiuli()
    end
	local xingpan=require "logic.xingpan.xingpandlg".getInstanceNotCreate()
	if xingpan then
		xingpan:UpdateEquip()
	end

end

local sgetitemtips = require "protodef.fire.pb.item.sgetitemtips"
function sgetitemtips:process()
    
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local proto = self
    local data = FireNet.Marshal.OctetsStream(proto.tips)
	
	local pItem = roleItemManager:FindItemByBagAndThisID(proto.keyinpack, proto.packid)
	if pItem == nil then
		return
	end

	--//c unmarshal server data 
	pItem:GetObject():MakeTips(data)
    pItem:updateEquipScore()
	pItem:GetObject():SetNeedRequireData(false)
		
	local wslabel = require("logic.workshop.workshoplabel").getInstanceNotCreate()
	if wslabel then 
		wslabel:RefreshItemTips(pItem)
	end
	
	local marketThreeTable = require("logic.shop.shopmanager").marketThreeTable
	if marketThreeTable and marketThreeTable[pItem:GetObjectID()] then
		local dlg = require("logic.shop.stalldlg").getInstanceNotCreate()
		if dlg then
			dlg:refreshBagItemTable()
		end
	end

	-- ycl ����������������������������Ʒ����Ʒtips��ʾ����Ϣ���Ե�����
	 local dlg = require("logic.tips.commontipdlg").getInstanceNotCreate();
	 if dlg and dlg.nBagId == proto.packid and dlg.nItemKey == proto.keyinpack then
		dlg:RefreshItem(dlg.nType,dlg.nItemId,dlg.nCellPosX,dlg.nCellPosY,dlg.pObj)
	 end

	 -- �ͻ�������������Ƕ��ʯ�����ڼ��װ���ϵ�7����ʯ�����Ƿ�������
	 if GameCenterUtil.requestAttachGem then
		local Lv7GemCount = pItem:GetGemCountByLevel(7);
		if Lv7GemCount > GameCenterUtil.Lv7GemCount then
			-- װ���ϵ�7����ʯ���࣬���� GameCenter �ɾͷ���
			if GameCenter:GetInstance() then
                local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
                if manager then
                    if manager.m_isPointCardServer then
                        GameCenter:GetInstance():sendAchievementScore(GameCenterAchievementId_DK.DK_Lv7Gem, 50);
                    else
                        GameCenter:GetInstance():sendAchievementScore(GameCenterAchievementId.Lv7Gem, 50);
                    end
                end
			end
			GameCenterUtil.Lv7GemCount = Lv7GemCount;
		end
		GameCenterUtil.requestAttachGem = false;
	 end

     if     self.packid==fire.pb.item.BagTypes.BAG or
            self.packid==fire.pb.item.BagTypes.EQUIP or
            self.packid==fire.pb.item.BagTypes.DEPOT
             then
        require("logic.yangchengnotify.yangchenglistdlg").checkEquipTishiXiuli(pItem)

        roleItemManager:refreshToXiuliFlag(pItem)
     end

     local dlg = require "logic.workshop.workshophcnew".getInstanceNotCreate()
     if dlg then
         dlg:RefreshAllGemData()
     end
	 local zbqh=require "logic.workshop.zhuangbeiqh".getInstanceNotCreate()
	 if zbqh then
		zbqh:RefreshRichBox(false)
	 end

end

local shechengitem = require "protodef.fire.pb.item.shechengitem"
function shechengitem:process()
	local uiDlg = require "logic.workshop.workshophcnew"
	uiDlg.OnCombinResult()
end

local shechengret = require "protodef.fire.pb.item.shechengret"
function shechengret:process()
	local proto = self
	local xqdlg = require "logic.workshop.workshopxqnew"
	if proto.ret==0 then
		
	elseif proto.ret==1 then
		xqdlg.OnXqResult(proto)
	elseif proto.ret==4 then
		xqdlg.OnTHResult(proto)
	elseif proto.ret==5 then
		xqdlg.OnQXResult(proto)
	end

end

local sitemnumchange = require "protodef.fire.pb.item.sitemnumchange"
function sitemnumchange:process()
    local proto = self
    if proto.packid == fire.pb.item.BagTypes.MARKET then
        local dlg = require("logic.shop.stalldlg").getInstanceNotCreate()
        if dlg then
            dlg:recvMyStallItemNumChanged(proto.keyinpack, proto.curnum)
        end
        return 
    end

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    roleItemManager:ItemNumChange(self.keyinpack,self.packid,self.curnum)
end


-------------------------------------------------------------------------
fire_pb_item = {}


local sadditem = require "protodef.fire.pb.item.sadditem"
function sadditem:process()

	if not gGetGameUIManager() then
		return
	end

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    
	if self.packid == fire.pb.item.BagTypes.BAG then
		-- ���Ӵ���������ʹ����ʾ
        require "logic.reminduseitemdlg"
        if RemindUseItemDlg.IsRemindItem(self.data[1].id) then
            RemindUseItemDlg.NewInstance(self.data[1].id):AddRemindItem(self.data[1].id)
        end
	end

    local bagInfo = roleItemManager:GetBagInfo()

	if not bagInfo[self.packid] then
        for k,v in pairs(self.data) do
			roleItemManager:AddItem(self.packid, v, false, false, true)
			NewRoleGuideManager.getInstance():GuideStartConditionItem(v.id)
		end
	else
        for k,v in pairs(self.data) do
			roleItemManager:AddItem(self.packid, v, false, false, true)
			NewRoleGuideManager.getInstance():GuideStartConditionItem(v.id)
			roleItemManager:setLastAddeditemkey(v.key)
		end
	end

	require("logic.item.depot"):getInstanceRefresh()

    -- ��װ��ʱ��װ������������״̬���װ����
	if self.packid == fire.pb.item.BagTypes.EQUIP then
        require 'logic.item.mainpackdlg'
        if CMainPackDlg:getInstanceOrNot() then
            CMainPackDlg:getInstanceOrNot():SetEquipDialogState(true)
        end
    -- ��ʱ����������Ʒʱ������������ʱ��������ͼ����ʾ
	elseif self.packid == fire.pb.item.BagTypes.TEMP then
		local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(120057)
		if tip.id ~= -1 then
			GetCTipsManager():AddMessageTip(tip.msg)
		end
		if not CTemporaryPack_IsVisible() then
			MainControl.ShowBtnInFirstRow(MainControlBtn_TmpBag)
		end
	end

	roleItemManager:CheckEquipEffect()

end

-- �������������ľ��������ĵ�����Ϣ
local sgetpackinfo = require "protodef.fire.pb.item.sgetpackinfo"
function sgetpackinfo:process()

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	roleItemManager:ClearBag(self.packid)

    -- �Ƿ���������������
	local bIsOnTidyPack = false
	if fire.pb.item.BagTypes.BAG == self.packid then
		bIsOnTidyPack = true
	end

	roleItemManager:AddBagItem(self.packid, self.baginfo, bIsOnTidyPack)

	if self.packid == fire.pb.item.BagTypes.DEPOT then
		roleItemManager:SetBagCapacity(self.packid, self.baginfo.capacity)
	end
	require("logic.item.depot"):getInstanceRefresh()

end

local sgetdepotinfo = require "protodef.fire.pb.item.sgetdepotinfo"
function sgetdepotinfo:process()
    local bIsOnTidyPack = false

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	roleItemManager:ClearBag(fire.pb.item.BagTypes.DEPOT);
	roleItemManager:AddBagItem(fire.pb.item.BagTypes.DEPOT, self.baginfo, bIsOnTidyPack)
    roleItemManager:SetBagCapacity(fire.pb.item.BagTypes.DEPOT, self.baginfo.capacity)

    local depotDlg = require "logic.item.depot":getInstanceOrNot()

	if depotDlg  then
		depotDlg:SwitchToDepotPage(self.pageid)
    end

end

-- ˢ���ֽ�����
local srefreshcurrency = require "protodef.fire.pb.item.srefreshcurrency"
function srefreshcurrency:process()

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()

    for first, second in pairs(self.currency) do
        -- ����
		if first == fire.pb.game.MoneyType.MoneyType_SilverCoin then
				if self.packid == fire.pb.item.BagTypes.BAG then

					-- �������ӵ���Ч
					local oldmoney = roleItemManager:GetPackMoney()
					if second > oldmoney then
						if roleItemManager:isShowMoneyFlyEffect() then
							local MoneyItemID = 336000
							local itemconfig = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(MoneyItemID)
                            if itemconfig then
							    local p1 = itemconfig.icon
							    local p2 = second - oldmoney
							    local p3 = itemconfig.id
							    AddNewItemsEffect.PlayAddItemsEffect(p1,p2,p3)
                            end
						end

						if gGetGameConfigManager() and gGetGameConfigManager():isPlayEffect() then
                            local PFN = "/sound/ui/coins.ogg"
	                        local FPFN = PFN
	                        FPFN = gGetGameUIManager():GetFullPathFileName(PFN)
                            SimpleAudioEngine:sharedEngine():playEffect(FPFN)
						end
					end

					roleItemManager:SetPackMoney(second)

				elseif self.packid == fire.pb.item.BagTypes.DEPOT then

					roleItemManager:SetDeportMoney(second)

				end

		-- ���
		elseif first == fire.pb.game.MoneyType.MoneyType_GoldCoin then
				if self.packid == fire.pb.item.BagTypes.BAG then

					-- ������ӵ���Ч
					local oldGold = roleItemManager:GetGold()
					if second > oldGold then
						if roleItemManager:isShowMoneyFlyEffect() then
							local GoldID = 330000
							local itemconfig = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(GoldID)
                            if itemconfig then
							    local p1 = itemconfig.icon
							    local p2 = second - oldGold
							    local p3 = itemconfig.id
							    AddNewItemsEffect.PlayAddItemsEffect(p1,p2,p3)
                            end
						end

						if gGetGameConfigManager() and gGetGameConfigManager():isPlayEffect() then
                            local PFN = "/sound/ui/coins.ogg"
	                        local FPFN = PFN
	                        FPFN = gGetGameUIManager():GetFullPathFileName(PFN)
                            SimpleAudioEngine:sharedEngine():playEffect(FPFN)
						end
					end

				end

				roleItemManager:SetGold(second)

		-- ����
		else
			roleItemManager:SetMoneyByMoneyType(first, second)
		end
	end

end
local srefreshitemflag = require "protodef.fire.pb.item.srefreshitemflag"
function srefreshitemflag:process()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local pitem = roleItemManager:FindItemByBagAndThisID(self.itemkey, self.packid)
	if pitem then
        pitem:SetFlag(self.flag)
    end
end

local srefreshitemtimeout = require "protodef.fire.pb.item.srefreshitemtimeout"
function srefreshitemtimeout:process()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local pitem = roleItemManager:FindItemByBagAndThisID(self.itemkey, self.packid)
	if pitem then
        pitem:SetTimeout(self.timeout)
    end
end

local smodifydepotname = require "protodef.fire.pb.item.smodifydepotname"
function smodifydepotname:process()
    GetCTipsManager():AddMessageTipById(162176)
    RoleItemManager.getInstance():setDepotNameByIndex(self.depotindex, self.depotname)
    local dlg = require "logic.item.depot":getInstanceOrNot()
    if dlg then
        dlg:setDepotName(self.depotname)
    end
end

p = require "protodef.fire.pb.huishou.sitembuybacklist"
function p:process()
	local dlg = require("logic.item.buyback.itembuyback").getInstanceNotCreate()
	if dlg then
		dlg:setCellData(self);
		dlg:refreshCell();
	end
end
p = require "protodef.fire.pb.huishou.ssubmitbuyback"
function p:process()
	local id = self.id
    local itemnum = self.itemnum
    local backnum = self.backnum
    local cells = require "logic.item.buyback.itembuybackcell".cells
    local cell = cells[id]
    if cell == nil then
        return
    end

    cell:renderNew(id, itemnum, backnum)

end



p = require "protodef.fire.pb.item.srideupdate"
function p:process()
	RoleItemManager.getInstance():setRideData(self.itemid, self.rideid)
    local packDlg = require("logic.item.mainpackdlg"):getInstanceOrNot()
    if packDlg then
        packDlg:UpdataModel()
    end
end

--<<��Ʒ�һ�

-- ���������ص����һ��б�
p = require "protodef.fire.pb.item.sitemrecoverlist"
function p:process()
	local dlg = require("logic.shop.zhenpinbuyback").getInstanceNotCreate()
	if dlg then
		dlg:recvGoodsList(self.items, 1) --1:ITEM
	end
end

-- ���������ص����һؽ��
p = require "protodef.fire.pb.item.sitemrecover"
function p:process()
	local dlg = require("logic.shop.zhenpinbuyback").getInstanceNotCreate()
	if dlg then
		dlg:recvGoodsBuyBackResult(self.itemid, self.uniqid, 1)
	end
end

-- ����������һ���һص��ߵ���Ϣ
p = require "protodef.fire.pb.item.srecoveriteminfo"
function p:process()
	local data = FireNet.Marshal.OctetsStream(self.tips)
	local dlg = require("logic.tips.commontipdlg").getInstanceNotCreate()
    if dlg and dlg.isZhenPinBuyBack and dlg.itemkey == self.uniqid and dlg.roleItem then
        dlg.roleItem:GetObject():MakeTips(data)
        dlg:RefreshItem_normal() 
		dlg.willCheckTipsWnd = true
        return
    end
end


-- ���������س����һ��б�
p = require "protodef.fire.pb.pet.spetrecoverlist"
function p:process()
	local dlg = require("logic.shop.zhenpinbuyback").getInstanceNotCreate()
	if dlg then
		dlg:recvGoodsList(self.pets, 2) --2:PET
	end
end

-- ���������س����һؽ��
p = require "protodef.fire.pb.pet.spetrecover"
function p:process()
	local dlg = require("logic.shop.zhenpinbuyback").getInstanceNotCreate()
	if dlg then
		dlg:recvGoodsBuyBackResult(self.petid, self.uniqid, 2)
	end
end

-- ����������һ���һس������Ϣ
p = require "protodef.fire.pb.pet.srecoverpetinfo"
function p:process()
	local petData = require("logic.pet.mainpetdata"):new()
    petData:initWithLua(self.petinfo)
	LuaRecvPetTipsData(petData, PETTIPS_T.PET_DETAIL)
end


local p = require "logic.zuoqi.szuoqizyyongyou"
function p:process()
	if self.id==0 then
		local dlg=require "logic.zuoqi.zuoqity".getInstanceNotCreate()
		if dlg then
			dlg:refreshSzTable2(self.zuoqix)
		end
	end
	if self.id==1 then
		local dlg=require "logic.zuoqi.zuoqity".getInstanceNotCreate()
		if dlg then
			dlg:refreshSzTable(self)
		end
	end
	if self.id==8 then
		local dlg=require "logic.zuoqi.wenshihc".getInstanceNotCreate()
		if dlg then
			dlg:UpdateWenShi(self.weishiopen,1)
		end
	end
	if self.id==9 then
		local dlg=require "logic.zuoqi.wenshihc".getInstanceNotCreate()
		if dlg then
			dlg:UpdateWenShi(self.weishiopen,2)
		end
	end

end

--��Ʒ�һ�>>

return fire_pb_item
