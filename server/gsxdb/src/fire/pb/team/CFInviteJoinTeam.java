//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.StateCommon;
import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffRoleImpl;
import fire.pb.main.ConfigManager;
import fire.pb.map.MapConfig;
import fire.pb.map.Role;
import fire.pb.map.RoleManager;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import xbean.InviteInfo;
import xbean.Pod;
import xbean.SingleInvitings;
import xbean.TeamInvite;
import xtable.Properties;
import xtable.Roleid2teamid;
import xtable.Singleinviting;
import xtable.Teaminvite;

public class CFInviteJoinTeam extends __CFInviteJoinTeam__ {
    private long now = 0L;
    public static final int PROTOCOL_TYPE = 794493;
    public long roleid;

    protected void process() {
        TeamManager.logger.debug("Enter: " + this.getClass());
        final long inviterRoleId = Onlines.getInstance().findRoleid(this);
        if (inviterRoleId >= 0L) {
            final long invitedRoleId = this.roleid;
            if (inviterRoleId != invitedRoleId) {
                BuffAgent agent = new BuffRoleImpl(inviterRoleId, true);
                if (agent.existBuff(500019)) {
                    if (TeamManager.isInTeam(inviterRoleId)) {
                        MessageMgr.sendMsgNotify(inviterRoleId, 141866, (List)null);
                    } else {
                        MessageMgr.sendMsgNotify(inviterRoleId, 141133, (List)null);
                    }

                } else {
                    BuffAgent var7 = new BuffRoleImpl(invitedRoleId, true);
                    if (((BuffAgent)var7).existBuff(500019)) {
                        MessageMgr.sendMsgNotify(inviterRoleId, 141865, (List)null);
                    } else {
                        Procedure createTeamP = new Procedure() {
                            protected boolean process() {
                                Team team = null;
                                Long teamId = Roleid2teamid.select(inviterRoleId);
                                if (teamId != null) {
                                    team = new Team(teamId, false);
                                    if (!team.isTeamLeader(inviterRoleId)) {
                                        return true;
                                    }
                                }

                                Long inviterTeamId = null;
                                Long invitedTeamId = null;
                                if (inviterRoleId < invitedRoleId) {
                                    inviterTeamId = Roleid2teamid.get(inviterRoleId);
                                    invitedTeamId = Roleid2teamid.get(invitedRoleId);
                                } else {
                                    invitedTeamId = Roleid2teamid.get(invitedRoleId);
                                    inviterTeamId = Roleid2teamid.get(inviterRoleId);
                                }

                                CFInviteJoinTeam.this.now = System.currentTimeMillis();
                                if (!CFInviteJoinTeam.this.checkOnline(invitedRoleId, inviterRoleId)) {
                                    TeamManager.logger.debug("FAIL:被邀请的玩家不在线,RoleId: " + invitedRoleId);
                                } else if (!CFInviteJoinTeam.this.checkInviterStatus(inviterRoleId)) {
                                    MessageMgr.psendMsgNotify(inviterRoleId, 141618, (List)null);
                                    TeamManager.logger.debug("FAIL:邀请者处于不能组队的状态,RoleId: " + inviterRoleId);
                                } else if (!CFInviteJoinTeam.this.checkInvitedStatus(invitedRoleId)) {
                                    MessageMgr.psendMsgNotify(inviterRoleId, 141619, (List)null);
                                    TeamManager.logger.debug("FAIL:被邀请者处于不能组队的状态,RoleId: " + invitedRoleId);
                                } else if (!CFInviteJoinTeam.this.checkInvitedTeamFuctionEnable(invitedRoleId)) {
                                    MessageMgr.psendMsgNotify(inviterRoleId, 141201, (List)null);
                                    TeamManager.logger.debug("FAIL:被邀请者的组队功能没有打开,invitedRoleId: " + invitedRoleId);
                                } else if (!CFInviteJoinTeam.this.checkInvitedInNoTeam(invitedTeamId)) {
                                    TeamManager.logger.debug("FAIL:被邀请者在队伍中,invitedRoleId: " + invitedRoleId);
                                    MessageMgr.psendMsgNotify(inviterRoleId, 141191, (List)null);
                                } else if (!CFInviteJoinTeam.this.checkNotBeingInvited(invitedRoleId)) {
                                    MessageMgr.psendMsgNotify(inviterRoleId, 141202, (List)null);
                                    TeamManager.logger.debug("FAIL:被邀请者正在被其他人邀请中,invitedRoleId: " + invitedRoleId);
                                } else if (!CFInviteJoinTeam.this.checkNotInvitedIn30s(invitedRoleId, inviterRoleId, inviterTeamId)) {
                                    TeamManager.logger.debug("FAIL:被邀请者30秒内曾经被队伍或者个人邀请过,invitedRoleId: " + invitedRoleId);
                                    MessageMgr.psendMsgNotify(inviterRoleId, 141050, (List)null);
                                } else if (team != null) {
                                    if (!CFInviteJoinTeam.this.checkInviterIsLeader(inviterRoleId, team)) {
                                        TeamManager.logger.debug("FAIL:邀请者不是队长,RoleId: " + inviterRoleId);
                                    } else if (!CFInviteJoinTeam.this.checkTeamNotFull(team)) {
                                        psendWhileCommit(inviterRoleId, new STeamError(11));
                                        TeamManager.logger.debug("FAIL:邀请队伍满人,TeamId: " + inviterTeamId);
                                    } else if (!CFInviteJoinTeam.this.checkTeamFilter(team, invitedRoleId)) {
                                        TeamManager.logger.debug("FAIL:TeamFilter否决,TeamId: " + inviterTeamId);
                                    } else if (!CFInviteJoinTeam.this.checkTeamInviteNotFull(team)) {
                                        psend(inviterRoleId, new STeamError(15));
                                        TeamManager.logger.debug("FAIL:邀请队伍的正在邀请人数达到4个，不能再邀请更多,TeamId: " + inviterTeamId);
                                    } else if (!CFInviteJoinTeam.this.checkTeamLeaderState(inviterRoleId)) {
                                        TeamManager.logger.debug("FAIL:队长当前状态不能邀请。");
                                    } else {
                                        if (!this.checkMap()) {
                                            return false;
                                        }

                                        TeamManager.logger.debug("SUCC:满足条件，可以发出队伍邀请 " + inviterTeamId);
                                        SInviteJoinTeam snd = new SInviteJoinTeam();
                                        snd.op = 0;
                                        snd.invitername = Properties.get(inviterRoleId).getRolename();
                                        snd.inviterlevel = Properties.get(inviterRoleId).getLevel();
                                        team.getTeamInfo().getInvitingids().put(invitedRoleId, CFInviteJoinTeam.this.now);
                                        InviteInfo inviteInfo = Teaminvite.get(invitedRoleId);
                                        if (inviteInfo == null) {
                                            inviteInfo = Pod.newInviteInfo();
                                            Teaminvite.add(invitedRoleId, inviteInfo);
                                        }

                                        inviteInfo.setBeinginvited(true);
                                        inviteInfo.getInviting().setTeamid(inviterTeamId);
                                        inviteInfo.getInviting().setRoleid(inviterRoleId);
                                        inviteInfo.getInviting().setInvitetime(CFInviteJoinTeam.this.now);
                                        inviteInfo.getInvited().add(inviteInfo.getInviting().copy());
                                        psendWhileCommit(inviterRoleId, new SInviteJoinSucc(invitedRoleId));
                                        MessageMgr.psendMsgNotify(inviterRoleId, 142358, (List)null);
                                        Procedure.psendWhileCommit(invitedRoleId, snd);
                                    }
                                } else if (!CFInviteJoinTeam.this.checkSingleInviteNotFull(inviterRoleId)) {
                                    psend(inviterRoleId, new STeamError(15));
                                    TeamManager.logger.debug("FAIL:邀请者正在邀请人数达到4个，不能再邀请更 " + inviterRoleId);
                                } else if (!CFInviteJoinTeam.this.checkTeamFilter(inviterRoleId, invitedRoleId)) {
                                    TeamManager.logger.debug("FAIL:TeamFilter否决,TeamId: " + inviterTeamId);
                                } else {
                                    if (!this.checkMap()) {
                                        return false;
                                    }

                                    TeamManager.logger.debug("SUCC:满足条件，可以发出个人邀请 " + inviterRoleId);
                                    xbean.Properties inviterProperty = Properties.get(inviterRoleId);
                                    SInviteJoinTeam snd = new SInviteJoinTeam();
                                    snd.op = 0;
                                    snd.invitername = inviterProperty.getRolename();
                                    snd.inviterlevel = Properties.get(inviterRoleId).getLevel();
                                    SingleInvitings singleInvitings = Singleinviting.get(inviterRoleId);
                                    if (singleInvitings == null) {
                                        singleInvitings = Pod.newSingleInvitings();
                                        Singleinviting.add(inviterRoleId, singleInvitings);
                                    }

                                    singleInvitings.getInvitingids().put(invitedRoleId, CFInviteJoinTeam.this.now);
                                    InviteInfo inviteInfo = Teaminvite.get(invitedRoleId);
                                    if (inviteInfo == null) {
                                        inviteInfo = Pod.newInviteInfo();
                                        Teaminvite.add(invitedRoleId, inviteInfo);
                                    }

                                    inviteInfo.setBeinginvited(true);
                                    if (inviterTeamId == null) {
                                        inviterTeamId = -1L;
                                    }

                                    inviteInfo.getInviting().setTeamid(inviterTeamId);
                                    inviteInfo.getInviting().setRoleid(inviterRoleId);
                                    inviteInfo.getInviting().setInvitetime(CFInviteJoinTeam.this.now);
                                    inviteInfo.getInvited().add(inviteInfo.getInviting().copy());
                                    psendWhileCommit(inviterRoleId, new SInviteJoinSucc(invitedRoleId));
                                    MessageMgr.psendMsgNotify(inviterRoleId, 142358, (List)null);
                                    Procedure.psendWhileCommit(invitedRoleId, snd);
                                }

                                return true;
                            }

                            private boolean checkMap() {
                                Role invitMaprole = RoleManager.getInstance().getRoleByID(inviterRoleId);
                                Role desMaprole = RoleManager.getInstance().getRoleByID(invitedRoleId);
                                if (invitMaprole != null && desMaprole != null) {
                                    int srcMapId = invitMaprole.getMapId();
                                    MapConfig cfg = (MapConfig)ConfigManager.getInstance().getConf(MapConfig.class).get(srcMapId);
                                    int desMapId = desMaprole.getMapId();
                                    MapConfig descfg = (MapConfig)ConfigManager.getInstance().getConf(MapConfig.class).get(desMapId);
                                    if (cfg != null && descfg != null) {
                                        return cfg.getSafemap() == descfg.getSafemap() && cfg.getSafemap() == 1 ? true : true;
                                    } else {
                                        return true;
                                    }
                                } else {
                                    return true;
                                }
                            }
                        };
                        createTeamP.submit();
                    }
                }
            }
        }
    }

    private boolean checkOnline(long invitedRoleId, long inviterRoleId) {
        if (StateCommon.isOnline(invitedRoleId)) {
            return true;
        } else {
            MessageMgr.sendMsgNotify(inviterRoleId, 141701, (List)null);
            return false;
        }
    }

    private boolean checkInviterStatus(long inviterRoleId) {
        BuffAgent buffagent = new BuffRoleImpl(inviterRoleId, true);
        if (!buffagent.canAddBuff(507006)) {
            TeamManager.logger.info("玩家(roleId=" + inviterRoleId + ")处于不能组队的状态");
            return false;
        } else {
            return true;
        }
    }

    private boolean checkInvitedStatus(long invitedRoleId) {
        BuffAgent buffagent = new BuffRoleImpl(invitedRoleId, true);
        if (!buffagent.canAddBuff(507006)) {
            TeamManager.logger.info("玩家(roleId=" + invitedRoleId + ")处于不能组队的状态");
            return false;
        } else {
            return true;
        }
    }

    private boolean checkInvitedTeamFuctionEnable(long invitedRoleId) {
        return true;
    }

    private boolean checkInvitedInNoTeam(Long invitedTeamId) {
        return invitedTeamId == null;
    }

    private boolean checkNotBeingInvited(long invitedRoleId) {
        InviteInfo inviteInfo = Teaminvite.get(invitedRoleId);
        if (inviteInfo == null) {
            return true;
        } else if (!inviteInfo.getBeinginvited()) {
            this.cleanTimeoutInvites(inviteInfo.getInvited());
            return true;
        } else if (this.now - inviteInfo.getInviting().getInvitetime() > 20000L) {
            inviteInfo.setBeinginvited(false);
            this.cleanTimeoutInvites(inviteInfo.getInvited());
            return true;
        } else {
            return false;
        }
    }

    private void cleanTimeoutInvites(List<TeamInvite> invites) {
        List<TeamInvite> timeoutList = new ArrayList();

        for(TeamInvite invite : invites) {
            if (this.now - invite.getInvitetime() > 20000L) {
                timeoutList.add(invite);
            }
        }

        invites.removeAll(timeoutList);
    }

    private boolean checkNotInvitedIn30s(long invitedRoleId, long inviterRoleId, Long inviterTeamId) {
        InviteInfo inviteInfo = Teaminvite.get(invitedRoleId);
        if (inviteInfo != null) {
            List<TeamInvite> timeoutList = new ArrayList();
            boolean result = true;

            for(TeamInvite invited : inviteInfo.getInvited()) {
                if (this.now - invited.getInvitetime() < 20000L) {
                    if (result) {
                        if (invited.getRoleid() == inviterRoleId) {
                            result = false;
                        } else if (inviterTeamId != null && invited.getTeamid() == inviterTeamId) {
                            result = false;
                        }
                    }
                } else {
                    timeoutList.add(invited);
                }
            }

            inviteInfo.getInvited().removeAll(timeoutList);
            return result;
        } else {
            return true;
        }
    }

    private boolean checkInviterIsLeader(long inviterRoleId, Team team) {
        return team.getTeamInfo().getTeamleaderid() == inviterRoleId;
    }

    private boolean checkTeamNotFull(Team team) {
        return team.getTeamInfo().getMembers().size() < 4;
    }

    private boolean checkTeamFilter(Team team, long roleId) {
        TeamFilter filter = team.getFilter();
        return filter == null ? true : filter.checkInviteJoin(team.getTeamLeaderId(), roleId);
    }

    private boolean checkTeamFilter(long inviterId, long roleId) {
        TeamFilter filter = TeamManager.getActiveFilter(inviterId);
        return filter == null ? true : filter.checkInviteJoin(inviterId, roleId);
    }

    private boolean checkTeamInviteNotFull(Team team) {
        this.cleanTimoutInvitings(team.getTeamInfo().getInvitingids());
        return team.getTeamInfo().getInvitingids().size() < 4;
    }

    private boolean checkTeamLeaderState(long inviterRoleId) {
        BuffAgent buffagent = new BuffRoleImpl(inviterRoleId);
        return buffagent.canAddBuff(516001);
    }

    private boolean checkSingleInviteNotFull(long inviterRoleId) {
        SingleInvitings singleInvitings = Singleinviting.get(inviterRoleId);
        if (singleInvitings == null) {
            return true;
        } else {
            this.cleanTimoutInvitings(singleInvitings.getInvitingids());
            return singleInvitings.getInvitingids().size() < 4;
        }
    }

    private void cleanTimoutInvitings(Map<Long, Long> invitings) {
        Object[] keys = invitings.keySet().toArray();

        for(int i = 0; i < keys.length; ++i) {
            if (this.now - (Long)invitings.get(keys[i]) > 20000L) {
                invitings.remove(keys[i]);
            }
        }

    }

    public int getType() {
        return 794493;
    }

    public CFInviteJoinTeam() {
    }

    public CFInviteJoinTeam(long _roleid_) {
        this.roleid = _roleid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.roleid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CFInviteJoinTeam) {
            CFInviteJoinTeam _o_ = (CFInviteJoinTeam)_o1_;
            return this.roleid == _o_.roleid;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CFInviteJoinTeam _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.roleid - _o_.roleid);
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
