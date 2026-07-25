require "logic.friend.frienddialog"
require "logic.pet.petlabel"
require "logic.jingying.jingyingfubendlg"
require "logic.fubenguidedialog"
require "utils.log"

require "logic.logo.logoinfodlg"
require "logic.battleautofightdlg"
require "logic.shop.shopmanager"
require "logic.shijiebobaodlg"
require "logic.huodong.huodongmanager"
require "logic.team.teammembermenu"
require "logic.answerquestion.answerquestionhelp"
require "logic.leitai.leitaidialog"
require "logic.exp.mainroleexpdlg"

debugrequire "logic.yincang"


ShowHide = {}
function ShowHide.GetChatOutWndClosedSetChan()
    return 3--当前频道.
end
--锁屏通知
function ShowHide.ClientLockScreen()
    local send = require "protodef.fire.pb.hook.cclientlockscreen":new()
    send.lock = 1
    require "manager.luaprotocolmanager":send(send)
end
--恢复不锁屏状态通知
function ShowHide.UnClientLockScreen()
    local send = require "protodef.fire.pb.hook.cclientlockscreen":new()
    send.lock = 0
    require "manager.luaprotocolmanager":send(send)
end
--进入战斗 
function ShowHide.EnterBattle()
	LogInfo("showhide enterbattle")
    require  "logic.leitai.leitaidatamanager".m_IsTick = false
    require  "logic.leitai.leitaidatamanager".m_Time = 0
	
    require "logic.worldmap.worldmapdlg".DestroyDialog()

    local simplipy = require "logic.framesimplipy".getInstanceNotCreate()
    if simplipy then
        simplipy:CloseDlg() 
    end

	if YinCang.getInstanceNotCreate() then
		YinCang.CShowAll()
	end
	
	--LogCustom(99,"EnterBattle .. 1")
	if ZhanDouAnNiu.getInstance() then
		ZhanDouAnNiu.getInstance():Show()
	end
	--LogCustom(99,"EnterBattle .. 2")
	if DeviceInfo:sGetDeviceType() == 3 then
		local sizeMem = DeviceInfo:sGetTotalMemSize()
		if sizeMem <= 1024 then
			Nuclear.GetEngine():EnableParticle(true)
		end
	end
	--LogCustom(99,"EnterBattle .. 3")
	--LogCustom(99,"EnterBattle .. 4")
	--LogCustom(99,"EnterBattle .. 5")
	if ContactRoleDialog.getInstanceNotCreate() then
		ContactRoleDialog.DestroyDialog()
	end

    local smalldlg = require"logic.mapchose.smallmapdlg".getInstanceNotCreate()
    if smalldlg then
        smalldlg.DestroyDialog()
    end


	 --LogCustom(99,"EnterBattle .. 9")
    if LeiTaiDialog.getInstanceNotCreate() then
       LeiTaiDialog.DestroyDialog()
    end
	--LogCustom(99,"EnterBattle .. 10")
	if FubenGuideDialog.getInstanceNotCreate() then
		FubenGuideDialog.getInstanceNotCreate():SetVisible(false)
	end
	--LogCustom(99,"EnterBattle .. 11")
	if MainControl.getInstanceNotCreate() then
		MainControl.getInstanceNotCreate():SetVisible(false)
	end
	--LogCustom(99,"EnterBattle .. 12")
	--LogCustom(99,"EnterBattle .. 13")
	--LogCustom(99,"EnterBattle .. 14")
	--LogCustom(99,"EnterBattle .. 15")
	--LogCustom(99,"EnterBattle .. 16")
	if Renwulistdialog.getSingleton() then
		Renwulistdialog.getSingleton():SetVisible(false)
	end
	--LogCustom(99,"EnterBattle .. 17")
    --about logo info dialog
    if LogoInfoDialog.getInstanceNotCreate() then
        --LogoInfoDialog.getInstanceNotCreate():SetVisible(false)
        LogoInfoDialog.getInstanceNotCreate():MoveWifiLeft()
        LogoInfoDialog.getInstanceNotCreate():HideAllButton()
    end
	--LogCustom(99,"EnterBattle .. 18")
	if SettingMainFrame.getInstanceNotCreate() then
		SettingMainFrame.DestroyDialog()
	end
	--LogCustom(99,"EnterBattle .. 19")
	local jewelrylabel = require "logic.label".getLabelById("jewelry")
	if jewelrylabel then
		jewelrylabel:OnClose()
	end
--	if BattleAutoDlg.getInstanceNotCreate() then
--		BattleAutoDlg.getInstanceNotCreate():StartBattle()
--	end
	--LogCustom(99,"EnterBattle .. 20")
	--LogCustom(99,"EnterBattle .. 21")
	--LogCustom(99,"EnterBattle .. 22")
	--LogCustom(99,"EnterBattle .. 23")
	--LogCustom(99,"EnterBattle .. 24")
	--自动关闭全到分枝后安全锁的两个模态窗改成自动关闭
	gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
    --LogCustom(99,"EnterBattle .. 25")
    if Jingyingfubendlg.getInstanceNotCreate() then
        Jingyingfubendlg.getInstanceNotCreate():SetVisible(false)
    end
	--LogCustom(99,"EnterBattle .. 26")
	ShowHide.TeamPvpDestroyDlg()
	--LogCustom(99,"EnterBattle .. 27")
	--LogCustom(99,"EnterBattle .. 28")
    
	--LogCustom(99,"EnterBattle .. 29")
--    if SkillLable.getInstanceNotCreate() ~= nil then
--    	SkillLable.DestroyDialog()
--    end
	--LogCustom(99,"EnterBattle .. 30")
    local ycDlg = require "logic.yangchengnotify.yangchenglistdlg"
    if ycDlg.getInstanceNotCreate() then
        ycDlg.DestroyDialog()
    end
	--LogCustom(99,"EnterBattle .. 31")
    local teamMemberMenu =  TeamMemberMenu.getInstanceNotCreate()
	if teamMemberMenu and teamMemberMenu:IsVisible() then
        teamMemberMenu:SetVisible(false)
    end
	--LogCustom(99,"EnterBattle .. 32")
	ShowHide.SetButtonsVisible(false)
    --LogCustom(99,"EnterBattle .. 33")
	LuaBattleUIManager.CreateBattleUI()
	--LogCustom(99,"EnterBattle .. end")
    require("logic.bingfengwangzuo.bingfengwangzuoTaskTips").DestroyDialog()
    require("logic.task.tasknpcchatdialog").DestroyDialog()

    local taskuseitemdialog = require  "logic.task.taskuseitemdialog".getInstanceNotCreate()
    if taskuseitemdialog then
        taskuseitemdialog:OnBattleBegin()
    end
    local familybossBloodBardlg = familybossBloodBar.getInstanceNotCreate()
    if familybossBloodBardlg then
        familybossBloodBardlg:setState(2)
    end

    local bingfengTaskTips = bingfengTaskTips.getInstanceNotCreate()
    if bingfengTaskTips then
        GetMainCharacter():clearGotoNpc()
        GetMainCharacter():clearGoTo()
    end

	BattleZhenFa.getInstance()
    ShowHide.closeAllJingDialog()
    
    require("logic.npc.npcscenespeakdialog").DestroyDialog()
    require("logic.npc.npcdialog").DestroyDialog()

    --New Guide
    if GetTeamManager() then
        GetTeamManager():prepareGuideTeam()
    end

    if GetIsInFamilyFight() then
        local familyfight = require ("logic.family.familyfightxianshi").getInstanceNotCreate()
        if familyfight then
            familyfight:SetVisible(false)
        end
    end

    if PiPeiDlg.getInstanceNotCreate() then
        PiPeiDlg.DestroyDialog()
    end
end


function ShowHide.closeAllJingDialog()
    closeJingjiDialog()
	closeEnterJingjiDialog()
    closeJingjiDialog3()
    closeEnterJingjiDialog3()
    closeJingjiDialog5()
    closeEnterJingjiDialog5()
end

--退出战斗
function ShowHide.EndBattle()
	LogInfo("showhide endbattle")

    MainPetDataManager_ClearBattlePetOfEndBattleScene()
	
	bossdaxuetiao.CSetVisible(false)
	bossdaxuetiao.DestroyDialog()

	BattleZhenFa.DestroyDialog()
    ZhenFaTip.DestroyDialog()
	
	if ZhanDouAnNiu.getInstance() then
		--LogCustom(99,"ZhanDouAnNiu.getInstance():Hide()")
		ZhanDouAnNiu.DestroyDialog()
	end
	
	--LogCustom(99,"DeviceInfo:GetDeviceType()")
	if DeviceInfo:sGetDeviceType() == 3 then
		--LogCustom(99,"DeviceInfo:GetTotalMemSize()")
		local sizeMem = DeviceInfo:sGetTotalMemSize()
		if sizeMem <= 1024 then
			--LogCustom(99,"Nuclear.GetEngine():EnableParticle(false)")
			Nuclear.GetEngine():EnableParticle(false)
		end
	end

	
--	WelfareBtn.Refresh() --new add
	--LogCustom(99,"LogoInfoDialog.GetInstanceRefreshAllBtn()")
	LogoInfoDialog.GetInstanceRefreshAllBtn()



	if Renwulistdialog.getSingleton() and require "logic.bingfengwangzuo.bingfengwangzuomanager":isInBingfeng() == false then
		--LogCustom(99,"Renwulistdialog.getSingleton():SetVisible(true)")
        local nIsJingji1v1 = 0
        if gGetScene() then
             local nMapId = gGetScene():GetMapID()
              local nJingjiType = getJingjiMapType(nMapId)
             if nJingjiType==1 then
                nIsJingji1v1 = 1
             end
        end
        if nIsJingji1v1==0 then
		    Renwulistdialog.getSingleton():SetVisible(true)
        end
	end
	if FubenGuideDialog.getInstanceNotCreate() then
		--LogCustom(99,"FubenGuideDialog.getInstanceNotCreate():SetVisible(true)")
		FubenGuideDialog.getInstanceNotCreate():SetVisible(true)
	end

	if MainControl.getInstanceNotCreate() then
		--LogCustom(99,"MainControl.getInstanceNotCreate():SetVisible(true)")
		MainControl.getInstanceNotCreate():SetVisible(true)
		--LogCustom(99,"MainControl.RefreshFriendBtnFlashState()")
        MainControl.RefreshFriendBtnFlashState()
	end

    if LogoInfoDialog.getInstanceNotCreate() then
		--LogCustom(99,"LogoInfoDialog.getInstanceNotCreate():MoveWifiRight()")
        LogoInfoDialog.getInstanceNotCreate():MoveWifiRight()
		--LogCustom(99,"LogoInfoDialog.getInstanceNotCreate():ShowAllButton()")
        LogoInfoDialog.getInstanceNotCreate():ShowAllButton()
		--LogCustom(99,"LogoInfoDialog.getInstanceNotCreate():RefreshAllBtn()")
        LogoInfoDialog.getInstanceNotCreate():RefreshAllBtn()
    end
--	if BattleAutoDlg.getInstanceNotCreate() then
--		BattleAutoDlg.getInstanceNotCreate():EndBattle()
--   end
    
    if Jingyingfubendlg.getInstanceNotCreate() then
		--LogCustom(99,"Jingyingfubendlg.getInstanceNotCreate():SetVisible(true)")
        Jingyingfubendlg.getInstanceNotCreate():SetVisible(true)
    end

	--LogCustom(99,"GetScene():IsInFuben()")
    -- if CPvpservice:GetSingleton() ~= nil then
    -- 	CPvpservice:GetSingleton():SetVisible(true)
    -- end

	--LogCustom(99,"LuaBattleUIManager.DestoryBattleUI()")
	LuaBattleUIManager.DestoryBattleUI()
	
	--LogCustom(99,"BattlePetSummonDlg.EndBattle()")
	BattlePetSummonDlg.EndBattle()

	--LogCustom(99,"GetScene():IsInFuben()")
	if not gGetScene():IsInFuben() then
		--LogCustom(99,"ShowHide.SetButtonsVisible(true)")
		ShowHide.SetButtonsVisible(true)
	end

    if require("logic.tips.commontipdlg").getInstanceNotCreate() then
        --LogCustom(99,"logic.tips.commontipdlg.getInstanceNotCreate().DestroyDialog()")
        require("logic.tips.commontipdlg").getInstanceNotCreate().DestroyDialog()
    end

	require("logic.team.teamrollmelondialog").DestroyDialog()

    if require("logic.bingfengwangzuo.bingfengwangzuomanager").isInBingfeng() then
        local dlg = require("logic.bingfengwangzuo.bingfengwangzuoTaskTips"):getInstanceAndShow()
        local info = require("logic.bingfengwangzuo.bingfengwangzuomanager"):getBingfengInfo()
        dlg:updateInfo(info.instzoneid, info.stage, 0)
    end

  	--LogCustom(99,"ShowHide.checkShowJingjiBtn Start")
  
    ShowHide.checkShowJingjiBtn()

    local p = require("protodef.fire.pb.creqroleinfo"):new()
    p.reqkey = 2
	LuaProtocolManager:send(p)

  	--LogCustom(99,"ShowHide.checkShowJingjiBtn End")

    local taskuseitemdialog = require  "logic.task.taskuseitemdialog".getInstanceNotCreate()
    if taskuseitemdialog then
        taskuseitemdialog:OnBattleEnd()
    end

    --刷新人物名字
    local character = gGetScene():FindCharacterByID(gCommon.changeRoleId)
    if character then
        character:UpdatNameTexture(true)
    end
    --local roleId = gGetDataManager():GetMainCharacterID()
    --local character = gGetScene():FindCharacterByID(roleId)
    --if character then
        --character:UpdatNameTexture(true)
    --end

    local Renwulistdialog = require "logic.task.renwulistdialog"
    if Renwulistdialog then
           Renwulistdialog.tryRefreshTeamInfo()
    end
    
    local familybossBloodBardlg = familybossBloodBar.getInstanceNotCreate()
    if familybossBloodBardlg then
        familybossBloodBardlg:setState(1)
    end

    local bingfengTaskTips = bingfengTaskTips.getInstanceNotCreate()
    if bingfengTaskTips then
        GetMainCharacter():clearGotoNpc()
    end

    if GetIsInFamilyFight() then
        local familyfight = require ("logic.family.familyfightxianshi").getInstanceNotCreate()
        if familyfight then
            familyfight:SetVisible(true)
        end
    end

    --公会战结束
    if GetIsInFamilyFight() then
        FamilyFightManager.Data.m_changeColor = {}
    end
    local dlg2 = OrderSetDlg.getInstanceNotCreate()
    if dlg2 then
        dlg2:DestroyDialog()
    end   
end


function ShowHide.SetButtonsVisible( show )
	LogInfo("ShowHide SetButtonsVisible "..tostring(show))
    local bVisible = (show == true)
	if gGetScene() then
		bVisible = bVisible and (gGetScene():GetMapInfo() ~= 1426) --跨服地图不显示
	end
    local logoDlg = LogoInfoDialog.getInstanceNotCreate()
    if not logoDlg then
        return
    end
    if bVisible then
        logoDlg:ShowAllButton()
        logoDlg:RefreshAllBtn()
    else
        logoDlg:HideAllButton()
    end
end

function ShowHide.TeamPvpDestroyDlg()

end


function ShowHide.EnterEnChouScene()
	LogInfo("showhide enterenchouscene")
	PetLabel.hide()
--	PKEntrance.DestroyDialog()
	bingfengwangzuoTips.DestroyDialog()
	bingfengwangzuoDlg.DestroyDialog()
    local Renwulistdialog = require "logic.task.renwulistdialog"
    Renwulistdialog.trySetVisibleFalse()
    ShowHide.SetButtonsVisible(false)
end


function ShowHide.EnChouBattleEnd()
	LogInfo("showhide enchoubattleend")
	ShowHide.SetButtonsVisible(false)
end


function ShowHide.EnterPVPScene()
	LogInfo("showhide enterpvpscene")
	PetLabel.hide()
--	PKEntrance.DestroyDialog()
    ShowHide.SetButtonsVisible(false)
end


function ShowHide.ExitEnChouPVPScene()
	LogInfo("showhide exitenchoupvpscene")
	if gGetWelfareManager() then
		LogoInfoDialog.GetInstanceRefreshAllBtn()		
    end

    ShowHide.SetButtonsVisible(true)
end

--进入游戏，创建需要的控件
function ShowHide.OnGameStart()
	LogInfo("ShowHide OnGameStart Lua")
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstance()
    if not IsPointCardServer() then
        require "protodef.fire.pb.fushi.crequestvipinfo"
        local msg = CRequestVipInfo.Create()
        LuaProtocolManager.getInstance():send(msg)
    end


    local cqqexchangecodestatus = require "protodef.fire.pb.activity.exchangecode.cqqexchangecodestatus".Create()
    LuaProtocolManager.getInstance():send(cqqexchangecodestatus)

    local luap = require "protodef.fire.pb.fushi.creqchargerefundsinfo".Create()
    LuaProtocolManager.getInstance():send(luap)

    local crefreshroleclan = require "protodef.fire.pb.clan.crefreshroleclan":new()
	require "manager.luaprotocolmanager".getInstance():send(crefreshroleclan)

    -- 获取关联手机信息
    local cgetbindtel = require "protodef.fire.pb.cgetbindtel":new()
    require "manager.luaprotocolmanager".getInstance():send(cgetbindtel)
    
	if DeviceInfo:sGetDeviceType() == 3 then
		gSetGCCooldown(1000)
	end
	ResetServerTimer()
	--core.GetCoreLogger():setLoggingLevel(core.Insane)
	--if CEGUI.Logger:getSingleton() then
	--	CEGUI.Logger:getSingleton():setLoggingLevel(CEGUI.Errors)
	--end

	if DeviceInfo:sGetDeviceType() == 3 then
		local sizeMem = DeviceInfo:sGetTotalMemSize()
		if sizeMem <= 1024 then
			Nuclear.GetEngine():EnableParticle(false)
			GetChatManager():SetPerFrameProcessMsgNum(3)
		end
	end

	MainControl.getInstanceAndShow()
	Renwulistdialog.getSingletonDialog()
	HuoDongManager.getInstance()
	
	FormationManager.getInstance()
	LogoInfoDialog.GetSingletonDialogAndShowIt()

    require  "logic.exp.mainroleexpdlg".getInstanceAndShow()
    require  "logic.petandusericon.userandpeticon".getInstanceAndShow()
--    ShiJieBoBaoDlg.getInstance()

	YinCang.getInstanceAndShow()
	
	ShopManager:init()

	if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "ysuc" then
		require "luaj"
		luaj.callStaticMethod("com.locojoy.mini.mt3.uc.UcPlatform", "testUCVIP", nil, nil)
	end
	if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "azhi" then
		local luaj = require "luaj"
		local tempTable = {}
		tempTable[1] = gGetDataManager():GetMainCharacterName()
		tempTable[2] = gGetDataManager():GetMainCharacterLevel()
		tempTable[3] = gGetDataManager():GetMainCharacterName()
		tempTable[4] = ""
		luaj.callStaticMethod("com.locojoy.mini.mt3.anzhi2.AnzhiPlatform", "setDate", tempTable, nil)
		luaj.callStaticMethod("com.locojoy.mini.mt3.anzhi2.AnzhiPlatform", "AnZhiUploadUserDate", nil, nil)
	end

	--hjw
	local value = gGetGameConfigManager():GetConfigValue("sceneeffect")
	if value == 1 then
		require "logic.specialeffect.specialeffectmanager"
		SpecialEffectManager.getInstance()
		if SpecialEffectManager.getInstanceNotCreate() then
		    SpecialEffectManager.getInstanceNotCreate():InitScreenEffect()
		end
	end
	--new add
	--if WaringButtonDlg.getInstanceNotCreate() then
    --	WaringButtonDlg.DestroyDialog()
	--end

	--WelfareBtn.getInstanceAndShow()
	LogoInfoDialog.GetInstanceRefreshAllBtn()

    --请求指引历数据协议
    local req = require "protodef.fire.pb.mission.cgetarchiveinfo".Create()
    LuaProtocolManager.getInstance():send(req)
	
    --new add, prevent the mgr not create
    LoginRewardManager.getInstance()
    LoginRewardManager.getInstance():UpdateLevelShowDlg()

	--new add
    YangChengListDlg.setInit(0)
	local req = require "protodef.fire.pb.cgetsysconfig".Create()
    LuaProtocolManager.getInstance():send(req)

    local level = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(309).value)
    if tonumber(gGetDataManager():GetMainCharacterLevel()) >= level then
        local creqchargerefundsinfo = require "protodef.fire.pb.fushi.creqchargerefundsinfo".Create()
        LuaProtocolManager.getInstance():send(creqchargerefundsinfo)
    end


    --智慧试炼请求可以进入决赛
    local cqueryimpexamstate = require "protodef.fire.pb.npc.cqueryimpexamstate".Create()
    LuaProtocolManager.getInstance():send(cqueryimpexamstate)

	--new add, if show signin

    LogoInfoDialog.SendSignInRequre()

 	ShowHide.CheckAndroidNotity()

    local p = require "protodef.fire.pb.clan.cbonusquery":new()
    require "manager.luaprotocolmanager":send(p)

    if MT3.ChannelManager:isDefineSDK() then
		if MT3.ChannelManager:IsAndroid() then
			MT3.ChannelManager:onLogin_sta()
		else
			MT3.ChannelManager:onLogin_sta()
		end
	end

	--new add, start wg check
	gGetGameApplication():gStartWGAnalysis()
   
    if DeviceInfo:sGetDeviceType()==4 then --WIN7_32
        local serverName = gGetLoginManager():GetSelectServer()
        local pos = string.find(serverName, "-")
        if pos then
            serverName = string.sub(serverName, 1, pos - 1)
        end
        gGetGameApplication():SetGameMainWindowTitle(Config.GetGameName() .. "---" .. serverName .. "---" .. gGetDataManager():GetMainCharacterName())
    end
    
end


function ShowHide.CheckAndroidNotity()
	--安卓本地推送
	if Config.androidNotifyAll == true or Config.CUR_3RD_LOGIN_SUFFIX == "lemn" then
		require "luaj"
		local param = {}
		param[1] = 2
		luaj.callStaticMethod("com.locojoy.mini.mt3.LocalNotificationManager", "enableNotification", param, "(I)V")
	end	

end




--新手引导刷新需要显示的控件
function ShowHide.NewRoleGuide()
	LogInfo("showhide newroleguide")
	if MainControl.getInstanceNotCreate() then
		MainControl.getInstanceNotCreate():ShowBtnByGuide()
	end
end



function ShowHide.EnterFuben()
    LogInfo("showhide enter fuben")
    PetLabel.hide()
    --	PKEntrance.DestroyDialog()
    ShowHide.SetButtonsVisible(false)

    -- 停止副本确认界面的动画-cc-2024年12月6日08点21分
    if fubenEnterDlg.getInstanceNotCreate() then  -- 获取副本确认界面
        local dlg = fubenEnterDlg.getInstanceNotCreate()
        if dlg.textScrollAnimation1 then  
            dlg.textScrollAnimation1:stop()  -- 停止动画
        end
		if dlg.textScrollAnimation2 then  
            dlg.textScrollAnimation2:stop()  -- 停止动画
        end
		if dlg.textScrollAnimation3 then  
            dlg.textScrollAnimation3:stop()  -- 停止动画
        end
		if dlg.textScrollAnimation4 then  
            dlg.textScrollAnimation4:stop()  -- 停止动画
        end
		if dlg.textScrollAnimation5 then  
            dlg.textScrollAnimation5:stop()  -- 停止动画
        end
		if dlg.textScrollAnimation6 then  
            dlg.textScrollAnimation6:stop()  -- 停止动画
        end
		if dlg.textScrollAnimation7 then  
            dlg.textScrollAnimation7:stop()  -- 停止动画
        end
    end

    fubenEnterDlg.DestroyDialog()  -- 销毁副本确认界面
end

function ShowHide.ExitFuben()
	LogInfo("showhide exit fuben")

	if gGetWelfareManager() then
		LogoInfoDialog.GetInstanceRefreshAllBtn()
    end

	ShowHide.SetButtonsVisible(true)
end

function ShowHide.EnterLeavePVPArea()
	--LogInfo("showhide enterleave pvp area")
	--[[local camp = GetMainCharacter():GetCamp()
	if camp ~= 1 and camp ~= 2 then
		local num = gGetScene():GetSceneCharNum()
		for i = 1, num do
			local character = gGetScene():GetSceneCharacter(i)
			character:SetNameColour(0xff33ffff) 			--yellow
		end
	else
		if GetMainCharacter():IsInPVPArea() then
			local num = gGetScene():GetSceneCharNum()
			for i = 1, num do
				local character = gGetScene():GetSceneCharacter(i)
				if character:GetCamp() == camp then
					character:SetNameColour(0xff33ff33) 	--green
				elseif character:GetCamp() ~= 1 and character:GetCamp() ~= 2 then
					character:SetNameColour(0xff33ffff) 	--yellow
				else
					character:SetNameColour(0xff3333ff) 	--red
				end
			end
		else
			local num = gGetScene():GetSceneCharNum()
			for i = 1, num do
				local character = gGetScene():GetSceneCharacter(i)
				if character:GetCamp() == camp then
					character:SetNameColour(0xff33ff33) 	--green
				else
					character:SetNameColour(0xff33ffff) 	--yellow
				end
			end
		end
	end--]]
end

function ShowHide.SetNormalVisible(show)
	LogInfo("ShowHide.SetNormalVisible ---> " .. tostring(show))
	local Renwulistdialog = require "logic.task.renwulistdialog"

	Renwulistdialog.getSingletonDialog():SetVisible(show)
	if show then
		LogoInfoDialog.GetInstanceRefreshAllBtn()
	end
    
	ShowHide.SetButtonsVisible(show)
	print("ShowHide.SetNormalVisible------------>" .. tostring(show))
end

function ShowHide.SHJiHouSai(hasenter)
	print("ShowHide.SHJiHouSai .. " .. tostring(hasenter))
	ShowHide.SetNormalVisible(not hasenter)

end

function ShowHide.ChangeMap(LastMapID, CurMapID)
	LogInfo("ShowHide ChangeMap " .. tostring(LastMapID) .. " " .. tostring(CurMapID))
	--应该先处理 LastMapID 再处理 CurMapID，避免以后可能从副本跳转到另一个副本界面显示冲突
    require "logic.worldmap.worldmapdlg".DestroyDialog()
    require"logic.mapchose.smallmapdlg".DestroyDialog()
	--hjw
	local value = gGetGameConfigManager():GetConfigValue("sceneeffect")
	require "logic.specialeffect.specialeffectmanager"
	if SpecialEffectManager.getInstanceNotCreate() and value == 1 then
		SpecialEffectManager.getInstanceNotCreate():InitLocationEffect()
	end    
    if PiPeiDlg.getInstanceNotCreate() then
        PiPeiDlg.CloseAndSendExit()
    end
end

function ShowHide.IsSpecialFuben(id)
	return 0
end

function ShowHide.ShowHpOrMpClickYes(ShowHide, args)
    local deathDlg = deathNoteDlg.getInstanceNotCreate()
    if deathDlg then
        deathDlg:GetWindow():setProperty("AllowModalStateClick", "False")
    end
    local dlg = require "logic.shop.npcshop":getInstanceAndShow()
	dlg:setShopType( SHOP_TYPE.WINESHOP )
    gGetMessageManager():CloseMessageBoxByType(eMsgType_Normal, false)
end
function ShowHide.ShowHpOrMpClickNo(ShowHide, args)
    if CEGUI.toWindowEventArgs(args).handled ~= 1 then
        gGetMessageManager():CloseMessageBoxByType(eMsgType_Normal, false)
    end
    return
end

function ShowHide.ShowHpOrMpDlg()
    local role_hp_buffid = 500009
    local role_mp_buffid = 500010
    local hpstore = gGetDataManager():GetHPMPStoreByID(role_hp_buffid)
	local mpstore = gGetDataManager():GetHPMPStoreByID(role_mp_buffid)

    if hpstore == 0 or mpstore == 0 then

        local msg = MHSD_UTILS.get_msgtipstring(162056)
        gGetMessageManager():AddMessageBox("",msg,ShowHide.ShowHpOrMpClickYes,ShowHide,ShowHide.ShowHpOrMpClickNo,ShowHide,eMsgType_Normal,30000,0,0,nil,MHSD_UTILS.get_resstring(996),MHSD_UTILS.get_resstring(997))
    end
end

function ShowHide.checkShowJingjiBtn()
     local nMapId = gGetScene():GetMapID()
    local nJingjiType = getJingjiMapType(nMapId)
    if nJingjiType==1 then
        require("logic.jingji.jingjienterdialog").getInstanceAndShow()
    elseif nJingjiType==2 then
        require("logic.jingji.jingjienterdialog3").getInstanceAndShow()
    elseif nJingjiType==3 then
        require("logic.jingji.jingjienterdialog5").getInstanceAndShow()
    elseif nJingjiType==4 then
        --挂机设置
        require("logic.guaji.guajidia").getInstanceAndShow()
    end
     
end


return ShowHide
