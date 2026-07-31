
-- 禁言和解禁
local p = require "protodef.fire.pb.clan.sbannedtalk"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    local member = datamanager.getMember(self.memberid)
    if self.flag == 1 then
        -- 操作标示：1禁言  2解禁
        member.isbannedtalk = 1
    elseif self.flag == 2 then
        member.isbannedtalk = 0
    end

    -- 刷新
    if Family.getInstanceNotCreate() then
        Family.getInstanceNotCreate():ReFreshFamilyListView()
    end
    if Familychengyuandialog.getInstanceNotCreate() then
        Familychengyuandialog.getInstanceNotCreate():RefreshMemberListView()
    end
end

-- 取消申请公会
p = require "protodef.fire.pb.clan.scancelapplyclan"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.removeHasbeenApplyListEntry(self.clanid)
    -- 刷新状态
    if Familyjiarudialog.getInstanceNotCreate() then
        Familyjiarudialog.getInstanceNotCreate():RefreshApplyState()
    end
end

-- 返回申请过的公会列表
p = require "protodef.fire.pb.clan.sapplyclanlist"
function p:process()
    local len = #self.applyclanlist
    local datamanager = require "logic.faction.factiondatamanager"
    for i = 1, len do
        local entry = self.applyclanlist[i]
        datamanager.addHasbeenApplyListEntry(entry)
    end
    -- 刷新状态
    if Familyjiarudialog.getInstanceNotCreate() then
        Familyjiarudialog.getInstanceNotCreate():RefreshApplyState()
    end
end

-- 返回成员列表
p = require "protodef.fire.pb.clan.srefreshmemberlist"
function p:process()
    if self.memberlist then
        local datamanager = require "logic.faction.factiondatamanager"
        datamanager.members = { }
        for i = 1, #self.memberlist do
            local member = self.memberlist[i]
            table.insert(datamanager.members, member)
        end
    end

    -- 刷新界面
    local dlg = Familychengyuandialog.getInstanceNotCreate()
    if dlg then
        dlg:reSort()
        dlg:ResetClick1()
        dlg:RefreshTab1()
    end
end

-- 服务端响应客户端请求工会信息(有公会)
p = require "protodef.fire.pb.clan.sopenclan"
function p:process()
    if CChatOutBoxOperatelDlg.getInstanceNotCreate() then
        CChatOutBoxOperatelDlg.setGonghuiVoiceBtnVisible(1)
    end

    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.campid = self.camp
    datamanager.factionid = self.clanid
    datamanager.factionname = self.clanname
    datamanager.factionlevel = self.clanlevel
    datamanager.membersnum = self.membersnum
    datamanager.factionmaster = self.clanmaster
    datamanager.factionaim = self.clanaim
    datamanager.index = self.index
    datamanager.factioncreator = self.clancreator
    datamanager.oldfactionname = self.oldclanname
    datamanager.factioncreatorid = self.clancreatorid
    datamanager.members = { }
    datamanager.money = self.money
    datamanager.house = self.house
    datamanager.autostate = self.autostate -- 公会自动接收申请人入会的状态：0关闭 1开启
    datamanager.requestlevel = self.requestlevel -- 自动接收申请人的等级
    datamanager.costeverymoney = self.costeverymoney
    datamanager.costmax = self.costmax
    datamanager.claninstservice = self.claninstservice
    if self.memberlist then
        for i = 1, #self.memberlist do
            local member = self.memberlist[i]
            table.insert(datamanager.members, member)
        end
    end

    -- 如果当前创建对话框存在，关闭对话框
    if Familychuangjiandialog.getInstanceNotCreate() then
        Familychuangjiandialog.getInstanceNotCreate().m_IsUpdate = false
        Familychuangjiandialog.getInstanceNotCreate():DestroyDialog()
    end

    -- 如果加入公会对话框存在，关闭对话框
    if Familyjiarudialog.getInstanceNotCreate() then
        Familyjiarudialog.DestroyDialog()
    end

    -- 若是来自点击创建公会，则显示公会UI的标签
    if datamanager.m_IsOpenFamilyUI == 1 then
        Familylabelframe.getInstanceAndShow()
        datamanager.m_IsOpenFamilyUI = 0
    else
        -- 刷新公会UI
        if Family.getInstanceNotCreate() then
            datamanager.SortByLevel(-1)
            Family.getInstanceNotCreate():RefreshShow()
        end
    end

    -- 自己的公会申请被处理
    datamanager.m_HasbeenApplyList = { }
    NewRoleGuideManager.getInstance():AddToWaitingList(33100)
end

-- 服务端返回申请加入公会的人员列表
p = require "protodef.fire.pb.clan.srequestapply"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.RefreshApplyerList(self.applylist)
    local len = #FactionDataManager.m_ApplyerList
    if len == 0 then
        if datamanager.m_FactionTips then
            datamanager.m_FactionTips[1] = 0
        end
    end
    datamanager.RefreshRedPointTips()

    -- 如果成员界面存在，并且停留在申请者界面时刷新一下
    local instance = Familychengyuandialog.getInstanceNotCreate()
    if instance then
        instance.m_FactionData.m_ApplyerList = datamanager.m_ApplyerList
        if instance.m_Mode == 2 then
            instance:RefreshTab2()
        end
    end
end

-- 脱离公会成功，客户端将公会界面关闭
p = require "protodef.fire.pb.clan.sleaveclan"
function p:process()
    -- 已经脱离公会，申请最新的公会列表信息,并且将自己的信息重置

    -- 重置信息
    local datamanager = require "logic.faction.factiondatamanager"
    local data = gGetDataManager():GetMainCharacterData()

    -- 我脱离工会
    if self.memberid == data.roleid then
        if CChatOutBoxOperatelDlg.getInstanceNotCreate() then
            CChatOutBoxOperatelDlg.setGonghuiVoiceBtnVisible(0)
        if datamanager.m_FactionTips then
            datamanager.m_FactionTips[1] = 0
        end
        if datamanager.bonus then
            datamanager.bonus = 0
        end
        datamanager.RefreshRedPointTips()
        end
        datamanager:Clear()
        datamanager.m_FamilyList.m_FactionList = { }
        local p = require "protodef.fire.pb.clan.copenclanlist":new()
        p.currpage = 1
        require "manager.luaprotocolmanager".getInstance():send(p)
        print("=====================Apply Faction Data===================")
        -- 关闭公会成员UI
        if Familychengyuandialog.getInstanceNotCreate() then
            Familychengyuandialog.DestroyDialog(true)
        end
        if Family.getInstanceNotCreate() then
            Family.getInstanceNotCreate().DestroyDialog()
        end

        -- 打开加入公会UI
        Familyjiarudialog.getInstanceAndShow()

    -- 其他人脱离公会
    else
        datamanager.removeMember(self.memberid)
        -- 刷新公会信息UI
        if Family.getInstanceNotCreate() then
            Family.getInstanceNotCreate():ReFreshFamilyListView()
        end

        -- 刷新成员列表界面
        if Familychengyuandialog.getInstanceNotCreate() then
            if Familychengyuandialog.getInstanceNotCreate().m_Mode == 1 then
                Familychengyuandialog.getInstanceNotCreate():RefreshMemberListView()
            end
        end
    end

end

-- 服务端响应客户端请求公会列表（没有公会）
p = require "protodef.fire.pb.clan.sopenclanlist"
function p:process()
    -- 获得公会管理数据
    local datamanager = require "logic.faction.factiondatamanager"
    -- 判断当前页
    local temp = self.currpage - datamanager.m_FamilyList.m_Curpage
    if temp == 1 then
        datamanager.m_FamilyList.m_Curpage = self.currpage
        datamanager.AppendFamilyList(self.clanlist)
    elseif temp == 0 then
        datamanager.m_FamilyList.m_FactionList = self.clanlist
    end
    -- 刷新加入公会UI，刷新公会列表
    if Familyjiarudialog.getInstanceNotCreate() then
        Familyjiarudialog.getInstanceNotCreate().m_FactionData = datamanager
        Familyjiarudialog.getInstanceNotCreate():ReFreshFamilyListView()
    end

end

-- 驱逐成员返回
p = require "protodef.fire.pb.clan.sfiremember"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    local data = gGetDataManager():GetMainCharacterData()

    -- 我脱离公会
    if self.memberroleid == data.roleid then
        if CChatOutBoxOperatelDlg.getInstanceNotCreate() then
            CChatOutBoxOperatelDlg.setGonghuiVoiceBtnVisible(0)
        if datamanager.m_FactionTips then
            datamanager.m_FactionTips[1] = 0
        end
        if datamanager.bonus then
            datamanager.bonus = 0
        end
        datamanager.RefreshRedPointTips()
        end
        datamanager:Clear()
        datamanager.m_FamilyList.m_FactionList = { }
        local p = require "protodef.fire.pb.clan.copenclanlist":new()
        p.currpage = 1
        require "manager.luaprotocolmanager".getInstance():send(p)
        print("=====================Apply Faction Data===================")
        -- 关闭公会成员UI
        if Familychengyuandialog.getInstanceNotCreate() then
            Familychengyuandialog.DestroyDialog(true)
        end
        if Family.getInstanceNotCreate() then
            Family.getInstanceNotCreate().DestroyDialog()
        end

		--刷新公会频道信息
		local dlg = CChatOutputDialog.getInstanceNotCreate()
		if dlg and dlg.m_pMainFrame and dlg.m_pMainFrame:isVisible() then
			dlg:RefreshClanMsg()
			dlg:RefeshJoinGuideBtn(ChannelType.CHANNEL_CLAN)
		end

    -- 其他人脱离公会
    else
        datamanager.removeMember(self.memberroleid)
        -- 刷新公会信息UI
        if Family.getInstanceNotCreate() then
            Family.getInstanceNotCreate():ReFreshFamilyListView()
        end
        -- 刷新成员列表界面
        if Familychengyuandialog.getInstanceNotCreate() then
            Familychengyuandialog.getInstanceNotCreate():RefreshMemberListView()
        end
    end

end

-- 服务器回复接受申请人员
p = require "protodef.fire.pb.clan.sacceptapply"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    -- 添加到成员列表中
    datamanager.addMember(self.memberinfo)
    -- 移除申请者列表中的人
    datamanager.RemoveApplyer(self.memberinfo.roleid)
    local len = #datamanager.m_ApplyerList
    if len == 0 then
        if datamanager.m_FactionTips then
            datamanager.m_FactionTips[1] = 0
        end
    end
    datamanager.RefreshRedPointTips()

    -- 如果成员界面存在，并且停留在申请者界面时刷新一下
    local instance = Familychengyuandialog.getInstanceNotCreate()
    if instance then
        instance.m_FactionData = datamanager
        if instance.m_Mode == 2 then
            instance:RefreshTab2()
        end
    end
    -- 自己的公会申请被处理
    local data = gGetDataManager():GetMainCharacterData()
    if self.memberinfo.roleid == data.roleid then
        datamanager.m_HasbeenApplyList = { }
        -- 刷新状态
        if Familyjiarudialog.getInstanceNotCreate() then
            Familyjiarudialog.getInstanceNotCreate():RefreshApplyState()
        end
    end
end

-- 服务器返回拒绝申请人员（玩家加入其他公会的情况，将玩家从公会的申请者列表中删除）
p = require "protodef.fire.pb.clan.srefuseapply"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    local ID = self.applyroleid
    datamanager.RemoveApplyer(ID)
    local len = #datamanager.m_ApplyerList
    if len == 0 then
        if datamanager.m_FactionTips then
            datamanager.m_FactionTips[1] = 0
        end
    end
    datamanager.RefreshRedPointTips()
    -- 如果成员界面存在，并且停留在申请者界面时刷新一下
    local instance = Familychengyuandialog.getInstanceNotCreate()
    if instance then
        instance.m_FactionData.m_ApplyerList = datamanager.m_ApplyerList
        if instance.m_Mode == 2 then
            instance:RefreshTab2()
        end
    end
    -- 自己的公会申请被处理（不应该出现这样的情况！？）
    local data = gGetDataManager():GetMainCharacterData()
    if ID == data.roleid then
        datamanager.m_HasbeenApplyList = { }
        -- 刷新状态
        if Familyjiarudialog.getInstanceNotCreate() then
            Familyjiarudialog.getInstanceNotCreate():RefreshApplyState()
        end
    end
end

-- 修改公会名字回复
p = require "protodef.fire.pb.clan.schangeclanname"
function p:process()
    -- 获得缓存数据
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.oldfactionname = datamanager.factionname
    datamanager.factionname = self.newname

    -- 刷新相关UI
    if Family.getInstanceNotCreate() then
        Family.getInstanceNotCreate().m_FactionData.factionname = datamanager.factionname
        Family.getInstanceNotCreate():RefreshFamilyInfor()
    end

    -- 关闭UI
    if Familygaiming1dialog.getInstanceNotCreate() then
        Familygaiming1dialog.DestroyDialog()
    end
end

-- 搜索公会返回
p = require "protodef.fire.pb.clan.ssearchclan"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_LastSearchResult = self.clansummaryinfo
    -- 更新需要用到这个结果的UI
    if Familyjiarudialog.getInstanceNotCreate() then
        Familyjiarudialog.getInstanceNotCreate().m_FactionData.m_LastSearchResult = datamanager.m_LastSearchResult
        if datamanager.m_LastSearchResult.clanid ~= 0 then
            -- 显示进行显示单条
            local cancelInputBtn = Familyjiarudialog.getInstanceNotCreate().m_CancelInputBtn
            if cancelInputBtn then
                if cancelInputBtn:isVisible() then
                table.insert(Familyjiarudialog.getInstanceNotCreate().m_FactionData.m_FamilyList.m_FactionList, 1, datamanager.m_LastSearchResult)
                end
            else
                LogWar("recv protodef.fire.pb.clan.ssearchfaction cancelInputBtn == nil;");
            end
            datamanager.m_SearchIsNull = false
        else
            datamanager.m_SearchIsNull = true
        end
        Familyjiarudialog.getInstanceNotCreate().Searched = true
        Familyjiarudialog.getInstanceNotCreate():ReFreshFamilyListView()
    end

end

-- 服务器回复更改公会宗旨
p = require "protodef.fire.pb.clan.schangeclanaim"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.factionaim = self.newaim
    -- 刷新宗旨
    if Family.getInstanceNotCreate() then
        Family.getInstanceNotCreate().m_FactionData.factionaim = datamanager.factionaim
        Family.getInstanceNotCreate():RefreshIdeaText()
    end
end

-- 任命回复（返回职务）
p = require "protodef.fire.pb.clan.srefreshposition"
function p:process()
    -- 刷新信息
    -- 更改缓存数据
    local datamanager = require "logic.faction.factiondatamanager"
    local member = datamanager.getMember(self.roleid)
    if not member then
        return
    end
    member.position = self.position
    -- 刷新信息UI
    if Family.getInstanceNotCreate() then
        Family.getInstanceNotCreate():RefreshPosition(self.roleid, self.position)
        Family.getInstanceNotCreate():RefreshFamilyInfor()
    end
    -- 刷新成员列表界面
    if Familychengyuandialog.getInstanceNotCreate() then
        Familychengyuandialog.getInstanceNotCreate():RefreshPosition(self.roleid, self.position)
        Familychengyuandialog.getInstanceNotCreate():RefreshQunFa()
        Familychengyuandialog.getInstanceNotCreate():RefreshAutoRecvVisible()
        Familychengyuandialog.getInstanceNotCreate():RefreshYaoQingVisible() -- 刷新“公会邀请”是否显示
    end
end

-- 公会邀请
p = require "protodef.fire.pb.clan.sclaninvitation"
-- 邀请
function p:process()
    -- 主线任务CG插画时不能弹出公会邀请栏
    if require("logic.npc.npcscenespeakdialog").getInstanceNotCreate() then
        return
    end

    local function nofactioninvitation(self, args)
        local hostroleid = gGetMessageManager():GetUserID()
        local send = require "protodef.fire.pb.clan.cacceptorrefuseinvitation":new()
        send.hostroleid = hostroleid
        send.accept = 0
        require "manager.luaprotocolmanager":send(send)

        if CEGUI.toWindowEventArgs(args).handled ~= 1 then
            gGetMessageManager():CloseCurrentShowMessageBox()
        end
    end

    local function acceptfactioninvitation(self, args)
        local hostroleid = gGetMessageManager():GetUserID()
        local send = require "protodef.fire.pb.clan.cacceptorrefuseinvitation":new()
        send.hostroleid = hostroleid
        send.accept = 1
        require "manager.luaprotocolmanager":send(send)

        gGetMessageManager():CloseCurrentShowMessageBox()
    end


    local formatstr = GameTable.message.GetCMessageTipTableInstance():getRecorder(145034).msg
    local sb = require "utils.stringbuilder":new()
    sb:Set("parameter1", self.hostrolename)
    sb:Set("parameter2", self.clannname)
    sb:SetNum("parameter3", self.clanlevel)

    local msg = sb:GetString(formatstr)
    gGetMessageManager():AddMessageBox("", msg, acceptfactioninvitation, self, nofactioninvitation, self, eMsgType_Normal, 30000, self.hostroleid, 0, nil, MHSD_UTILS.get_msgtipstring(160144), MHSD_UTILS.get_msgtipstring(160145))

    sb:delete()
end

-- 服务端返回公会宗旨
p = require "protodef.fire.pb.clan.sclanaim"
function p:process()
    if Familyjiarudialog.getInstanceNotCreate() then
        Familyjiarudialog.getInstanceNotCreate():RefreshZongZhi(self.clanaim)
        Familyjiarudialog.getInstanceNotCreate():RefreshOldName(self.oldclanname)
    end
end

-- 查询分红结果
p = require "protodef.fire.pb.clan.sbonusquery"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.bonus = self.bonus
    if Familyfulidialog.getInstanceNotCreate() then
        Familyfulidialog.getInstanceNotCreate():RefreshFenHongText()
    end
    datamanager.RefreshRedPointTips()
end

-- 公会升级
local sclanlevelup = require "protodef.fire.pb.clan.sclanlevelup"
function sclanlevelup:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.costmax = self.costmax
    if self.change[1] then
        datamanager.factionlevel = self.change[1]
    end
    if self.change[2] then
        datamanager.house[2] = self.change[2]
    end
    if self.change[3] then
        datamanager.house[3] = self.change[3]
    end
    if self.change[4] then
        datamanager.house[4] = self.change[4]
    end
    datamanager.money = self.money

    if familybuilddialog.getInstanceNotCreate() then
        familybuilddialog.getInstanceNotCreate():processRefreshData()
    end
end

-- 返回是否开启自动接收入会
local p = require "protodef.fire.pb.clan.sopenautojoinclan"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.autostate = self.autostate -- 公会自动接收申请人入会的状态：0关闭 1开启
    datamanager.requestlevel = self.requestlevel -- 自动接收申请人的等级
    if Familychengyuandialog.getInstanceNotCreate() then
        Familychengyuandialog.getInstanceNotCreate():RefreshAutoRecvState()
    end
end

-- 请求公会事件信息的返回
p = require "protodef.fire.pb.clan.srequesteventinfo"
function p:process()
    -- 刷新缓存
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_FamilyEventList = { }
    datamanager.m_FamilyEventList = self.eventlist
    if Familychengyuandialog.getInstanceNotCreate() then
        -- 当前停留在事件界面刷新下
        if Familychengyuandialog.getInstanceNotCreate().m_Mode == 3 then
            Familychengyuandialog.getInstanceNotCreate():RefreshTab3()
        end
    end
end

-- 请求会员信息的返回
p = require "protodef.fire.pb.clan.srequestroleinfo"
function p:process()
    if not self.roleinfo then
        return
    end
    local roleID = self.roleinfo.roleid;
    gGetFriendsManager():SetContactRole(roleID, true)
end

-- 请求药房信息的返回
p = require "protodef.fire.pb.clan.sopenclanmedic"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_FamilyYaoFangList = self.medicitemlist
    datamanager.m_FamilyChanYaoMode = self.selecttype
    datamanager.m_CurDayHasBuyNumber = self.buyitemnum
    -- 刷新药房
    if Familyyaofang.getInstanceNotCreate() then
        Familyyaofang.getInstanceNotCreate().m_FactionData = datamanager
        -- 刷新列表
        Familyyaofang.getInstanceNotCreate():RefreshInfor()
        Familyyaofang.getInstanceNotCreate():ReFreshFamilyYaoFangListView()
        Familyyaofang.getInstanceNotCreate():RefreshCheckBoxChecked()
    end
end

-- 购买药房的药品的返回
p = require "protodef.fire.pb.clan.sbuymedic"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    local temp = datamanager.getYaoFangEntry(self.itemid)
    if temp then
        temp.itemnum = self.itemnum
        datamanager.m_CurDayHasBuyNumber = self.buyitemnum
        -- 刷新界面
        if Familyyaofang.getInstanceNotCreate() then
            Familyyaofang.getInstanceNotCreate():ReFreshFamilyYaoFangListView()
        end
    end

end

-- 选择产药倍数的返回
p = require "protodef.fire.pb.clan.srequestselecttype"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_FamilyChanYaoMode = self.selecttype
    -- 刷新界面
    if Familyyaofang.getInstanceNotCreate() then
        Familyyaofang.getInstanceNotCreate():ResetCheckBox()
        Familyyaofang.getInstanceNotCreate():RefreshCheckBoxChecked()
    end
end

-- 请求符文信息的返回
p = require "protodef.fire.pb.clan.srequestruneinfo"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_RuneQuestList = { }
    local data = gGetDataManager():GetMainCharacterData()
    for k, v in pairs(self.runeinfolist) do
        if v.actiontype == 0 then
            if datamanager.IsPassFuwenShow(v.itemid) or(v.roleid == data.roleid) then
                table.insert(datamanager.m_RuneQuestList, 1, v)
            end
        else
            table.insert(datamanager.m_RuneQuestList, 1, v)
        end
    end
    datamanager.m_DaFuTimes = self.requestnum
    datamanager.m_XiaoHaoHuoLi = self.useenergy
    -- 刷新界面
    -- 保存当前缓存数据并且刷新界面
    if Familyfuwendialog.getInstanceNotCreate() then
        Familyfuwendialog.getInstanceNotCreate().m_FactionData = datamanager
        Familyfuwendialog.getInstanceNotCreate():RefreshTab1()
    end
end

-- 请求符文界面的返回
p = require "protodef.fire.pb.clan.srunerequestview"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_HasBeenRuneQuestList = self.runerequestinfolist
    datamanager.m_DaFuTimes = self.requestnum
    local dlg = Familyfuwendialog.getInstanceNotCreate()
    if dlg then
        dlg:RefreshTab2()
    end
end

-- 请求符文的返回
p = require "protodef.fire.pb.clan.srunerequest"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_DaFuTimes = self.requestnum
    datamanager.m_HasBeenRuneQuestList = self.runerequestinfolist
    local dlg = Familyfuwendialog.getInstanceNotCreate()
    if dlg then
        dlg.SelectIDCollection = { }
        dlg:ResetSelectBox()
        dlg:RefreshTab2()
    end
end

-- 请求符文统计的返回
p = require "protodef.fire.pb.clan.srequestrunecount"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_FuwenTongjiList = self.runecountinfolist
    datamanager.FuWenTongJiSort()
    local dlg = Familyfuwendialog.getInstanceNotCreate()
    if dlg then
        dlg:RefreshTab3()
    end
end

-- 捐献符文的返回（刷新活力值）
p = require "protodef.fire.pb.clan.srunegive"
function p:process()

    local dlg = Familyfuwendialog.getInstanceNotCreate()
    if dlg then
        dlg:RefreshHuoLi()
    end
end

-- 通知客户端红点信息
p = require "protodef.fire.pb.clan.sclanredtip"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_FactionTips = self.redtips
    datamanager.RefreshRedPointTips()
end

-- 服务器返回该玩家是否有公会（新手）
p = require "protodef.fire.pb.clan.srefreshroleclan"
function p:process()
    if self.clankey > 0 then
        NewRoleGuideManager.getInstance():AddToWaitingList(33100)
    end

    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.factionid = self.clankey
    datamanager.factionname = self.clanname

    local dlg =  require "logic.characterinfo.characterprodlg".getInstanceNotCreate()
    if dlg then
        dlg:UpdateFactionAndSchool()
    end

	--2016.8.3 yangbin 进入游戏后刷新是否有公会的状态，显示公会语音按钮（之前一直没事儿，不知道谁改协议了）
	if datamanager.factionid ~= nil and datamanager.factionid > 0 then
		CChatOutBoxOperatelDlg.setGonghuiVoiceBtnVisible(1)
	end
	
end

-- 更新帮贡信息
local srefreshcontribution = require "protodef.fire.pb.clan.srefreshcontribution"
function srefreshcontribution:process()
    if not gGetDataManager() then
        return
    end
    gGetDataManager():setContribution(self.currentcontribution);
end

-- 领取分红回复
p = require "protodef.fire.pb.clan.sgrabbonus"
function p:process()
    -- 代表已经领取成功，不用处理
end

-- 服务器返回邀请列表
p = require "protodef.fire.pb.clan.sclaninvitationview"
function p:process()
    require("logic.family.familyyaoqingcommon").RefreshYaoQingList(self.invitationroleinfolist)
end

-- 服务器返回邀请的搜索列表
p = require "protodef.fire.pb.clan.srequestsearchrole"
function p:process()
    require("logic.family.familyyaoqingcommon").RefreshYaoQing(self.invitationroleinfolist)
end

-- 改变公会副本成功
p = require "protodef.fire.pb.clan.schangeclaninst"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.setFubenInfo(self.claninstservice)
    require("logic.family.familyfuben").DestroyDialog()
end

-- 会长弹劾返回
p = require "protodef.fire.pb.clan.srequestimpeachmentview"
function p:process()
    -- 保存弹劾数据
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_impeach.state = self.impeachstate
    datamanager.m_impeach.maxnum = self.maxnum
    datamanager.m_impeach.name = self.impeachname
    datamanager.m_impeach.time = self.impeachtime
    datamanager.m_impeach.curnum = self.curnum

    local faqidlg = require("logic.family.familyfaqitanhedialog")
    local xiangyingdlg = require("logic.family.familyxiangyingtanhedialog")

    if datamanager.m_impeach.state == 0 then
        if faqidlg.getInstanceNotCreate() then
            faqidlg.getInstanceNotCreate():refreshUI()
        else
            if datamanager.m_bClickToShowImpeachUI then
                faqidlg.getInstanceAndShow()
            end
        end
        
        if xiangyingdlg.getInstanceNotCreate() then
            xiangyingdlg.DestroyDialog()
        end
    else
        local bShowFaqiDlg = false
        if faqidlg.getInstanceNotCreate() then
            bShowFaqiDlg = true
            faqidlg.DestroyDialog()
        end
        
        if xiangyingdlg.getInstanceNotCreate() then
            xiangyingdlg.getInstanceNotCreate():refreshUI()
        else
            if datamanager.m_bClickToShowImpeachUI or bShowFaqiDlg then
                xiangyingdlg.getInstanceAndShow()
            end
        end
    end
    datamanager.m_bClickToShowImpeachUI = false
end

--获取对战双方信息
p = require "protodef.fire.pb.clan.fight.srequestroleisenemy"
function p:process()
    local datamanager = require "logic.family.familyfightmanager"
    datamanager:UpdateUserList(self.rolelist)
end

--获取对战的积分排名详细信息
p = require "protodef.fire.pb.clan.fight.sbattlefieldranklist"
function p:process()
    local score1 = self.clanscore1
    local score2 = self.clanscroe2
    local myrank = self.myrank
    local myscore = self.myscore
    local list1 = self.ranklist1
    local list2 = self.ranklist2
    require ("logic.family.familyfightxianshi").getInstance():UpdateFightInfo(score1,score2,myrank,myscore,list1,list2)
end

--获取对战的积分排名信息
p = require "protodef.fire.pb.clan.fight.sbattlefieldscore"
function p:process()
    local score1 = self.clanscore1
    local score2 = self.clanscroe2
    local myrank = self.myrank
    local myscore = self.myscore
    require ("logic.family.familyfightxianshi").getInstance():UpdateMyScoreAndRank(score1,score2,myrank,myscore)
end

--获取行动力
p = require"protodef.fire.pb.clan.fight.sbattlefieldact"
function p:process()
    local act = self.roleact
    local datamanager = require "logic.family.familyfightmanager"
    if datamanager then
        datamanager:SetXingDongli(act)
    end
end

--帮战结束
p = require"protodef.fire.pb.clan.fight.sclanfightover"
function p:process()
    local status = self.status
    local timestamp = self.overtimestamp
    require ("logic.family.familyfightxianshi").getInstance():SetLeftTimeAndStatus(status,timestamp)
end

--公会战时信息
p =  require"protodef.fire.pb.clan.fight.sbattlefieldinfo"
function p:process()
    local name1 = self.clanname1
    local name2 = self.clanname2
    local clanid1 = self.clanid1
    local clanid2 = self.clanid2
    --if  GetIsInFamilyFight() then
        require ("logic.family.familyfightxianshi").getInstance():UpdateBattleInfo(name1,name2,clanid1,clanid2)
    --end
end

--离开公会战战场
p =  require"protodef.fire.pb.clan.fight.sleavebattlefield"
function p:process()
    local datamanager = require "logic.family.familyfightmanager"
    if datamanager then
        datamanager:ResetData()
    end
end

p =  require("protodef.fire.pb.clan.fight.sgetclanfightlist")
function p:process()
    local datalist = self.clanfightlist
    local curweek = self.curweek
    local isover = self.over
    require ("logic.family.familyfightrank").getInstance():RefreshFamilyFightList(datalist,curweek,isover)
end


p =  require("protodef.fire.pb.clan.fight.sgetcleartime")
function p:process()
    local pCleartime = self.cleartime
	 local dlg = require("logic.family.familyfightrank").getInstanceNotCreate()
    if dlg then
        dlg:RefreshFamilyRankClearTime( pCleartime )
    end
end