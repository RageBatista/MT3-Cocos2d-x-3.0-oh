//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.PropRole;
import fire.pb.StateCommon;
import fire.pb.battle.pvp.PvPTeamHandle;
import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffRoleImpl;
import fire.pb.buff.Module;
import fire.pb.clan.ClanUtils;
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
import xbean.ClanInfo;
import xbean.ClanMemberInfo;
import xbean.InviteInfo;
import xbean.Pod;
import xbean.SingleInvitings;
import xbean.TeamInvite;
import xtable.Properties;
import xtable.Roleid2clanfightid;
import xtable.Roleid2teamid;
import xtable.Singleinviting;
import xtable.Teaminvite;

public class CInviteJoinTeam extends __CInviteJoinTeam__ {
    private long now = 0L;
    public static final int PROTOCOL_TYPE = 794446;
    public long roleid;
    public int force;

    protected void process() {
        TeamManager.logger.debug("Enter: " + this.getClass());
        final long inviterRoleId = Onlines.getInstance().findRoleid(this);
        if (inviterRoleId >= 0L) {
            final long invitedRoleId = this.roleid;
            if (inviterRoleId == invitedRoleId) {
                MessageMgr.sendMsgNotify(inviterRoleId, 166006, (List)null);
            } else if (invitedRoleId >= 0L) {
                BuffAgent agent = new BuffRoleImpl(inviterRoleId, true);
                if (agent.existBuff(500019)) {
                    if (TeamManager.isInTeam(inviterRoleId)) {
                        MessageMgr.sendMsgNotify(inviterRoleId, 141866, (List)null);
                    } else {
                        MessageMgr.sendMsgNotify(inviterRoleId, 141133, (List)null);
                    }

                } else {
                    Long inviterclanfightid = Roleid2clanfightid.select(inviterRoleId);
                    if (inviterclanfightid != null) {
                        Long invitedclanfightid = Roleid2clanfightid.select(invitedRoleId);
                        if (!inviterclanfightid.equals(invitedclanfightid)) {
                            MessageMgr.sendMsgNotify(inviterRoleId, 410022, (List)null);
                            return;
                        }

                        ClanInfo claninfo = ClanUtils.getClanInfoById(inviterRoleId, true);
                        if (claninfo == null) {
                            return;
                        }

                        ClanMemberInfo memberinfo = (ClanMemberInfo)claninfo.getMembers().get(invitedRoleId);
                        if (memberinfo == null) {
                            MessageMgr.sendMsgNotify(inviterRoleId, 410023, (List)null);
                            return;
                        }
                    } else {
                        Long invitedclanfightid = Roleid2clanfightid.select(invitedRoleId);
                        if (invitedclanfightid != null && !invitedclanfightid.equals(inviterclanfightid)) {
                            MessageMgr.sendMsgNotify(inviterRoleId, 410024, (List)null);
                            return;
                        }
                    }

                    PropRole prole = new PropRole(invitedRoleId, true);
                    if (prole.getProperties().getCruise() > 0) {
                        TeamManager.logger.info("CInviteJoinTeam:被邀请人" + invitedRoleId + "巡游状态,此时不能入队");
                        MessageMgr.sendMsgNotify(inviterRoleId, 162026, (List)null);
                    } else {
                        PropRole inviterroleid = new PropRole(inviterRoleId, true);
                        if (inviterroleid.getProperties().getCruise() > 0) {
                            TeamManager.logger.error("CInviteJoinTeam:邀请人" + inviterroleid + "被邀请人" + invitedRoleId + "邀请人在巡游状态,不能邀请某人");
                            MessageMgr.sendMsgNotify(inviterRoleId, 162026, (List)null);
                        } else {
                            BuffAgent var10 = new BuffRoleImpl(invitedRoleId, true);
                            if (((BuffAgent)var10).existBuff(500019)) {
                                MessageMgr.sendMsgNotify(inviterRoleId, 141865, (List)null);
                            } else if (checkPvP(inviterRoleId, invitedRoleId) == 0) {
                                Procedure createTeamP = new Procedure() {
                                    protected boolean process() {
                                        Team team = null;
                                        Long teamId = Roleid2teamid.select(inviterRoleId);
                                        if (teamId != null) {
                                            team = new Team(teamId, false);
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

                                        CInviteJoinTeam.this.now = System.currentTimeMillis();
                                        if (!CInviteJoinTeam.this.checkOnline(invitedRoleId, inviterRoleId)) {
                                            TeamManager.logger.info("FAIL:CInviteJoinTeam:被邀请的玩家不在线,RoleId: " + invitedRoleId);
                                        } else if (!CInviteJoinTeam.this.checkInviterStatus(inviterRoleId)) {
                                            MessageMgr.psendMsgNotify(inviterRoleId, 141618, (List)null);
                                            TeamManager.logger.info("FAIL:CInviteJoinTeam:邀请者处于不能组队的状态,RoleId: " + inviterRoleId);
                                        } else if (!CInviteJoinTeam.this.checkInvitedStatus(invitedRoleId)) {
                                            MessageMgr.psendMsgNotify(inviterRoleId, 141619, (List)null);
                                            TeamManager.logger.info("FAIL:CInviteJoinTeam:被邀请者处于不能组队的状态,RoleId: " + invitedRoleId);
                                        } else if (!CInviteJoinTeam.this.checkInvitedTeamFuctionEnable(invitedRoleId)) {
                                            MessageMgr.psendMsgNotify(inviterRoleId, 141201, (List)null);
                                            TeamManager.logger.info("FAIL:CInviteJoinTeam:被邀请者的组队功能没有打开,invitedRoleId: " + invitedRoleId);
                                        } else if (!CInviteJoinTeam.this.checkInvitedInNoTeam(invitedTeamId)) {
                                            TeamManager.logger.info("FAIL:CInviteJoinTeam:被邀请者在队伍中,invitedRoleId: " + invitedRoleId);
                                            MessageMgr.psendMsgNotify(inviterRoleId, 141191, (List)null);
                                        } else if (!CInviteJoinTeam.this.checkNotBeingInvited(invitedRoleId)) {
                                            MessageMgr.psendMsgNotify(inviterRoleId, 141202, (List)null);
                                            TeamManager.logger.info("FAIL:CInviteJoinTeam:被邀请者正在被其他人邀请中,invitedRoleId: " + invitedRoleId);
                                        } else if (!CInviteJoinTeam.this.checkNotInvitedIn30s(invitedRoleId, inviterRoleId, inviterTeamId)) {
                                            TeamManager.logger.info("FAIL:CInviteJoinTeam:被邀请者30秒内曾经被队伍或者个人邀请过,invitedRoleId: " + invitedRoleId);
                                            MessageMgr.psendMsgNotify(inviterRoleId, 141050, (List)null);
                                        } else if (team != null) {
                                            if (!CInviteJoinTeam.this.checkTeamNotFull(team)) {
                                                psendWhileCommit(inviterRoleId, new STeamError(11));
                                                TeamManager.logger.info("FAIL:CInviteJoinTeam:邀请队伍满人,TeamId: " + inviterTeamId);
                                            } else if (!CInviteJoinTeam.this.checkTeamFilter(team, invitedRoleId)) {
                                                TeamManager.logger.info("FAIL:CInviteJoinTeam:TeamFilter否决,TeamId: " + inviterTeamId);
                                            } else if (!CInviteJoinTeam.this.checkTeamInviteNotFull(team)) {
                                                psend(inviterRoleId, new STeamError(15));
                                                TeamManager.logger.info("FAIL:CInviteJoinTeam:邀请队伍的正在邀请人数达到4个，不能再邀请更多,TeamId: " + inviterTeamId);
                                            } else if (!CInviteJoinTeam.this.checkTeamLeaderState(inviterRoleId)) {
                                                TeamManager.logger.info("FAIL:CInviteJoinTeam:队长当前状态不能邀请。");
                                            } else {
                                                if (!this.checkMap()) {
                                                    return false;
                                                }

                                                boolean isForceTeam = TeamManager.getInstance().isForceTeam(teamId, invitedRoleId);
                                                TeamManager.logger.info("SUCC:CInviteJoinTeam:满足条件，可以发出队伍邀请 " + inviterTeamId);
                                                SInviteJoinTeam snd = new SInviteJoinTeam();
                                                snd.op = 0;
                                                snd.invitername = Properties.get(inviterRoleId).getRolename();
                                                snd.inviterlevel = Properties.get(inviterRoleId).getLevel() + Properties.get(inviterRoleId).getZhuansheng() * 1000;
                                                team.getTeamInfo().getInvitingids().put(invitedRoleId, CInviteJoinTeam.this.now);
                                                InviteInfo inviteInfo = Teaminvite.get(invitedRoleId);
                                                if (inviteInfo == null) {
                                                    inviteInfo = Pod.newInviteInfo();
                                                    Teaminvite.add(invitedRoleId, inviteInfo);
                                                }

                                                if (inviterTeamId == null) {
                                                    return false;
                                                }

                                                inviteInfo.setBeinginvited(true);
                                                inviteInfo.getInviting().setTeamid(inviterTeamId);
                                                inviteInfo.getInviting().setRoleid(inviterRoleId);
                                                inviteInfo.getInviting().setInvitetime(CInviteJoinTeam.this.now);
                                                inviteInfo.getInvited().add(inviteInfo.getInviting().copy());
                                                if (isForceTeam && CInviteJoinTeam.this.force == 1) {
                                                    snd.op = 1;
                                                    Procedure.psendWhileCommit(invitedRoleId, snd);
                                                } else if (!team.isTeamLeader(inviterRoleId)) {
                                                    snd.op = 2;
                                                    snd.leaderroleid = team.getTeamLeaderId();
                                                    psendWhileCommit(inviterRoleId, new SInviteJoinSucc(invitedRoleId));
                                                    MessageMgr.psendMsgNotify(inviterRoleId, 142358, (List)null);
                                                    Procedure.psendWhileCommit(invitedRoleId, snd);
                                                } else {
                                                    xbean.Properties invitedProp = Properties.select(invitedRoleId);
                                                    if (invitedProp != null) {
                                                        Integer v = (Integer)invitedProp.getSysconfigmap().get(11);
                                                        if (v != null && v == 1) {
                                                            MessageMgr.psendMsgNotify(inviterRoleId, 166060, (List)null);
                                                            return false;
                                                        }
                                                    }

                                                    snd.op = 0;
                                                    psendWhileCommit(inviterRoleId, new SInviteJoinSucc(invitedRoleId));
                                                    MessageMgr.psendMsgNotify(inviterRoleId, 142358, (List)null);
                                                    Procedure.psendWhileCommit(invitedRoleId, snd);
                                                }
                                            }
                                        } else if (!CInviteJoinTeam.this.checkSingleInviteNotFull(inviterRoleId)) {
                                            psend(inviterRoleId, new STeamError(15));
                                            TeamManager.logger.debug("FAIL:邀请者正在邀请人数达到4个，不能再邀请更 " + inviterRoleId);
                                        } else if (!CInviteJoinTeam.this.checkTeamFilter(inviterRoleId, invitedRoleId)) {
                                            TeamManager.logger.debug("FAIL:TeamFilter否决,TeamId: " + inviterTeamId);
                                        } else if (Module.existState(invitedRoleId, 507026)) {
                                            TeamManager.logger.info("玩家(roleId=" + invitedRoleId + ")invite处于副本中,不能组队");
                                        } else if (Module.existState(inviterRoleId, 507026)) {
                                            TeamManager.logger.info("玩家(roleId=" + inviterRoleId + ")invite处于副本中,不能组队");
                                        } else {
                                            if (!this.checkMap()) {
                                                return false;
                                            }

                                            TeamManager.logger.debug("SUCC:满足条件，可以发出个人邀请 " + inviterRoleId);
                                            xbean.Properties inviterProperty = Properties.get(inviterRoleId);
                                            SInviteJoinTeam snd = new SInviteJoinTeam();
                                            snd.op = 0;
                                            snd.invitername = inviterProperty.getRolename();
                                            snd.inviterlevel = inviterProperty.getLevel() + inviterProperty.getZhuansheng() * 1000;
                                            SingleInvitings singleInvitings = Singleinviting.get(inviterRoleId);
                                            if (singleInvitings == null) {
                                                singleInvitings = Pod.newSingleInvitings();
                                                Singleinviting.add(inviterRoleId, singleInvitings);
                                            }

                                            singleInvitings.getInvitingids().put(invitedRoleId, CInviteJoinTeam.this.now);
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
                                            inviteInfo.getInviting().setInvitetime(CInviteJoinTeam.this.now);
                                            inviteInfo.getInvited().add(inviteInfo.getInviting().copy());
                                            psendWhileCommit(inviterRoleId, new SInviteJoinSucc(invitedRoleId));
                                            MessageMgr.psendMsgNotify(inviterRoleId, 142358, (List)null);
                                            Procedure.psendWhileCommit(invitedRoleId, snd);
                                        }

                                        return true;
                                    }

                                    private boolean checkMap() {
                                        boolean inWaiting1 = false;
                                        boolean inWaiting = false;
                                        Role invitMaprole = RoleManager.getInstance().getRoleByID(inviterRoleId);
                                        Role desMaprole = RoleManager.getInstance().getRoleByID(invitedRoleId);
                                        if (invitMaprole != null && desMaprole != null) {
                                            int srcMapId = invitMaprole.getMapId();
                                            MapConfig cfg = (MapConfig)ConfigManager.getInstance().getConf(MapConfig.class).get(srcMapId);
                                            int desMapId = desMaprole.getMapId();
                                            MapConfig descfg = (MapConfig)ConfigManager.getInstance().getConf(MapConfig.class).get(desMapId);
                                            if (srcMapId != desMapId || !inWaiting && !inWaiting1) {
                                                if (cfg != null && descfg != null) {
                                                    return cfg.getSafemap() == descfg.getSafemap() && cfg.getSafemap() == 1 ? true : true;
                                                } else {
                                                    return true;
                                                }
                                            } else {
                                                MessageMgr.psendMsgNotifyWhileRollback(inviterRoleId, 145250, (List)null);
                                                return false;
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
        }
    }

    private static int checkPvP(long inviterRoleId, long invitedRoleId) {
        return PvPTeamHandle.onInviteJoinTeam(inviterRoleId, invitedRoleId);
    }

    private boolean checkOnline(long invitedRoleId, long inviterRoleId) {
        if (StateCommon.isOnlineBuffer(invitedRoleId)) {
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
        return 794446;
    }

    public CInviteJoinTeam() {
    }

    public CInviteJoinTeam(long _roleid_, int _force_) {
        this.roleid = _roleid_;
        this.force = _force_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.roleid);
            _os_.marshal(this.force);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.force = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CInviteJoinTeam) {
            CInviteJoinTeam _o_ = (CInviteJoinTeam)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else {
                return this.force == _o_.force;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.force;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append(this.force).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CInviteJoinTeam _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.roleid - _o_.roleid);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.force - _o_.force;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
