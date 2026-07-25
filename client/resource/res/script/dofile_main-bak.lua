-- just for debug, by liugeng
if DeviceInfo:sGetDeviceType() == 4 then
    --WIN7_32
    require "debughelper"
else
    _G.debugrequire = _G.require
end

-- dofile entry for lua function registering to c++

----------/////////////////////////////////////
require "protodef.protocols"
----------/////////////////////////////////////

----------/////////////////////////////////////
--manager
require "logic.showhide"
require "manager.protocolhandlermanager"
require "manager.luaprotocolmanager"
require "manager.beanconfigmanager"
require "manager.notifymanager"
require "manager.npcservicemanager"
require "manager.currencymanager"
require "manager.notificationcenter"
require "manager.teammanager"
require "manager.mt3heromanager"
require "manager.welfaremanager"
require "manager.npcservicemanager"
require "manager.taskmanager_ctolua"
require "manager.mainroledatamanager"

require "logic.shop.shopmanager"
require "logic.skillboxcontrol"

require "logic.luauimanager"
require "logic.team.formationmanager"

require "logic.battle.battlemanager"
require "logic.skill.roleskillmanager"

require "logic.contactroledlg"
require "logic.rank.zonghepingfendlg"

require "utils.typedefine"
require "utils.log"
require "utils.bit"
require "utils.commonutil"

require "logic.pet.mainpetdatamanager"

require "logic.guide.newroleguidemanager"

----------/////////////////////////////////////
require "mainticker"
require "globalfunctionsforcpp"
----------/////////////////////////////////////
--ui dialog
--take note,since the nested relation is very complex about xiake lua files, now keep them in this file temporarily
require "logic.texttip"
require "logic.multimenu"
require "logic.numkeyboarddlg"
require "logic.tableview"
require "logic.treeview"
require "logic.messageboxsimple"
require "logic.selectserversdialog"
require "logic.maincontrol"
require "logic.workshop.workshoplabel"
require "utils.reload_util"
require "logic.battle.zhenfa"
require "logic.battle.zhenfatip"
require "logic.pet.petlabel"
require "logic.checktipswnd"
require "logic.loginqueuedialog"
require "logic.task.taskdialog"
require "logic.task.renwulistdialog"
require "logic.luanewroleguide"
require "logic.chatinsimpleshow"
require "logic.chargedialog"
require "logic.skill.skilllable"
require "logic.task.showtaskdetail"

--has been used in cpp, need to require in this
require "logic.jingying.jingyingenddlg"
require "logic.rank.rankinglist"

-- item from c++ to lua
require "logic.item.itemcommon"
require "logic.item.roleitem"
require "logic.item.roleitemmanager"

----------/////////////////////////////////////
require "logic.useitemhandler"

require "logic.pet.battlepetsummondlg"
require "logic.battle.luabattleuimanager"

--has been used in cpp, need to require in this
require "logic.systemsettingdlgnew"

require "logic.battleautofightdlg"
require "logic.pet.petoperatedlg"
require "system.banlistmanager"
require "logic.task.specialgotonpc"
require "logic.switchaccountdialog"

require "logic.battle.zhandouanniu"
require "logic.characterinfo.characterpropertyaddptrdlg"
require "logic.addpointintro"
require "logic.addpointlistdlg"
require "logic.team.teamdialognew"

require "logic.characterinfo.characterpropertyaddptrresetcell"
require "logic.characterinfo.characterpropertyaddptrresetdlg"

require "logic.characterinfo.addpointmanger"

require "logic.skill.lifeskilltipdlg"
require "logic.workshop.tipsguajiimgcell"
require "logic.workshop.tipsguajiimg"
require "logic.bingfengwangzuo.bingfengwangzuoTaskTips"
require "logic.battle.battlebag"
require "logic.battle.battlefabaobag"
require "logic.battle.battletips"
require "logic.battle.battleskilltip"
require "logic.battle.battleskillpanel"
require "logic.battle.characteroperatedlg"

require "logic.tips.equipinfotips"
require "logic.tips.petskilltipsdlg"
require "logic.deathNoteDlg"
require "logic.treasureMap.treasureChosedDlg"
require "logic.treasureMap.supertreasuremap"

require "logic.pet.petstoragedlg"

require "logic.mapchose.hookmanger"
require "logic.showhide"
require "logic.battleautofightdlg"
require "logic.pet.battlepetsummondlg"
require "logic.battle.luabattleuimanager"
require "logic.pet.petoperatedlg"
require "logic.battle.userminiicondlg"
require "logic.battle.battlebag"
require "logic.battle.battlefabaobag"
require "logic.battle.battletishi"
require "logic.battle.zhandouanniu"
require "logic.battle.battletips"
require "logic.battle.battletipscell"
require "logic.battle.bossdaxuetiao"
require "logic.skill.skilllable"
require "logic.skill.characterskillupdatedlg"
require "logic.task.taskuseitemdialog"
require "logic.task.taskhelper"

require "logic.qiandaosongli.qiandaosonglicell_mtg"
require "logic.qiandaosongli.qiandaosonglidlg_mtg"
require "logic.qiandaosongli.loginrewardmanager"
require "logic.qiandaosongli.continuedaycell"
require "logic.qiandaosongli.continuedayreward"
require "logic.qiandaosongli.mtg_firstchargedlg"
require "logic.qiandaosongli.mtg_onlinewelfaredlg"
require "logic.qiandaosongli.fengcefanhuandlg"
require "logic.team.huobanzhuzhanjiesuo"
require "logic.zhenfa.zhenfadlg"
require "logic.bingfengwangzuo.bingfengwangzuodlg"
require "logic.bingfengwangzuo.bingfengwangzuoTips"

require "logic.qiandaosongli.leveluprewarddlg"
require "logic.qiandaosongli.leveluprewardcell"
require "logic.pet.petdetaildlg"
require "logic.npcnamelist"
--�������
require "logic.family.family" --����UI
require "logic.family.familyjiarudialog" -- ���빫��UI
require "logic.family.familylabelframe"   --�����ǩҳ
require "logic.family.familychengyuandialog" --�����ԱUI
require "logic.family.familyfulidialog"    --���ḣ��UI
require "logic.family.familyhuodongdialog"    --����
require "logic.family.familychuangjiandialog" --��������
require "logic.family.familyBossBloodBar" -- ����BOSS
require "logic.family.familyfightrank" -- ����ս����
require "logic.libaoduihuan.libaoduihuanma" --����һ���
require "logic.leitai.leitaidialog"   --PK
require "logic.chakan.chakan" --�鿴����װ��
require "logic.addnewitemseffect"
require "logic.shijiebobaodlg"
require "logic.yangchengnotify.yangchenglistdlg"
require "logic.team.teamrollmelondialog"
require "logic.ransedlg"
require "logic.ransebaocundlg"
require "logic.bingfengwangzuo.bingfengwangzuomanager"
require "logic.numbersel"
require "logic.guajicfg"
require "logic.item.MainPackLabelDlg" -- ������ֿ�
require "logic.item.gameitemtable"
require "logic.readtimeprogressdlg"
require "logic.scenemovie.scriptnpctalkdialog"
require "logic.shengsizhan.shengsizhanteampanel"
require "logic.shengsizhan.shengsizhandlg"
require "logic.shengsizhan.shengsizhanguizedlg"
require "logic.shengsizhan.shengsizhanwatchdlg"
require "logic.shengsizhan.shengsibangdlg"

require "logic.exp.mainroleexpdlg"
require "logic.petandusericon.userandpeticon"

-- ��½
require "logic.login.logindlg"
require "logic.login.LoginImageAndBar"
-- ��ʱ����
require "logic.item.TemporaryPack"

--�������
require "logic.chat.cchatoutboxoperateldlg"
require "logic.chat.chatoutputdialog"
require "logic.chat.chatcommon"
require "logic.chat.chatmanager"
require "logic.chat.insertdlg"
require "logic.chat.roleaccusation"
require "logic.chat.chatcellmanager"
require "logic.chat.tipsmanager"

--תְ���
debugrequire "logic.zhuanzhi.zhuanzhidlg"
require "logic.zhuanzhi.zhuanzhibaoshi"
require "logic.zhuanzhi.zhuanzhicommon"
require "logic.zhuanzhi.zhuanzhiwuqidlg"

require "logic.item.xilian.zhuangbeixiliandlg"

require "logic.fuyuanbox.fuyuanboxdlg"
require "logic.newguide.guideModelSelectDlg"

require "logic.wisdomtrialdlg.wisdomrrialhelpdlg"
require "logic.redpack.redpacklabel"
require "logic.redpack.redpackmanager"
require "logic.worldmap.worldmapdlg"

require "logic.newguide.newguidebg"
require "logic.openui"
require "logic.chat.chatmanager"

require "logic.space.spacemanager"
require "logic.json"

require "logic.pointcardserver.currencytradingdlg"
require "logic.pointcardserver.pointcardservermanager"

require "logic.GameCenterDefine"

require "logic.friend.friendmanager"

require "logic.login.loginbackground"
require "logic.windowsexplain"

require "logic.fightorder.ordereditordlg"
require "logic.fightorder.ordereditorinput"
require "logic.fightorder.ordersetdlg"

require "logic.pipeidlg"

function QuickCommandToC(Cmd, Param0, Param1, Param2, Param3)
    gGetGameUIManager():QuickCommand(Cmd, Param0, Param1, Param2, Param3)
end
function ReloadLua(FileName)
    debugrequire(FileName)
end
function QuickCommand(Cmd, Param0, Param1, Param2, Param3)
    if Cmd == "ReloadLua" then
        ReloadLua(Param0)
    end
end



--debugrequire "logic.showhide"

function Entry_Init()
    LogInfo("dofile enter init")
    --	pcall(require "debug.debugger")

    if DeviceInfo:sGetDeviceType() == 4 then
        --WIN7_32

    else
        CFileUtil:DelFileArrOfPath(CFileUtil:GetTempDir() .. "/", ".wav", false)
        CFileUtil:DelFileArrOfPath(CFileUtil:GetTempDir() .. "/", ".amr", false)
    end

    gGetGameApplication():RegisterTickerHandler(LuaMainTick)

    ProtocolHandlerManager.RegisterProtocolScriptHandler()

    --lua protocols
    Game.gGetProtocolLuaFunManager():RegisterLuaProtocolHandler(LuaProtocolManager.Dispatch)
    RegisterLuaProtocols()

    BeanConfigManager.getInstance():Initialize("/table/xmltable/", "/table/bintable/")

    --[[
    local tt = GameTable.mission.GetCMainMissionInfoTableInstance()

    t = tt:getRecorder(100101)
    for k,v in pairs(t.PostMissionList) do
        print("xml -- "..k .. v)
    end
    --]]
end

Entry_Init()

--gGetGameApplication():SetReadXmlFromBinary(false)
MT3.ChannelManager:RemoveRCPFiles(30)

function OnAuthError()
    LoginQueueDlg.DestroyDialog()
end

function OnAuthError2(detail)
    --if gGetFriendsManager() then
    --local strContent = string.format("<T t=\"%s\" c=\"FF693F00\"></T>", detail)
    --		gGetFriendsManager():AddChatRecord(0, -1, "", "", strContent)
    --end
end

----------end/////////////////////////////////
