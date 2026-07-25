
Openui = { }

Openui.eUIId =
{
    shanghui_01 = 1,
    baitan_02 = 2,
    bangpaijineng_03 = 3,
    shangcheng_04 = 4,
    chongzhi_05 = 5,
    zhuangbeidazao_06 = 6,
    baoshihecheng_07 = 7,
    zhuangbeixiuli_08 = 8,
    zhuangbeixiangqian_09 = 9,
    -- //==============================
    beibao_10 = 10,

    cangku_11 = 11,
    renwushuxing_12 = 12,
    renwuxinxi_13 = 13,
    renwujiadian_14 = 14,

    chongwushuxing_15 = 15,
    chongwulianyao_16 = 16,
    chongwupeiyang_17 = 17,
    chongwutujian_18 = 18,

    menpaijineng_19 = 19,
    xiulianjineng_20 = 20,

    duiwu_21 = 21,
    fuben_22 = 22,
    guaji_23 = 23,
    huobanzhuzhan_24 = 24,
    fenyeqian_25 = 25,
    lianyao_26 = 26,
    linshibeibao_27 = 27,
    huoliduixian_28 = 28,
    npcshangdian_29 = 29,
    chongwushangdian_30 = 30,
    chongwucangku_31 = 31,
    renwushangjiaochongwu_32 = 32,
    renwushangjiaowupin_33 = 33,
    putongwabao_34 = 34,
    gaojiwabao_35 = 35,
    chongwujinengxuexi_36 = 36,
    chongwufangsheng_37 = 37,
    chongzhishuxing_38 = 38,
    siwangtixing_39 = 39,
    renwu_40 = 40,
    huodong_41 = 41,
    haoyou_42 = 42,
    paihangbang_43 = 43,
    liaotian_44 = 44,
    hongzhongzhouli_45 = 45,

    shengjidalibao_46 = 46,
    chongwujinengxiulian_47 = 47,
    chongxidian_48 = 48,
    tianjiahayou_49 = 49,
    duihuanma_50 = 50,
    ranse_51 = 51,
    leitai_52 = 52,
    leitai_53 = 53,
    leitai_54 = 54,
    ransebaocun_55 = 55,
    faction_56 = 56,
    bianjizudui_57 = 57,    
    shengsizhanshu_58 = 58,
    shengsizhanguanzhan_59 = 59,
    shengsizhanbang_60 = 60,
    shengsizhanguize_61 = 61,
    anyemaxituan_62 = 62,
    fenxiang_63 = 63,
    jifenduihuan_64 = 64,
    friendzendsong_65 = 65,
    meiriqiandao_66 = 66,
    shouchong_67 = 67,
    qiriqiandao_68 = 68,
    xinshoulibao_69 = 69,
	hongbao_71 = 71,
    hechong_72 = 72,
    ziyoufenpei_73 = 73,
    fenxiang_url_74 = 74,
	zhenpinbuyback_75 = 75
}

function Openui.isOpen(nUIId)
    local uiCfg = BeanConfigManager.getInstance():GetTableByName("mission.cuicongig"):getRecorder(nUIId)
    if not uiCfg or uiCfg.id == -1 then
        return false
    end
    local nGongNengId = uiCfg.ngongnengid

    
    local bOpen = require("logic.xingongnengkaiqi.xingongnengopendlg").checkFeatureOpened(nGongNengId)
    return bOpen
   

end


function Openui.OpenUI(nUIId, nParam1, nParam2)
   
    if not nParam1 then
        nParam1 = -1
    end

    if not nParam2 then
        nParam2 = -1
    end

   
    local bOpen = Openui.isOpen(nUIId)

    if not bOpen then
        local uiCfg = BeanConfigManager.getInstance():GetTableByName("mission.cuicongig"):getRecorder(nUIId)
        if not uiCfg then
            return
        end
        local nGongNengId = uiCfg.ngongnengid
        
        local gongNengTable = BeanConfigManager.getInstance():GetTableByName("mission.cnewfunctionopen"):getRecorder(nGongNengId)
        if not gongNengTable then
            return
        end
        local nNeedLevel = gongNengTable.needlevel
        local strjikaiqizi = MHSD_UTILS.get_resstring(11049)

        if nNeedLevel == 0 and nGongNengId == 1 then
            local tipstr = MHSD_UTILS.get_msgtipstring(170037)
            GetCTipsManager():AddMessageTip(tipstr)
        else
            local sb = StringBuilder.new()
            sb:Set("parameter1", tostring(nNeedLevel))
            local strResult = sb:GetString(strjikaiqizi)
            sb:delete()

            local strName = uiCfg.name
            strResult = strResult .. strName
            GetCTipsManager():AddMessageTip(strResult)
        end

        return
    end


    LogInfo("Openui.OpenUI(nUIId)=nUIId=" .. nUIId)
    -- //=========================================
    -- //=========================================
    if Openui.eUIId.shanghui_01 == nUIId then
        local nItemId = nParam1
        require("logic.shop.shoplabel").showCommerce()
        local commercedlg = require("logic.shop.commercedlg").getInstanceNotCreate()
        if commercedlg then
            commercedlg:selectGoodsByItemid(nItemId)
        end
        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.baitan_02 == nUIId then
        local nItemId = nParam1
        require("logic.shop.stalllabel").openStallToBuy(nItemId)

        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.bangpaijineng_03 == nUIId then
        require("logic.skill.skilllable").getInstance():ShowOnly(2)

        local nSkillId = nParam1
        LogInfo("nSkillId=" .. nSkillId)
        require("logic.skill.gonghuiskilldlg").setSelectedSkillId(nSkillId)
        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.shangcheng_04 == nUIId then
        local nItemId = nParam1
        require("logic.shop.shoplabel").showMallShop()
        local mallshop = require("logic.shop.mallshop").getInstanceNotCreate()
        if mallshop then
            mallshop:selectGoodsByItemid(nItemId)
        end
        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.chongzhi_05 == nUIId then
        require("logic.shop.shoplabel").getInstance():showOnly(3)
        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.zhuangbeidazao_06 == nUIId then
        local nType = 1
        -- dz
        local nBagId = -1
        local nItemKey = -1
        local nItemIdCailiao = nParam1
        require "logic.workshop.workshoplabel".Show(nType, nItemIdCailiao, nItemKey)
        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.baoshihecheng_07 == nUIId then
        local nType = 3
        -- hc
        local nBagId = nParam1
        local nItemKey = nParam2
        require "logic.workshop.workshoplabel".Show(nType, nBagId, nItemKey)
        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.zhuangbeixiuli_08 == nUIId then
        local nType = 4
        -- xl
        local nBagId = nParam1
        local nItemKey = nParam2
        require "logic.workshop.workshoplabel".Show(nType, nBagId, nItemKey)
        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.zhuangbeixiangqian_09 == nUIId then
        local nBagId = nParam1
        local nItemKey = nParam2
        local nType = 2
        -- xq
        require "logic.workshop.workshoplabel".Show(nType, nBagId, nItemKey)
        -- //=========================================
        -- //=========================================


        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.beibao_10 == nUIId then
        -- CMainPackLabelDlg::Show(1)
        CMainPackLabelDlg:GetSingletonDialogAndShowIt():Show()
        -- default 0
        -- //=========================================
        -- //=========================================

        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.cangku_11 == nUIId then
        CMainPackLabelDlg:GetSingletonDialogAndShowIt():Show(1)
        require 'logic.item.depot':GetSingletonDialogAndShowIt()
        -- //=========================================
        -- //=========================================

        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.renwushuxing_12 == nUIId then
        require("logic.characterinfo.characterlabel").Show(1)
        -- //=========================================
        -- //=========================================

        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.renwuxinxi_13 == nUIId then
        require("logic.characterinfo.characterlabel").Show(2)
        -- //=========================================
        -- //=========================================


        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.renwujiadian_14 == nUIId then
        require("logic.characterinfo.characterlabel").Show(3)
        -- //=========================================
        -- //=========================================


        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.chongwushuxing_15 == nUIId then
        
        if MainPetDataManager.getInstance():GetPetNum() == 0 then
            GetCTipsManager():AddMessageTipById(162058)
            return
        end
        require("logic.pet.petlabel").Show(1)
        -- //=========================================
        -- //=========================================

        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.chongwulianyao_16 == nUIId then
        
        if MainPetDataManager.getInstance():GetPetNum() == 0 then
            GetCTipsManager():AddMessageTipById(162059)
            return
        end
        require("logic.pet.petlabel").Show(2)
        -- //=========================================
        -- //=========================================

        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.chongwupeiyang_17 == nUIId then
        
        if MainPetDataManager.getInstance():GetPetNum() == 0 then
            GetCTipsManager():AddMessageTipById(162060)
            return
        end
        require("logic.pet.petlabel").Show(3)
        -- //=========================================
        -- //=========================================


        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.chongwutujian_18 == nUIId then
        require("logic.pet.petlabel").Show(4)
        -- //=========================================
        -- //=========================================


        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.menpaijineng_19 == nUIId then
        require("logic.skill.skilllable").getInstance():ShowOnly(1)
        -- //=========================================
        -- //=========================================

        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.xiulianjineng_20 == nUIId then
        local beanTabel = BeanConfigManager.getInstance():GetTableByName("mission.cnewfunctionopen")
        local data = gGetDataManager():GetMainCharacterData()
        local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL)
        local recordOpen = beanTabel:getRecorder(16)
        if nLvl >= recordOpen.needlevel then
            -- FIXME:新功能开启表  现在新功能开启那块代码有问题判断方法有问题 暂时这样处理等新功能开启完成再修改  wjf
            require("logic.skill.skilllable").getInstance():ShowOnly(3)
        else
            local msg = require "utils.mhsdutils".get_msgtipstring(145390)
            GetCTipsManager():AddMessageTip(msg)
        end

        -- //=========================================
        -- //=========================================


        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.duiwu_21 == nUIId then
        require("logic.team.teamdialognew").getInstanceAndShow()
        -- //=========================================
        -- //=========================================

        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.fuben_22 == nUIId then
        require("logic.fuben.fubenlabel").getInstanceAndShow()
        -- //=========================================
        -- //=========================================

        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.guaji_23 == nUIId then
        require("logic.mapchose.mapchosedlg").getInstanceAndShow()
        -- //=========================================
        -- //=========================================

        -- //=========================================
        -- //=========================================
    elseif Openui.eUIId.huobanzhuzhan_24 == nUIId then
        require("logic.team.huobanzhuzhandialog").getInstanceAndShow()
        -- //=========================================
        -- //=========================================

        -- //=========================================
    elseif Openui.eUIId.fenyeqian_25 == nUIId then
        -- un use
        -- require("logic.team.huobanzhuzhandialog").getInstanceAndShow()
        -- //=========================================

        -- //=========================================
    elseif Openui.eUIId.lianyao_26 == nUIId then
        require("logic.skill.zuoyaodlg").getInstanceAndShow()
	    local p = require("protodef.fire.pb.skill.liveskill.crequestattr").Create()
        local attr = {}
        attr[1] = fire.pb.attr.AttrType.ENERGY
	    p.attrid = attr
	    LuaProtocolManager:send(p)	
        -- //=========================================


        -- //=========================================
    elseif Openui.eUIId.linshibeibao_27 == nUIId then
        CTemporaryPack:GetSingletonDialogAndShowIt()
        -- //=========================================


        -- //=========================================
    elseif Openui.eUIId.huoliduixian_28 == nUIId then
        local dlg = require "logic.skill.strengthusedlg".getInstanceAndShow()
        dlg:GetWindow():setAlwaysOnTop(true)
        -- //=========================================

        -- //=========================================
    elseif Openui.eUIId.npcshangdian_29 == nUIId then
        -- local dlg = require("logic.shop.npcshop").getInstanceAndShow()
        -- local shopType = require("logic.shop.shopmanager"):getShopTypeByNpcKey(nNpcKey)
        -- dlg:setShopType(shopType)
        -- //=========================================

        -- //=========================================
    elseif Openui.eUIId.chongwushangdian_30 == nUIId then
        require("logic.shop.npcpetshop").getInstanceAndShow()
        -- //=========================================

        -- //=========================================
    elseif Openui.eUIId.chongwucangku_31 == nUIId then
        -- require("logic.shop.npcpetshop").getInstanceAndShow()
        -- //=========================================

        -- //=========================================
    elseif Openui.eUIId.renwushangjiaochongwu_32 == nUIId then
        -- unuse
        -- //=========================================


        -- //=========================================
    elseif Openui.eUIId.renwushangjiaowupin_33 == nUIId then
        -- unuse
        -- //=========================================

        -- //=========================================
    elseif Openui.eUIId.putongwabao_34 == nUIId then
        -- //=========================================


        -- //=========================================
    elseif Openui.eUIId.gaojiwabao_35 == nUIId then
        -- //=========================================

        -- //=========================================
    elseif Openui.eUIId.chongwujinengxuexi_36 == nUIId then
        if MainPetDataManager.getInstance():GetPetNum() == 0 then
            GetCTipsManager():AddMessageTipById(162059)
            return
        end
        require("logic.pet.petlabel").ShowLearnSkillView()
        -- //=========================================


        -- //=========================================
    elseif Openui.eUIId.chongwufangsheng_37 == nUIId then
        if MainPetDataManager.getInstance():GetPetNum() == 0 then
            GetCTipsManager():AddMessageTipById(162058)
            return
        end
        require("logic.pet.petlabel").Show(1)
        -- //=========================================



        -- //=========================================
    elseif Openui.eUIId.chongzhishuxing_38 == nUIId then
        -- pet
        if MainPetDataManager.getInstance():GetPetNum() == 0 then
            GetCTipsManager():AddMessageTipById(162058)
            return
        end
        require("logic.pet.petlabel").Show(1)
        -- //=========================================

        -- //=========================================
    elseif Openui.eUIId.siwangtixing_39 == nUIId then
        -- unuse
        -- require("logic.pet.petlabel").Show(1)
        -- //=========================================

        -- //=========================================
    elseif Openui.eUIId.renwu_40 == nUIId then
        require("logic.task.tasklabel").Show(1)
        -- //=========================================

        -- //=========================================
    elseif Openui.eUIId.huodong_41 == nUIId then
        getHuodongDlg().getInstanceAndShow()
        local p = require("protodef.fire.pb.mission.activelist.crefreshactivitylistfinishtimes"):new()
	    LuaProtocolManager:send(p)
        -- //=========================================

        -- //=========================================
    elseif Openui.eUIId.haoyou_42 == nUIId then
        require "logic.friend.friendmaillabel".Show(1)
        -- //=========================================


        -- //=========================================
    elseif Openui.eUIId.paihangbang_43 == nUIId then
        require"logic.rank.rankinglist".getInstanceAndShow()
        -- //=========================================

        -- //=========================================
    elseif Openui.eUIId.liaotian_44 == nUIId then

        
		if (CMainPackLabelDlg:getInstanceOrNot()) then
			CMainPackLabelDlg:getInstanceOrNot():DestroyDialog();
		end
        --[[
        CChatOutputDialog:GetSingletonDialogAndShowIt()
        if CChatOutputDialog:getInstance() then
            CChatOutputDialog:getInstance():ToShow()
        end
        --]]

        local chatDlg = CChatOutputDialog:getInstance()
        if chatDlg then
            chatDlg:ToShow()
        else
            chatDlg = CChatOutputDialog:GetSingletonDialogAndShowIt()
        end
        -- //=========================================


        -- //=========================================
    elseif Openui.eUIId.hongzhongzhouli_45 == nUIId then
        -- require("logic.task.tasklabel").Show(1)
        require 'logic.huodong.huodongzhoulidlg'.getInstanceAndShow()
        -- //=========================================
    elseif Openui.eUIId.shengjidalibao_46 == nUIId then
        require 'logic.qiandaosongli.leveluprewarddlg'.getInstanceAndShow()
    elseif Openui.eUIId.chongwujinengxiulian_47 == nUIId then
        -- require("logic.pet.petlabel").Show(2)
        require("logic.skill.skilllable").getInstance():ShowOnly(3)
        require("logic.skill.xiulianskilldlg").getInstance().m_curSkillIndex = 5
    elseif Openui.eUIId.chongxidian_48 == nUIId then

        require("logic.characterinfo.characterpropertyaddptrresetdlg").getInstanceAndShow();
    elseif Openui.eUIId.tianjiahayou_49 == nUIId then
        require("logic.friendadddialog").getInstanceAndShow()
    elseif Openui.eUIId.duihuanma_50 == nUIId then
        require("logic.libaoduihuan.libaoduihuanma")
        Libaoduihuanma.getInstanceAndShow()
    elseif Openui.eUIId.ranse_51 == nUIId then
        require("logic.ranse.ranselabel").Show(1)   
    elseif Openui.eUIId.leitai_52 == nUIId then
        local dlg = LeiTaiDialog.getInstanceAndShow()
        if dlg then
            dlg:SetPage(1)
        end
    elseif Openui.eUIId.leitai_53 == nUIId then
        local dlg = LeiTaiDialog.getInstanceAndShow()
        if dlg then
            dlg:SetPage(2)
        end
    elseif Openui.eUIId.leitai_54 == nUIId then
        local dlg = LeiTaiDialog.getInstanceAndShow()
        if dlg then
            dlg:SetPage(3)
        end
    elseif Openui.eUIId.ransebaocun_55 == nUIId then
        RanseBaoCunDlg.getInstanceAndShow()      
    elseif Openui.eUIId.faction_56 == nUIId then
        -- 打开公会UI
        require "logic.faction.factiondatamanager".OpenFamilyUI()
    --------------------------------------------------
    elseif Openui.eUIId.bianjizudui_57 == nUIId then
        if GetTeamManager():IsOnTeam() then
		    require("logic.team.teamsettingdlg").getInstance()
	    else
		    local teamdlg = require("logic.team.teammatchdlg").getInstanceAndShow()
	    end        
    --------------------------------------------------
    elseif Openui.eUIId.shengsizhanshu_58 == nUIId then
        ShengSiZhanDlg.getInstanceAndShow()
    elseif Openui.eUIId.shengsizhanguanzhan_59 == nUIId then
        ShengSiZhanWatchDlg.getInstanceAndShow()
    elseif Openui.eUIId.shengsizhanbang_60 == nUIId then
        ShengSiBangDlg.getInstanceAndShow()
    elseif Openui.eUIId.shengsizhanguize_61 == nUIId then
        ShengSiZhanGuiZeDlg.getInstanceAndShow()
    elseif Openui.eUIId.anyemaxituan_62 == nUIId then
        local taskmanager = require("logic.task.taskmanager").getInstance()
        if taskmanager.nAnyeTimes >= tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(311).value) then
            GetCTipsManager():AddMessageTipById(166112)
            require("logic.task.taskmanager").getInstance().nAnyeCurSelIndex = -1
            return
        end
        require("logic.anye.anyemaxituandialog").getInstanceAndShow()
    elseif Openui.eUIId.fenxiang_63 == nUIId then
        require "logic.share.sharedlg".SetShareFunc(1)
        require "logic.share.sharedlg".SetShareIsActivity(true)
        require "logic.share.sharedlg".getInstanceAndShow()
    elseif Openui.eUIId.fenxiang_url_74 == nUIId then
        require "logic.share.sharedlg".SetShareFunc(2)
        require "logic.share.sharedlg".SetShareIsActivity(true)
        require "logic.share.sharedlg".getInstanceAndShow()
    elseif Openui.eUIId.jifenduihuan_64 == nUIId then
        require "logic.shop.scoreexchangeshop".getInstanceAndShow()
    elseif Openui.eUIId.friendzendsong_65 == nUIId then
        local nItemId = nParam1
        local sendgift = require "logic.friend.sendgiftdialog".getInstanceAndShow()
        sendgift:createContactList(nil)
        sendgift:showGiftPage(nItemId)
    elseif Openui.eUIId.meiriqiandao_66 == nUIId then
        require("logic.qiandaosongli.qiandaosonglidlg_mtg").getInstanceAndShow()
    elseif Openui.eUIId.shouchong_67 ==nUIId then
        require("logic.qiandaosongli.mtg_firstchargedlg").getInstanceAndShow()
    elseif Openui.eUIId.qiriqiandao_68 ==nUIId then
        require("logic.qiandaosongli.continuedayreward").getInstanceAndShow()
    elseif Openui.eUIId.xinshoulibao_69 ==nUIId then
        require("logic.qiandaosongli.mtg_onlinewelfaredlg").getInstanceAndShow()
	elseif Openui.eUIId.hongbao_71 == nUIId then
        local funopenclosetype = require("protodef.rpcgen.fire.pb.funopenclosetype"):new()
        local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
        if manager then
            if manager.m_OpenFunctionList.info then
                for i,v in pairs(manager.m_OpenFunctionList.info) do
                    if v.key == funopenclosetype.FUN_REDPACK then
                        if v.state == 1 then
                            GetCTipsManager():AddMessageTipById(172060)
                            return
                        end
                    end
                end
            end
        end
        require("logic.redpack.redpacklabel").DestroyDialog()
        require("logic.redpack.redpacklabel").show(1)
    elseif Openui.eUIId.hechong_72 == nUIId then
        if MainPetDataManager.getInstance():GetPetNum() == 0 then
            GetCTipsManager():AddMessageTipById(162059)
            return
        end
        require("logic.pet.petlabel").Show(2)
        local dlg = require("logic.pet.petlianyaodlg").getInstanceNotCreate()
        if dlg then
            dlg:showBineView()
        end
    elseif Openui.eUIId.ziyoufenpei_73 == nUIId then
        local dlg = require("logic.monthcard.freedisrewarddlg").getInstanceAndShow()
        dlg:setId(tonumber(nParam1))
	elseif Openui.eUIId.zhenpinbuyback_75 == nUIId then
		require("logic.shop.zhenpinbuyback").getInstanceAndShow()
	end
end


--[[

1	商会
2	摆摊
3	公会技能
4	商城
5	充值
6	装备打造
7	宝石合成
8	装备修理
9	装备镶嵌
10	背包
11	仓库
12	人物属性
13	人物信息
14	人物加点
15	宠物属性
16	宠物炼妖
17	宠物培养
18	宠物图鉴
19	公会（门-派）技能
20	修炼技能
21	队伍
22	副本
23	挂机界面
24	伙伴助战
25	分页签
26	炼药
27	临时背包
28	活力兑现
29	npc商店
30	宠物商店
31	宠物仓库
32	任务上交宠物
33	任务上交物品
34	普通挖宝
35	高级挖宝
36	宠物技能学习
37	宠物放生
38	重置属性
39	死亡提醒
40	任务
41	活动
42	好友
43	排行榜
44	聊天
45	活动周历




Openui.eUIId =
{
	shanghui_01 =1,
	baitan_02 =2,
	bangpaijineng_03 =3,
	shangcheng_04 =4,
	chongzhi_05 =5,
	zhuangbeidazao_06 =6,
	baoshihecheng_07 =7,
	zhuangbeixiuli_08 =8,
	zhuangbeixiangqian_09 =9,
	--//==============================
	beibao_10 = 10,

	cangku_11 = 11,
	renwushuxing_12 = 12,
	renwuxinxi_13 = 13,
	renwujiadian = 14,

	chongwushuxing_15 = 15,
	chongwulianyao_16 = 16,
	chongwupeiyang_17 = 17,
	chongwutujian_18 = 18,

	menpaijineng_19 = 19,
	xiulianjineng = 20,

	duiwu_21 = 21,
	fuben_22 = 22,
	guaji_23 = 23,
	huobanzhuzhan_24 = 24,
	fenyeqian_25 = 25,
	lianyao_26 = 26,
	linshibeibao_27 = 27,
	huoliduixian_28 = 28,
	npcshangdian_29 = 29,
	chongwushangdian_30 = 30,
	chongwucangku_31 = 31,
	renwushangjiaochongwu_32 = 32,
	renwushangjiaowupin_33 = 33,
	putongwabao_34 = 34,
	gaojiwabao_35 = 35,
	chongwujinengxuexi_36 = 36,
	chongwufangsheng_37 = 37,
	chongzhishuxing_38 = 38,
	siwangtixing_39 = 39,
	renwu_40 = 40,
	huodong_41 = 41,
	haoyou_42 = 42,
	paihangbang_43 = 43,
	liaotian_44 = 44,
	hongzhongzhouli_45 = 45,


}
--]]

return Openui
