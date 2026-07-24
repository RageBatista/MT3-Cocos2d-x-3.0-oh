package fire.pb.team;

import fire.msp.team.GNotifyTeamChange;
import fire.msp.team.TeamChangeType;
import fire.pb.GsClient;
import fire.pb.PropRole;
import fire.pb.StateCommon;
import fire.pb.battle.battleflag.SSetCommander;
import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffConstant;
import fire.pb.buff.BuffRoleImpl;
import fire.pb.main.ConfigManager;
import fire.pb.map.MapConfig;
import fire.pb.map.Role;
import fire.pb.map.RoleManager;
import fire.pb.pet.PShowPetOffProc;
import fire.pb.scene.Scene;
import fire.pb.talk.ChatChannel;
import fire.pb.talk.DisplayInfo;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import mkdb.Procedure;
import xdb.Transaction;
import xbean.Pod;
import xbean.Properties;
import xbean.TeamFilter;
import xbean.TeamInfo;
import xbean.TeamMember;
import xtable.Roleid2battleid;
import xtable.Roleid2teamid;
import xtable.Roleonoffstate;
import xtable.Teamfilters;
import xtable.Teaminvite;

public class Team {
    private TeamInfo teamInfo;
    private boolean readonly;
    public final long teamId;
    public static final int MAX_RETURN_SCALE_LENGTH = 480;
    public static final int MAX_RETURN_SCALE_SQUARE = 230400;
    public static int TEAM_VOLUME = 5;

	/**
	 * 构造函数。
	 * 
	 * @lock团队锁
	 * @param teamId
	 */
    Team(long teamId) {
        this(teamId, false);
    }

	/**
	 * 构造函数。
	 * 
	 * @lock readonly=true 无锁；reandonly=false锁teamlock
	 * @param teamId
	 * @参数只读
	 *            如果为true,那么只能读数据，不能修改数据
	 */
    Team(long teamId, boolean readonly) {
        this.teamId = teamId;
        this.readonly = readonly;
        if (readonly) {
            this.teamInfo = xtable.Team.select(teamId);
        } else {
            this.teamInfo = xtable.Team.get(teamId);
        }

        if (this.teamInfo == null) {
            throw new IllegalArgumentException("错误的teamId：" + teamId);
        } else {
            if (this.teamInfo.getCommanderroleid() == 0L) {
                this.teamInfo.setCommanderroleid(this.teamInfo.getTeamleaderid());
            }

        }
    }

    public Team(long teamId, TeamInfo teamInfo, boolean readonly) {
        this.teamId = teamId;
        this.teamInfo = teamInfo;
        this.readonly = readonly;
        if (teamInfo.getCommanderroleid() == 0L) {
            teamInfo.setCommanderroleid(teamInfo.getTeamleaderid());
        }

    }

    public void SetCommanderRoleId(long roleid) {
        if (this.isInTeam(roleid)) {
            if (roleid != this.teamInfo.getCommanderroleid()) {
                Properties commanderprop = xtable.Properties.select(roleid);
                if (commanderprop != null) {
                    List<String> params = new ArrayList<>();
                    params.add(commanderprop.getRolename());
                    MessageMgr.sendMsgNotify(this.teamInfo.getTeamleaderid(), 180044, null);
                    if (this.teamInfo.getCommanderroleid() != this.teamInfo.getTeamleaderid()) {
                        MessageMgr.sendMsgNotify(this.teamInfo.getCommanderroleid(), 180045, null);
                    }

                    this.teamInfo.setCommanderroleid(roleid);
                    SSetCommander send = new SSetCommander(roleid);
                    Procedure.psend(this.teamInfo.getTeamleaderid(), send);
                    if (roleid == this.teamInfo.getTeamleaderid()) {
                        MessageMgr.sendMsgNotify(this.teamInfo.getTeamleaderid(), 180042, null);
                    } else {
                        MessageMgr.sendMsgNotify(this.teamInfo.getTeamleaderid(), 180043, params);
                    }

                    String msg1 = "您已经被队长委任成指挥";
                    String msg2 = "成功委任" + commanderprop.getRolename() + "为指挥";
                    ArrayList<DisplayInfo> showinfos = new ArrayList<>();

                    for(TeamMember member : this.teamInfo.getMembers()) {
                        Procedure.psend(member.getRoleid(), send);
                        if (roleid == member.getRoleid()) {
                            MessageMgr.sendMsgNotify(member.getRoleid(), 180042, null);
                            ChatChannel.getInstance().process(member.getRoleid(), 2, msg1, "指挥", showinfos, 0);
                        } else {
                            MessageMgr.sendMsgNotify(member.getRoleid(), 180043, params);
                            ChatChannel.getInstance().process(member.getRoleid(), 2, msg2, "指挥", showinfos, 0);
                        }
                    }
                }

            }
        }
    }

    public long GetCommanderRoleId() {
        return this.teamInfo.getCommanderroleid();
    }

    public TeamInfo getTeamInfo() {
        return this.teamInfo;
    }

    public boolean isTeamLeader(long roleId) {
        return roleId == this.teamInfo.getTeamleaderid();
    }

    public boolean isTeamMember(long roleId) {
        for(TeamMember member : this.teamInfo.getMembers()) {
            if (member.getRoleid() == roleId) {
                return true;
            }
        }

        return false;
    }

	/**
	 * 是不是正常队员，不包括队长
	 * 队长用isTeamLeader判断
	 * @参数角色Id
	 * @返回
	 */
    public boolean isNormalMember(long roleId) {
        return this.isMemberState(roleId, TeamMemberState.eTeamNormal);
    }

	/**
	 * 是否是暂离队员
	 * ！注意：这里包括了归队中队员，因为归队中队员很大程度上与暂离的处理时一致的
	 * @参数角色Id
	 * @返回
	 */
    public boolean isAbsentMember(long roleId) {
        return this.isMemberState(roleId, TeamMemberState.eTeamAbsent) || this.isMemberState(roleId, TeamMemberState.eTeamReturn);
    }

	/**
	 * 是否是归队中队员
	 * @参数角色Id
	 * @返回
	 */
    public boolean isReturnMember(long roleId) {
        return this.isMemberState(roleId, TeamMemberState.eTeamReturn);
    }

	/**
	 * 是否是掉线队员
	 * @参数角色Id
	 * @返回
	 */
    public boolean isOfflineMember(long roleId) {
        return this.isMemberState(roleId, TeamMemberState.eTeamFallline);
    }

    public boolean isMemberState(long roleId, int memberState) {
        for(TeamMember member : this.teamInfo.getMembers()) {
            if (member.getRoleid() == roleId) {
                if (member.getState() == memberState) {
                    return true;
                }

                return false;
            }
        }

        return false;
    }

	/**
	 * 获取队伍中所有队员ID，包括队长
	 * 获取的ID保持队伍的顺序
	 * @返回
	 */
    public List<Long> getAllMemberIds() {
        List<Long> ids = new ArrayList<>();
        ids.add(this.teamInfo.getTeamleaderid());

        for(TeamMember member : this.teamInfo.getMembers()) {
            ids.add(member.getRoleid());
        }

        return ids;
    }

	/**
	 * 获取队伍中所有队员ID，包括队长
	 * 
	 * @返回
	 */
    public Set<Long> getAllMemberIdSet() {
        Set<Long> ids = new HashSet<>();
        ids.add(this.teamInfo.getTeamleaderid());

        for(TeamMember member : this.teamInfo.getMembers()) {
            ids.add(member.getRoleid());
        }

        return ids;
    }

	/**
	 * 获取所有在线的队伍成员Id（包括队长）
	 * 
	 * @return List<Long> 在线的队伍成员Id
	 */
    public List<Long> getOnlineMemberIds() {
        List<Long> result = new ArrayList<>();
        result.add(this.teamInfo.getTeamleaderid());

        for(TeamMember member : this.teamInfo.getMembers()) {
            if (member.getState() != TeamMemberState.eTeamFallline) {
                result.add(member.getRoleid());
            }
        }

        return result;
    }

	/**
	 * 获取所有正常状态的队伍成员Id（包括队长）。 为进入战斗时提供
	 * 
	 * @return List<Long> 正常状态的队伍成员Id
	 */
    public List<Long> getNormalMemberIds() {
        List<Long> result = new ArrayList<>();
        result.add(this.teamInfo.getTeamleaderid());

        for(TeamMember member : this.teamInfo.getMembers()) {
            if (member.getState() == TeamMemberState.eTeamNormal) {
                result.add(member.getRoleid());
            }
        }

        return result;
    }

	/**
	 * 获取所有能战斗状态的队伍成员Id（包括队长）。 为进入战斗时提供
	 * 
	 * @return List<Long> 正常状态的队伍成员Id
	 */
    public List<Long> getFighterMemberIds() {
        List<Long> result = new ArrayList<>();
        result.add(this.teamInfo.getTeamleaderid());

        for(TeamMember member : this.teamInfo.getMembers()) {
            if (member.getState() == TeamMemberState.eTeamNormal) {
                result.add(member.getRoleid());
            }
        }

        return result;
    }

	/**
	 * 获取所有离线队伍成员Id。 为进入战斗时提供
	 * 
	 * @return List<Long> 离线的队伍成员Id
	 */
    public List<Long> getOfflineMemberIds() {
        List<Long> result = new ArrayList<>();

        for(TeamMember member : this.teamInfo.getMembers()) {
            if (member.getState() == TeamMemberState.eTeamFallline) {
                result.add(member.getRoleid());
            }
        }

        return result;
    }

	/**
	 * 获取所有归队中队伍成员Id（不包括队长）。 为进入战斗时提供
	 * 
	 * @return List<Long> 归队中成员Id
	 */
    public List<Long> getReturningMemberIds() {
        List<Long> result = new ArrayList<>();

        for(TeamMember member : this.teamInfo.getMembers()) {
            if (member.getState() == TeamMemberState.eTeamReturn) {
                result.add(member.getRoleid());
            }
        }

        return result;
    }

	/**
	 * 获取所有暂离状态的队伍成员Id（肯定没有队长）。
	 * ！注意：这里包括了归队中队员，因为大部分的处理情况，暂离和归队中是一致的
	 * @return List<Long> 暂离状态的队伍成员Id
	 */
    public List<Long> getAbsentMemberIds() {
        List<Long> result = new ArrayList<>();

        for(TeamMember member : this.teamInfo.getMembers()) {
            if (member.getState() == TeamMemberState.eTeamAbsent || member.getState() == TeamMemberState.eTeamReturn) {
                result.add(member.getRoleid());
            }
        }

        return result;
    }

    public void setformLevel() {
    }

	/**
	 * 添加新队员（包括广播队员信息、广播排序）。 只能在Procedure中被调用！
	 * 
	 * @lock: 队长和新队员的rolelock
	 * @param newMemberRoleId
	 */
    public boolean addNewMemberWithSP(long newMemberRoleId) {
        if (this.readonly) {
            return false;
        } else if (!this.validAddNewMemeber(newMemberRoleId)) {
            return false;
        } else {
            TeamMember member = Pod.newTeamMember();
            member.setRoleid(newMemberRoleId);
            member.setState(TeamMemberState.eTeamAbsent);
            this.teamInfo.getMembers().add(member);
            Roleid2teamid.add(newMemberRoleId, this.teamId);
            this.teamInfo.getInvitingids().remove(newMemberRoleId);
            Teaminvite.remove(newMemberRoleId);
            this.removeTeamApplyWithSendProtocol(newMemberRoleId);
            int memberstate = this.calculateMemberState(newMemberRoleId);
            member.setState(memberstate);
            (new PShowPetOffProc(newMemberRoleId)).call();
            this.broadcastAddNewMember(newMemberRoleId);
            SSetCommander send = new SSetCommander(this.teamInfo.getCommanderroleid());
            Procedure.psend(newMemberRoleId, send);
            long leaderid = this.teamInfo.getTeamleaderid();
            if (leaderid != newMemberRoleId) {
                Properties leaderprop = xtable.Properties.select(leaderid);
                if (leaderprop != null) {
                    List<String> params = new ArrayList<>();
                    params.add(leaderprop.getRolename());
                    MessageMgr.sendMsgNotify(newMemberRoleId, 141203, params);
                }
            }

            int changetype = member.getState() == TeamMemberState.eTeamNormal ? TeamChangeType.ADD_NORMAL_MEMBER : TeamChangeType.ADD_ABSENT_MEMBER;
            GsClient.tSendWhileCommit(new GNotifyTeamChange(changetype, this.teamId, newMemberRoleId, 0L));
            this.OnTeamStructChange(TeamManager.STRUCT_CHANGE_NEW_MEMBER, newMemberRoleId, 0L);
            Procedure.psendWhileCommit(newMemberRoleId, new SSetTeamFormation(this.teamInfo.getFormation(), this.getFormLevel(), (byte)0));
            TeamManager.logger.debug("队伍加入新队员,RoleId: " + newMemberRoleId + " ;TeamId: " + this.teamId);
            if (this.teamInfo.getMembers().size() >= TeamManager.MAX_MEMBER_COUNT) {
                TeamManager.getInstance().delTeamMatch(this.getTeamLeaderId());
            }

            TeamManager.getInstance().delTeamMatch(newMemberRoleId);
            TeamManager.getInstance().sendCurTeamMatchStateByRoleId(this.getTeamLeaderId(), newMemberRoleId);
            return true;
        }
    }

    public int getFormLevel() {
        return this.teamInfo.getFormationlevel();
    }

    private boolean validAddNewMemeber(long newmemId) {
        BuffAgent buffagent = new BuffRoleImpl(newmemId, true);
        if (!buffagent.canAddBuff(BuffConstant.StateType.STATE_TEAM)) {
            TeamManager.logger.info("玩家(roleId=" + newmemId + ")处于不能组队的状态");
            return false;
        } else {
            TeamFilter xfilter = Teamfilters.get(this.teamId);
            return xfilter == null || xfilter.getFilter().checkEnterTeam(this.getTeamLeaderId(), newmemId);
        }
    }

    public fire.pb.team.TeamFilter getFilter() {
        if (Transaction.current() == null) {
            return null;
        } else {
            TeamFilter xfilter = Teamfilters.get(this.teamId);
            return xfilter == null ? null : xfilter.getFilter();
        }
    }

	/**
	 * 获得队伍的群发列表（不包括掉线的成员）
	 * 
	 * @return Set<Long> 队伍所有成员的IDs
	 */
    public Set<Long> getTeamBroadcastSet() {
        Set<Long> roleids = new HashSet<>();
        roleids.add(this.teamInfo.getTeamleaderid());

        for(TeamMember member : this.teamInfo.getMembers()) {
            if (member.getState() != TeamMemberState.eTeamFallline) {
                roleids.add(member.getRoleid());
            }
        }

        return roleids;
    }

	/**
	 * 删除一个非队长队员（包括群发删除队员协议） 只能在Procedure中被调用
	 * 
	 * @return false队伍中没有该队员
	 */
    public boolean removeTeamMemberWithSP(long leverRoleId, boolean active) {
        if (this.readonly) {
            return false;
        } else {
            Set<Long> roleIds = this.getTeamBroadcastSet();

            int i;
            for(i = 0; i < this.teamInfo.getMembers().size() && ((TeamMember)this.teamInfo.getMembers().get(i)).getRoleid() != leverRoleId; ++i) {
            }

            if (i >= this.teamInfo.getMembers().size()) {
                return false;
            } else {
                this.teamInfo.getMembers().remove(i);
                if (leverRoleId == this.teamInfo.getCommanderroleid()) {
                    this.SetCommanderRoleId(this.teamInfo.getTeamleaderid());
                }

                if (this.teamInfo.getSwitchleaderid() == leverRoleId) {
                    this.teamInfo.setSwitchleaderid(0L);
                    Procedure.psendWhileCommit(this.teamInfo.getTeamleaderid(), new STeamError(TeamError.RefuseChangeLeader));
                }

                Roleid2teamid.remove(leverRoleId);
                SRemoveTeamMember sRemoveTeamMember = new SRemoveTeamMember();
                sRemoveTeamMember.memberids.add(leverRoleId);
                roleIds.remove(leverRoleId);
                if (roleIds.size() != 0) {
                    Procedure.psendWhileCommit(roleIds, sRemoveTeamMember);
                }

                SDismissTeam sDismissTeam = new SDismissTeam();
                Procedure.psendWhileCommit(leverRoleId, sDismissTeam);
                this.OnTeamStructChange(TeamManager.STRUCT_CHANGE_REMOVE_MEMBER, leverRoleId, 0L);
                return true;
            }
        }
    }
	/**
	 * 解散队伍。请提前按从小到大锁rolelock，然后在调用。 只能在Peocedure中调用
	 * ！注意：这个方法不能被直接调用，解散队伍请使用PDismissTeam过程
	 * 
	 * @lock:队长和所有队员的rolelock
	 */
    public void dismissTeam() {
        Set<Long> roleIds = new HashSet<>();
        long leaderid = this.teamInfo.getTeamleaderid();
        TeamManager.getInstance().delTeamMatch(leaderid);
        Roleid2teamid.remove(this.teamInfo.getTeamleaderid());
        if (StateCommon.isOnline(this.teamInfo.getTeamleaderid())) {
            roleIds.add(this.teamInfo.getTeamleaderid());
        }

        for(TeamMember member : this.teamInfo.getMembers()) {
            Roleid2teamid.remove(member.getRoleid());
            if (Roleonoffstate.get(member.getRoleid()) != null && Roleonoffstate.get(member.getRoleid()) != TeamMemberState.eTeamFallline) {
                roleIds.add(member.getRoleid());
            }
        }

        xtable.Team.remove(this.teamId);
        Teamfilters.remove(this.teamId);
        SDismissTeam sDismissTeam = new SDismissTeam();
        if (roleIds.size() != 0) {
            Procedure.psendWhileCommit(roleIds, sDismissTeam);
        }

        GsClient.tSendWhileCommit(new GNotifyTeamChange(TeamChangeType.DISMISS, this.teamId, leaderid, 0L));
    }

	/**
	 * 查看该队员是否处于可以归队的范围内（与队长在10*10范围） 只能在Procedure中调用
	 * 
	 * @lock：队长和该队员的rolelock
	 * @return true=在范围内; false=在范围外
	 */
    public boolean isMemberInReturnScale(long memberRoleId) {
        long leaderRoleId = this.teamInfo.getTeamleaderid();
        Role leaderRole = RoleManager.getInstance().getRoleByID(leaderRoleId);
        Role memberRole = RoleManager.getInstance().getRoleByID(memberRoleId);
        if (leaderRole.getScene() != memberRole.getScene()) {
            return false;
        } else {
            MapConfig mapcfg = (MapConfig)ConfigManager.getInstance().getConf(MapConfig.class).get((int)leaderRole.getScene());
            if (mapcfg == null) {
                return false;
            } else if (mapcfg.visibletype == Scene.VISIBLE_SINGLE) {
                return false;
            } else {
                return memberRole.getPos().getZ() == leaderRole.getPos().getZ();
            }
        }
    }

    public void updateMemberSequenceWithSendProtocol() {
        Set<Long> roleids = new HashSet<>();
        if (this.sequenceMembersByStatus(this.teamInfo.getMembers())) {
            SMemberSequence sMemberSequence = new SMemberSequence();
            sMemberSequence.teammemeberlist.add(this.teamInfo.getTeamleaderid());
            roleids.add(this.teamInfo.getTeamleaderid());

            for(TeamMember member : this.teamInfo.getMembers()) {
                sMemberSequence.teammemeberlist.add(member.getRoleid());
                roleids.add(member.getRoleid());
            }

            Procedure.psendWhileCommit(roleids, sMemberSequence);
        }

    }

	/**
	 * 主动交换队长，原队长跟新队长必须都处于正常状态 主动交换队长后，原队长作为队员也处于正常状态，其他人不变 包括群发交换队长协议
	 * 只能在Procedure中被调用
	 * 
	 * @lock: 原队长和新队长的rolelock
	 * 
	 * @return true表示交换队长成功，fasle表示队伍中已经没有其他在线成员
	 */
    public boolean switchTeamLeaderWithSP(long newLeaderId) {
        BuffAgent buffagent = new BuffRoleImpl(newLeaderId);
        if (!buffagent.canAddBuff(BuffConstant.StateType.STATE_TEAM_LEADER)) {
            return false;
        } else {
            this.teamInfo.setSwitchleaderid(-1L);
            long oldLeaderId = this.teamInfo.getTeamleaderid();
            TeamMember newMember = Pod.newTeamMember();
            newMember.setRoleid(oldLeaderId);
            newMember.setState(TeamMemberState.eTeamNormal);
            this.teamInfo.setTeamleaderid(newLeaderId);

            for(int i = 0; i < this.teamInfo.getMembers().size(); ++i) {
                if (((TeamMember)this.teamInfo.getMembers().get(i)).getRoleid() == newLeaderId) {
                    this.teamInfo.getMembers().set(i, newMember);
                    break;
                }
            }

            if (oldLeaderId == this.teamInfo.getCommanderroleid()) {
                this.SetCommanderRoleId(newLeaderId);
            }

            SSetTeamLeader sSetTeamLeader = new SSetTeamLeader();
            sSetTeamLeader.roleid = newLeaderId;
            Procedure.psendWhileCommit(this.getTeamBroadcastSet(), sSetTeamLeader);
            this.refreshAllAppliersWithSendProtocol(newLeaderId);
            PropRole role = new PropRole(newLeaderId, true);
            int formId = role.getDealutFormId();
            int formLevel = role.getFormLevel(formId);
            this.teamInfo.setFormation(formId);
            this.teamInfo.setFormationlevel(formLevel);
            this.changeFormationWithSP(formId, formLevel, false);
            Procedure.pexecuteWhileCommit(new PShowPetOffProc(oldLeaderId));
            this.OnTeamStructChange(TeamManager.STRUCT_CHANGE_SWITCH_LEADER, newLeaderId, oldLeaderId);
            this.teamInfo.setOnekeytimestamp(0L);
            return true;
        }
    }
	/**
	 * 被动交换队长（由下线、逃离战斗等触发），只发送更改状态协议 ，不发送设置队长协议 可能失败，没有其他在线成员，外面需要判断是解散队伍还是不换队长
	 * 
	 * @return true表示交换队长成功，fasle表示队伍中已经没有其他在线成员，交换队长失败
	 */
    private boolean passiveSwitchLeader() {
        if (this.teamInfo.getMembers().size() != 0 && ((TeamMember)this.teamInfo.getMembers().get(0)).getState() != TeamMemberState.eTeamFallline) {
            long newLeaderId = 0L;
            int newLeaderMemberSeq = 0;

            for(TeamMember xtm : this.teamInfo.getMembers()) {
                if (xtm.getState() != TeamMemberState.eTeamFallline) {
                    BuffAgent buffagent = new BuffRoleImpl(xtm.getRoleid());
                    if (buffagent.canAddBuff(BuffConstant.StateType.STATE_TEAM_LEADER)) {
                        newLeaderId = xtm.getRoleid();
                        break;
                    }
                }

                ++newLeaderMemberSeq;
            }

            if (newLeaderId == 0L) {
                return false;
            } else {
                this.teamInfo.setSwitchleaderid(-1L);
                PropRole prole = new PropRole(newLeaderId, true);
                int formLevel = prole.getFormLevel(prole.getDealutFormId());
                this.teamInfo.setFormation(prole.getDealutFormId());
                this.teamInfo.setFormationlevel(formLevel);
                long oldLeaderId = this.teamInfo.getTeamleaderid();
                TeamMember newMember = Pod.newTeamMember();
                newMember.setRoleid(oldLeaderId);
                this.teamInfo.setTeamleaderid(newLeaderId);
                this.teamInfo.getMembers().set(newLeaderMemberSeq, newMember);
                if (oldLeaderId == this.teamInfo.getCommanderroleid()) {
                    this.SetCommanderRoleId(newLeaderId);
                }

                return true;
            }
        } else {
            return false;
        }
    }

    public boolean changeFormationWithSP(int newForm, int formLevel, boolean msg) {
        this.teamInfo.setFormation(newForm);
        this.teamInfo.setFormationlevel(formLevel);
        Procedure.psendWhileCommit(this.getTeamBroadcastSet(), new SSetTeamFormation(newForm, formLevel, (byte)0));
        return true;
    }

    public boolean allMemberAbsent() {
        for(TeamMember xtm : this.teamInfo.getMembers()) {
            if (xtm.getState() != TeamMemberState.eTeamAbsent) {
                return false;
            }
        }

        return true;
    }

	/**
	 * 被动交换队长 可能失败，没有其他在线成员，外面需要判断是解散队伍还是不换队长 (包括群发交换队长协议,群发当前顺序)
	 * 
	 * @return true表示交换队长成功，fasle表示队伍中已经没有其他可以做队长的队员，交换队长失败
	 */
    public boolean passiveSwitchLeaderWithSP(int leaderNewState) {
        long oldleader = this.teamInfo.getTeamleaderid();
        if (!this.passiveSwitchLeader()) {
            if (leaderNewState == -1 || leaderNewState == TeamMemberState.eTeamFallline) {
                TeamManager.getInstance().delTeamMatch(oldleader);
            }

            return false;
        } else {
            SSetTeamLeader sSetTeamLeader = new SSetTeamLeader();
            sSetTeamLeader.roleid = this.teamInfo.getTeamleaderid();
            Procedure.psendWhileCommit(this.getTeamBroadcastSet(), sSetTeamLeader);
            this.OnTeamStructChange(TeamManager.STRUCT_CHANGE_PASSIVE_SWITCH_LEADER, this.teamInfo.getTeamleaderid(), oldleader);
            this.refreshAllAppliersWithSendProtocol(this.teamInfo.getTeamleaderid());
            if (leaderNewState >= 0) {
                this.setTeamMemberState(oldleader, leaderNewState);
            }

            Procedure.pexecuteWhileCommit(new PShowPetOffProc(oldleader));

            for(TeamMember member : this.teamInfo.getMembers()) {
                if (member.getState() == TeamMemberState.eTeamReturn) {
                    this.setTeamMemberState(member.getRoleid(), TeamMemberState.eTeamAbsent);
                }
            }

            this.updateMemberSequenceWithSendProtocol();
            PropRole prole = new PropRole(this.teamInfo.getTeamleaderid(), true);
            int formId = prole.getDealutFormId();
            int level = prole.getFormLevel(formId);
            this.teamInfo.setFormation(formId);
            this.teamInfo.setFormationlevel(level);
            Procedure.psendWhileCommit(this.getTeamBroadcastSet(), new SSetTeamFormation(formId, level, (byte)0));
            if (this.teamInfo.getMinlevel() != 1 || this.teamInfo.getMaxlevel() != 155) {
                this.teamInfo.setMinlevel(1);
                this.teamInfo.setMaxlevel(155);
                SSetTeamLevel sSetTeamLevel = new SSetTeamLevel();
                sSetTeamLevel.minlevel = 1;
                sSetTeamLevel.maxlevel = 155;
                Procedure.psendWhileCommit(this.getTeamBroadcastSet(), sSetTeamLevel);
            }

            TeamManager.getInstance().delTeamMatch(oldleader);
            TeamManager.logger.debug("队伍：" + this.teamId + " 被动交换队长，新队长ID：" + this.teamInfo.getTeamleaderid());
            return true;
        }
    }
	/**
	 * 删除一条申请入队信息 只能在Procedure中调用
	 * 
	 * @return true表示删除申请入队信息成功，fasle表示没有该申请
	 */
    public boolean removeTeamApplyWithSendProtocol(long applierRoleId) {
        Long time = (Long)this.teamInfo.getApplierids().remove(applierRoleId);
        if (time != null) {
            SRemoveTeamApply sRemoveTeamApply = new SRemoveTeamApply();
            sRemoveTeamApply.applyids.add(applierRoleId);
            Procedure.psendWhileCommit(this.teamInfo.getTeamleaderid(), sRemoveTeamApply);
            return true;
        } else {
            return false;
        }
    }

	/**
	 * 删除超时申请 只能在Procedure中调用
	 */
    public void removeTimeoutTeamApplys() {
        long now = System.currentTimeMillis();
        List<Long> rmroleIds = new ArrayList<>();

        for(Long applierRoleId : this.teamInfo.getApplierids().keySet()) {
            if (now - (Long)this.teamInfo.getApplierids().get(applierRoleId) > TeamManager.MAX_ARRLY_TIMEOUT) {
                rmroleIds.add(applierRoleId);
            }
        }

        for(long rmroleId : rmroleIds) {
            this.teamInfo.getApplierids().remove(rmroleId);
        }
    }

	/**
	 * 队员下线，更新队伍信息，提供给下线模块用 只能在Procedure中调用
	 * 
	 * @lock: 角色的rolelock
	 * 
	 * @return true表示成员下线更新队伍信息成功，fasle表示没有该成员
	 */
    public boolean roleOffline(long roleId) {
        if (roleId == this.teamInfo.getTeamleaderid()) {
            if (!this.passiveSwitchLeaderWithSP(TeamMemberState.eTeamFallline)) {
                PDisMissTeam pDisMissTeam = new PDisMissTeam(this.teamId, PDisMissTeam.REASON_SYSTEM);
                Procedure.pexecute(pDisMissTeam);
            }

            return true;
        } else {
            boolean isMemberExist = this.setTeamMemberStateWithSP(roleId, TeamMemberState.eTeamFallline);
            return isMemberExist;
        }
    }

	/**
	 * 设置队伍的状态和玩法ID
	 * @参数团队状态
	 */
    public void setTeamState(int teamstate, int smapId) {
        this.teamInfo.setState(teamstate);
        this.teamInfo.setSmapid(smapId);
        Procedure.psendWhileCommit(this.getTeamBroadcastSet(), new SSetTeamState(teamstate, smapId));
    }
	/**
	 * 队员上线，更新队伍信息，提供给上线模块用 只能在Procedure中调用
	 * 
	 * @lock: 角色的rolelock
	 * 
	 * @return true表示成员上线更新队伍信息成功，fasle表示没有该成员
	 */
    public boolean roleOnline(long roleId) {
        if (!this.isInTeam(roleId)) {
            return false;
        } else {
            SCreateTeam sCreateTeam = new SCreateTeam();
            sCreateTeam.teamid = this.teamId;
            sCreateTeam.formation = this.teamInfo.getFormation();
            sCreateTeam.teamstate = this.teamInfo.getState();
            sCreateTeam.smapid = this.teamInfo.getSmapid();
            Procedure.psendWhileCommit(roleId, sCreateTeam);
            SAddTeamMember sAddTeamMemeber = new SAddTeamMember();
            sAddTeamMemeber.memberlist.add(this.getTeamMemeberBasic(this.teamInfo.getTeamleaderid()));

            for(TeamMember member : this.teamInfo.getMembers()) {
                sAddTeamMemeber.memberlist.add(this.getTeamMemeberBasic(member.getRoleid()));
            }

            Procedure.psendWhileCommit(roleId, sAddTeamMemeber);
            int teamstate = this.getTeamMemberState(roleId);
            if (teamstate == TeamMemberState.eTeamFallline) {
                if (Roleid2battleid.get(roleId) == null) {
                    this.setTeamMemberStateWithSP(roleId, TeamMemberState.eTeamAbsent);
                } else {
                    this.setTeamMemberStateWithSP(roleId, TeamMemberState.eTeamReturn);
                }
            }

            this.updateTeamMemberBasic2Others(roleId);
            Procedure.psendWhileCommit(roleId, new SSetTeamFormation(this.teamInfo.getFormation(), this.getFormLevel(), (byte)0));
            if (this.teamInfo.getTeamleaderid() == roleId) {
                Procedure.pexecuteWhileCommit(new PSendTeamApplierids(this.teamInfo.getTeamleaderid()));
            }

            SSetCommander send2 = new SSetCommander(this.GetCommanderRoleId());
            Procedure.psend(roleId, send2);
            TeamManager.getInstance().sendCurTeamSetInfo(roleId);
            TeamManager.getInstance().sendCurTeamMatchStateByRoleId(this.teamInfo.getTeamleaderid(), roleId);
            return true;
        }
    }

    private boolean sequenceMembersByStatus(List<TeamMember> members) {
        boolean sequenceChanged = false;

        for(int i = 0; i < members.size(); ++i) {
            for(int j = i; j > 0; --j) {
                TeamMember frontMember = (TeamMember)members.get(j - 1);
                TeamMember backMember = (TeamMember)members.get(j);
                if (frontMember.getState() == TeamMemberState.eTeamNormal || (frontMember.getState() == TeamMemberState.eTeamReturn || frontMember.getState() == TeamMemberState.eTeamAbsent) && backMember.getState() != TeamMemberState.eTeamNormal || frontMember.getState() == TeamMemberState.eTeamFallline && backMember.getState() == TeamMemberState.eTeamFallline) {
                    break;
                }

                members.set(j - 1, backMember.copy());
                members.set(j, frontMember.copy());
                sequenceChanged = true;
            }
        }

        return sequenceChanged;
    }

	/**
	 * 计算一个队员的状态 只能在Procedure中调用
	 * 
	 * @lock: 队长和队员的rolelock
	 * @param long memberRoleId 成员角色ID
	 * @return 团队成员状态
	 */
    private int calculateMemberState(long memberRoleId) {
        if (this.isMemberInReturnScale(memberRoleId)) {
            BuffAgent brole = new BuffRoleImpl(memberRoleId);
            if (!fire.pb.buff.Module.existState(this.teamInfo.getTeamleaderid(), BuffConstant.StateType.STATE_BATTLE_FIGHTER) && !fire.pb.buff.Module.existState(this.teamInfo.getTeamleaderid(), BuffConstant.StateType.STATE_REPLAY) && !fire.pb.buff.Module.existState(this.teamInfo.getTeamleaderid(), BuffConstant.StateType.STATE_BATTLE_WATCHER)) {
                return brole.canAddBuff(BuffConstant.StateType.STATE_TEAM_MEMBER_NORMAL) ? TeamMemberState.eTeamNormal : TeamMemberState.eTeamAbsent;
            } else {
                return TeamMemberState.eTeamReturn;
            }
        } else {
            return TeamMemberState.eTeamAbsent;
        }
    }

    private void broadcastAddNewMember(long newMemberRoleId) {
        SAddTeamMember sAddTeamMemeber = new SAddTeamMember();
        sAddTeamMemeber.memberlist.add(this.getTeamMemeberBasic(newMemberRoleId));
        Set<Long> roleids = new HashSet<>();

        for(TeamMember member : this.teamInfo.getMembers()) {
            roleids.add(member.getRoleid());
        }

        roleids.add(this.teamInfo.getTeamleaderid());
        roleids.remove(newMemberRoleId);
        if (roleids.size() != 0) {
            Procedure.psendWhileCommit(roleids, sAddTeamMemeber);
        }

        SCreateTeam sCreateTeam = new SCreateTeam();
        sCreateTeam.teamid = this.teamId;
        sCreateTeam.formation = this.teamInfo.getFormation();
        sCreateTeam.teamstate = this.teamInfo.getState();
        sCreateTeam.smapid = this.teamInfo.getSmapid();
        Procedure.psendWhileCommit(newMemberRoleId, sCreateTeam);
        SAddTeamMember sAddTeamMemeber2 = new SAddTeamMember();
        sAddTeamMemeber2.memberlist.add(this.getTeamMemeberBasic(this.teamInfo.getTeamleaderid()));

        for(TeamMember member : this.teamInfo.getMembers()) {
            sAddTeamMemeber2.memberlist.add(this.getTeamMemeberBasic(member.getRoleid()));
        }

        Procedure.psendWhileCommit(newMemberRoleId, sAddTeamMemeber2);
        if (roleids.size() != 0) {
            this.updateMemberSequenceWithSendProtocol();
        }
    }

	/**
	 * 获取一个角色的TeamMemberBasic（协议定义的队伍成员结构） 只能在Procedure中调用
	 * 
	 * @lock: 角色的rolelock
	 * @param long memberRoleId 成员角色ID
	 * @return TeamMemberBasic
	 */
    public TeamMemberBasic getTeamMemeberBasic(long memberRoleId) {
        TeamMemberBasic memberBasic = new TeamMemberBasic();
        memberBasic.roleid = memberRoleId;
        memberBasic.state = this.getTeamMemberState(memberRoleId);
        if (memberBasic.state == TeamMemberState.eTeamReturn) {
            memberBasic.state = TeamMemberState.eTeamAbsent;
        }

        Properties newProperty = xtable.Properties.select(memberRoleId);
        if (newProperty != null) {
            memberBasic.level = newProperty.getLevel();
            memberBasic.rolename = newProperty.getRolename();
            memberBasic.school = newProperty.getSchool();
            memberBasic.shape = newProperty.getShape();
            Role.getPlayerComponents(memberRoleId, memberBasic.components);
        }

        fire.pb.effect.Role calAttr = new fire.pb.effect.RoleImpl(memberRoleId, true);
        memberBasic.hp = calAttr.getHp();
        memberBasic.mp = calAttr.getMp();
        memberBasic.maxhp = calAttr.getMaxHp();
        memberBasic.maxmp = calAttr.getMaxMp();
        memberBasic.hugindex = this.getHugIndex(memberRoleId);
        Role role = RoleManager.getInstance().getRoleByID(memberRoleId);
        if (role != null) {
            memberBasic.sceneid = role.getScene();
            memberBasic.pos.x = role.getPos().getX();
            memberBasic.pos.y = role.getPos().getY();
        } else {
            memberBasic.sceneid = 0L;
            memberBasic.pos.x = 0;
            memberBasic.pos.y = 0;
        }

        return memberBasic;
    }
	
	/**
	 * 获取一个角色的TeamMemberSimple（协议定义的队伍成员结构） 只能在Procedure中调用 简单的成员数据，作者 changhao
	 * 
	 * @lock: 角色的rolelock
	 * @param long memberRoleId 成员角色ID
	 * @return TeamMemberBasic
	 */
    public TeamMemberSimple getTeamMemeberSimple(long memberRoleId) {
        TeamMemberSimple member = new TeamMemberSimple();
        member.roleid = memberRoleId;
        Properties newProperty = xtable.Properties.select(memberRoleId);
        if (newProperty != null) {
            member.level = newProperty.getLevel();
            member.rolename = newProperty.getRolename();
            member.school = newProperty.getSchool();
            member.shape = newProperty.getShape();
        }

        return member;
    }

    public byte getHugIndex(long roleId) {
        List<Long> rids = this.getNormalMemberIds();
        if (!rids.contains(roleId)) {
            return 0;
        } else {
            Iterator<Map.Entry<Long, Long>> it = this.getTeamInfo().getHugs().entrySet().iterator();

            while(it.hasNext()) {
                Map.Entry<Long, Long> entry = (Map.Entry)it.next();
                if (rids.contains(entry.getKey()) && rids.contains(entry.getValue())) {
                    if ((Long)entry.getKey() == roleId) {
                        int index = rids.indexOf((Long)entry.getValue());
                        if (index < 0) {
                            return 0;
                        }

                        return (byte)(index + 1);
                    }

                    if ((Long)entry.getValue() == roleId) {
                        int index = rids.indexOf((Long)entry.getKey());
                        if (index < 0) {
                            return 0;
                        }

                        return (byte)(index + 1);
                    }
                } else {
                    it.remove();
                }
            }

            return 0;
        }
    }

    public boolean canHug(long roleid1, long roleid2) {
        Properties prop1 = xtable.Properties.select(roleid1);
        if (this.isHugging(roleid1)) {
            return false;
        } else if (prop1.getSex() == 2 && this.isTeamLeader(roleid1)) {
            return false;
        } else if (!this.isTeamLeader(roleid1) && !this.isNormalMember(roleid1)) {
            MessageMgr.psendMsgNotify(roleid1, 144618, null);
            return false;
        } else {
            Properties prop2 = xtable.Properties.select(roleid2);
            if (this.isHugging(roleid2)) {
                MessageMgr.psendMsgNotify(roleid1, 144621, null);
                return false;
            } else if (prop2.getSex() == 2 && this.isTeamLeader(roleid2)) {
                MessageMgr.psendMsgNotify(roleid1, 144622, null);
                return false;
            } else if (!this.isTeamLeader(roleid2) && !this.isNormalMember(roleid2)) {
                MessageMgr.psendMsgNotify(roleid1, 144618, null);
                return false;
            } else if (prop1.getSex() == prop2.getSex()) {
                MessageMgr.psendMsgNotify(roleid1, 144619, null);
                return false;
            } else {
                return true;
            }
        }
    }

    public boolean isHugging(long roleId) {
        for(Map.Entry<Long, Long> entry : this.getTeamInfo().getHugs().entrySet()) {
            if ((Long)entry.getKey() == roleId || (Long)entry.getValue() == roleId) {
                return true;
            }
        }

        return false;
    }

    public int getTeamMemberState(long memberRoleId) {
        if (this.teamInfo.getTeamleaderid() == memberRoleId) {
            return TeamMemberState.eTeamNormal;
        } else {
            for(TeamMember member : this.teamInfo.getMembers()) {
                if (member.getRoleid() == memberRoleId) {
                    return member.getState();
                }
            }

            return -1;
        }
    }

    public boolean setTeamMemberState(long memberRoleId, int newState) {
        TeamMember teammember = null;

        for(TeamMember member : this.teamInfo.getMembers()) {
            if (member.getRoleid() == memberRoleId && member.getState() != newState) {
                teammember = member;
            }
        }

        if (teammember != null) {
            TeamManager.logger.debug("设置队员新状态：" + newState);
            BuffAgent buffagent = new BuffRoleImpl(memberRoleId);
            switch (newState) {
                case TeamMemberState.eTeamNormal:
                    if (!buffagent.canAddBuff(BuffConstant.StateType.STATE_TEAM_MEMBER_NORMAL)) {
                        return false;
                    }
                    break;
                case TeamMemberState.eTeamAbsent:
                    if (!buffagent.canAddBuff(BuffConstant.StateType.STATE_TEAM_MEMBER_ABSENT)) {
                        return false;
                    }
                    break;
                case TeamMemberState.eTeamReturn:
                    if (!buffagent.canAddBuff(BuffConstant.StateType.STATE_TEAM_MEMBER_RETURN)) {
                        return false;
                    }
                    break;
                case TeamMemberState.eTeamFallline:
                    if (memberRoleId == this.teamInfo.getCommanderroleid()) {
                        this.SetCommanderRoleId(this.teamInfo.getTeamleaderid());
                    }
            }

            teammember.setState(newState);
            if (newState != TeamMemberState.eTeamReturn) {
                SUpdateMemberState sUpdateMemberState = new SUpdateMemberState();
                sUpdateMemberState.roleid = memberRoleId;
                sUpdateMemberState.state = newState;
                Procedure.psendWhileCommit(this.getTeamBroadcastSet(), sUpdateMemberState);
            }

            this.OnTeamStructChange(newState, memberRoleId, 0L);
            return true;
        } else {
            return false;
        }
    }

    public boolean setTeamMemberStateWithSP(long memberRoleId, int newState) {
        boolean sucess = this.setTeamMemberState(memberRoleId, newState);
        if (sucess) {
            this.updateMemberSequenceWithSendProtocol();
            return true;
        } else {
            return false;
        }
    }

    public Long[] getMembersSequenceRolelocks() {
        Long[] memberIds = new Long[this.teamInfo.getMembers().size() + 1];
        memberIds[0] = this.teamInfo.getTeamleaderid();

        for(int i = 1; i < memberIds.length; ++i) {
            memberIds[i] = ((TeamMember)this.teamInfo.getMembers().get(i - 1)).getRoleid();
        }

        return TeamManager.getSequenceRolelocks(memberIds);
    }

    public boolean isInTeam(long roleId) {
        if (this.teamInfo.getTeamleaderid() == roleId) {
            return true;
        } else {
            for(TeamMember member : this.teamInfo.getMembers()) {
                if (member.getRoleid() == roleId) {
                    return true;
                }
            }

            return false;
        }
    }

    public void refreshAllAppliersWithSendProtocol(long roleId) {
        Procedure.pexecuteWhileCommit(new PSendAndModifyTeamApplierids(roleId));
    }

    public boolean isApplyListFull() {
        this.removeTimeoutTeamApplys();
        return this.teamInfo.getApplierids().size() >= TeamManager.MAX_TEAM_APPLIER_COUNT;
    }

    public void switchTeamMemberWithSP(int index1, int index2) {
        long roleId1 = ((TeamMember)this.getTeamInfo().getMembers().get(index1 - 1)).getRoleid();
        long roleId2 = ((TeamMember)this.getTeamInfo().getMembers().get(index2 - 1)).getRoleid();
        ((TeamMember)this.getTeamInfo().getMembers().get(index2 - 1)).setRoleid(roleId1);
        ((TeamMember)this.getTeamInfo().getMembers().get(index1 - 1)).setRoleid(roleId2);
        Set<Long> roleids = new HashSet<>();
        SMemberSequence sMemberSequence = new SMemberSequence();
        sMemberSequence.teammemeberlist.add(this.getTeamInfo().getTeamleaderid());
        roleids.add(this.getTeamInfo().getTeamleaderid());

        for(TeamMember member : this.getTeamInfo().getMembers()) {
            sMemberSequence.teammemeberlist.add(member.getRoleid());
            roleids.add(member.getRoleid());
        }

        Procedure.psendWhileCommit(roleids, sMemberSequence);
        this.OnTeamStructChange(TeamManager.STRUCT_CHANGE_SWITCH_MEMBER, roleId1, roleId2);
    }

    private void OnTeamStructChange(int reason, long newRoleId, long oldRoleid) {
        if (this.readonly) {
            throw new RuntimeException("只读的情况下不能引起队伍结构变化！！");
        } else {
            this.updateTeamToMap(reason, newRoleId, oldRoleid);
            if (oldRoleid == 0L) {
                long oldLeaderId = this.getTeamLeaderId();
            }

        }
    }

    private void updateTeamToMap(int reason, long newRoleId, long oldRoleid) {
        GNotifyTeamChange gchange = new GNotifyTeamChange();
        gchange.teamid = this.teamId;
        gchange.roleid = newRoleId;
        gchange.roleid2 = oldRoleid;
        switch (reason) {
            case TeamManager.STRUCT_CHANGE_MEMBER_STATE_NORMAL:
                gchange.changetype = TeamChangeType.CHANGE_MEMBER_NORMAL;
                break;
            case TeamManager.STRUCT_CHANGE_MEMBER_STATE_ABSENT:
                gchange.changetype = TeamChangeType.CHANGE_MEMBER_ABSENT;
            case 3:
            case 5:
            default:
                break;
            case TeamManager.STRUCT_CHANGE_MEMBER_STATE_OFFLINE:
                gchange.changetype = TeamChangeType.MEMBER_OFFLINE;
                break;
            case TeamManager.STRUCT_CHANGE_SWITCH_LEADER:
            case TeamManager.STRUCT_CHANGE_PASSIVE_SWITCH_LEADER:
                gchange.changetype = TeamChangeType.SWITCH_LEADER;
                break;
            case TeamManager.STRUCT_CHANGE_REMOVE_MEMBER:
                gchange.changetype = TeamChangeType.REMOVE_MEMBER;
                break;
            case TeamManager.STRUCT_CHANGE_SWITCH_MEMBER:
                gchange.changetype = TeamChangeType.SWITCH_MEMBER;
        }

        if (gchange.changetype != 0) {
            GsClient.tSendWhileCommit(gchange);
        }

    }

    public void notifyHpMpChange(long roleId) {
        Set<Long> roleIds = this.getAllMemberIdSet();
        Properties prop = xtable.Properties.select(roleId);
        if (prop != null) {
            SUpdateMemberHPMP update = new SUpdateMemberHPMP(roleId, prop.getHp(), prop.getMp());
            Onlines.getInstance().send(roleIds, update);
        }
    }

    public long getTeamLeaderId() {
        return this.teamInfo.getTeamleaderid();
    }

    public void updateTeamMemberBasic2Others(long memberRoleId) {
        TeamMemberBasic memberbasic = this.getTeamMemeberBasic(memberRoleId);
        if (memberbasic != null) {
            Set<Long> roleids = this.getTeamBroadcastSet();
            roleids.remove(memberRoleId);
            if (Transaction.current() != null) {
                Procedure.psendWhileCommit(roleids, new SUpdateTeamMemberBasic(memberbasic));
            } else {
                Onlines.getInstance().send(roleids, new SUpdateTeamMemberBasic(memberbasic));
            }

        }
    }

    public void updateTeamMemberComponents2Others(long memberRoleId) {
        Set<Long> roleids = this.getTeamBroadcastSet();
        roleids.remove(memberRoleId);
        SUpdateTeamMemberComponent send = new SUpdateTeamMemberComponent();
        send.memberid = memberRoleId;
        Role.getPlayerComponents(memberRoleId, send.components);
        if (Transaction.current() != null) {
            Procedure.psendWhileCommit(roleids, send);
        } else {
            Onlines.getInstance().send(roleids, send);
        }

    }

    public long getTeamId() {
        return this.teamId;
    }
}
