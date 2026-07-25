require "utils.mhsdutils"
require "logic.dialog"
require  "logic.qiandaosongli.mtg_firstchargedlg"
require "logic.qiandaosongli.qiandaosonglidlg_mtg"

LoginRewardManager = {ShowQianDao = 0}
LoginRewardManager.__index = LoginRewardManager

local _instance;

LoginRewardManager.eRewardType=
{
	eSignInGift =1,
	eFirstChargeGift = 2,
    eVipGift = 3,
    eMonthCard = 4,
    eQQGift = 5,
	eSevenDayGift =6,
	eOnlineGift = 7,
    eLevelUp = 8,
    eTestReturn = 9,
    ePhoneBind = 10,
	eGiftMax = 11
}


function LoginRewardManager.getInstance()
    if not _instance then
        _instance = LoginRewardManager:new()
    end
    return _instance
end

function LoginRewardManager.getInstanceNotCreate()
    return _instance
end

function LoginRewardManager.Destroy()
    if not _instance then
        return
    end
	_instance = nil
end


function LoginRewardManager.getInstanceAndUpdate()
	if not _instance then
        _instance = LoginRewardManager:new()
    end
    return _instance

end

function LoginRewardManager:new()
    local self = {}
	setmetatable(self, LoginRewardManager)
	self:Init()
    return self
end

function LoginRewardManager:Init()

	self.m_listOpenReward = {}
	for i = 1 , LoginRewardManager.eRewardType.eGiftMax - 1 do
		self.m_listOpenReward[i] = 0		
	end

	self.m_listRewardEffect = {}
	for i = 1 , LoginRewardManager.eRewardType.eGiftMax - 1 do
		self.m_listRewardEffect[i] = 0		
	end
	
	self.m_nDays = 0 --ÿ�յ�¼
	self.m_mapAwards = {}

    self.paynum = 0

	self.total = 0

	self.dayrewardmap = {}

	self.totalrewardmap = {}

	self.m_nSevenDays = 0 --���յ�½
	self.m_mapSevenAwards = 0

	self.m_firstchargeState = 0
	self.m_firstchargeFlag = 0

	self.signinmonth = -1
	self.signintimes = -1
	self.signinrewardflag = -1
	self.signinsuppsignnums = -1
	
	self.levelupItemID = 334000

    self.m_TestReturnNum = 0
    self.m_TestReturnNumOld = 0

    
	
    self.signinsuppregdays = -1
    self.cansuppregtimes = -1

    self.m_listOpenReward[ LoginRewardManager.eRewardType.eMonthCard ] = 1
    self.m_listOpenReward[ LoginRewardManager.eRewardType.eQQGift ] = 1

    self.m_monthcardGet = 0
    self.m_monthcardEndTime = 0

    self.m_qqGiftOpen = 1

    if IsPointCardServer() then
        self.m_listOpenReward[ LoginRewardManager.eRewardType.eMonthCard ] = 0
    end

end


function LoginRewardManager:refreshMonthCard()
    if IsPointCardServer() then
        self.m_listOpenReward[ LoginRewardManager.eRewardType.eMonthCard ] = 0
    else
        self.m_listOpenReward[ LoginRewardManager.eRewardType.eMonthCard ] = 1
        local funopenclosetype = require("protodef.rpcgen.fire.pb.funopenclosetype"):new()
        local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
        if manager then
            if manager.m_OpenFunctionList.info then
                for i,v in pairs(manager.m_OpenFunctionList.info) do
                    if v.key == funopenclosetype.FUN_MONTHCARD then
                        if v.state == 1 then
                            self.m_listOpenReward[ LoginRewardManager.eRewardType.eMonthCard ] = 0
                            break
                        end
                    end
                end
            end
        end
    end
end


function LoginRewardManager:getHaveLevelUpSys()
    local nItemidList = { 334000, 334001, 334002, 334003, 334004, 334005, 334006, 334007, 334008, 334009 }
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    for index , itemid in pairs( nItemidList ) do
        local pitem = roleItemManager:GetItemByBaseID(itemid)
        if pitem then
            return itemid
        end
    end
    return -1
end

function LoginRewardManager:getCanGetLevelupItemId()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local itemid = self:getHaveLevelUpSys()
    local pitem = roleItemManager:GetItemByBaseID(itemid)
    if pitem then
        local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid )
        local roleLevel = gGetDataManager():GetMainCharacterLevel()
        if itembean and roleLevel >= itembean.needLevel then
            return itemid
        end
    end
    return -1
end

function LoginRewardManager:UpdateLevelShowDlg()
    if not _instance then
        return
    end
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local itemid = _instance:getCanGetLevelupItemId()
    local pitem = roleItemManager:GetItemByBaseID(itemid)
    if pitem then
        local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid )
        local roleLevel = gGetDataManager():GetMainCharacterLevel()
        if itembean and roleLevel >= itembean.needLevel then
			local useItemDlg = require "logic.task.taskuseitemdialog".getInstance()
			useItemDlg:SetUseItemId(itemid)
        end
    end
   _instance:refreshAllRed()
end

function LoginRewardManager:refreshAllRed()
    self:refreshLevelupRedData()
    self:refreshMainBoxRed()
    self:refreshJiangliWndRed()
end

function LoginRewardManager:ShowFengCeFanHuan()
    self.m_listOpenReward[ LoginRewardManager.eRewardType.eTestReturn ] = 1
    self.m_listRewardEffect[LoginRewardManager.eRewardType.eTestReturn] = 1
end
function LoginRewardManager:HideFengCeFanHuan()
    self.m_listOpenReward[ LoginRewardManager.eRewardType.eTestReturn ] = 0
    self.m_listRewardEffect[LoginRewardManager.eRewardType.eTestReturn] = 0
end

function LoginRewardManager:refreshMainBoxRed()
    local logodlg = require("logic.logo.logoinfodlg").getInstanceNotCreate()
    if not logodlg then
        return
    end
    logodlg:RefreshBtnJiangli()
end

function LoginRewardManager:refreshJiangliWndRed()
    local dlg = require("logic.qiandaosongli.jianglinewdlg").getInstanceNotCreate()
    if dlg then
        dlg:refreshAllRedPoint()
    end
end

function LoginRewardManager:SetLoginDays(days)
	self.m_nDays = days
end

function LoginRewardManager:GetLoginDays()
	return self.m_nDays
end

function LoginRewardManager:SetPayNum(num)
    self.paynum = num
end

function LoginRewardManager:GetPayNum()
	return self.paynum
end
function LoginRewardManager:SetTotal(num)
    self.total = num
end

function LoginRewardManager:GetTotal()
	return self.total
end
function LoginRewardManager:SetDayReawardMap(mapAwards)
	self.dayrewardmap = mapAwards
    local dlg = fuliplane.getInstanceNotCreate()
	if dlg then
		dlg:UpdateCellData()
	end
end

function LoginRewardManager:GetDayReawardMap()
	return self.dayrewardmap
end
function LoginRewardManager:SetTotalReawardMap(mapAwards)
	self.totalrewardmap = mapAwards
    local dlg = fuliplane.getInstanceNotCreate()
	if dlg then
		dlg:UpdateCellData()
	end
end

function LoginRewardManager:GetTotalReawardMap()
	return self.totalrewardmap
end
function LoginRewardManager:SetLoginMapAwards( mapAwards )
	self.m_mapAwards = mapAwards
	self.m_listRewardEffect[ LoginRewardManager.eRewardType.eSevenDayGift ] = 0
	
	self.m_listOpenReward[ LoginRewardManager.eRewardType.eSevenDayGift ] = 1
	
	local gotcnt = 0
	for i, v in pairs( self.m_mapAwards ) do
		if v ~= 0 then
			gotcnt = gotcnt + 1
		end
	end
	
	if gotcnt >= 7 then
		self.m_listOpenReward[ LoginRewardManager.eRewardType.eSevenDayGift ] = 0
	end

	
	for i, v in pairs( self.m_mapAwards ) do
		if v == 0 then
			self.m_listRewardEffect[ LoginRewardManager.eRewardType.eSevenDayGift ] = 1
			break
		end
	end

    self:refreshAllRed()

	local logoDlg = LogoInfoDialog.getInstanceNotCreate()
	if logoDlg then
		logoDlg:RefreshBtnJiangli()
	end 
	
	local dlg = ContinueDayReward.getInstanceNotCreate()
	if dlg then
		dlg:UpdateCellData()
	end
end

function LoginRewardManager:GetMapAwards()
	return self.m_mapAwards
end

function LoginRewardManager:SetMapAwardsSignalCell( index , result )
 	if result == 0 then
		local tempStrTip = MHSD_UTILS.get_msgtipstring(150013)
		GetCTipsManager():AddMessageTip(tempStrTip)
	end
end

function LoginRewardManager:SetVipInfo( viplevel, kelingviplevel )
    if self.m_listOpenReward[ LoginRewardManager.eRewardType.eFirstChargeGift ] == 0 then
        if viplevel ~= VipDialog.m_MaxVipLevel then
            self.m_listOpenReward[ LoginRewardManager.eRewardType.eVipGift ] = 1
            local winMgr = CEGUI.WindowManager:getSingleton()
            if winMgr:isWindowPresent("VIPBG") == false and winMgr:isWindowPresent("shouchong") then
                local dlg = require("logic.qiandaosongli.jianglinewdlg").getInstanceNotCreate()
                if dlg~=nil then
                    dlg:ShowVipDialog()
                end
            end
            if viplevel ~= kelingviplevel then
                self.m_listRewardEffect[LoginRewardManager.eRewardType.eVipGift] = 1
            else
                self.m_listRewardEffect[LoginRewardManager.eRewardType.eVipGift] = 0
            end
        else
            self.m_listOpenReward[ LoginRewardManager.eRewardType.eVipGift ] = 0
            self.m_listRewardEffect[LoginRewardManager.eRewardType.eVipGift] = 0
        end
        local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
        if manager then
            if manager.m_isPointCardServer then
                self.m_listOpenReward[ LoginRewardManager.eRewardType.eVipGift ] = 0
                self.m_listRewardEffect[LoginRewardManager.eRewardType.eVipGift] = 0
            end
        end
        self:refreshJiangliWndRed()
    end
end

function LoginRewardManager:SetFirstChargeState( state, flag )
	self.m_firstchargeState = state
	self.m_firstchargeFlag = flag	
	self.m_listOpenReward[ LoginRewardManager.eRewardType.eFirstChargeGift ] = 0
	self.m_listRewardEffect[ LoginRewardManager.eRewardType.eFirstChargeGift ] = 0
	if false then  --�Ƿ������׳佱�� true ����  false ����
		local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
		if manager then
			if not manager.m_isPointCardServer then
				if self.m_firstchargeState ~= 2 then
					self.m_listOpenReward[ LoginRewardManager.eRewardType.eFirstChargeGift ] = 1
					if self.m_firstchargeState == 1 then
						self.m_listRewardEffect[ LoginRewardManager.eRewardType.eFirstChargeGift ] = 1	
					end
				end
			end
		end  
    else
		if self.m_firstchargeState ~= 2 then
			self.m_listOpenReward[ LoginRewardManager.eRewardType.eFirstChargeGift ] = 1
			if self.m_firstchargeState == 1 then
				self.m_listRewardEffect[ LoginRewardManager.eRewardType.eFirstChargeGift ] = 1	
			end
		end
	end
	
    self:refreshAllRed()

	local dlg = MTGFirstChargeDlg.getInstanceNotCreate()
	if dlg then
		dlg:RefreshBtn()
	end
	
	local logoDlg = LogoInfoDialog.getInstanceNotCreate()
	if logoDlg then
		logoDlg:RefreshBtnJiangli()
	end 
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            return
        end
    end
    --����VIP��Ϣ
    require "protodef.fire.pb.fushi.crequestvipinfo"
    local msg = CRequestVipInfo.Create()
    LuaProtocolManager.getInstance():send(msg)
    -- end!

end

function LoginRewardManager.MTOnlineRewardProcess( giftid, remainTime )
	local mgr = LoginRewardManager:getInstance()
    if gGetWelfareManager() then
        if giftid <=0 then
            gGetWelfareManager():setOnLineWelfareFinish(true);
        else
            gGetWelfareManager():setGiftId(giftid);
            gGetWelfareManager():setOnLineWelfareFinish(false);
        end
    end
	
	if remainTime < 0 then remainTime = 0 end

    if giftid >0 then
		mgr.m_listOpenReward[ LoginRewardManager.eRewardType.eOnlineGift ] = 1
		mgr.m_listRewardEffect[ LoginRewardManager.eRewardType.eOnlineGift ] = 0
		if gGetWelfareManager() and (not gGetWelfareManager():getOnLineWelfareFinish())then
			gGetWelfareManager():setCountDownEnable(true)
		end
        if remainTime <= 0 then
			mgr.m_listRewardEffect[ LoginRewardManager.eRewardType.eOnlineGift ] = 1
        elseif gGetWelfareManager() then
            gGetWelfareManager():setBeginTime(remainTime / 1000);
        end

	else
		mgr.m_listOpenReward[ LoginRewardManager.eRewardType.eOnlineGift ] = 0
		mgr.m_listRewardEffect[ LoginRewardManager.eRewardType.eOnlineGift ] = 0
    end
	
    if _instance then
        _instance:refreshAllRed()
    end
	
	
   	local logoDlg = LogoInfoDialog.getInstanceNotCreate()
	if logoDlg then
		logoDlg:RefreshBtnJiangli()
	end 
	
	if giftid <=0 then
		local dlg = MTG_OnLineWelfareDlg.getInstanceNotCreate()
		if dlg then
			dlg.DestroyDialog()
		end
	end
end

function LoginRewardManager:SetSignInData( month, times, rewardflag, suppsignnums, suppregdays, cansuppregtimes)
	self.signinmonth = month
	self.signintimes = times
	self.signinrewardflag = rewardflag
	self.signinsuppsignnums = suppsignnums
    self.signinsuppregdays = suppregdays
    self.cansuppregtimes = cansuppregtimes
	self.m_listOpenReward[ LoginRewardManager.eRewardType.eSignInGift ] = 1
	
	if self.signinrewardflag == 0  then
		self.m_listRewardEffect[ LoginRewardManager.eRewardType.eSignInGift ] = 1
	else
		self.m_listRewardEffect[ LoginRewardManager.eRewardType.eSignInGift ] = 0
	end

    self:refreshAllRed()

	require "logic.qiandaosongli.qiandaosonglidlg_mtg"	
	local dlg = QiandaosongliDlg.getInstanceNotCreate()
	if dlg then
		dlg:SetData(  month, times, rewardflag, suppsignnums, suppregdays, cansuppregtimes )
	end
	local logoDlg = LogoInfoDialog.getInstanceNotCreate()
	if logoDlg then
		logoDlg:RefreshBtnJiangli()
	end 
    local bShowSignIn = self.m_listRewardEffect[ LoginRewardManager.eRewardType.eSignInGift ]
	if bShowSignIn == 1 and LoginRewardManager.ShowQianDao ~= 2 then
		print( "QiandaosongliDlg.getInstanceAndShow" )
        local record = GameTable.common.GetCCommonTableInstance():getRecorder(180)
        local needlevel = record.value
        local data = gGetDataManager():GetMainCharacterData()
		local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL)
		-- ����Ǵ� ios9 ��ݲ˵�������Ϸ������ʾ�������棬��ΪҪ��ʾ��ݲ˵���Ӧ�Ľ���
        if nLvl>=tonumber(needlevel) and not gGetLoginManager():isShortcutLaunched() then
            QiandaosongliDlg.getInstanceAndShow()
        end
	end

	LoginRewardManager.ShowQianDao = 0
end


function LoginRewardManager:getEffectEnabel()
	for i = 1, 5 do
		if self.m_listRewardEffect[ i ] == 1 then
			return true
		end
	end
	return false
end

function LoginRewardManager.SetLevelUpItemID( itemID )
	local mgr = LoginRewardManager:getInstance()
	if itemID ~= 0 then
		mgr.levelupItemID = itemID
		
		local 	dlg = require "logic.qiandaosongli.leveluprewarddlg":getInstanceNotCreate()
		if dlg then
			dlg:DestroyListCell()
			dlg:SetRewardID(mgr.levelupItemID)
		end
	else
		local 	dlg = require "logic.qiandaosongli.leveluprewarddlg":getInstanceNotCreate()
		if dlg then
			dlg:RefreshRewardID()
		end
	end
    if not _instance then
        return
    end
    _instance:refreshAllRed()
end

function LoginRewardManager:GetCanRewardCount()
    self:refreshLevelupRedData()
	local cnt = 0
	for i, v in pairs( self.m_listRewardEffect ) do
		if v > 0 then
			cnt = cnt + 1
		end		
	end
	return cnt	
end

function LoginRewardManager:refreshLevelupRedData()
    local nItemId = self:getHaveLevelUpSys()
    if nItemId~=-1 then
         self.m_listOpenReward[LoginRewardManager.eRewardType.eLevelUp] = 1
    else
         self.m_listOpenReward[LoginRewardManager.eRewardType.eLevelUp] = 0
    end
     local nItemId = self:getCanGetLevelupItemId()
     if nItemId~= -1 then
        self.m_listRewardEffect[LoginRewardManager.eRewardType.eLevelUp] = 1
     else
        self.m_listRewardEffect[LoginRewardManager.eRewardType.eLevelUp] = 0
     end
end

function LoginRewardManager:SetMonthCardInfo(endtime, nget)
    self.m_monthcardGet = nget
    self.m_monthcardEndTime = endtime
    if self.m_monthcardGet == 0  then
        self.m_listRewardEffect[LoginRewardManager.eRewardType.eMonthCard] = 0
     else
        self.m_listRewardEffect[LoginRewardManager.eRewardType.eMonthCard] = 1
    end
    local dlg = require("logic.monthcard.monthcarddlg").getInstanceNotCreate()
    if dlg then
        dlg:RefreshTimeAndBtn()
    end
    self:refreshAllRed()
end
function LoginRewardManager:SetQQopen(status)
    require "logic.qiandaosongli.loginrewardmanager"
	local mgr = LoginRewardManager.getInstance()
    mgr.m_listOpenReward[LoginRewardManager.eRewardType.eQQGift] = status
end

function LoginRewardManager:SetPhoneBindOpen(status)
    self.m_listOpenReward[LoginRewardManager.eRewardType.ePhoneBind] = status
end

function LoginRewardManager:SetPhoneBindRedPoint(status)
    self.m_listRewardEffect[LoginRewardManager.eRewardType.ePhoneBind] = status
end

return LoginRewardManager
