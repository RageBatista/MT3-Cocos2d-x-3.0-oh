
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

local p = require "protodef.fire.pb.item.sfreshrepairdata"
function p:process()
	print("protodef.fire.pb.item.sfreshrepairdata process")
	local xlDlg = require "logic.workshop.workshopxlnew"
	xlDlg.OnRefreshAllResult(self)
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
end

local p = require "protodef.fire.pb.item.smailinfo"
function p:process()
	LogInfo("protodef.fire.pb.item.smailinfo process")
	require "system.maillistmanager"
	MailListManager.getInstance():RefreshMailInfo(self.mail)
    require "logic.friend.maildialog".GlobalOnNewMail()
end

local p = require "protodef.fire.pb.item.smailstate"
function p:process()
	LogInfo("protodef.fire.pb.item.smailstate process")
	require "system.maillistmanager"
	MailListManager.getInstance():RefreshMailState(self.kind, self.id, self.statetype, self.statevalue)
    require "logic.friend.maildialog".GlobalOnNewMail()
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
	 local dlg=require("logic.shengsizhan.jingmaihecheng_hs1").getInstanceNotCreate()
	 if dlg then
		dlg:refreshcount()
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
	local dlg=require("logic.shengsizhan.jingmaihecheng_hs1").getInstanceNotCreate()
	if dlg then
	   dlg:refreshcount()
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

p = require "protodef.fire.pb.item.srideupdate"
function p:process()
	RoleItemManager.getInstance():setRideData(self.itemid, self.rideid)
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

--��Ʒ�һ�>>

p = require("protodef.fire.pb.item.xilian.sxilianzhuangbei")
function p:process()
	GetCTipsManager():AddMessageTipById(191105)
end


return fire_pb_item
