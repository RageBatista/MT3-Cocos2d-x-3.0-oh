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
import fire.pb.clan.ClanUtils;
import fire.pb.event.ArriveTeamSpecialQuestEvent;
import fire.pb.event.Poster;
import fire.pb.main.ConfigManager;
import fire.pb.map.MapConfig;
import fire.pb.map.Role;
import fire.pb.map.RoleManager;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import mkdb.Lockeys;
import mkdb.Procedure;
import mkdb.Trace;
import xbean.ClanInfo;
import xbean.ClanMemberInfo;
import xbean.InviteInfo;
import xbean.Properties;
import xbean.SingleInvitings;
import xbean.TeamInfo;
import xbean.TeamInvite;
import xtable.Locks;
import xtable.Roleid2clanfightid;
import xtable.Roleid2teamid;
import xtable.Singleinviting;
import xtable.Teaminvite;

public class CRespondInvite extends __CRespondInvite__ {
    private long now = 0L;
    Team team;
    public static final int PROTOCOL_TYPE = 794448;
    public byte agree;

    protected void process() {
        TeamManager.logger.debug("Enter: " + this.getClass());
        final long invitedRoleId = Onlines.getInstance().findRoleid(this);
        if (invitedRoleId >= 0L) {
            Procedure resInviteP = new Procedure() {
                protected boolean process() {
                    CRespondInvite.this.now = System.currentTimeMillis();

                    boolean var2;
                    try {
                        InviteInfo inviteInfo = Teaminvite.select(invitedRoleId);
                        if (inviteInfo != null) {
                            if (!inviteInfo.getBeinginvited()) {
                                var2 = true;
                                return var2;
                            }

                            if (CRespondInvite.this.now - inviteInfo.getInviting().getInvitetime() > 20000L) {
                                inviteInfo.setBeinginvited(false);
                                var2 = true;
                                return var2;
                            }

                            TeamInvite inviting = inviteInfo.getInviting();
                            long inviterRoleId = inviting.getRoleid();
                            Long inviterTeamId = null;
                            if (inviting.getTeamid() > -1L) {
                                inviterTeamId = inviting.getTeamid();
                            }

                            int lockState = 0;
                            if (CRespondInvite.this.agree == 1) {
                                Long inviterclanfightid = Roleid2clanfightid.select(inviterRoleId);
                                if (inviterclanfightid != null) {
                                    Long invitedclanfightid = Roleid2clanfightid.select(invitedRoleId);
                                    if (!inviterclanfightid.equals(invitedclanfightid)) {
                                        MessageMgr.sendMsgNotify(inviterRoleId, 410022, (List)null);
                                        MessageMgr.sendMsgNotify(invitedRoleId, 410031, (List)null);
                                        boolean var31 = true;
                                        return var31;
                                    }

                                    ClanInfo claninfo = ClanUtils.getClanInfoById(inviterRoleId, true);
                                    if (claninfo == null) {
                                        boolean var37 = true;
                                        return var37;
                                    }

                                    ClanMemberInfo memberinfo = (ClanMemberInfo)claninfo.getMembers().get(invitedRoleId);
                                    if (memberinfo == null) {
                                        MessageMgr.sendMsgNotify(inviterRoleId, 410023, (List)null);
                                        MessageMgr.sendMsgNotify(invitedRoleId, 410029, (List)null);
                                        boolean var11 = true;
                                        return var11;
                                    }
                                } else {
                                    Long invitedclanfightid = Roleid2clanfightid.select(invitedRoleId);
                                    if (invitedclanfightid != null && !invitedclanfightid.equals(inviterclanfightid)) {
                                        MessageMgr.sendMsgNotify(inviterRoleId, 410024, (List)null);
                                        MessageMgr.sendMsgNotify(invitedRoleId, 410032, (List)null);
                                        boolean var34 = true;
                                        return var34;
                                    }
                                }

                                PropRole inviterprop = new PropRole(inviterRoleId, true);
                                if (inviterprop.getProperties().getCruise() > 0) {
                                    MessageMgr.sendMsgNotify(invitedRoleId, 162026, (List)null);
                                    MessageMgr.sendMsgNotify(inviterRoleId, 162027, (List)null);
                                    TeamManager.logger.info("CRespondInvite1:邀请人" + inviterRoleId + "被邀请人" + invitedRoleId + ",邀请人在巡游状态,不能邀请某人");
                                    boolean invitedTeamId = true;
                                    return invitedTeamId;
                                }

                                PropRole invitedprop = new PropRole(invitedRoleId, true);
                                if (invitedprop.getProperties().getCruise() > 0) {
                                    MessageMgr.sendMsgNotify(invitedRoleId, 162027, (List)null);
                                    MessageMgr.sendMsgNotify(inviterRoleId, 162026, (List)null);
                                    TeamManager.logger.info("CRespondInvite2:邀请人" + inviterRoleId + "被邀请人" + invitedRoleId + ",邀请人在巡游状态,不能邀请某人");
                                    boolean teamInfox = true;
                                    return teamInfox;
                                }

                                if (CRespondInvite.this.checkInviteFromTeam(inviterTeamId)) {
                                    lockState = 3;
                                } else {
                                    inviterTeamId = Roleid2teamid.select(inviterRoleId);
                                    if (inviterTeamId != null) {
                                        lockState = 3;
                                    } else {
                                        lockState = 2;
                                    }
                                }
                            } else {
                                lockState = 1;
                            }

                            switch (lockState) {
                                case 1:
                                    Long[] roleids1 = new Long[1];
                                    roleids1[0] = invitedRoleId;
                                    this.lock(Lockeys.get(Locks.ROLELOCK, (Object[])roleids1));
                                    break;
                                case 2:
                                    Object[] roleids2 = new Object[2];
                                    if (inviterRoleId < invitedRoleId) {
                                        roleids2[0] = inviterRoleId;
                                        roleids2[1] = invitedRoleId;
                                    } else {
                                        roleids2[0] = invitedRoleId;
                                        roleids2[1] = inviterRoleId;
                                    }

                                    this.lock(Lockeys.get(Locks.ROLELOCK, roleids2));
                                    break;
                                case 3:
                                    TeamInfo teamInfo = xtable.Team.get(inviterTeamId);
                                    if (teamInfo == null) {
                                        psend(invitedRoleId, new STeamError(16));
                                        TeamManager.logger.debug("FAIL:邀请您的队伍已经解散,TeamId: " + inviterTeamId);
                                        boolean teamx = true;
                                        return teamx;
                                    }

                                    CRespondInvite.this.team = new Team(inviterTeamId, false);
                                    Set<Long> roleids = CRespondInvite.this.team.getAllMemberIdSet();
                                    roleids.add(invitedRoleId);
                                    this.lock(Lockeys.get(Locks.ROLELOCK, roleids));
                                    break;
                                default:
                                    boolean var52 = true;
                                    return var52;
                            }

                            if (CRespondInvite.this.agree == 1) {
                            }

                            PropRole prole = new PropRole(invitedRoleId, true);
                            String invitedName = prole.getName();
                            Long invitedTeamId = Roleid2teamid.get(invitedRoleId);
                            if (!CRespondInvite.this.checkInviteExist(invitedRoleId)) {
                                TeamManager.logger.debug("FAIL:邀请已经超时或者邀请不存在,RoleId: " + invitedRoleId);
                                boolean var46 = true;
                                return var46;
                            }

                            if (CRespondInvite.this.agree != 1) {
                                List<String> name = new ArrayList();
                                name.add(invitedName);
                                if (CRespondInvite.this.checkInviteFromTeam(inviterTeamId)) {
                                    Long leaderId = xtable.Team.selectTeamleaderid(inviterTeamId);
                                    if (leaderId != null) {
                                        MessageMgr.psendMsgNotify(leaderId, 140851, name);
                                        psendWhileCommit(leaderId, new SRespondInvite(invitedRoleId, (byte)0));
                                    }
                                } else {
                                    MessageMgr.psendMsgNotify(inviterRoleId, 140851, name);
                                    psendWhileCommit(inviterRoleId, new SRespondInvite(invitedRoleId, (byte)0));
                                }

                                TeamManager.logger.debug("FAIL，不接受组队邀请,invitedRoleId: " + invitedRoleId);
                                return true;
                            }

                            if (CRespondInvite.checkPvP(inviterRoleId, invitedRoleId) != 0) {
                                boolean var44 = true;
                                return var44;
                            }

                            if (!CRespondInvite.this.checkOnline(invitedRoleId)) {
                                TeamManager.logger.debug("FAIL:被邀请者不在线,接受邀请后又下线了？,RoleId: " + invitedRoleId);
                                return true;
                            }

                            if (!CRespondInvite.this.checkInvitedTeamFuctionEnable(invitedRoleId)) {
                                psend(invitedRoleId, new STeamError(7));
                                TeamManager.logger.debug("FAIL:被邀请者的组队功能没有打开,RoleId: " + invitedRoleId);
                                return true;
                            }

                            if (!CRespondInvite.this.checkInvitedInNoTeam(invitedTeamId)) {
                                TeamManager.logger.debug("FAIL:被邀请者在队伍中,RoleId: " + invitedTeamId);
                                return true;
                            }

                            if (inviting.getTeamid() > -1L) {
                                TeamManager.logger.debug("INFO:来自队伍的邀请,TeamId: " + inviterTeamId);
                                TeamInfo teamInfo = xtable.Team.get(inviterTeamId);
                                if (!CRespondInvite.this.checkInviterTeamExist(teamInfo)) {
                                    psend(invitedRoleId, new STeamError(16));
                                    TeamManager.logger.debug("FAIL:邀请您的队伍已经解散,TeamId: " + inviterTeamId);
                                    return true;
                                }

                                if (!CRespondInvite.this.checkTeamInvitingValid(teamInfo, invitedRoleId)) {
                                    TeamManager.logger.debug("FAIL:队伍邀请已经超时,TeamId: " + inviterTeamId);
                                    return true;
                                }

                                if (!CRespondInvite.this.checkTeamNotFull(teamInfo)) {
                                    MessageMgr.psendMsgNotify(invitedRoleId, 145740, (List)null);
                                    psend(invitedRoleId, new STeamError(11));
                                    TeamManager.logger.debug("FAIL:对方队伍人数已满,TeamId: " + inviterTeamId);
                                    return true;
                                }

                                if (CRespondInvite.this.isLeaderInDuel(teamInfo.getTeamleaderid())) {
                                    TeamManager.logger.debug("FAIL:队长在决斗,TeamId: " + inviterTeamId);
                                    return true;
                                }

                                if (!CRespondInvite.this.checkMap(teamInfo.getTeamleaderid(), invitedRoleId)) {
                                    return true;
                                }

                                Team team = new Team(inviterTeamId, false);
                                TeamManager.logger.debugWhileCommit("SUCC:队伍可以加入这个新成员(原来的队伍),TeamId: " + inviterTeamId);
                                boolean ok = team.addNewMemberWithSP(invitedRoleId);
                                if (ok) {
                                    boolean iscruise = CRespondInvite.this.checkCruiseWhenInvited(invitedRoleId);
                                    if (iscruise) {
                                        (new PAbsentReturnTeam(invitedRoleId, 1)).call();
                                    } else {
                                        int ret = TeamManager.getInstance().execGotoLeader(invitedRoleId, team, true, 2);
                                        if (ret == 0) {
                                            Properties invitedprop = xtable.Properties.get(invitedRoleId);
                                            List<String> params = new ArrayList();
                                            params.add(invitedprop.getRolename());
                                            MessageMgr.sendMsgNotify(teamInfo.getTeamleaderid(), 160196, params);
                                        }
                                    }
                                }

                                Poster.getPoster().dispatchEvent(new ArriveTeamSpecialQuestEvent(team.getTeamLeaderId(), invitedRoleId));
                                boolean var54 = ok;
                                return var54;
                            }

                            TeamManager.logger.debug("INFO:来自个人的邀请,inviterRoleId: " + inviterRoleId);
                            if (!CRespondInvite.this.checkOnline(inviterRoleId)) {
                                psend(invitedRoleId, new STeamError(6));
                                TeamManager.logger.debug("FAIL:邀请者不在线,inviterRoleId: " + inviterRoleId);
                                return true;
                            }

                            inviterTeamId = Roleid2teamid.get(inviterRoleId);
                            if (!CRespondInvite.this.checkInviterInTeam(inviterTeamId)) {
                                TeamManager.logger.debug("INFO:邀请者邀请时没有队伍，现在仍然没有,inviterRoleId: " + inviterRoleId);
                                if (!CRespondInvite.this.checkSingleInvitingExist(inviterRoleId, invitedRoleId)) {
                                    TeamManager.logger.debug("FAIL:邀请者的邀请已经超时,inviterRoleId: " + inviterRoleId);
                                    return true;
                                }

                                if (CRespondInvite.this.isLeaderInDuel(inviterRoleId)) {
                                    TeamManager.logger.debug("FAIL:队长在决斗,TeamId: " + inviterTeamId);
                                    return true;
                                }

                                if (!CRespondInvite.this.checkMap(inviterRoleId, invitedRoleId)) {
                                    return true;
                                }

                                Team team = TeamManager.getInstance().createNewTeam(inviterRoleId);
                                if (team == null) {
                                    MessageMgr.sendMsgNotify(invitedRoleId, 141619, (List)null);
                                    TeamManager.logger.debug("FAIL:创建队伍失败（可能由于状态冲突）。");
                                    boolean var49 = true;
                                    return var49;
                                }

                                TeamManager.logger.debugWhileCommit("SUCC:队伍加入这个新成员(新建的队伍，邀请者为队长),TeamId: " + inviterTeamId);
                                boolean leaderId = team.addNewMemberWithSP(invitedRoleId);
                                return leaderId;
                            }

                            Trace.log(Trace.DEBUG, "邀请者邀请时没有队伍，但是回复时已经有队伍,TeamId: " + inviterTeamId);
                            TeamInfo teamInfo = xtable.Team.get(inviterTeamId);
                            if (!CRespondInvite.this.checkInviterIsLeader(inviterRoleId, teamInfo)) {
                                MessageMgr.psendMsgNotify(invitedRoleId, 141861, (List)null);
                                TeamManager.logger.debug("FAIL:邀请者不是队长,TeamId: " + inviterTeamId);
                                return true;
                            }

                            if (CRespondInvite.this.isLeaderInDuel(inviterRoleId)) {
                                TeamManager.logger.debug("FAIL:队长在决斗,TeamId: " + inviterTeamId);
                                return true;
                            }

                            if (!CRespondInvite.this.checkTeamInvitingValid(teamInfo, invitedRoleId)) {
                                TeamManager.logger.debug("FAIL:邀请已经超时,TeamId: " + inviterTeamId);
                                return true;
                            }

                            if (!CRespondInvite.this.checkTeamNotFull(teamInfo) || !CRespondInvite.this.checkMap(teamInfo.getTeamleaderid(), invitedRoleId)) {
                                return true;
                            }

                            Team team = new Team(inviterTeamId, false);
                            TeamManager.logger.debugWhileCommit("SUCC:队伍加入这个新成员(后来的队伍),TeamId: " + inviterTeamId);
                            boolean ok = team.addNewMemberWithSP(invitedRoleId);
                            return ok;
                        }

                        var2 = true;
                    } finally {
                        CRespondInvite.this.deleteInvite(invitedRoleId);
                    }

                    return var2;
                }
            };
            resInviteP.submit();
        }
    }

    private boolean checkMap(long leaderRoleId, long applierRoleId) {
        boolean inWaiting1 = false;
        boolean inWaiting = false;
        Role invitMaprole = RoleManager.getInstance().getRoleByID(leaderRoleId);
        Role desMaprole = RoleManager.getInstance().getRoleByID(applierRoleId);
        if (invitMaprole != null && desMaprole != null) {
            int srcMapId = invitMaprole.getMapId();
            MapConfig cfg = (MapConfig)ConfigManager.getInstance().getConf(MapConfig.class).get(srcMapId);
            int desMapId = desMaprole.getMapId();
            MapConfig descfg = (MapConfig)ConfigManager.getInstance().getConf(MapConfig.class).get(desMapId);
            if (!inWaiting && !inWaiting1) {
                if (cfg != null && descfg != null) {
                    return cfg.getSafemap() == descfg.getSafemap() && cfg.getSafemap() == 1 ? true : true;
                } else {
                    return true;
                }
            } else {
                return false;
            }
        } else {
            return true;
        }
    }

    private static int checkPvP(long inviterRoleId, long invitedRoleId) {
        return PvPTeamHandle.onRespondInvite(inviterRoleId, invitedRoleId);
    }

    private boolean checkInviteExist(long invitedRoleId) {
        InviteInfo invite = Teaminvite.get(invitedRoleId);
        if (invite == null) {
            return false;
        } else if (!invite.getBeinginvited()) {
            return false;
        } else if (this.now - invite.getInviting().getInvitetime() > 20000L) {
            invite.setBeinginvited(false);
            this.cleanTimeoutInvites(invite.getInvited());
            return false;
        } else {
            return true;
        }
    }

    private boolean checkOnline(long roleId) {
        return StateCommon.isOnline(roleId);
    }

    private boolean checkInvitedTeamFuctionEnable(long invitedRoleId) {
        return true;
    }

    private boolean checkInvitedInNoTeam(Long invitedTeamId) {
        return invitedTeamId == null;
    }

    private boolean checkCruiseWhenInvited(long invitedRoleId) {
        PropRole prole = new PropRole(invitedRoleId, true);
        return prole.getProperties().getCruise() > 0;
    }

    private boolean checkInviteFromTeam(Long inviterTeamId) {
        return inviterTeamId != null;
    }

    private boolean checkInviterTeamExist(TeamInfo teamInfo) {
        return teamInfo != null;
    }

    private boolean checkTeamInvitingValid(TeamInfo teamInfo, long invitedRoleId) {
        Map<Long, Long> invitings = teamInfo.getInvitingids();
        this.cleanTimoutInvitings(invitings);
        return invitings.get(invitedRoleId) != null;
    }

    private boolean checkTeamNotFull(TeamInfo teamInfo) {
        return teamInfo.getMembers().size() < 4;
    }

    private boolean checkInviterInTeam(Long inviterTeamId) {
        return inviterTeamId != null;
    }

    private boolean checkInviterIsLeader(long inviterRoleId, TeamInfo teamInfo) {
        return teamInfo.getTeamleaderid() == inviterRoleId;
    }

    private boolean checkSingleInvitingExist(long inviterRoleId, long invitedRoleId) {
        SingleInvitings singleInvitings = Singleinviting.get(inviterRoleId);
        if (singleInvitings == null) {
            return false;
        } else {
            this.cleanTimoutInvitings(singleInvitings.getInvitingids());
            return singleInvitings.getInvitingids().get(invitedRoleId) != null;
        }
    }

    private void deleteInvite(final long invitedRoleId) {
        InviteInfo inviteInfo = Teaminvite.select(invitedRoleId);
        if (inviteInfo != null) {
            if (inviteInfo.getInviting().getTeamid() > -1L) {
                TeamInfo team = xtable.Team.get(inviteInfo.getInviting().getTeamid());
                inviteInfo = Teaminvite.get(invitedRoleId);
                if (inviteInfo == null) {
                    return;
                }

                if (team != null) {
                    team.getInvitingids().remove(invitedRoleId);
                }
            } else {
                inviteInfo = Teaminvite.get(invitedRoleId);
                if (inviteInfo == null) {
                    return;
                }

                final long invitingroleid = inviteInfo.getInviting().getRoleid();
                Procedure.pexecuteWhileCommit(new Procedure() {
                    protected boolean process() throws Exception {
                        SingleInvitings singleInvitings = Singleinviting.get(invitingroleid);
                        if (singleInvitings != null) {
                            singleInvitings.getInvitingids().remove(invitedRoleId);
                            if (singleInvitings.getInvitingids().size() == 0) {
                                Singleinviting.remove(invitingroleid);
                            }
                        }

                        return true;
                    }
                });
            }

            inviteInfo.setBeinginvited(false);
            this.cleanTimeoutInvites(inviteInfo.getInvited());
            if (inviteInfo.getInvited().size() == 0) {
                Teaminvite.remove(invitedRoleId);
            }

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

    private void cleanTimoutInvitings(Map<Long, Long> invitings) {
        Object[] keys = invitings.keySet().toArray();

        for(int i = 0; i < keys.length; ++i) {
            if (this.now - (Long)invitings.get(keys[i]) > 20000L) {
                invitings.remove(keys[i]);
            }
        }

    }

    public boolean isLeaderInDuel(long leaderRoleId) {
        BuffAgent agent = new BuffRoleImpl(leaderRoleId, true);
        if (agent.existBuff(500019)) {
            MessageMgr.sendMsgNotify(leaderRoleId, 141867, (List)null);
            return true;
        } else {
            return false;
        }
    }

    public int getType() {
        return 794448;
    }

    public CRespondInvite() {
    }

    public CRespondInvite(byte _agree_) {
        this.agree = _agree_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.agree);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.agree = _os_.unmarshal_byte();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CRespondInvite) {
            CRespondInvite _o_ = (CRespondInvite)_o1_;
            return this.agree == _o_.agree;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.agree;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.agree).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CRespondInvite _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.agree - _o_.agree;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
