require "logic.characterinfo.getdatainfomsg"

require "logic.task.renwulistdialog"
require "logic.lottery.lotterycarddlg"
require "logic.specialeffect.specialeffectmanager"
require "logic.lockscreendlg"
require "logic.xingongnengkaiqi.xingongnengopendlg"
require "logic.shop.mallshop"
require "logic.answerquestion.answerquestiondlg"
require "logic.answerquestion.kejuxiangshi"
debugrequire "logic.leitai.leitaidatamanager"
require "logic.shop.stalldlg"

local gcTime = 0
--local serverStartTime = 0
--local nativeTime = -1
-- main tick 
function LuaMainTick(delta)

    NewRoleGuideManager_Run(delta*0.001)

    AddNewItemsEffect.Run(delta)
	if YinCang.getInstanceNotCreate() then
		YinCang.getInstanceNotCreate():Run(delta)
	end

	if MainControl.getInstanceNotCreate() then
		MainControl.getInstanceNotCreate():run(delta)
	end
	
	GetDataInfoMsg.run(delta)

	if Renwulistdialog.getSingleton() then
		Renwulistdialog.getSingleton():Run(delta)		
	end	
	
	if LockScreenDlg.getInstanceNotCreate() then
		LockScreenDlg.getInstanceNotCreate():run(delta)
	end
	
	if XinGongNengOpenDLG.getInstanceNotCreate() then
		XinGongNengOpenDLG.getInstanceNotCreate():run(delta)
	end

    if MallShop.getInstanceNotCreate() then
        MallShop.getInstanceNotCreate():update(delta)
    end

	require "handler.fire_pb_npc"(delta / 1000)
	if SpecialEffectManager.getInstanceNotCreate() then
		SpecialEffectManager.getInstanceNotCreate():run(delta)
	end

    if require("logic.npc.npcscenespeakdialog").getInstanceNotCreate() then
		require("logic.npc.npcscenespeakdialog").getInstanceNotCreate():run(delta)
	end

    if require("logic.npc.npcdialog").getInstanceNotCreate() then
		require("logic.npc.npcdialog").getInstanceNotCreate():run(delta)
	end

	if require("logic.team.teamrollmelondialog").getInstanceNotCreate() then
		require("logic.team.teamrollmelondialog").getInstanceNotCreate():run(delta)
	end 

    local dlg = require("logic.capturedlg").getInstanceNotCreate()
    if dlg then
        dlg:run(delta)
    end
	
	local dlg = require("logic.pet.petpropertydlgnew").getInstanceNotCreate()
	if dlg then
		dlg:update(delta)
	end
	
	dlg = require("logic.pet.petlianyaodlg").getInstanceNotCreate()
	if dlg then
		dlg:update(delta)
	end
	
	dlg = require("logic.pet.petcombineresultdlg").getInstanceNotCreate()
	if dlg then
		dlg:update(delta)
	end
	
	dlg = require("logic.pet.petgallerydlg").getInstanceNotCreate()
	if dlg then
		dlg:update(delta)
	end
    
    dlg = require ("logic.shijiebobaodlg").getInstanceNotCreate()
    if dlg then
        dlg:update(delta)
    end
	
    require("logic.team.huobanzhuzhandialog").updateTime(delta)

	dlg = require("logic.team.huobanzhuzhandialog").getInstanceNotCreate()
	if dlg then
		dlg:update(delta)
	end

	dlg = require("logic.team.huobanzhuzhaninfo").getInstanceNotCreate()
	if dlg then
		dlg:update(delta)
	end	

	dlg = require("logic.team.teammatchdlg").getInstanceNotCreate()
	if dlg then
		dlg:update(delta)
	end
	
	dlg = require("logic.treasureMap.treasureChosedDlg").getInstanceNotCreate()
	if dlg then
		dlg:update(delta)
	end

	--new add
	dlg = require("logic.qiandaosongli.continuedayreward").getInstanceNotCreate()
	if dlg then
		dlg:update(delta)
	end
	
	dlg = require("logic.treasureMap.supertreasuremap").getInstanceNotCreate()
	if dlg then
		dlg:update(delta)
	end
	
	require("manager.buffmanager").getInstance():update(delta)
	require("logic.task.taskmanager").getInstance():update(delta)
	--dlg = require("logic.treasureMap.treasureChosedDlg").getInstanceNotCreate()
	if treasureChosedDlg.startTimer == true then
		treasureChosedDlg.tick(delta)
	end
	
	dlg = require("logic.pet.petdetaildlg").getInstanceNotCreate()
	if dlg then
		dlg:update(delta)
	end

    dlg = require("logic.reconnectdlg").getInstanceNotCreate()
    if dlg then
        dlg:tick(delta)
    end
    
    dlg = require("logic.family.familychuangjiandialog").getInstanceNotCreate()
    if dlg then
        dlg:update(delta)
    end

    dlg = require("logic.family.familyqunfaxiaoxidialog").getInstanceNotCreate()
    if dlg then
        dlg:update(delta)
    end

    dlg = require("logic.family.familyjiarudialog").getInstanceNotCreate()
    if dlg then
        dlg:update(delta)
    end

	dlg = require("logic.worldmap.worldmapdlg").GetSingleton()
    if dlg then
        dlg:update(delta)
    end
    dlg = require ("logic.family.familyyaofang").getInstanceNotCreate()
    if dlg then
       dlg:update(delta)
    end

    dlg = require ("logic.jingling.jinglingdlg").getInstanceNotCreate()
    if dlg then
        dlg:run(delta / 1000)
    end

    dlg = require ("logic.libaoduihuan.libaoduihuanma").getInstanceNotCreate()
    if dlg then
       dlg:update(delta)
    end

    dlg = require ("logic.answerquestion.answerquestiondlg").getInstanceNotCreate()
	if dlg then
		dlg:UpdateTime(delta)
	end
    
    dlg = require ("logic.ranse.characterransedlg").getInstanceNotCreate()
	if dlg then
		dlg:update(delta)
	end

    dlg = require ("logic.chat.cchatoutboxoperateldlg").getInstanceNotCreate()
	if dlg then
		dlg:UpdateChatContentBox(delta)
	end

	dlg = require ("logic.chat.chatoutputdialog").getInstanceNotCreate()
	if dlg then
		dlg:update(delta)
	end

	dlg = GetChatManager()
	if dlg then
		dlg:update(delta)
	end

	dlg = require ("logic.answerquestion.kejuxiangshi").getInstanceNotCreate()
	if dlg then
		dlg:UpdateTime(delta)
	end

    dlg = require ("logic.friend.sendgiftdialog").getInstanceNotCreate()
	if dlg then
		dlg:update(delta)
	end

    dlg = require("logic.fuyuanbox.fuyuanboxdlg").getInstanceNotCreate()
	if dlg then
		dlg:update(delta)
	end

    dlg = require("logic.wisdomtrialdlg.wisdomtrialdlg").getInstanceNotCreate()
	if dlg then
		dlg:UpdateTime(delta)
	end

    dlg = require("logic.busytext.busytextdlg").getInstanceNotCreate()
	if dlg then
		dlg:update(delta)
	end

    dlg = require("logic.logo.logoinfodlg").getInstanceNotCreate()
	if dlg then
		dlg:update(delta)
	end

    dlg = require("logic.fuben.fubenEnterDlg").getInstanceNotCreate()
    if dlg then
        dlg:run(delta)
    end
    dlg = require("logic.title.titledlg").getInstanceNotCreate()
    if dlg then
        dlg:Update()
    end

    dlg = require("logic.schoolLeader.leaderElectionDlg").getInstanceNotCreate()
    if dlg then
        dlg:run(delta)
    end
    dlg = require("logic.redpack.redpackdlg").getInstanceNotCreate()
    if dlg then
        dlg:Update(delta)
    end
    dlg = require("logic.redpack.redpacksenddlg").getInstanceNotCreate()
    if dlg then
        dlg:Update(delta)
    end
    dlg = require("logic.redpack.redpackhistorydlg").getInstanceNotCreate()
    if dlg then
        dlg:Update(delta)
    end
    if CurrencyManager.scheduleForAutoBuyRes then
        CurrencyManager.tick(delta)
    end
    LeiTaiDataManager.Run(delta)

	LuaBattleUIManager.Tick(delta)

    dlg = require ("logic.guajicfg").getInstanceNotCreate()
	if dlg then
		dlg:update(delta)
	end

    dlg = require ("logic.newswarndlg").getInstanceNotCreate()
    if dlg then
		dlg:update(delta)
	end

     local datamanager = require "logic.faction.factiondatamanager"
     if datamanager then
      datamanager.OnTick(delta)
     end

    dlg = require("logic.gaimingka").getInstanceNotCreate()
    if dlg then
        dlg:update(delta)
    end

    dlg = require("logic.task.taskdialog").getInstanceNotCreate()
    if dlg then
        dlg:update(delta)
    end    

    require("logic.task.schedulermanager").getInstance():update(delta)

    Tick1Minute(delta)
    TickFPSCheck(delta)
    --TickFPS(delta)

    dlg = StallDlg.getInstanceNotCreate()
    if dlg then
        dlg:update(delta)
    end
    
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    roleItemManager:update(delta)

    dlg = require("logic.tips.commontipdlg").getInstanceNotCreate()
    if dlg then
        dlg:Update(delta)
    end

    dlg = familybossBloodBar.getInstanceNotCreate()
    if dlg then
        dlg:run(delta)
    end

    dlg = require"logic.huodong.huodongmanager".getInstanceNotCreate()
    if dlg then
        dlg:Update(delta)
    end

    if GetTeamManager() then
        GetTeamManager():Run(delta)
    end

    if gGetWelfareManager() then
        gGetWelfareManager():run(delta)
    end

	checkShortcutItemLaunchedBy();

    dlg = require"logic.pointcardserver.currencytradingdlg".getInstanceNotCreate()
    if dlg then
        dlg:update(delta)
    end

    dlg = require "logic.monthcard.monthcarddlg".getInstanceNotCreate()
	if dlg then
		dlg:update()
	end

    dlg = require ("logic.qqgift.qqgiftdlg").getInstanceNotCreate()
    if dlg then
       dlg:update(delta)
    end

    local familyfightmgr = require("logic.family.familyfightmanager").getInstance()
    if familyfightmgr then
        familyfightmgr:update(delta)
    end

    dlg = require"logic.family.familyfightxianshi".getInstanceNotCreate()
    if dlg then
        dlg:update(delta)
    end

    dlg = require"logic.family.familyduizhanzudui".getInstanceNotCreate()
    if dlg then
       dlg:update(delta)
    end
    
    dlg = require("logic.family.familyxiangyingtanhedialog").getInstanceNotCreate()
    if dlg then
        dlg:update(delta)
    end

    dlg = require("logic.recruit.recruitdlg").getInstanceNotCreate()
    if dlg then
        dlg:Update()
    end

    dlg = require"logic.gamewaitingdlg".getInstanceNotCreate()
    if dlg then
        dlg:Update(delta)
    end

    if gGetDataManager() then
        gGetDataManager():update(delta)
    end

    dlg = require("logic.shoujianquan.shoujiguanlianshuru").getInstanceNotCreate()
    if dlg then
        dlg:CountDownUpdate(delta)
    end

    dlg = require("logic.shoujianquan.shoujiguanlianchenggong").getInstanceNotCreate()
    if dlg then
        dlg:CountDownUpdate(delta)
    end

    require("logic.chargecell").update(delta)

end

local tick1min = 0
function Tick1Minute(delta)
    tick1min = tick1min + delta
    if tick1min >= 60000 then
       tick1min = tick1min - 60000
        if gGetDataManager() and gGetDataManager():GetMainCharacterLevel() >= 60 and not gGetScene():IsInFuben() and not GetBattleManager():IsInBattle() then
           
        end
    end
end

local tick3min = 0
function TickFPSCheck(delta)
    tick3min = tick3min + delta
    if tick3min >= 60000 then
       tick3min = tick3min - 60000                
            local p = require "protodef.fire.pb.game.cclienttime":new()
            p.time = gGetServerTime()
	        require "manager.luaprotocolmanager":send(p)
    end
end

local tickFPSctrl = 0
local lastFPS = 0
PlayerCountByFPS = 150  
function TickFPS(delta)
    tickFPSctrl = tickFPSctrl + delta
    if tickFPSctrl >= 3000 then
        tickFPSctrl = tickFPSctrl - 3000
        local fps = Nuclear.GetEngine():GetFPS()

        if not gGetScene():isLoadMaping() and gGetGameConfigManager():GetConfigValue("sceneeffect") == 1 then
            if  fps < 15 then
                gGetScene():pauseSceneEffects()
            else
                gGetScene():resumeSceneEffects()
            end
        end

        local det = math.abs(fps - lastFPS)
        if det >= 2 then
            lastFPS = fps

            local tableAllId = BeanConfigManager.getInstance():GetTableByName("SysConfig.cpcountfpssetting"):getAllID()
            for _, v in pairs(tableAllId) do
                local fpsinfo = BeanConfigManager.getInstance():GetTableByName("SysConfig.cpcountfpssetting"):getRecorder(v)
                if fpsinfo.minfps < lastFPS and lastFPS <= fpsinfo.maxfps then
                    if PlayerCountByFPS ~= fpsinfo.playercount then
                        PlayerCountByFPS = fpsinfo.playercount
                        SystemSettingNewDlg.SendMaxPlayerNum()
                    end
                    break
                end
            end
        end
    end
end

function ResetServerTimer()
--	nativeTime = -1
end

function checkShortcutItemLaunchedBy()
	-- ios9 快捷菜单启动
	local shortcutItem = gGetLoginManager():getShortcutItemLaunchedBy();
	local handled = gGetLoginManager():isShortcutItemHandled();
	if shortcutItem ~= eShortcutItem_None and not handled then

		-- 获取玩家等级
		local data = gGetDataManager():GetMainCharacterData();
		local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL);

		if shortcutItem == eShortcutItem_ViewStall then
			require("logic.shop.stalllabel").show()

		elseif shortcutItem == eShortcutItem_FriendChat then
			require "logic.friend.friendmaillabel".Show(1)

		elseif shortcutItem == eShortcutItem_ActivityCalendar then

			-- 活动有开启等级的要求
			local needLevel = BeanConfigManager.getInstance():GetTableByName("mission.cnewfunctionopen"):getRecorder(14).needlevel;
			if nLvl >= needLevel then
				require "logic.huodong.huodongmanager".getInstance();
				require "logic.logo.logoinfodlg".openHuoDongDlg();
			end

		end
		
		gGetLoginManager():setShortcutItemHandled(true);
	end
end

--Lua--十进制转二进制
function dec_to_binary (data)
    local dst = ""
    local remainder, quotient

    --异常处理
    if not data then return dst end                 --源数据为空
    if not tonumber(data) then return dst end       --源数据无法转换为数字

    --如果源数据是字符串转换为数字
    if "string" == type(data) then
        data = tonumber(data)
    end

    while true do
        quotient = math.floor(data / 2)
        remainder = data % 2
        dst = dst..remainder
        data = quotient
        if 0 == quotient then
            break
        end
    end

    --翻转
    dst = string.reverse(dst)

    --补齐8位
    if 8 > #dst then
        for i = 1, 8 - #dst, 1 do
            dst = '0'..dst
        end
    end
    return dst
end

--Lua--二进制转十进制
function binary_to_dec (data)
    local dst = 0
    local tmp = 0

    --异常处理
    if not data then return dst end                 --源数据为空
    if not tonumber(data) then return dst end       --源数据无法转换为数字

    --如果源数据是字符串去除前面多余的0
    if "string" == type(data) then
        data = tostring(tonumber(data))
    end

    --如果源数据是数字转换为字符串
    if "number" == type(data) then
        data = tostring(data)
    end

    --转换
    for i = #data, 1, -1 do
        tmp = tonumber(data:sub(-i, -i))
        if 0 ~= tmp then
            for j = 1, i - 1, 1 do
                tmp = 2 * tmp
            end
        end
        dst = dst + tmp
    end
    return dst
end

function base64decode(data)
    local basecode = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local dst = ""
    local code = ""
    local tmp, index

    --异常处理
    if not data then return dst end                   --源数据为空

    data = data:gsub("\n", "")                        --去除换行符
    data = data:gsub("=", "")                         --去除'='

    for i = 1, #data, 1 do
        tmp = data:sub(i, i)
        index = basecode:find(tmp)
        if nil == index then
            return dst
        end
        index = index - 1
        tmp = dec_to_binary(index)
        code = code..tmp:sub(3)                       --去除前面多余的两个'00'
    end

    --开始解码
    for i = 1, #code, 8 do
        tmp = string.char(binary_to_dec(code:sub(i, i + 7)))
        if nil ~= tmp then
            dst = dst..tmp
        end
    end
    return dst
end