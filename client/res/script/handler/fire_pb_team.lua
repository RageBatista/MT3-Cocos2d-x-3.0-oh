local sformationsmap = require "protodef.fire.pb.team.sformationsmap"
function sformationsmap:process()
    LogInsane("sformationsmap process")
    local manager = FormationManager.getInstance()
    manager:updateFormations(self.formationmap)
end

local ssetmyformation = require "protodef.fire.pb.team.ssetmyformation"
function ssetmyformation:process()
    LogInsane("ssetmyformation process")
    local manager = FormationManager.getInstance()
    manager:setMyFormation(self.formation, self.entersend)
end

local ssetteamformation = require "protodef.fire.pb.team.ssetteamformation"
function ssetteamformation:process()
    LogInsane("ssetteamformation process")
    local manager = FormationManager.getInstance()
    manager:setTeamFormation(self.formation, self.formationlevel, self.msg)
end

local sonekeyteammatch = require("protodef.fire.pb.team.sonekeyteammatch")
function sonekeyteammatch:process()
    -- 一键喊话成功
    if self.ret == 0 then
        if TeamHanHuaEdit then
            TeamHanHuaEdit.ToggleOpenClose()
        end
    end

    if GetTeamManager() then
        TeamManager.chatTimestamp = os.time()
    end
end

local p = require("protodef.fire.pb.team.srequestmatchinfo")
function p:process()
    local dlg = require("logic.team.teammatchdlg").getInstanceNotCreate()
    if dlg then
        dlg:recvMatchingCountInfo(self.teammatchnum, self.playermatchnum)
    end
end

-- 启动ROLL点消息
local p = require "protodef.fire.pb.team.teammelon.steamrollmelon"
function p:process()
    for i, v in pairs(self.melonlist) do
        local itemInfo = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(v.itemid)
        if itemInfo then
            local nItemType = itemInfo.itemtypeid
            local nFirstType = require "utils.mhsdutils".GetItemFirstType(nItemType)

            if nFirstType == eItemType_EQUIP then
                GetChatManager():AddObjTips(0, 0, v.itemid, v.melonid, 0, v.itemdata) 
            end
        end
    end
    TeamRollMelondDialog.SetRollInfoList(self.melonlist)
    if self.watcher == 0 then
        TeamRollMelondDialog.getInstanceAndShow()
        TeamRollMelondDialog.getInstance():onSTeamRollMelon(self.melonlist)
    end
end

local m = require("protodef.fire.pb.team.teammelon.soneteamrollmeloninfo")
function m:process()
    local xuqiuText = "<T c=\"ffffff00\" t=\"" .. BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11138).msg .. "\"></T>"
    local huodeText = "<T c=\"ffff0000\" t=\"" .. BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11140).msg .. "\"></T>"
    local touzhiText = "<T c=\"FF693F00\" t=\"" .. BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11136).msg .. "\"></T>"
    local dianText = "<T c=\"FF693F00\" t=\"" .. BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11139).msg .. "\"></T>"
    local fangqiText = "<T t=\"" .. BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11137).msg .. "\"></T>"

    local m_melonid = self.melonid
    local m_roleid = self.rollinfo.roleid
    local m_roll = self.rollinfo.roll
    local m_itemid = self.itemid

    local itemInfo = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(m_itemid)
    -- 写道具名字
    local winMgr = CEGUI.WindowManager:getSingleton()

    local title = "<P t=\"[" .. itemInfo.name .. "]\" roleid=\"0\" type=\"11\" key=\"0\" baseid=\"" .. m_itemid .. "\" shopid=\"" .. m_melonid .. "\" counter=\"1\" bind=\"0\" loseefftime=\"0\" TextColor=\"" .. itemInfo.colour .. "\"></P>"

    local text = ""

    local nameText = "<T c=\"ff00c6ff\" t=\"" .. self.rollinfo.rolename .. "\"></T>"
    if m_roll == 0 then
        text = nameText .. fangqiText .. title
    else
        text = nameText .. xuqiuText .. title .. touzhiText .. "<T c=\"ff00ff00\" t=\"" .. tostring(m_roll) .. "\"></T>" .. dianText
    end

    local ids = BeanConfigManager.getInstance():GetTableByName("chat.cchatcolorconfig"):getAllID()
    for j=1, #ids do
        local colorConfig = BeanConfigManager.getInstance():GetTableByName("chat.cchatcolorconfig"):getRecorder(ids[j])
        local color = colorConfig.color
        local toReplace = colorConfig.notifylist[12]
        if toReplace ~= "0" then
            local strTable = StringBuilder.Split(toReplace, ",")
            local doubleColor = false
            if require "utils.tableutil".tablelength(strTable) == 2 then 
                doubleColor = true
            end
                        
            local pos = string.find(text, "c=\""..color) 

            if pos == nil then
                pos = string.find(text, "c=\'"..color) 
            end

            if pos == nil then
                pos = string.find(text, "TextColor=\""..color)
            end

            if pos ~= nil then
                if doubleColor then
                    if string.len(strTable[1]) > 1 then
                        text = string.gsub(text, "(c=['\"])"..color.."['\"]", "%1"..strTable[1].."\" ob=\""..color.."\"")
                        text = string.gsub(text, "(TextColor=['\"])"..color.."['\"]", "%1"..strTable[1].."\" ob=\""..color.."\"")
                    end
                else
                        text = string.gsub(text, "(c=['\"])"..color.."['\"]", "%1"..toReplace.."\" ob=\""..color.."\"")
                        text = string.gsub(text, "(TextColor=['\"])"..color.."['\"]", "%1"..toReplace.."\" ob=\""..color.."\"")
                end
            end

        end
    end

    if GetChatManager() then
        GetChatManager():AddMsg_Team(0, 0, 0, 0, "", text, true) 
    end
end



-- 返回是否有队伍
local p = require "protodef.fire.pb.team.srequesthaveteam"
function p:process()
    Familycaidan.DestroyDialog()
    if Familychengyuandialog.getInstanceNotCreate() then
        if Familychengyuandialog.getInstanceNotCreate().SingleMember then
            -- 菜单
            local wnd = Familycaidan.getInstanceAndShow(Familychengyuandialog.getInstanceNotCreate().SingleMember)
            wnd.m_TeamState = self.ret
            wnd:RefreshShow()
            wnd:RefreshPosition(self, 450, 120, 0)
        end
    end

    if Family.getInstanceNotCreate() then
        if Family.getInstanceNotCreate().SingleMember then
            -- 菜单
            local wnd = Familycaidan.getInstanceAndShow(Family.getInstanceNotCreate().SingleMember)
            wnd.m_TeamState = self.ret
            wnd:RefreshShow()
            wnd:RefreshPosition(self, 450, 120, 0)
        end
    end
end

local sstopteammatch = require "protodef.fire.pb.team.sstopteammatch"
function sstopteammatch:process()
    if not GetTeamManager() then
        return
    end
    GetTeamManager():recvStopTeamMatch()
end

local sforceinvitejointteam = require "protodef.fire.pb.team.sforceinvitejointteam"
function sforceinvitejointteam:process()
    if not GetTeamManager() then
        return
    end
    GetTeamManager():ForceRequestInviteToMyTeam(self.roleid)
end


local srequestteammatch = require "protodef.fire.pb.team.srequestteammatch"
function srequestteammatch:process()
    if not GetTeamManager() then
        return
    end
    GetTeamManager():SetTeamMatchInfo(self.targetid, self.levelmin, self.levelmax)
	if self.typematch == 0 or self.typematch == 1 then
		GetTeamManager():StartTeamMatch()
	end
    
end

local steamerror = require "protodef.fire.pb.team.steamerror"
function steamerror:process()
    if not GetTeamManager() then
        return
    end
    GetTeamManager():ShowErrorInfo(self.teamerror)
end

local saskforcallback = require "protodef.fire.pb.team.saskforcallback"
function saskforcallback:process()
    if not GetTeamManager() then
        return
    end
    GetTeamManager():AskIfAcceptBeCallback(self.leaderid)
end

local sswapmember = require "protodef.fire.pb.team.sswapmember"
function sswapmember:process()
    if not GetTeamManager() then
        return
    end
    GetTeamManager():SwapMember(self.index1+1, self.index2+1)
end

local ssetteamleader = require "protodef.fire.pb.team.ssetteamleader"
function ssetteamleader:process()
    if not GetTeamManager() then
        return
    end
    GetTeamManager():SetTeamLeader(self.roleid)

    if not GetTeamManager():IsMyselfLeader() and GetChatManager() then
        local member = GetTeamManager():GetTeamMemberByID(self.roleid)
        if member then
            GetChatManager():AddTipsMsg(162137, 0, {member.strName}, false) --$parameter1$成为队长
        end
    end
end

local sremoveteammember = require "protodef.fire.pb.team.sremoveteammember"
function sremoveteammember:process()
    if not GetTeamManager() then
        return
    end
    for k,llValue in pairs(self.memberids) do
        GetTeamManager():RemoveTeamMember(llValue)
    end
end

local sremoveteamapply = require "protodef.fire.pb.team.sremoveteamapply"
function sremoveteamapply:process()
    if not GetTeamManager() then
        return
    end
    for k,llValue in pairs(self.applyids) do
        GetTeamManager():RemoveApplicant(llValue)
    end
end

local sdismissteam = require "protodef.fire.pb.team.sdismissteam"
function sdismissteam:process()
    if not GetTeamManager() then
        return
    end
   GetTeamManager():DismissTeam()
end

local screateteam = require "protodef.fire.pb.team.screateteam"
function screateteam:process()
    if not GetTeamManager() then
        return
    end
   	GetTeamManager():CreateTeam(self.teamid,self.teamstate,self.smapid,self.formation)
end

local supdatememberposition = require "protodef.fire.pb.team.supdatememberposition"
function supdatememberposition:process()
    if not GetTeamManager() then
        return
    end
   	GetTeamManager():UpdateMemberPosition(self.roleid,Nuclear.NuclearPoint(self.position.x,self.position.y),self.sceneid)

end

local srespondinvite = require "protodef.fire.pb.team.srespondinvite"
function srespondinvite:process()
    if not GetTeamManager() then
        return
    end
    GetTeamManager():RemoveWhenInviterJoin(self.roleid)

end

local sabsentreturnteam = require "protodef.fire.pb.team.sabsentreturnteam"
function sabsentreturnteam:process()
    if not GetTeamManager() then
        return
    end
    if self.ret == 1 then
		GetTeamManager():DoAbsentReturnTeam()
	end

end

local sinvitejoinsucc = require "protodef.fire.pb.team.sinvitejoinsucc"
function sinvitejoinsucc:process()
    if not GetTeamManager() then
        return
    end
    GetTeamManager():AddAlreadyInviterInfo(self.roleid)

end

local supdatememberstate = require "protodef.fire.pb.team.supdatememberstate"
function supdatememberstate:process()
    if not GetTeamManager() then
        return
    end
    GetTeamManager():UpdateMemberState(self.roleid,self.state)
end

local supdatememberlevel = require "protodef.fire.pb.team.supdatememberlevel"
function supdatememberlevel:process()
    if not GetTeamManager() then
        return
    end
    GetTeamManager():UpdateMemberLevel(self.roleid,self.level)
end

local supdatememberhpmp = require "protodef.fire.pb.team.supdatememberhpmp"
function supdatememberhpmp:process()
    if not GetTeamManager() then
        return
    end
    GetTeamManager():UpdateMemberHpMp(self.roleid,self.hp,self.mp)
end

local supdatemembermaxhpmp = require "protodef.fire.pb.team.supdatemembermaxhpmp"
function supdatemembermaxhpmp:process()
    if not GetTeamManager() then
        return
    end
    GetTeamManager():UpdateMemberMaxHpMp(self.roleid,self.maxhp,self.maxmp)
end


local sinvitejointeam = require "protodef.fire.pb.team.sinvitejointeam"
function sinvitejointeam:process()
     if not GetTeamManager() then
        return
    end

	--// 0是正常 1是强制邀请 2是队员邀请
	if self.op== 0 then--//其他队的队长发出的入队请求
		GetTeamManager():AskIfAcceptJoinTeam(self.invitername, self.inviterlevel)
	elseif self.op==1 then--//强制接受的入队邀请，出现在自动匹配的时候
		if (GetTeamManager():IsOnTeam()==false) then
            local p = require("protodef.fire.pb.team.crespondinvite"):new()
            p.agree = 1
            LuaProtocolManager:send(p)
		end
	elseif self.op==2 then	--//其他队的队员发出的邀请，点确定后需要向对方队长提出申请
		GetTeamManager():AskIfAcceptJoinTeam(self.invitername, self.inviterlevel, self.leaderroleid)	
	end
end

p = require "protodef.fire.pb.team.saskforsetleader"
function p:process()
	local p = require("protodef.fire.pb.team.canswerforsetleader"):new()
	p.agree = 1
	LuaProtocolManager:send(p)
end
--申请队长 
p = require "protodef.fire.pb.team.saskforgetleader"
function p:process()
    require "manager.teammanager":AskIfAcceptToMarry(self.leaderid)

end

-- 点击组队目标后，返回一键喊话队伍信息
p = require "protodef.fire.pb.team.sonekeyapplyteaminfo"
function p:process()
    -- 打开队伍信息界面
    local dlg = require("logic.team.showteaminfobyclicklink").getInstanceAndShow()
    dlg:RefreshUI(self.memberlist)
end

p = require "protodef.fire.pb.team.srequestteammatchlist"
function p:process()
    if self.ret ~= 0 then --0正确1目标错误2数量错误3其他未知错误
        print("srequestteammatchlist ret error: " .. self.ret)
        return
    end

    local dlg = require("logic.team.teammatchdlg").getInstanceNotCreate()
    if dlg then
        dlg:recvTeamMatchList(self)
    end
end

p = require "protodef.fire.pb.team.supdateteammembercomponent"
function p:process()
    if not GetTeamManager() then
		return
	end
	local pMember = GetTeamManager():GetTeamMemberByID(self.memberid)
	if pMember then
		--这里的components是全刷的，而不是刷改变量
		pMember.components = self.components

        NotificationCenter.postNotification(Notifi_TeamMemberComponentChange, self.memberid)
        NotificationCenter.postNotification(Notifi_TeamMemberDataRefresh)
	end
end


--刷新队伍成员数据
p = require "protodef.fire.pb.team.supdateteammemberbasic"
function p:process()
	if not GetTeamManager() then
		return
	end
	local pMember = GetTeamManager():GetTeamMemberByID(self.data.roleid)
	if pMember then
        local oldComponent = pMember.components
        pMember:setData(self.data)

        for k,v in pairs(self.data.components) do
            if oldComponent[k] then  --如果该部件原来就有
                if v == 0 then  --如果现在是0，则删除
                    oldComponent[k] = nil
                else  --否则是替换
                    oldComponent[k] = v
                end
            elseif v ~= 0 then  --如果该部件原来没有，并且新部件不为0，则添加
                oldComponent[k] = v
            end
        end
        
        pMember.components = oldComponent

        NotificationCenter.postNotification(Notifi_TeamMemberDataRefresh, self.data.roleid)
		GetTeamManager():UpdateMemberSpeed()
	end
end


--添加队伍申请者
p = require "protodef.fire.pb.team.saddteamapply"
function p:process()
	if not GetTeamManager() then
		return
	end

    for _,v in pairs(self.applylist) do
        GetTeamManager():AddApplicant(v)
    end
end

--添加队员
p = require "protodef.fire.pb.team.saddteammember"
function p:process()
	if not GetTeamManager() then
		return
	end

	local willshowtip = GetTeamManager():IsOnTeam()

    for _,v in pairs(self.memberlist) do
        GetTeamManager():AddTeamMember(v)
        local pChar = gGetScene():FindCharacterByID(v.roleid);
        if pChar then
            pChar:SetVisible(true)
        end
        if willshowtip then
			if GetChatManager() then
				GetChatManager():AddTipsMsg(141196, 0, {v.rolename}) --xxx加入队伍
			end
		end
    end

    GetTeamManager():PostTeamListChanged()
    Renwulistdialog.tryShowTeamPane()
end

--更新队伍顺序
p = require "protodef.fire.pb.team.smembersequence"
function p:process()
	if not GetTeamManager() then
		return
	end
	GetTeamManager():SetTeamSequence(self.teammemeberlist)
end
local p = require "protodef.fire.pb.huoban.sactivehuoban"
function p:process()
    MT3HeroManager.getInstance():unlockHero(self.huobanid, self.state)
    MT3HeroManager.getInstance():sort() 
    -- 刷新其他界面
    if huobanzhuzhaninfo.getInstanceNotCreate() then
        huobanzhuzhaninfo.getInstanceNotCreate():refreshUI()
    end

    if HuoBanZhuZhanDialog.getInstanceNotCreate() then
        local selectGroupId = HuoBanZhuZhanDialog.getInstance().m_SelectGroup
        local selectGroupPos = HuoBanZhuZhanDialog.getInstance().mSelectGroupPos
        local filter = HuoBanZhuZhanDialog.getInstance().mState_filter
        HuoBanZhuZhanDialog.getInstance():refreshUI(selectGroupId, selectGroupPos, filter)
    end
    -- 解锁成功后 自动关闭此UI
    local msg = MHSD_UTILS.get_msgtipstring(141073)
    GetCTipsManager():AddMessageTip(msg)
    huobanzhuzhanjiesuo.getInstance().DestroyDialog()
end



-- 返回公会战队伍数量和未组队玩家数
p = require "protodef.fire.pb.team.srequestclanfightteamrolenum"
function p:process()
	local dlg = require("logic.family.familyduizhanzudui").getInstanceNotCreate()
    if dlg then
        dlg:SetTeamNumAndNoTeamMemberNum(self.teamnum,self.rolenum)
    end
end

-- 返回公会战队伍列表
p = require "protodef.fire.pb.team.srequestclanfightteamlist"
function p:process()
    if self.ret ~= 0 then --0正确1目标错误2数量错误3其他未知错误
        print("protodef.fire.pb.team.srequestclanfightteamlist  ret error: " .. self.ret)
    end
	local list = self.teamlist
    local dlg = require("logic.family.familyduizhanzudui").getInstanceNotCreate()
    if dlg then
        dlg:RefreshTeamList( self.ret, list, self.isfresh )
    end
end

-- 返回公会战未组队玩家列表
p = require "protodef.fire.pb.team.srequestclanfightrolelist"
function p:process()
    if self.ret ~= 0 then --0正确1错误
        print("protodef.fire.pb.team.srequestclanfightrolelist  ret error: " .. self.ret)
    end
    local list = self.rolelist
    local dlg = require("logic.family.familyduizhanzudui").getInstanceNotCreate()
    if dlg then
        dlg:UpdateNoTeamMemberList( self.ret, list, self.isfresh)
    end
end
