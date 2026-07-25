require "logic.shop.shoplabel"
require "logic.chargedialog"
require "logic.vip.vip"

local sreqcharge = require "protodef.fire.pb.fushi.sreqcharge"
function sreqcharge:process()
    print("enter sreqcharge process ")
    require "logic.chargedialog"

    -- debugrequire "logic.chargedialog"

	--comment by lg, 如果切到别的页面了就不该再显示充值了
    --ChargeDialog.getInstance():SetVisible(true)
    local pcManager = require "logic.pointcardserver.pointcardservermanager".getInstance()
    if self.opendy==1 then
        pcManager.bDingyueOpen = true
    else
        pcManager.bDingyueOpen = false
    end

    require "utils.tableutil"
    local yuanbao_max = 0
    for k, v in ipairs(self.goods) do
        local item = BeanConfigManager.getInstance():GetTableByName("fushi.caddcashlua"):getRecorder(v.goodid)
        -- lua
        if item.maxcash == 1 then
            yuanbao_max = v.goodid
            break
        end
    end



    local nIndex = 0
    for k, v in ipairs(self.goods) do
        -- 更新一下最新的数据 by changhao
        local dlg = ChargeDialog.getInstanceNotCreate()
        if dlg then
            dlg:UpdateGood(k, v.goodid, v.price, v.fushi, v.present, v.beishu, yuanbao_max)
        end
        nIndex = nIndex + 1
        if nIndex==8 then
            break
        end
    end

    local chargeDlg = ChargeDialog.getInstanceNotCreate()
    if chargeDlg then
        chargeDlg:refreshDingyueBtn()
    end
    
end

local srequestchargereturnprofit = require "protodef.fire.pb.fushi.srequestchargereturnprofit"
function srequestchargereturnprofit:process()
    print("enter srequestchargereturnprofit process ")
    require "logic.chargedialog"
    require "utils.tableutil"
    local datamanager = require "logic.chargedatamanager"
    if datamanager then
        datamanager.m_ChargeReturnList = self.listchargereturnprofit
    end

    local dlg = ChargeDialog.getInstanceNotCreate()	
    for k, v in ipairs(self.listchargereturnprofit) do
        if dlg then
            local item = BeanConfigManager.getInstance():GetTableByName("fushi.cchargereturnprofit"):getRecorder(v.id)
            dlg:UpdateChargeReturn(v.id, v.value, v.maxvalue, v.status, item.text)
        end
    end

    local redpoint =  datamanager.GetRedPointStatus()
    --[[
    if dlg then
        if dlg.m_ReturnRedPoint then
            dlg.m_ReturnRedPoint:setVisible(redpoint)
        else
            LogWar("srequestchargereturnprofit:process dlg datamanager.m_ReturnRedPoint == nil");
        end
    end
    --]]
    local dlg2 =  ShopLabel.getInstanceNotCreate()
    if dlg2 then
        if dlg2.m_ReturnRedPoint then
            dlg2.m_ReturnRedPoint:setVisible(redpoint)
        else
            LogWar("srequestchargereturnprofit:process dlg2 ShopLabel.m_ReturnRedPoint == nil");
        end
    end

    local dlg3 = LogoInfoDialog.getInstanceNotCreate()
    if dlg3 then
        if dlg3.m_ReturnRedPoint then
            dlg3.m_ReturnRedPoint:setVisible(redpoint)
        else
            LogWar("srequestchargereturnprofit:process dlg3 LogoInfoDialog.m_ReturnRedPoint == nil");
        end
    end
    
    local dlg4 = ZhanDouAnNiu.getInstanceNotCreate()
    if dlg4 then
     dlg4.m_pShangChengMark:setVisible(redpoint)
    end
end

local sgrabchargereturnprofitreward = require "protodef.fire.pb.fushi.sgrabchargereturnprofitreward"
function sgrabchargereturnprofitreward:process()
    print("enter sgrabchargereturnprofitreward process ")
    require "logic.chargedialog"

    require "utils.tableutil"
    local datamanager = require "logic.chargedatamanager"
    if datamanager then
        datamanager.ChangeData(self.id, self.status)
    end

    local dlg = ChargeDialog.getInstanceNotCreate()
    if dlg then
        dlg:UpdateChargeReturnCellStatus(self.id, self.status);
    end
    local redpoint =  datamanager.GetRedPointStatus()
    --[[
    if dlg then
        if dlg.m_ReturnRedPoint then
            dlg.m_ReturnRedPoint:setVisible(redpoint)
        else
            LogWar("sgrabchargereturnprofitreward:process dlg datamanager.m_ReturnRedPoint == nil");
        end
    end
    --]]
    local dlg2 =  ShopLabel.getInstanceNotCreate()
    if dlg2 then
        if dlg.m_ReturnRedPoint then
            dlg2.m_ReturnRedPoint:setVisible(redpoint)
        else
            LogWar("sgrabchargereturnprofitreward:process dlg ShopLabel.m_ReturnRedPoint == nil");
        end
    end

    local dlg3 = LogoInfoDialog.getInstanceNotCreate()
    if dlg3 then
        if dlg.m_ReturnRedPoint then
            dlg3.m_ReturnRedPoint:setVisible(redpoint)
        else
            LogWar("sgrabchargereturnprofitreward:process dlg LogoInfoDialog.m_ReturnRedPoint == nil");
        end
    end
        
    local dlg4 = ZhanDouAnNiu.getInstanceNotCreate()
    if dlg4 then
     dlg4.m_pShangChengMark:setVisible(redpoint)
    end
end

local sconfirmcharge = require "protodef.fire.pb.fushi.sconfirmcharge"
function sconfirmcharge:process()
    LogInfo("enter sconfirmcharge process")
    require "logic.gamewaitingdlg".DestroyDialog()
    -- JSON  {"customInfo":"3031062677","roleId":"405506","roleName":"xxxx","roleGrade":"1","amount":"1000","serverid":"1"}

    if self.extra ~= "" then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(191031))
        return
    end

    if Config.CUR_3RD_PLATFORM == "app" then
            local appgoodid = self.goodid
            if MT3.ChannelManager:IsAndroid() == 1 then
                    appgoodid = appgoodid + 100
                    if gGetChannelName() == Config.PlatformOfLenovo then
                        appgoodid = appgoodid + 200
                    elseif gGetChannelName() == Config.PlatformOfCoolPad then
                        appgoodid = appgoodid + 100
                    end
            end
        MT3.ChannelManager:StartBuyYuanbao(self.billid, self.goodname, appgoodid, self.goodnum, self.price, self.serverid)
        return
    end

    local json = '{"customInfo":"'
    .. tostring(self.billid)
    .. '",'
    .. '"roleId":"'
    .. tostring(gGetDataManager():GetMainCharacterID())
    .. '",'
    .. '"roleName":"'
    .. gGetDataManager():GetMainCharacterName()
    .. '",'
    .. '"roleGrade":"'
    .. tostring(gGetDataManager():GetMainCharacterLevel())
    .. '",'
    .. '"amount":"'
    .. tostring(self.price)
    .. '",'
    .. '"serverid":"'
    .. tostring(self.serverid)
    .. '"}'

    local goodname = self.goodname

    if Config.CUR_3RD_PLATFORM == "efunios" then
        record = BeanConfigManager.getInstance():GetTableByName("fushi.caddcashlua"):getRecorder(self.goodid)
        -- lua
        goodname = ""
    end

    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "efad" then
        local record = nil
        if self.goodid then
            record = BeanConfigManager.getInstance():GetTableByName("fushi.caddcashlua"):getRecorder(self.goodid)
        else
            print("____error no self.goodid")
        end

        if record and record.id ~= -1 then
            goodname = goodname .. "#"
        else
            LogInfo("____error not correct record")
            goodname = goodname .. "#" .. " "
        end
        if gGetDataManager() and gGetDataManager():GetMainCharacterLevel() then
            goodname = goodname .. "#" .. tostring(gGetDataManager():GetMainCharacterLevel())
        else
            LogInfo("___error note get character level")
            goodname = goodname .. "#" .. " "
        end
    end


    if Config.isKoreanAndroid() then
        local record = nil
        if self.goodid then
            record = BeanConfigManager.getInstance():GetTableByName("fushi.caddcashlua"):getRecorder(self.goodid)
        else
            print("____error no self.goodid")
        end

        if record and record.id ~= -1 then
            goodname = goodname .. "#"
        else
            LogInfo("____error not correct record")
            goodname = goodname .. "#" .. " "
        end

    end


    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "thlm" then
        local record = nil
        if self.goodid then
            record = BeanConfigManager.getInstance():GetTableByName("fushi.caddcashlua"):getRecorder(self.goodid)
        else
            print("____error no self.goodid")
        end

        if record and record.id ~= -1 then
            goodname = goodname .. "#"
        else
            LogInfo("____error not correct record")
            goodname = goodname .. "#" .. " "
        end
    end

    if Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_LOGIN_SUFFIX == "this" then
        local record = nil
        if self.goodid then
            record = BeanConfigManager.getInstance():GetTableByName("fushi.caddcashlua"):getRecorder(self.goodid)
        else
            print("____error no self.goodid")
        end

        if record and record.id ~= -1 then
            goodname = ""
        end
    end



    if Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_LOGIN_SUFFIX == "kris" then
        local record = nil
        if self.goodid then
            record = BeanConfigManager.getInstance():GetTableByName("fushi.caddcashlua"):getRecorder(self.goodid)
        else
            print("____error no self.goodid")
        end

        if record and record.id ~= -1 then
            goodname = ""
        end
    end

    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "unpy" then
        local record = nil
        if self.goodid then
            record = BeanConfigManager.getInstance():GetTableByName("fushi.caddcashlua"):getRecorder(self.goodid)
        else
            print("____error no self.goodid")
        end

        if record and record.id ~= -1 then
            goodname = goodname .. "#" .. "#"
        else
            LogInfo("____error not correct record")
            goodname = goodname .. "#" .. " "
        end
    end


    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "ydjd" then
        if self.goodid then
            local record = BeanConfigManager.getInstance():GetTableByName("fushi.caddcashlua"):getRecorder(self.goodid)
            goodname = ""
            if not string.find(record.roofid, "ydjd") then
                return
            end
        end
    end

    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "ximi" then
        require "luaj"
        
        require "logic.faction.factiondatamanager"

        local curUserData = { }
        local blankStr = " "
        if gGetDataManager() and gGetDataManager():GetYuanBaoNumber() then
            curUserData[1] = tostring(gGetDataManager():GetYuanBaoNumber())
        else
            curUserData[1] = blankStr
        end
       
            curUserData[1] = curUserData[1] .. "#" .. blankStr
        
        if gGetDataManager() and gGetDataManager():GetMainCharacterLevel() then
            curUserData[1] = curUserData[1] .. "#" .. tostring(gGetDataManager():GetMainCharacterLevel())
        else
            curUserData[1] = curUserData[1] .. "#" .. blankStr
        end

        local bGet, facName = FactionDataManager.GetCurFactionName()
        if bGet then
            curUserData[1] = curUserData[1] .. "#" .. facName
        else
            curUserData[1] = curUserData[1] .. "#" .. blankStr
        end

        if gGetDataManager() and gGetDataManager():GetMainCharacterID() then
            curUserData[1] = curUserData[1] .. "#" .. gGetDataManager():GetMainCharacterID()
        else
            curUserData[1] = curUserData[1] .. "#" .. blankStr
        end

        luaj.callStaticMethod("com.locojoy.mini.mt3.GameApp", "setPlayerData", curUserData, nil)
    end

    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "lnvo" then
        if self.goodid then
            local record = BeanConfigManager.getInstance():GetTableByName("fushi.caddcashlua"):getRecorder(self.goodid)
            goodname = ""
            if not string.find(record.roofid, "lnvo") then
                return
            end
        end
    end

    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "lemn" then
        local record = nil
        if self.goodid then
            record = BeanConfigManager.getInstance():GetTableByName("fushi.caddcashlua"):getRecorder(self.goodid)
        else
            print("____error no self.goodid")
        end

        if record and record.id ~= -1 then
            goodname = ""
        end
    end

    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "txqq" then
        goodname = self.extra
    end

    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "ysuc" then
        require "luaj"
        luaj.callStaticMethod("com.locojoy.mini.mt3.uc.UcPlatform", "purchase2", { json }, nil)
        return
    end

    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "twap" then
        require "luaj"
        luaj.callStaticMethod("com.efun.ensd.ucube.PlatformTwApp01", "purchase2", { json }, nil)
        return
    end

    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "tw36" then
        require "luaj"
        luaj.callStaticMethod("com.locojoy.mini.mt3.tw360.PlatformTw360", "purchase2", { json }, nil)
        return
    end

    MT3.ChannelManager:StartBuyYuanbao(self.billid, goodname, self.goodid, self.goodnum, self.price, self.serverid)
end

local srefreshchargestate = require "protodef.fire.pb.fushi.srefreshchargestate"
function srefreshchargestate:process()
    LogInfo("enter srefreshchargestate process state :" .. self.state)
    require "logic.chargedialog"

    require "logic.qiandaosongli.loginrewardmanager"
    local mgr = LoginRewardManager.getInstance()
    LoginRewardManager.getInstance():SetFirstChargeState(self.state, self.flag)

    -- ChargeDialog.m_ChargeState = self.state
    -- ChargeDialog.m_ChargeFlag = self.flag
end

local sreqfushinum = require "protodef.fire.pb.fushi.sreqfushinum"
function sreqfushinum:process()
    if not gGetDataManager() then
		return;
	end
	gGetDataManager():SetYuanBaoNumber(self.num);
	gGetDataManager():SetBindYuanBaoNuber(self.bindnum);
	gGetDataManager():SetTotalRechargeYuanBaoNumber(self.totalnum);

	if LoginRewardManager.ShowQianDao == 1 then
		LoginRewardManager.ShowQianDao = 2
	end
end
local sreqchargerefundsinfo = require "protodef.fire.pb.fushi.sreqchargerefundsinfo"
function sreqchargerefundsinfo:process()
    LogInfo("enter sreqchargerefundsinfo process")
    if self.result == 1 then
        require "logic.qiandaosongli.loginrewardmanager"
	    local mgr = LoginRewardManager.getInstance()
        mgr:ShowFengCeFanHuan()
        mgr.m_TestReturnNum = self.chargevalue
        mgr.m_TestReturnNumOld = self.charge
    end
end
local sgetchargerefunds = require "protodef.fire.pb.fushi.sgetchargerefunds"
function sgetchargerefunds:process()
    LogInfo("enter sgetchargerefunds process")

    local level = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(309).value)
    local nUserLevel = gGetDataManager():GetMainCharacterLevel()
    if self.result ==  1 and nUserLevel >= level then
        require "logic.qiandaosongli.loginrewardmanager"
        local mgr = LoginRewardManager.getInstance()
        mgr:HideFengCeFanHuan()
        mgr:refreshAllRed()
        local dlg = require"logic.qiandaosongli.fengcefanhuandlg".getInstanceNotCreate()
        if dlg then
            dlg:End()
        end
    end

end

local svipinfo = require "protodef.fire.pb.fushi.ssendvipinfo"
function svipinfo:process()
    LogInfo("enter svipinfo process")

	local oldVipLevel = gGetDataManager():GetVipLevel();

    local yiLingVipLevel = BitOP.GetMaxBit(self.gotbounus)
    local keLingVipLevel = BitOP.GetMaxBit(self.bounus)

	--设置为已取得的vip等级 yangbin
    gGetDataManager():SetVipLevel(keLingVipLevel)

    -- 刷loginrewardmanager.
    require "logic.qiandaosongli.loginrewardmanager"
    local mgr = LoginRewardManager.getInstance()
    LoginRewardManager.getInstance():SetVipInfo(yiLingVipLevel, keLingVipLevel)

    -- 缴费界面
    local winMgr = CEGUI.WindowManager:getSingleton()
    if winMgr:isWindowPresent("Charge/VIPBG") then
        local dlg = ChargeDialog.getInstanceNotCreate()
        if dlg then
            dlg:SetVipInfo(keLingVipLevel, keLingVipLevel + 1, self.vipexp)
        end
    end

    -- VIP领取界面，显示当前领取项
    if winMgr:isWindowPresent("VIPBG") then
        local dlg = VipDialog.getInstanceNotCreate()
        if dlg then
            dlg:SetVipInfo(yiLingVipLevel,keLingVipLevel,self.vipexp)
        end
    end

    require("logic.shop.mallshop").onVipLevelChanged()
    require("logic.shop.commercedlg").onVipLevelChanged()


	--解决解锁背包的时候如果符石不够，然后充值，冲到了vip5，解锁了40格背包，然后返回背包，会把锁定的背包格刷没的问题。刷新一下
	local VipLevel = gGetDataManager():GetVipLevel();
	if oldVipLevel and VipLevel and oldVipLevel ~= VipLevel then
		require "logic.item.mainpackdlg"
		if CMainPackDlg:getInstanceOrNot() then
			CMainPackDlg:getInstanceOrNot():ExpendPackCapacity()
		end
	end

end
local ssendredpackview = require "protodef.fire.pb.fushi.redpack.ssendredpackview"
function ssendredpackview:process()

    local manager = require"logic.redpack.redpackmanager".getInstance()
    if manager then
        local redpacks = {}
        manager.m_RedPackNums[self.modeltype] = self.daysrnum
        if self.redpackinfolist ~= nil then
            for i,v in pairs (self.redpackinfolist) do
                table.insert(redpacks, v)
            end
        end 
        manager.m_RedPacks[self.modeltype] = redpacks
        local dlg = require"logic.redpack.redpackdlg".getInstance()
        if dlg then
            if dlg.m_index == self.modeltype then
                dlg:InitTable()
            end
        end
    end
end
local ssendredpack = require "protodef.fire.pb.fushi.redpack.ssendredpack"
function ssendredpack:process()
    GetCTipsManager():AddMessageTipById(190084)-- 发送成功
end
local sgetredpack = require "protodef.fire.pb.fushi.redpack.sgetredpack"
function sgetredpack:process()
    local manager = require"logic.redpack.redpackmanager".getInstance()
    manager:UpdateData(self)
    if self.successflag == 1 then
        local scale = 1
        local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
        if manager then
            if manager.m_isPointCardServer then
                scale = 100
            end 
        end
        local dlg = require "logic.redpack.redpackdlg".getInstanceNotCreate()
        if dlg and dlg:IsVisible() then
            dlg:AddRedPackEffect(self.fushinum)
        else
            require"logic.redpack.topeffectdlg".DestroyDialog()
            local effectdlg = require"logic.redpack.topeffectdlg".getInstanceAndShow()
            if effectdlg then
                effectdlg:startRedPackOpen(self.fushinum / scale)
            end
        end

    end
end
local ssendredpackhisview = require "protodef.fire.pb.fushi.redpack.ssendredpackhisview"
function ssendredpackhisview:process()
    require"logic.redpack.redpackrecorddlg".DestroyDialog()
    local dlg = require"logic.redpack.redpackrecorddlg".getInstanceAndShow()
    if dlg then
        dlg:setData(self)
    end
  
end

local ssendredpackrolerecordview = require "protodef.fire.pb.fushi.redpack.ssendredpackrolerecordview"
function ssendredpackrolerecordview:process()
     local dlg = require"logic.redpack.redpackhistorydlg".getInstanceAndShow()
    if dlg then
        dlg:setData(self)
    end
   
end
local snoticeredpacklist = require "protodef.fire.pb.fushi.redpack.snoticeredpacklist"
function snoticeredpacklist:process()
    local manager = require"logic.redpack.redpackmanager".getInstance()
    manager:setNotice(self)
end
local snoticeredpack = require "protodef.fire.pb.fushi.redpack.snoticeredpack"
function snoticeredpack:process()
    local manager = require"logic.redpack.redpackmanager".getInstance()
    if manager then
        manager:setNotice(self.redpackroletip)
    end
end
--点卡服
local spayservertype = require "protodef.fire.pb.fushi.payday.spayservertype"
function spayservertype:process()
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstance()
    if self.paytype == 0 then
        manager.m_isPointCardServer = false
    else
        manager.m_isPointCardServer = true
    end
    if self.opendy==1 then
        manager.bDingyueOpen = true
    else
        manager.bDingyueOpen = false
    end

    require "logic.qiandaosongli.loginrewardmanager"
    local mgr = LoginRewardManager.getInstance()
    mgr:refreshMonthCard()
end
local sconsumedaypay = require "protodef.fire.pb.fushi.payday.sconsumedaypay"
function sconsumedaypay:process()
    GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(300006), false)
end

local shavedaypay = require "protodef.fire.pb.fushi.payday.shavedaypay"
function shavedaypay:process()
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstance()
    if self.daypay == 0 then
        require "logic.qiandaosongli.loginrewardmanager"
        local mgr = LoginRewardManager.getInstance()
        if mgr.m_firstchargeState == 0 then
            require"logic.pointcardserver.messageforpointcardnotcashdlg".getInstanceAndShow()
        else
            require"logic.pointcardserver.messageforpointcarddlg".getInstanceAndShow()
        end
        
        manager.m_isTodayNotFree = true
    else
        require "logic.qiandaosongli.loginrewardmanager"
        local mgr = LoginRewardManager.getInstance()
        if mgr.m_firstchargeState == 0 then
            require"logic.pointcardserver.messageforpointcardnotcashdlg".DestroyDialog()
        else
            require"logic.pointcardserver.messageforpointcarddlg".DestroyDialog()
        end
        manager.m_isTodayNotFree = false
        local label = require("logic.shop.shoplabel").getInstanceNotCreate()
        if label then
            require("logic.shop.shoplabel").showAllButton()
        end
    end

    local dlg = require("logic.chargedialog").getInstanceNotCreate()
    if dlg then
          dlg:refreshDingyueBtn()
    end
end


local shavedaypay = require "protodef.fire.pb.fushi.payday.squerysubscribeinfo"
function shavedaypay:process()
    
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstance()
    manager.nnDingyueOverTime = self.expiretime

    local dlg = require("logic.chargedialog").getInstanceNotCreate()
    if dlg then
          dlg:refreshDingyueBtn()
    end

end



local squeryconsumedaypay = require "protodef.fire.pb.fushi.payday.squeryconsumedaypay"
function squeryconsumedaypay:process()
    local function ClickYes(self, args)
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
        local p = require("protodef.fire.pb.fushi.payday.cqueryconsumedaypay"):new()
        p.yesorno = 1
	    LuaProtocolManager:send(p)
    end
    local function ClickNo(self, args)
        if CEGUI.toWindowEventArgs(args).handled ~= 1 then
            local  p = require("protodef.fire.pb.creturntologin"):new()
	        LuaProtocolManager:send(p)
            local huodongmanager = require"logic.huodong.huodongmanager".getInstanceNotCreate()
            if huodongmanager then
                huodongmanager:OpenPush()
            end
            gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)

        end
        return
    end
    local nTipId = 11519
    local pcManager = require "logic.pointcardserver.pointcardservermanager".getInstance()
    if pcManager.bDingyueOpen==true then
        nTipId = 11519
    else
        nTipId = 11618
    end
    gGetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_resstring(nTipId), ClickYes, 
    self, ClickNo, self,0,0,nil,MHSD_UTILS.get_resstring(11520),MHSD_UTILS.get_resstring(11521))
end
--符石交易系统

--求购符石返回
local sbuyspotcard = require "protodef.fire.pb.fushi.spotcheck.sbuyspotcard"
function sbuyspotcard:process()
    GetCTipsManager():AddMessageTipById(190046)
end
--寄卖符石返回
local ssellspotcard = require "protodef.fire.pb.fushi.spotcheck.ssellspotcard"
function ssellspotcard:process()
    GetCTipsManager():AddMessageTipById(190047)
end
--交易区界面
local stradingspotcardview = require "protodef.fire.pb.fushi.spotcheck.stradingspotcardview"
function stradingspotcardview:process()
    local manager = require"logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        manager.m_SpotBuys = {}
        manager.m_SpotSells = {}

        for i,v in pairs (self.buyspotcardinfolist) do
            table.insert(manager.m_SpotBuys, v)
        end
        for i,v in pairs (self.sellspotcardinfolist) do
            table.insert(manager.m_SpotSells, v)
        end
        local dlg = require"logic.pointcardserver.currencytradingdlg".getInstanceNotCreate()
        if dlg then
            dlg:refreshDataSpot()
        end
    end
end
--个人买卖界面
local sroletradingview = require "protodef.fire.pb.fushi.spotcheck.sroletradingview"
function sroletradingview:process()
    local manager = require"logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        manager.m_RoleBuys = {}
        manager.m_RoleSells = {}

        for i,v in pairs (self.buyspotcardinfolist) do
            table.insert(manager.m_RoleBuys, v)
        end
        for i,v in pairs (self.sellspotcardinfolist) do
            table.insert(manager.m_RoleSells, v)
        end
        local dlg = require"logic.pointcardserver.currencytradingdlg".getInstanceNotCreate()
        if dlg then
            dlg:refreshDataRole()
        end
    end
end
--个人买卖记录界面
local sroletradingrecordview = require "protodef.fire.pb.fushi.spotcheck.sroletradingrecordview"
function sroletradingrecordview:process()
    local manager = require"logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        manager.m_Records = {}
        for i,v in pairs (self.roletradingrecordlist) do
            table.insert(manager.m_Records, v)
        end
        local dlg = require"logic.pointcardserver.currencytradingdlg".getInstanceNotCreate()
        if dlg then
            dlg:refreshDataRecord()
        end
    end
end
--撤销订单
local scanceltrading = require "protodef.fire.pb.fushi.spotcheck.scanceltrading"
function scanceltrading:process()
    GetCTipsManager():AddMessageTipById(190048)
end

--应用宝充值成功后更新符石信息
local sreqfushiInfo = require "protodef.fire.pb.fushi.sreqfushiinfo"
function sreqfushiInfo:process()
    if not gGetDataManager() then
		return
	end
    gGetDataManager():SetYuanBaoNumber(self.balance);
    gGetDataManager():SetTotalRechargeYuanBaoNumber(self.saveamt);
end

--月卡
local smonthcard = require "protodef.fire.pb.fushi.monthcard.smonthcard"
function smonthcard:process()
    require "logic.qiandaosongli.loginrewardmanager"
    LoginRewardManager.getInstance():SetMonthCardInfo(self.endtime, self.grab)    
end

--点卡服专用，是否可以开启交易所
b_fire_pb_fushi_OpenTrading = 0
local m = require "protodef.fire.pb.fushi.spotcheck.stradingopenstate"
function m:process()
		b_fire_pb_fushi_OpenTrading = self.openstate
end