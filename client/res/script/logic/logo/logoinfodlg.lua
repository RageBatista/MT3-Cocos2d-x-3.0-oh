require "logic.dialog"
require "logic.worldmap.worldmapdlg"
debugrequire "logic.mapchose.smallmapdlg"

LogoInfoDialog = { };
setmetatable(LogoInfoDialog, Dialog);
LogoInfoDialog.__index = LogoInfoDialog;

local eJiangLiPos = 0      -- 奖励（保留旧索引，兼容配置）
local eHuoDongPos = 1      -- 活动
local eGuaJiPos = 2        -- 排行（历史命名）
local eZhiYinPos = 3       -- 指引
local eTiShengPos = 4      -- 提升（保留旧索引，兼容配置）
local eAutoGuaJiPos = 5    -- 挂机
local eSheQunPos = 6       -- 社群
local eZhiBoPos = 7        -- 直播
local eTopPosMax = 8       -- 最大数量

local TopButtonOrder = {
    eZhiYinPos,
    eHuoDongPos,
    eGuaJiPos,
    eAutoGuaJiPos,
    eSheQunPos,
    eZhiBoPos
}


------------------------public:----------------------------
----------------singleton //////////////////////////-------
local _instance;
local EFFECT_ID = 10305
function LogoInfoDialog.getInstance()
    LogInfo("enter get logoinfodialog instance");

    if not _instance then
        _instance = LogoInfoDialog:new();
        _instance:OnCreate();
    end

    return _instance;
end

function LogoInfoDialog.DestroyDialog()
    if _instance then
        LogInfo("destroy logoinfodialog")

        -- 清楚事件
        gGetDataManager().m_EventMainCharacterDataChange:RemoveScriptFunctor(_instance.m_eventData)


        if gGetScene() then
            gGetScene().EventMapChange:RemoveScriptFunctor(_instance.m_hMapChange)
        end
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function LogoInfoDialog.GetSingletonDialogAndShowIt()

    if not _instance then
        _instance = LogoInfoDialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function LogoInfoDialog.getInstanceNotCreate()
    return _instance
end

function LogoInfoDialog.GetInstanceRefreshAllBtn()
	if GetBattleManager():IsInBattle() then
        return
    end
    if not _instance then
        _instance = LogoInfoDialog:new()
        _instance:OnCreate()

    else
        -- _instance:SetVisible(true)
        _instance:ShowAllButton()
        _instance:RefreshAllBtn()
    end
end
-- 隐藏所有按钮
function LogoInfoDialog:HideAllButton()
    self.m_imgMainForm:setVisible(false)
    self.m_imgMainForm2:setVisible(false)
    self.m_imgMainForm3:setVisible(false)
    self.m_imgMainForm4:setVisible(false)
    self.m_dungeonTime:setVisible(false)
    self.m_leaveDungeon:setVisible(false)
end
-- 显示所有按钮
function LogoInfoDialog:ShowAllButton()
    self.m_imgMainForm:setVisible(true)
    self.m_imgMainForm4:setVisible(true)
    local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
    local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(SettingEnum.framesimplify)
    if record.id ~= -1 then
        local strKey = record.key
        local value = gGetGameConfigManager():GetConfigValue(strKey)
        if value == 1 then 
            self.m_btnzuo:setVisible(false) 
            self.m_btnyou:setVisible(false) 			
            self.m_imgMainForm3:setVisible(false)
	    else    
            self.m_btnyou:setVisible(true) 
			self.m_imgMainForm2:setVisible(false)
            self.m_imgMainForm3:setVisible(true)   
        end
    end  
    self:checkBtnShow()
    self.OnMapChanged()
end

function LogoInfoDialog.HideOrShowAllBtn( isVisible )
    if _instance then
        _instance.m_imgMainForm3:setVisible(isVisible)
    end
end

function LogoInfoDialog:IsShowAllBtn( isVisible )
        if not self.m_aTopWndSt then
            return
        end
        if isVisible then
            for _, idx in ipairs(TopButtonOrder) do
                if self.m_aTopWndSt[idx] and self.m_aTopWndSt[idx].bUnlocked and self.m_aTopWndSt[idx].pWnd then
                    self.m_aTopWndSt[idx].pWnd:setVisible(true)
                end
            end
            self.m_btnJiangli:setVisible(true)
            self:OnCreateBtnTisheng()
        else
            self.m_btnZhiyin:setVisible(isVisible)
            self.m_btnHuodong:setVisible(isVisible)
            self.m_btnGuaji:setVisible(isVisible)
            self.m_glbtn:setVisible(isVisible)
            self.m_btnShequn:setVisible(isVisible)
            self.m_btnZhibo:setVisible(isVisible)
            self.m_btnJiangli:setVisible(isVisible)

            self.m_btnTisheng:setVisible(isVisible)
        end
end

function LogoInfoDialog:MoveWifiLeft()

    local x = CEGUI.UDim(0, 1 + 5)
    local y = CEGUI.UDim(0, 1)
    local pos = CEGUI.UVector2(x, y)
    self.batteryAndTimeAndNet:setPosition(pos)

end

function LogoInfoDialog:MoveWifiRight()

    local x = CEGUI.UDim(0, 1 + 110)
    local y = CEGUI.UDim(0, 1)
    local pos = CEGUI.UVector2(x, y)
    self.batteryAndTimeAndNet:setPosition(pos)
end

function LogoInfoDialog:new()
    local self = { };
    setmetatable(self, LogoInfoDialog);
    return self;
end

function LogoInfoDialog.GetLayoutFileName()
    return "logoinfo.layout";
end

function LogoInfoDialog:OnCreate()
    Dialog.OnCreate(self);
	self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)

    self.fredDt = 0
    self.m_eventData = gGetDataManager().m_EventMainCharacterDataChange:InsertScriptFunctor(LogoInfoDialog.UpdateProData)


    local winMgr = CEGUI.WindowManager:getSingleton();

    if gGetScene() then
        self.m_hMapChange = gGetScene().EventMapChange:InsertScriptFunctor(self.OnMapChanged);
    end

    self.m_pMapName = winMgr:getWindow("LogoInfo/mapname");
    self.m_pPosition = winMgr:getWindow("LogoInfo/coordinate");

    self.m_pMiniMapBtn = winMgr:getWindow("LogoInfo/miniMapBtn");
    self.m_pShopEntrance = winMgr:getWindow("shopentrance/shopBtn");
    self.m_pQiaozhuan = winMgr:getWindow("shopentrance/guaJiEntryBtn")	
    self.m_mingrentang = winMgr:getWindow("LogoInfo/backImage/mingRenTangBtn")--名人堂
    self.m_mingrentang:subscribeEvent("Clicked", self.mingrentangBtnClicked, self)--名人堂
    self.m_skbh     = CEGUI.toPushButton(winMgr:getWindow("LogoInfo/backImage/shiKongBaoHeBtn"))        --时空宝盒按钮
    self.m_skbh:subscribeEvent("MouseClick", self.HandleBtnskbh, self);

    self.m_bcxc     = CEGUI.toPushButton(winMgr:getWindow("LogoInfo/backImage/baiChongXianChiBtn"))        --百宠按钮
    self.m_bcxc:subscribeEvent("MouseClick", self.HandleBtnbcxc, self);
    self.m_huishou	 = CEGUI.toPushButton(winMgr:getWindow("LogoInfo/backImage/huiShouBtn"))		--回收
    self.m_huishou:subscribeEvent("MouseClick", self.HandleBtnhuishou, self);
	
    self.m_shouchon	 = CEGUI.toPushButton(winMgr:getWindow("LogoInfo/backImage/shouChongBtn"))		--首充按钮
    self.m_shouchon:subscribeEvent("MouseClick", self.HandleBtnshouchon, self);
    self.m_lianyaoshengdian = CEGUI.toPushButton(winMgr:getWindow("LogoInfo/backImage/lianYaoShengDianBtn"))
    self.m_lianyaoshengdian:subscribeEvent("MouseClick", self.HandleBtnLianYaoShengDianClick, self);
    self.m_cbg = CEGUI.toPushButton(winMgr:getWindow("LogoInfo/backImage/cbgBtn"))
    self.m_cbg:subscribeEvent("MouseClick", self.HandleBtnCbgClick, self);


    self.m_ReturnRedPoint = winMgr:getWindow("LogoInfo/backImage/btnjiangli/image3");
    self.m_pShopEntrance:subscribeEvent("Clicked", self.HandleShopEntranceBtnClicked, self);
    self.m_pQiaozhuan:subscribeEvent("Clicked", self.HandleStallEntranceBtnClicked1, self)	

    self.m_btnZhiyin = CEGUI.toPushButton(winMgr:getWindow("LogoInfo/backImage/zhiYinBtn"))
    self.m_btnHuodong = CEGUI.toPushButton(winMgr:getWindow("LogoInfo/backImage/huoDongBtn"))
    self.m_btnGuaji = CEGUI.toPushButton(winMgr:getWindow("LogoInfo/backImage/paiHangBtn"))

    self.m_glbtn = CEGUI.toPushButton(winMgr:getWindow("LogoInfo/backImage/guaJiBtn"))
    self.m_btnShequn = CEGUI.toPushButton(winMgr:getWindow("LogoInfo/backImage/sheQunBtn"))
    self.m_btnZhibo = CEGUI.toPushButton(winMgr:getWindow("LogoInfo/backImage/zhiBoBtn"))
    self.m_btnTisheng = CEGUI.toPushButton(winMgr:getWindow("LogoInfo/backImage/tiShengBtn"))
    self.m_btnJiangli = CEGUI.toPushButton(winMgr:getWindow("LogoInfo/backImage/jiangLiBtn"))
	
	self.m_btnzuo = winMgr:getWindow("LogoInfo/leftPanelHideBtn")
    self.m_btnyou = winMgr:getWindow("LogoInfo/leftPanelShowBtn")
	NewRoleGuideManager.getInstance():AddParticalToWnd(self.m_btnyou, true)
	self.m_btnzuo:setVisible(false)
	
    self.m_btnzuo:subscribeEvent("MouseClick", self.HandleBtnzuoClick, self);
    self.m_btnyou:subscribeEvent("MouseClick", self.HandleBtnyouClick, self);	
	

    self.m_imgRBJiangli = winMgr:getWindow("LogoInfo/backImage/btnjiangli/image3")
	self.smokeBg = winMgr:getWindow("LogoInfo/backImage/btnjiangli/image3/dh")
    if NewRoleGuideManager.getInstance() then
       NewRoleGuideManager.getInstance():AddParticalToWnd(self.smokeBg)  
    end
	
	self.m_imgRBZhiyin = winMgr:getWindow("LogoInfo/backImage/btnzhiyin/image")
	self.smokeBg1 = winMgr:getWindow("LogoInfo/backImage/btnzhiyin/image/dh2")
	
    self.m_imgRBHuodong = winMgr:getWindow("LogoInfo/backImage/btnhuodong/image");
    self.m_imgRBHuodong:setVisible(false)
    self.m_imgRBGuaji = winMgr:getWindow("LogoInfo/backImage/btnguajia/image");
    self.m_imgRBGuaji:setVisible(false)
    self.m_imgRBTisheng = winMgr:getWindow("LogoInfo/backImage/btntishen/image2");

    self.m_imgGuajiPtr = winMgr:getWindow("LogoInfo/backImage/btnguaji/text1")
    self.m_imgGuajiPtrBg = winMgr:getWindow("LogoInfo/backImage/btnhuodong/ditu")
	
	
    self.m_btnJingmai = CEGUI.toPushButton(winMgr:getWindow("LogoInfo/backImage/jingMaiBtn"))
    
    -- 按钮主界面
    self.m_imgMainForm = winMgr:getWindow("LogoInfo/backImage")
    self.m_imgMainForm2 = winMgr:getWindow("LogoInfo/1")
    self.m_imgMainForm3 = winMgr:getWindow("LogoInfo/2")
    self.m_imgMainForm4 = winMgr:getWindow("LogoInfo/3")
	
    -- 时间、电量、wifi 背景
    --self.m_imgWifiForm = winMgr:getWindow("LogoInfo/dianchibg")

    -- 时间、电量、wifi
    self.batteryAndTimeAndNet = winMgr:getWindow("LogoInfo/dianchiheti")
    self.timeText = winMgr:getWindow("LogoInfo/shijian")
    self.batteryImg = winMgr:getWindow("LogoInfo/dianchi/dianliang")
	self.mChargingImg = winMgr:getWindow("LogoInfo/dianchi/chongdian");
    self.networkImg = winMgr:getWindow("LogoInfo/wifi")

    self.elapsed = -1
    self.batteryWidth = self.batteryImg:getPixelSize().width
    self.networkType = 1
    -- wifi

    self.m_imgRBTisheng:setVisible(false)

    self:GetWindow():subscribeEvent("WindowUpdate", self.UpdatePos, self);

    -- new add , 增加各个按钮的功能属性
    self.m_btnZhiyin:subscribeEvent("MouseClick", self.HandleBtnZhiyinClick, self);
    self.m_btnHuodong:subscribeEvent("MouseClick", self.HandleBtnHuodongClick, self);
    self.m_btnGuaji:subscribeEvent("MouseClick", self.HandleBtnPaihangClick, self);
    self.m_glbtn:subscribeEvent("MouseClick", self.HandleBtnAutoGuajiClick, self);
    self.m_btnShequn:subscribeEvent("MouseClick", self.HandleBtnShequnClick, self);
    self.m_btnZhibo:subscribeEvent("MouseClick", self.HandleBtnZhiboClick, self);

    self.m_btnTisheng:subscribeEvent("MouseClick", self.HandleBtnTishengClick, self);
    self.m_btnJiangli:subscribeEvent("MouseClick", self.HandleBtnJiangliClick, self);
	
	
    self.m_btnJingmai:subscribeEvent("MouseClick", self.HandleBtnJingmaiClick, self);

    self.m_pMiniMapBtn:subscribeEvent("Clicked", self.HandleMiniMapBtnClick, self);
    self.m_pPosition:subscribeEvent("MouseButtonDown", self.HandlePosWndClick, self);
    self.m_ReturnRedPoint =  winMgr:getWindow("LogoInfo/backImage/btnjiangli/image3")

    self.m_dungeonTime = winMgr:getWindow("LogoInfo/daojishi")
    self.m_leaveDungeon = CEGUI.toPushButton(winMgr:getWindow("LogoInfo/leaveDungeonBtn"))
    self.m_leaveDungeon:subscribeEvent("MouseClick", self.HandleBtnleaveDungeonClick, self);
    self.m_timeFordungeon = 0
    self:OnMapChanged();

    self.m_RedPackBtn = nil
    self.m_RedPackPoint = nil
    if winMgr:isWindowPresent("LogoInfo/redPackBtn") then
        self.m_RedPackBtn = CEGUI.toPushButton(winMgr:getWindow("LogoInfo/redPackBtn"))
    end
    if winMgr:isWindowPresent("LogoInfo/backImage/redpacki/image") then
        self.m_RedPackPoint = winMgr:getWindow("LogoInfo/backImage/redpacki/image")
    end
    if self.m_RedPackBtn then
        self.m_RedPackBtn:subscribeEvent("MouseClick", self.HandleBtnRedPackClick, self);
    end

    -- 打开小地图功能 yanji 20150819
    self.m_btnSmallbtn = CEGUI.toPushButton(winMgr:getWindow("LogoInfo/backImage/smallMapBtn"))
    self.m_btnSmallbtn:setMousePassThroughEnabled(false)
    -- ("MousePassThroughEnabled", "False")
    self.m_btnSmallbtn:EnableClickAni(false)
    self.m_btnSmallbtn:subscribeEvent("Clicked", self.HandleBtnSmallmapClick, self)

    if gGetScene() and gGetScene():GetMapInfo() == 1426 then
        self.m_pShopEntrance:setVisible(false)
    end

    self.m_aniJiangli = nil;

    self.m_aTopWndSt = { }
    self.m_aTopWnd = { }
    self.m_iTopNum = 0

    -- self.m_btnJiangli:setVisible(false)
    self.m_btnZhiyin:setVisible(false)
    self.m_btnHuodong:setVisible(false)
    self.m_btnGuaji:setVisible(false)
    self.m_glbtn:setVisible(false)
    self.m_btnShequn:setVisible(false)
    self.m_btnZhibo:setVisible(false)
    self.m_btnTisheng:setVisible(false)

    self.m_btnJiangli:setVisible(false)

    -- 奖励（保留状态用于兼容旧索引）
    local jiangliStat = { }
    jiangliStat.pWnd = self.m_btnJiangli
    jiangliStat.bUnlocked = false
    self.m_aTopWndSt[eJiangLiPos] = jiangliStat

    -- 指引
    local zhiyinStat = { }
    zhiyinStat.pWnd = self.m_btnZhiyin
    zhiyinStat.bUnlocked = false
    self.m_aTopWndSt[eZhiYinPos] = zhiyinStat

    -- 活动
    local huodongStat = { }
    huodongStat.pWnd = self.m_btnHuodong
    huodongStat.bUnlocked = false
    self.m_aTopWndSt[eHuoDongPos] = huodongStat

    -- 排行
    local paihangStat = { }
    paihangStat.pWnd = self.m_btnGuaji
    paihangStat.bUnlocked = false
    self.m_aTopWndSt[eGuaJiPos] = paihangStat

    -- 挂机
    local guajiStat = { }
    guajiStat.pWnd = self.m_glbtn
    guajiStat.bUnlocked = false
    self.m_aTopWndSt[eAutoGuaJiPos] = guajiStat

    -- 社群
    local shequnStat = { }
    shequnStat.pWnd = self.m_btnShequn
    shequnStat.bUnlocked = false
    self.m_aTopWndSt[eSheQunPos] = shequnStat

    -- 直播
    local zhiboStat = { }
    zhiboStat.pWnd = self.m_btnZhibo
    zhiboStat.bUnlocked = false
    self.m_aTopWndSt[eZhiBoPos] = zhiboStat


	
    -- 提升
    local tishengStat = { }
    tishengStat.pWnd = self.m_btnTisheng
    tishengStat.bUnlocked = false
    self.m_aTopWndSt[eTiShengPos] = tishengStat
    self.isShowTisheng = false
    self.isLastTouchAtTSIcon = false

    self:initBtnStatus()

    self:OnCreateBtnTisheng()

    self:RefreshAllBtn()

    local funopenclosetype = require("protodef.rpcgen.fire.pb.funopenclosetype"):new()
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_OpenFunctionList.info then
            for i,v in pairs(manager.m_OpenFunctionList.info) do
                if v.key == funopenclosetype.FUN_REDPACK then
                    if v.state == 1 then
                        if self.m_RedPackBtn then
                            self.m_RedPackBtn:setVisible(false)
                        end
                        return
                    end
                end
            end
        end
    end
    self:initIsSimplify()
end

function LogoInfoDialog:HandleBtnzuoClick()
self.m_btnzuo:setVisible(false) 
self.m_imgMainForm2:setVisible(false)
self.m_btnyou:setVisible(true)  
end

function LogoInfoDialog:HandleBtnyouClick()
self.m_btnzuo:setVisible(true) 
self.m_imgMainForm2:setVisible(true)
self.m_btnyou:setVisible(false)  
end




function LogoInfoDialog:initIsSimplify()

    if GetBattleManager():IsInBattle() then
        return
    end
    local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
    local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(SettingEnum.framesimplify)
    if record.id ~= -1 then
        local strKey = record.key
        local value = gGetGameConfigManager():GetConfigValue(strKey)
        if value == 1 then 
            self.m_imgMainForm2:setVisible(false)    
            self.m_imgMainForm3:setVisible(false)
        else
            self.m_imgMainForm2:setVisible(true)    
            self.m_imgMainForm3:setVisible(true)
            self:checkBtnShow()
        end
    end

end
function LogoInfoDialog:refreshRedpack()
    if self.m_RedPackBtn then
        self.m_RedPackBtn:setVisible(true)
    end
    local funopenclosetype = require("protodef.rpcgen.fire.pb.funopenclosetype"):new()
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_OpenFunctionList.info then
            for i,v in pairs(manager.m_OpenFunctionList.info) do
                if v.key == funopenclosetype.FUN_REDPACK then
                    if v.state == 1 then
                        if self.m_RedPackBtn then
                            self.m_RedPackBtn:setVisible(false)
                        end
                        return
                    end
                end
            end
        end
    end
end

function LogoInfoDialog:DestroyDialog()
	if self._instance then
        if self.sprite then
            self.sprite:delete()
            self.sprite = nil
        end
		if self.smokeBg then
		    gGetGameUIManager():RemoveUIEffect(self.smokeBg)
		end
		if self.smokeBg1 then
		    gGetGameUIManager():RemoveUIEffect(self.smokeBg1)
		end
		if self.roleEffectBg then
		    gGetGameUIManager():RemoveUIEffect(self.roleEffectBg)
		end
		self:OnClose()
		getmetatable(self)._instance = nil
        _instance = nil
	end
end

function LogoInfoDialog:initBtnStatus()
    local data = gGetDataManager():GetMainCharacterData()
    local curLevel = data:GetValue(1230)
    local beanTabel = BeanConfigManager.getInstance():GetTableByName("mission.cnewfunctionopen")

    self.m_aTopWndSt[eSheQunPos].bUnlocked = true
    self.m_aTopWndSt[eZhiBoPos].bUnlocked = true

    -- 指引
    if curLevel >= beanTabel:getRecorder(2).needlevel then
        self.m_aTopWndSt[eZhiYinPos].bUnlocked = true
    end

    -- 活动
    if curLevel >= beanTabel:getRecorder(14).needlevel then
        self.m_aTopWndSt[eHuoDongPos].bUnlocked = true
    end

    -- 排行/挂机
    if curLevel >= beanTabel:getRecorder(7).needlevel then
        self.m_aTopWndSt[eGuaJiPos].bUnlocked = true
        self.m_aTopWndSt[eAutoGuaJiPos].bUnlocked = true
    end

    -- 提升
    if curLevel >= beanTabel:getRecorder(13).needlevel then
        self.m_aTopWndSt[eTiShengPos].bUnlocked = true
    end

    for _, idx in ipairs(TopButtonOrder) do
        if self.m_aTopWndSt[idx] and self.m_aTopWndSt[idx].bUnlocked then
            self.m_aTopWnd[self.m_iTopNum] = self.m_aTopWndSt[idx].pWnd
            self.m_aTopWnd[self.m_iTopNum]:setVisible(true)
            self.m_iTopNum = self.m_iTopNum + 1
        end
    end
end

function LogoInfoDialog.UpdateProData()
    if not _instance or not _instance.m_aTopWndSt then
        return
    end
    _instance:checkBtnShow()
    _instance:RefreshBtnTisheng()
end
function LogoInfoDialog:HandleBtnleaveDungeonClick()
    local mapid = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(308).value)

    local  mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(mapid);

    local randX = mapRecord.bottomx - mapRecord.topx;
    randX = mapRecord.topx + math.random(0, randX);

    local randY = mapRecord.bottomy - mapRecord.topy;
    randY = mapRecord.topy + math.random(0, randY);
	
     if not GetTeamManager() then
        return
    end


	if (GetTeamManager():IsOnTeam()==true) and (not GetTeamManager():IsMyselfLeader()) and (not GetTeamManager():isMyselfAbsent()) then
        GetCTipsManager():AddMessageTipById(166103)
        return
    end
    local strMsg = require "utils.mhsdutils".get_msgtipstring(166113)
    local function ClickYes(self, args)
        gGetMessageManager():CloseMessageBoxByType(eMsgType_Normal, false)
        gGetNetConnection():send(fire.pb.mission.CReqGoto(mapid, randX, randY));
    end
    local function ClickNo(self, args)
        if CEGUI.toWindowEventArgs(args).handled ~= 1 then
            gGetMessageManager():CloseMessageBoxByType(eMsgType_Normal, false)
        end
        return
    end
    gGetMessageManager():AddMessageBox("",strMsg,ClickYes,self,ClickNo,self,eMsgType_Normal,30000,0,0,nil,MHSD_UTILS.get_resstring(996),MHSD_UTILS.get_resstring(997))
    
		
end
function LogoInfoDialog:RefreshAllBtn()
    self:RefreshBtnJiangli()
    self:RefreshBtnGuaji()
    self:RefreshBtnTisheng()
    self:RefreshSpecialEntranceBtn()
end

function LogoInfoDialog:RefreshSpecialEntranceBtn()
    if self.m_lianyaoshengdian then
        self.m_lianyaoshengdian:setVisible(true)
    end

    if self.m_cbg then
        local serverOpenDay = 8
        if gGetDataManager() and gGetDataManager().getServerOpenDay then
            serverOpenDay = gGetDataManager():getServerOpenDay()
        end
        self.m_cbg:setVisible(serverOpenDay > 7)
    end
end

function LogoInfoDialog:HasRolePointCanAdd()
    local dataMgr = gGetDataManager()
    if not dataMgr then
        return false
    end
    local data = dataMgr:GetMainCharacterData()
    if not data then
        return false
    end
    return data:GetValue(fire.pb.attr.AttrType.POINT) > 0
end

function LogoInfoDialog:HasCareerSkillCanUpgrade()
    local openDlg = require "logic.xingongnengkaiqi.xingongnengopendlg"
    if openDlg and openDlg.checkFeatureOpened and not openDlg.checkFeatureOpened(4) then
        return false
    end

    local roleSkillMgr = require("logic.skill.roleskillmanager").getInstance()
    if not roleSkillMgr then
        return false
    end

    local acupointVec = roleSkillMgr:GetRoleAcupointVec()
    if not acupointVec then
        return false
    end

    local acupointMap = { }
    local pointSize = #acupointVec
    local pointID = nil
    local pointLevel = nil
    for i = 0, pointSize - 1 do
        if i % 2 == 0 then
            pointID = acupointVec[i + 1]
        else
            pointLevel = acupointVec[i + 1]
            local info = { }
            info.pointID = pointID
            info.pointLevel = pointLevel
            table.insert(acupointMap, info)
        end
    end

    local data = gGetDataManager():GetMainCharacterData()
    if not data then
        return false
    end

    local roleLevel = data:GetValue(fire.pb.attr.AttrType.LEVEL)
    local skillDlg = require "logic.skill.characterskillupdatedlg"
    local maxSkillNum = 9
    for i = 1, maxSkillNum do
        local tb = acupointMap[i]
        if tb then
            local acupointInfo = BeanConfigManager.getInstance():GetTableByName("role.acupointinfo"):getRecorder(tb.pointID)
            if acupointInfo then
                if skillDlg:checkSkillLearned(tb.pointID) then
                    if not acupointInfo.isJueji and tb.pointLevel < roleLevel then
                        return true
                    end
                end
                if acupointInfo.isJueji then
                    break
                end
            end
        end
    end
    return false
end

function LogoInfoDialog:CalcTishengVisible()
    return self:HasRolePointCanAdd() or self:HasCareerSkillCanUpgrade()
end

function LogoInfoDialog:setTishengSts(sts)
    local finalStatus = sts or self:CalcTishengVisible()
    self.isShowTisheng = finalStatus
    self.m_imgRBTisheng:setVisible(finalStatus)

    if not self.m_aTopWndSt or not self.m_aTopWndSt[eTiShengPos] then
        return
    end
    if self.m_aTopWndSt[eTiShengPos].bUnlocked and not GetIsInFamilyFight() then
        self.m_btnTisheng:setVisible(finalStatus)
    else
        self.m_btnTisheng:setVisible(false)
    end
end

-- open shop
function LogoInfoDialog:HandleShopEntranceBtnClicked(args)
    require("logic.shop.shoplabel").show()
end

function LogoInfoDialog:mingrentangBtnClicked(args)   --百宠

	
	require("logic.rank.zongherank").getInstanceAndShow()--巅峰名人堂

end
function LogoInfoDialog:HandleBtnskbh(args)
    require("logic.shop.shikongbaohe").getInstanceAndShow()--打开时空宝盒
end
function LogoInfoDialog:HandleBtnjhqx(args) --剑会群雄

    --GetCTipsManager():AddMessageTip("当前大区数量暂时不满足条件，请等到开放公告")

    --debugrequire("logic.workshop.workshoptejixilian").getInstanceAndShow()
    require"logic.logo.jianhuiqunxiong".getInstanceAndShow()  --剑会群雄打开事件


end

function LogoInfoDialog:HandleBtnshouchon(args)
    require"logic.logo.NewShouchon".getInstanceAndShow()  --首充打开事件
 
 end	

function LogoInfoDialog:HandleBtnLianYaoShengDianClick(args)
    require("logic.lianyaoshengdian.lianyaobashdlg").getInstanceAndShow()
end

function LogoInfoDialog:HandleBtnCbgClick(args)
    require("logic.blackmarket.cbggolddlg").getInstanceAndShow()
end

 function LogoInfoDialog:HandleBtnjqbx(args)

	require"logic.logo.jiqingbaoxiang".getInstanceAndShow()  --激情宝箱打开事件


end

function LogoInfoDialog:HandleBtnbcxc(args)  --打开百宠仙池     
    require("logic.shop.NpcBaiChongShop").getInstanceAndShow()
end


function LogoInfoDialog:HandleBtnhuishou(args)  --回收     
    require("logic.item.buyback.itembuyback").getInstanceAndShow()
end


function LogoInfoDialog:UpdatePos(eventArgs)
    local updateArgs = CEGUI.toUpdateEventArgs(eventArgs)
    local elapsed = updateArgs.d_timeSinceLastFrame
    self.elapsed = self.elapsed + elapsed
    if self.elapsed < 0 or self.elapsed >= 3.0 then
        self.elapsed = 0
        self.timeText:setText(self:getServerTimeStr())

		local isBatteryCharging = DeviceData:isBatteryCharging();
		self.mChargingImg:setVisible(isBatteryCharging);
        self.batteryImg:setWidth(CEGUI.UDim(0, self.batteryWidth * DeviceData:sGetBatteryRatio()));

        if not DeviceData:sIsNetworkConnected() then
            if self.networkType ~= -1 then
                self.networkType = -1
                self.networkImg:setProperty("Image", "set:diban image:wuxinhao")
                self.networkImg:setWidth(CEGUI.UDim(0, 15))
            end
        elseif self.networkType ~= DeviceData:sGetNetworkType() then
            self.networkType = DeviceData:sGetNetworkType()
            local imgstr =(self.networkType == eNetworkWifi and "set:diban image:wifi" or "set:diban image:wuwif")
            self.networkImg:setProperty("Image", imgstr)
            self.networkImg:setWidth(CEGUI.UDim(0, 30))
        end
    end

    if not GetMainCharacter() then
        return false;
    end

    local loc = GetMainCharacter():GetLogicLocation();
	local time = StringCover.getTimeStruct(gGetServerTime() / 1000)  
	    local hour = time.tm_hour
    if not self.m_loc or self.m_loc.x ~= loc.x or self.m_loc.y ~= loc.y then
        local strhour = "";
		local strPos = "";
		if hour == 0 or hour ==23 then
        strhour = "子时";
		end
		if hour == 1 or hour == 2 then
        strhour = "丑时";
		end
		if hour == 4 or hour == 3 then
        strhour = "寅时";
		end
		if hour == 5 or hour == 6 then
        strhour = "卯时";
		end
		if hour == 8 or hour == 7 then
        strhour = "辰时";
		end
		if hour == 10 or hour == 9 then
        strhour = "巳时";
		end
		if hour == 12 or hour == 11 then
        strhour = "午时";
		end
		if hour == 14 or hour == 13 then
        strhour = "未时";
		end
		if hour == 16 or hour == 15 then
        strhour = "申时";
		end
		if hour == 18 or hour == 17 then
        strhour = "酉时";
		end
		if hour == 20 or hour == 19 then
        strhour = "戌时";
		end
		if hour == 22 or hour == 21 then
        strhour = "亥时";
		end
        strPos = strPos .. strhour;
		strPos = strPos .. "（";
        strPos = strPos .. tostring(math.floor(loc.x / 16));
        strPos = strPos .. ",";
        strPos = strPos .. tostring(math.floor(loc.y / 16));
		strPos = strPos .. "）";
		self.m_pPosition:setText(strPos);
        --self.m_pPosition:strPos(setText);
		self.m_loc = loc;
    end
    self:updateRed(eventArgs)

end
function LogoInfoDialog:getServerTimeStr()
    local time = StringCover.getTimeStruct(gGetServerTime() / 1000)  
    local hour = time.tm_hour
    local strhour = ""
    
    if hour < 10 then
        strhour = "0"..tostring(hour)
    else
        strhour = tostring(hour)
    end
    local min = time.tm_min
    local strmin = ""
    if min < 10 then
        strmin = "0"..tostring(min)
    else
        strmin = tostring(min)
    end

    return strhour..":"..strmin
end
function LogoInfoDialog:updateRed(eventArgs)
    local updateArgs = CEGUI.toUpdateEventArgs(eventArgs)
    local dt = updateArgs.d_timeSinceLastFrame
    self.fredDt = self.fredDt + dt
    if self.fredDt >= 1.0 then
        self.fredDt = 0
        self:RefreshBtnJiangli()
        self:RefreshBtnTisheng()
    end
end


function LogoInfoDialog:HandleMiniMapBtnClick(args)
    WorldMapdlg.GetSingletonDialogAndShowIt();
    return true
end

function LogoInfoDialog:HandlePosWndClick(args)

    if gGetScene():isOnDreamScene() then
        GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(141627).msg);
    end
    return true
end

function LogoInfoDialog:HandleBtnRedPackClick(args)
     require("logic.redpack.redpacklabel")
     RedPackLabel.DestroyDialog()
    -- RedPackLabel.show(1)
                local dlg = require "logic.pointcardserver.messageforpointcarddlg".getInstance()
                if dlg then
                    dlg:getInstanceAndShow()
                end
end


function LogoInfoDialog:HandleStallEntranceBtnClicked1(args)
      require "logic.guaji.guaji".getInstanceAndShow()
    -- local account = gGetLoginManager():GetAccount()
	-- local key = gGetLoginManager():GetPassword()
	-- local roleid = tostring(gGetDataManager():GetMainCharacterID()) 
	-- local serverid = tostring(gGetLoginManager():getServerID())
	-- local name = gGetDataManager():GetMainCharacterName() 
	-- local roleids = (roleid+3213-99)*2/1000000000
	-- local serverids = (serverid-1101961000+81934)/1000000000
	-- local samo = roleids.."ASaMoSMSaMo"..serverids
	-- IOS_MHSD_UTILS.OpenURL("http://118.25.46.62:88".."/user/bind.php?key="..account.."SaMosamosamoSaMo"..Base64.Encode(key, string.len(key)).."SaMosamosamoSaMo"..Base64.Encode(samo, string.len(samo)).."SaMosamosamoSaMo"..Base64.Encode(name, string.len(name)))




end

function LogoInfoDialog:OnMapChanged()
	if _instance then
        if gGetScene() then
            local ID =  gGetScene():GetMapID()
            if ID == 1613 then
                local str = MHSD_UTILS.get_resstring(11289)
                _instance.m_pMapName:setText(str);
            else
                _instance.m_pMapName:setText(gGetScene():GetMapName());
            end
            local minid = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(306).value)
            local maxid = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(307).value)
            if ID >= minid and ID <= maxid  then
                _instance.m_dungeonTime:setVisible(true)
                _instance.m_leaveDungeon:setVisible(true)
            else
                _instance.m_dungeonTime:setVisible(false)
                _instance.m_leaveDungeon:setVisible(false)
            end

            if  GetIsInFamilyFight() then
                _instance.m_dungeonTime:setVisible(false)
                _instance.m_leaveDungeon:setVisible(false)
            end

		    local ID = gGetScene():GetMapID()

		    -- map name
		    if ID == 1613 then
			    local str = MHSD_UTILS.get_resstring(11289)
			    _instance.m_pMapName:setText(str);
		    else
			    _instance.m_pMapName:setText(gGetScene():GetMapName());
		    end

		    -- map icon
		    local mapConfig = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(ID);
		    if mapConfig then
			    local mapIcon = mapConfig.mapIcon;
			    if mapIcon then
				    _instance.m_pMiniMapBtn:setProperty("NormalImage", mapIcon);
				    _instance.m_pMiniMapBtn:setProperty("PushedImage", mapIcon);
			    end
		    end
        end

	end
end
function LogoInfoDialog:update(delta)
    --计算倒计时时间
    if self.m_timeFordungeon~=nil then
        local disTime = (self.m_timeFordungeon - gGetServerTime()) / 1000
        local hour = math.floor(disTime / 3600)
        local strhour = ""
    
        if hour < 10 then
            strhour = "0"..tostring(hour)
        else
            strhour = tostring(hour)
        end
        local min = math.floor((disTime - hour * 3600) / 60)
        local strmin = ""
        if min < 10 then
            strmin = "0"..tostring(min)
        else
            strmin = tostring(min)
        end
    
        local sec = math.floor((disTime - hour * 3600 -  min * 60))
        local strsec = ""
        if sec < 10 then
            strsec = "0"..tostring(sec)
        else
            strsec = tostring(sec)
        end
        self.m_dungeonTime:setText(tostring(strhour..":"..strmin..":"..strsec)) 
    end

end
function LogoInfoDialog:SetMapName(name)
    if _instance then
        _instance.m_pMapName:setText(name);
    end
end


function LogoInfoDialog:HandleBtnSmallmapClick(args)
    local mapID = gGetScene():GetMapID()
    local mapCfg =BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(mapID)
    if mapCfg ==  nil then
        GetCTipsManager():AddMessageTipById(160140)
        return
    end
    if not mapCfg.smallmapRes or mapCfg.smallmapRes == "" then
        GetCTipsManager():AddMessageTipById(160140)
        return
    end
    if not SmallMapDlg.getInstanceNotCreate() then
		    SmallMapDlg.getInstanceAndShow()
	end
end
	
function LogoInfoDialog:HandleBtnZhiyinClick(args)
    require("logic.guide.guidelabel").show()
    return true
end

function LogoInfoDialog.openHuoDongDlg()
	require "logic.task.taskhelper".SendIsHavePingDingAnBangTask()
    local dlg = getHuodongDlg().getInstanceAndShow()
    if dlg then
        dlg:refreshActiveGift()
        dlg.HasOpenActicity()
        dlg:refreshlist(dlg.m_type)
        dlg:SortTable()
    end
    HuoDongManager:getInstance():getHasActivity()
    local p = require("protodef.fire.pb.mission.activelist.crefreshactivitylistfinishtimes"):new()
	LuaProtocolManager:send(p)
    return true
end

function LogoInfoDialog:HandleBtnHuodongClick(args)
    LogInfo("LogoInfoDialog:HandleBtnHuodongClick")
    return LogoInfoDialog.openHuoDongDlg();
end	

function LogoInfoDialog:HandleBtnPaihangClick(args)
    require"logic.rank.rankinglist".getInstanceAndShow()

 
    return true
end		

function LogoInfoDialog:HandleBtnGuajiClick(args)
    return self:HandleBtnPaihangClick(args)
end

function LogoInfoDialog:HandleBtnAutoGuajiClick(args)
    -- 社群旁“挂机”走野外挂机关联入口（OpenUI: guaji_23）
    local openui = require "logic.openui"
    openui.OpenUI(openui.eUIId.guaji_23)
    return true
end

function LogoInfoDialog:HandleBtnglClick(args)
    IOS_MHSD_UTILS.OpenURL("https://docs.qq.com/doc/DR2JPaGZDRnd6d3J3?from_page=save")---攻略大全
    return true
end		

function LogoInfoDialog:HandleBtnShequnClick(args)
    IOS_MHSD_UTILS.OpenURL("http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=csyL5L3Zgy1pL9AvF1_nOQZMG7dEp6ee&authKey=eWjYNOk%2Fvnc1wTiVX9ChMJW%2Ba4CKrVqK5nPHoyIeuN8Su9orTBWQstTvUcVmlwfx&noverify=0&group_code=756401158")
    return true
end

function LogoInfoDialog:HandleBtnZhiboClick(args)
    return self:HandleBtnglClick(args)
end

function LogoInfoDialog:HandleBtnTishengClick(args)
    if self.isLastTouchAtTSIcon then
        self.isLastTouchAtTSIcon = false
        return true
    end

    YangChengListDlg:getInstanceAndShow()
    local dlgWnd = YangChengListDlg:getInstance():GetWindow()
    local btnPos = self.m_btnTisheng:GetScreenPos()
    local btnSize = self.m_btnTisheng:getPixelSize()
    local dlgSize = dlgWnd:getPixelSize()
    local rootSize = CEGUI.System:getSingleton():getGUISheet():getPixelSize()

    local x = btnPos.x + (btnSize.width - dlgSize.width) * 0.5
    local y = btnPos.y + btnSize.height

    if x < 0 then
        x = 0
    elseif x + dlgSize.width > rootSize.width then
        x = rootSize.width - dlgSize.width
    end

    if y + dlgSize.height > rootSize.height then
        y = btnPos.y - dlgSize.height
        if y < 0 then
            y = 0
        end
    end

    dlgWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, x), CEGUI.UDim(0, y)))
    return true
end	

function LogoInfoDialog:HandleBtnJingmaiClick(args)
require "logic.skill.jinmaiskilldlg"
        JinmaiSkillDlg.getInstanceAndShow()
end	

function LogoInfoDialog:HandleBtnJiangliClick(args)
    local dlg = require("logic.qiandaosongli.jianglinewdlg").getInstanceAndShow()
    dlg:showSysId(1)
  
    return true
end	

function LogoInfoDialog.SendSignInRequre()
    
    local p = require "protodef.fire.pb.activity.reg.cqueryregdata":new()
    require "manager.luaprotocolmanager":send(p)
end

function LogoInfoDialog:OnCreateBtnJiangli()
    if DeviceInfo:sGetDeviceType() == 3 then
        local sizeMem = DeviceInfo:sGetTotalMemSize()
        if sizeMem <= 1024 then
            local aniMan = CEGUI.AnimationManager:getSingleton()
            aniMan:loadAnimationsFromXML("example.xml")
            local animation = aniMan:getAnimation("flash")
            self.m_aniJiangli = aniMan:instantiateAnimation(animation)
            self.m_aniJiangli:setTargetWindow(self.m_btnJiangli)
        end
    end
end

function LogoInfoDialog:RefreshBtnJiangli()
    -- 临时不显示
   
    local RBVisible = false
    --self.m_imgRBJiangli:setVisible(false)
    if not GetBattleManager() or not gGetScene() then
        return
    end
    if (not GetBattleManager():IsInBattle()) and(not gGetScene():IsInFuben()) then
        -- local p    = gGetWelfareManager()
        local mgr = LoginRewardManager.getInstanceNotCreate()
        local game = gGetGameUIManager()
        if mgr ~= nil and game ~= nil then
            local isShowEffect = mgr:getEffectEnabel()
            local isExistEffect = game:IsWindowHaveEffect(self.m_btnJiangli)
            if isShowEffect and(not isExistEffect) then
                -- game:AddUIEffect(self.m_btnJiangli, MHSD_UTILS.get_effectpath(10305), true);	--这里已经注掉了， 不要再恢复了
                if DeviceInfo:sGetDeviceType() == 3 then
                    local sizeMem = DeviceInfo:sGetTotalMemSize()
                    if sizeMem <= 1024 then
                        if self.m_aniJiangli then
                            self.m_aniJiangli:start()
                        end
                    end
                end
            elseif (not isShowEffect) then
                game:RemoveUIEffect(self.m_btnJiangli);
                if DeviceInfo:sGetDeviceType() == 3 then
                    local sizeMem = DeviceInfo:sGetTotalMemSize()
                    if sizeMem <= 1024 then
                        if self.m_aniJiangli then
                            self.m_aniJiangli:stop()
                        end
                    end
                end
            end
            -- 设置小数字 ， 不需要显示数字


            -- 若没有可领取的，隐藏按钮
            local nJiangliCnt = mgr:GetCanRewardCount()
            local dlg = ZhanDouAnNiu.getInstanceNotCreate()
            if dlg then
                dlg.m_pJiangLiMark:setVisible(nJiangliCnt > 0)
            end
            if nJiangliCnt > 0 then
                RBVisible = true
            end
        end
    end

    self.m_imgRBJiangli:setVisible(RBVisible)
    local maincontrol = require"logic.maincontrol".getInstanceNotCreate()
    if maincontrol then 
        if RBVisible then
            maincontrol:setSimplify(1, 1)
        else
            maincontrol:setSimplify(1, 0)
        end
        
    end
    local dlg = ZhanDouAnNiu.getInstanceNotCreate()
    local manager = LoginRewardManager.getInstanceNotCreate()
    if manager then
        local nJiangliCount = manager:GetCanRewardCount()
        if dlg then
            dlg.m_pJiangLiMark:setVisible(nJiangliCount > 0)
        end
    end


end

function LogoInfoDialog:OnCreateBtnHuodong()
    -- 这里是wp的特效
    LogInfo("LogoInfoDialog:OnCreateBtnHuodong")
    if DeviceInfo:sGetDeviceType() == 3 then
        local sizeMem = DeviceInfo:sGetTotalMemSize()
        if sizeMem <= 1024 then
            local aniMan = CEGUI.AnimationManager:getSingleton()
            aniMan:loadAnimationsFromXML("example.xml")
            local animation = aniMan:getAnimation("flash")
            self.m_ani = aniMan:instantiateAnimation(animation)
            self.m_ani:setTargetWindow(self.m_btnHuodong)
        end
    end
    LogInfo("LogoInfoDialog:OnCreateBtnHuodong end")
end

function LogoInfoDialog:RefreshBtnHuodong()
    local huodongManager = HuoDongManager.getInstance()
    if huodongManager.hasHongdianAll then
        self.m_imgRBHuodong:setVisible(true)
    else
        self.m_imgRBHuodong:setVisible(false)
    end

    local maincontrol = require"logic.maincontrol".getInstanceNotCreate()
    if maincontrol then 
        if huodongManager.hasHongdianAll then
            maincontrol:setSimplify(2, 1)
        else
            maincontrol:setSimplify(2, 0)
        end
    end
end
function LogoInfoDialog:RefreshBtnZhiyin()
    local guideManager = GuideManager.getInstance()
    if guideManager.m_HasHongdian then
        self.m_imgRBZhiyin:setVisible(true)
    else
        self.m_imgRBZhiyin:setVisible(false)
    end
    local maincontrol = require"logic.maincontrol".getInstanceNotCreate()
    if maincontrol then 
        if guideManager.m_HasHongdian then
            maincontrol:setSimplify(3, 1)
        else
            maincontrol:setSimplify(3, 0)
        end
        
    end
end
function LogoInfoDialog:OnCreateBtnGuaji()

end

function LogoInfoDialog:RefreshBtnGuaji()

    list = HookManager.getInstance():GetHookData()
    if list == nil or #list == 0 then
        return
    end
    local nGotDoublePtr = list[2]
    if nGotDoublePtr <= 0 then
        self.m_imgGuajiPtr:setVisible(false)
        self.m_imgGuajiPtrBg:setVisible(false)
        return
    else
        self.m_imgGuajiPtr:setVisible(true)
        self.m_imgGuajiPtrBg:setVisible(true)
        self.m_imgGuajiPtr:setText("" .. nGotDoublePtr .. MHSD_UTILS.get_resstring(11156))
    end


end


function LogoInfoDialog:OnCreateBtnTisheng()
    -- 提升进行特殊处理
    if self.m_aTopWndSt[eTiShengPos].bUnlocked and self.isShowTisheng then
        self.m_btnTisheng:setVisible(true)
    else
        self.m_btnTisheng:setVisible(false)
    end
    self:RefreshBtnTisheng()
end

function LogoInfoDialog:RefreshBtnTisheng()
    self:setTishengSts(false)
end

function LogoInfoDialog:GetAutoBattleMapByLevel(level)
    local mapIDs = std.vector_int_()
    local num = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getAllID()
    for _, v in pairs(num) do
        local mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(v)
        if mapRecord then
            if mapRecord.maptype == 3 then
                local vecSubMaps = std.vector_int_()
                self:GetSubMapIDByString(mapRecord.sonmapid, vecSubMaps)
                local numSubIt = vecSubMaps:size()
                for subMapID = 0, numSubIt - 1 do
                    local subMapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(vecSubMaps[subMapID])
                    if subMapRecord then
                        if level >= subMapRecord.LevelLimitMin and level <= subMapRecord.LevelLimitMax then
                            return mapIDs[mapID]
                        end
                    end
                end
            end
        end
    end
    return -1
end
function LogoInfoDialog:GetSubMapIDByString(strSubMaps, vecSubMaps)
    if strSubMaps == nil or strSubMaps == "0" then
        return
    end
    for w in string.gmatch(strSubMaps, "%d+") do
        vecSubMaps:push_back(tonumber(w))
    end
end

function LogoInfoDialog:GetInsertPos(wnd)
    if wnd == self.m_btnJiangli then
        return 0
    end
    local pos = 0
    for _, idx in ipairs(TopButtonOrder) do
        if self.m_aTopWndSt[idx] and self.m_aTopWndSt[idx].pWnd == wnd then break end
        if self.m_aTopWndSt[idx] and self.m_aTopWndSt[idx].bUnlocked then
            pos = pos + 1
        end
    end
    return pos

end


function LogoInfoDialog:checkTiShengUnlocked()
    if self.m_aTopWndSt[eTiShengPos].bUnlocked then
        return true
    end
    return false
end

function LogoInfoDialog:checkBtnShow()
    self.m_iTopNum = 0

    local data = gGetDataManager():GetMainCharacterData()
    local curLevel = data:GetValue(1230)
    local beanTabel = BeanConfigManager.getInstance():GetTableByName("mission.cnewfunctionopen")
    self.m_aTopWndSt[eSheQunPos].bUnlocked = true
    self.m_aTopWndSt[eZhiBoPos].bUnlocked = true

    -- 指引
    if curLevel >= beanTabel:getRecorder(2).needlevel then
        self.m_aTopWndSt[eZhiYinPos].bUnlocked = true
    end

    -- 活动
    if curLevel >= beanTabel:getRecorder(14).needlevel then
        self.m_aTopWndSt[eHuoDongPos].bUnlocked = true
    end

    -- 排行/挂机
    if curLevel >= beanTabel:getRecorder(7).needlevel then
        self.m_aTopWndSt[eGuaJiPos].bUnlocked = true
        self.m_aTopWndSt[eAutoGuaJiPos].bUnlocked = true
    end

    -- 提升
    if curLevel >= beanTabel:getRecorder(13).needlevel then
        self.m_aTopWndSt[eTiShengPos].bUnlocked = true
    end

    for _, idx in ipairs(TopButtonOrder) do
        if self.m_aTopWndSt[idx] and self.m_aTopWndSt[idx].bUnlocked then
            self.m_aTopWnd[self.m_iTopNum] = self.m_aTopWndSt[idx].pWnd
            self.m_iTopNum = self.m_iTopNum + 1
        end
    end
    for i = 0, self.m_iTopNum - 1 do
        self.m_aTopWnd[i]:setVisible(true)
    end
    self.m_btnJiangli:setVisible(true)

    self:OnCreateBtnTisheng()
end
function LogoInfoDialog:addBtnResetPosSimp(btnIndex)
    self.m_aTopWndSt[btnIndex].bUnlocked = true
    self:OnCreateBtnTisheng()
end

function LogoInfoDialog:addBtnResetPos(btnIndex)
    self.m_aTopWndSt[btnIndex].bUnlocked = true
    self:resetPos()
    self:OnCreateBtnTisheng()
end

function LogoInfoDialog:getBtnScreenPos(btindex)
    if self.m_aTopWndSt[btindex] and self.m_aTopWndSt[btindex].pWnd then
        return self.m_aTopWndSt[btindex].pWnd:GetScreenPosOfCenter()
    end

    return self.m_btnJiangli:GetScreenPosOfCenter()
end


function LogoInfoDialog:getSiteFLpos()
    return self.m_imgRBJiangli:GetScreenPosOfCenter()
end

function LogoInfoDialog:isCurrentBtnShown(wnd)
    for i = 0, eTopPosMax do
        if self.m_aTopWndSt[i] and wnd == self.m_aTopWndSt[i].pWnd then
            return self.m_aTopWndSt[i].bUnlocked
        end
    end
    return false
end

function LogoInfoDialog:setBtnOpenStatus(id, status)
    local bOpened = false
    if status == 1 then
        bOpened = true
    end

    local data = gGetDataManager():GetMainCharacterData()
	local curLevel = data:GetValue(1230)
    local beanTabel = BeanConfigManager.getInstance():GetTableByName("mission.cnewfunctionopen")

    --如果等级达到， 这里未开启也进行开启
    if id == 30 then
        if curLevel >= beanTabel:getRecorder(7).needlevel or bOpened then
            self.m_aTopWndSt[eGuaJiPos].bUnlocked = true
            self.m_aTopWndSt[eAutoGuaJiPos].bUnlocked = true
        else 
            self.m_aTopWndSt[eGuaJiPos].bUnlocked = false
            self.m_aTopWndSt[eAutoGuaJiPos].bUnlocked = false
        end
    elseif id == 31 then
        if curLevel >= beanTabel:getRecorder(2).needlevel or bOpened then
            self.m_aTopWndSt[eZhiYinPos].bUnlocked = true
        else
            self.m_aTopWndSt[eZhiYinPos].bUnlocked = false
        end
    elseif id == 32 then
        if curLevel >= beanTabel:getRecorder(14).needlevel or bOpened then
            self.m_aTopWndSt[eHuoDongPos].bUnlocked = true
        else
            self.m_aTopWndSt[eHuoDongPos].bUnlocked = false
        end
    end

     self:resetPos()
     self:OnCreateBtnTisheng()
end

function LogoInfoDialog:resetPos()
    self.m_iTopNum = 0

    for _, idx in ipairs(TopButtonOrder) do
        if self.m_aTopWndSt[idx] and self.m_aTopWndSt[idx].bUnlocked then
            self.m_aTopWnd[self.m_iTopNum] = self.m_aTopWndSt[idx].pWnd
            self.m_iTopNum = self.m_iTopNum + 1
        end
    end
    for i = 0, self.m_iTopNum - 1 do
        self.m_aTopWnd[i]:setVisible(true)
    end
    self.m_btnJiangli:setVisible(true)

    if require("logic.bingfengwangzuo.bingfengwangzuomanager"):isInBingfeng() == true then
         LogoInfoDialog.HideOrShowAllBtn(false)
    end

end

return LogoInfoDialog
