//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.PropRole;
import fire.pb.battle.pvp.PvPTeamHandle;
import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffRoleImpl;
import fire.pb.clan.ClanUtils;
import fire.pb.map.Role;
import fire.pb.map.RoleManager;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.List;
import mkdb.Lockeys;
import mkdb.Procedure;
import xbean.ClanInfo;
import xbean.ClanMemberInfo;
import xbean.Properties;
import xbean.TeamMatch;
import xtable.Locks;
import xtable.Roleid2clanfightid;
import xtable.Roleid2teamid;
import xtable.Roleonoffstate;

public class CRequestJoinTeam extends __CRequestJoinTeam__ {
    private long now = 0L;
    Team team;
    public static final int PROTOCOL_TYPE = 794449;
    public long roleid;

    protected void process() {
        final long applierRoleId = Onlines.getInstance().findRoleid(this);
        if (applierRoleId >= 0L) {
            Properties prop = xtable.Properties.select(this.roleid);
            if (prop != null) {
                Long appliedclanfightid = Roleid2clanfightid.select(this.roleid);
                if (appliedclanfightid != null) {
                    Long applierclanfightid = Roleid2clanfightid.select(applierRoleId);
                    if (!appliedclanfightid.equals(applierclanfightid)) {
                        MessageMgr.sendMsgNotify(applierRoleId, 410025, (List)null);
                        return;
                    }

                    ClanInfo claninfo = ClanUtils.getClanInfoById(this.roleid, true);
                    if (claninfo == null) {
                        return;
                    }

                    ClanMemberInfo memberinfo = (ClanMemberInfo)claninfo.getMembers().get(applierRoleId);
                    if (memberinfo == null) {
                        MessageMgr.sendMsgNotify(applierRoleId, 410026, (List)null);
                        return;
                    }
                } else {
                    Long applierclanfightid = Roleid2clanfightid.select(applierRoleId);
                    if (applierclanfightid != null && !applierclanfightid.equals(appliedclanfightid)) {
                        MessageMgr.sendMsgNotify(applierclanfightid, 410027, (List)null);
                        return;
                    }
                }

                TeamManager.logger.debug("角色（Id = " + applierRoleId + "）申请 入队");
                BuffAgent agent = new BuffRoleImpl(applierRoleId, true);
                if (agent.existBuff(500019)) {
                    MessageMgr.sendMsgNotify(applierRoleId, 141133, (List)null);
                } else {
                    PropRole applierprop = new PropRole(applierRoleId, true);
                    if (applierprop.getProperties().getCruise() > 0) {
                        TeamManager.logger.info("CRequestJoinTeam:申请入队者" + applierRoleId + "在巡游状态,此时不能申请入队");
                        MessageMgr.sendMsgNotify(applierRoleId, 162027, (List)null);
                    } else {
                        PropRole leaderprop = new PropRole(this.roleid, true);
                        if (leaderprop.getProperties().getCruise() > 0) {
                            TeamManager.logger.info("CRequestJoinTeam:队伍队长" + this.roleid + "申请人" + applierRoleId + "队伍队长正在巡游状态,不能申请入队");
                            MessageMgr.sendMsgNotify(applierRoleId, 162026, (List)null);
                        } else if (checkPvP(this.roleid, applierRoleId) == 0) {
                            BuffAgent leaderAgent = new BuffRoleImpl(this.roleid, true);
                            if (leaderAgent.existBuff(500019)) {
                                MessageMgr.sendMsgNotify(applierRoleId, 141867, (List)null);
                            } else {
                                Procedure requestJoinTeamP = new Procedure() {
                                    protected boolean process() {
                                        Long teamId = Roleid2teamid.select(CRequestJoinTeam.this.roleid);
                                        if (teamId == null) {
                                            MessageMgr.psendMsgNotify(applierRoleId, 150035, (List)null);
                                            return true;
                                        } else {
                                            CRequestJoinTeam.this.team = new Team(teamId, false);
                                            if (!CRequestJoinTeam.this.team.isInTeam(CRequestJoinTeam.this.roleid)) {
                                                return true;
                                            } else {
                                                long leaderRoleId = CRequestJoinTeam.this.team.getTeamInfo().getTeamleaderid();
                                                Long[] roleids = new Long[2];
                                                if (leaderRoleId < applierRoleId) {
                                                    roleids[0] = leaderRoleId;
                                                    roleids[1] = applierRoleId;
                                                } else {
                                                    roleids[0] = applierRoleId;
                                                    roleids[1] = leaderRoleId;
                                                }

                                                this.lock(Lockeys.get(Locks.ROLELOCK, (Object[])roleids));
                                                CRequestJoinTeam.this.now = System.currentTimeMillis();
                                                if (!CRequestJoinTeam.this.checkOnline(applierRoleId)) {
                                                    TeamManager.logger.debug("FAIL:申请者不在线,applierRoleId" + applierRoleId);
                                                } else if (!CRequestJoinTeam.this.checkApplierNotInTeam(applierRoleId)) {
                                                    MessageMgr.sendMsgNotify(applierRoleId, 140855, (List)null);
                                                    TeamManager.logger.debug("FAIL:申请者在队伍中,applierRoleId" + applierRoleId);
                                                } else if (!CRequestJoinTeam.this.checkApplierStatusValid(applierRoleId)) {
                                                    psend(applierRoleId, new STeamError(9));
                                                    TeamManager.logger.debug("FAIL:申请者处于不能申请组队的状态？（飞行，跑商，摆摊，护送等）,applierRoleId" + applierRoleId);
                                                } else if (!CRequestJoinTeam.this.checkLeaderTeamFuncEnable(leaderRoleId)) {
                                                    MessageMgr.psendMsgNotify(applierRoleId, 141201, (List)null);
                                                    TeamManager.logger.debug("FAIL:队长组队开关未打开,leaderRoleId" + leaderRoleId);
                                                } else if (!CRequestJoinTeam.this.checkTeamNotFull(CRequestJoinTeam.this.team)) {
                                                    MessageMgr.sendMsgNotify(applierRoleId, 145045, 0, (List)null);
                                                    TeamManager.logger.debug("FAIL:队伍人数已满,teamId" + teamId);
                                                } else if (!CRequestJoinTeam.this.checkTeamFilter(CRequestJoinTeam.this.team, applierRoleId)) {
                                                    TeamManager.logger.debug("FAIL:TeamFilter否决,TeamId: " + teamId);
                                                } else if (CRequestJoinTeam.this.team.isApplyListFull()) {
                                                    psend(applierRoleId, new STeamError(20));
                                                    TeamManager.logger.debug("FAIL:队伍申请列表已满（15个）,teamId" + teamId);
                                                } else if (CRequestJoinTeam.this.team.getTeamInfo().getApplierids().containsKey(applierRoleId)) {
                                                    psend(applierRoleId, new STeamError(30));
                                                    TeamManager.logger.debug("FAIL:申请者正在该队伍申请列表中,teamId" + teamId);
                                                } else if (!CRequestJoinTeam.this.checkLevelRequirementValid(CRequestJoinTeam.this.team, applierRoleId)) {
                                                    MessageMgr.psendMsgNotify(applierRoleId, 141207, (List)null);
                                                    TeamManager.logger.debug("FAIL:申请者未达到队伍级别要求,applierRoleId" + applierRoleId);
                                                } else {
                                                    boolean inWaiting1 = false;
                                                    boolean inWaiting = false;
                                                    Role invitMaprole = RoleManager.getInstance().getRoleByID(applierRoleId);
                                                    Role desMaprole = RoleManager.getInstance().getRoleByID(leaderRoleId);
                                                    if (invitMaprole == null || desMaprole == null) {
                                                        return true;
                                                    }

                                                    if (inWaiting || inWaiting1) {
                                                        MessageMgr.psendMsgNotifyWhileRollback(applierRoleId, 145250, (List)null);
                                                        return false;
                                                    }

                                                    Properties applierProperty = xtable.Properties.get(applierRoleId);
                                                    TeamMatch teammatch = TeamManager.getInstance().getTeamMatchByTeamid(teamId);
                                                    if (teammatch != null && applierProperty != null) {
                                                        int applierlevel = applierProperty.getLevel();
                                                        if (applierlevel >= teammatch.getLevelmin() && applierlevel <= teammatch.getLevelmax()) {
                                                            Procedure.pexecuteWhileCommit(new PAcceptToTeam(leaderRoleId, applierRoleId, 1, false));
                                                            return true;
                                                        }
                                                    }

                                                    CRequestJoinTeam.this.team.getTeamInfo().getApplierids().put(applierRoleId, CRequestJoinTeam.this.now);
                                                    SAddTeamApply sAddTeamApply = new SAddTeamApply();
                                                    TeamApplyBasic teamApplyBasic = new TeamApplyBasic();
                                                    teamApplyBasic.level = applierProperty.getLevel() + applierProperty.getZhuansheng() * 1000;
                                                    teamApplyBasic.roleid = applierRoleId;
                                                    teamApplyBasic.rolename = applierProperty.getRolename();
                                                    teamApplyBasic.school = applierProperty.getSchool();
                                                    teamApplyBasic.shape = applierProperty.getShape();
                                                    Role.fillPlayerComponents(applierRoleId, teamApplyBasic.components);
                                                    sAddTeamApply.applylist.add(teamApplyBasic);
                                                    psendWhileCommit(leaderRoleId, sAddTeamApply);
                                                    SRequestJoinSucc sRequestJoinSucc = new SRequestJoinSucc();
                                                    Properties leaderProperty = xtable.Properties.get(leaderRoleId);
                                                    sRequestJoinSucc.rolename = leaderProperty.getRolename();
                                                    psendWhileCommit(applierRoleId, sRequestJoinSucc);
                                                    ArrayList<String> param = new ArrayList();
                                                    param.add(sRequestJoinSucc.rolename);
                                                    MessageMgr.psendMsgNotify(applierRoleId, 150041, param);
                                                    TeamManager.logger.debug("SUCC:满足条件，队伍可以接受申请者,teamId" + teamId);
                                                }

                                                return true;
                                            }
                                        }
                                    }
                                };
                                requestJoinTeamP.submit();
                            }
                        }
                    }
                }
            }
        }
    }

    private static int checkPvP(long targetRoleId, long selfRoleId) {
        return PvPTeamHandle.onRequestJoinTeam(targetRoleId, selfRoleId);
    }

    private boolean checkOnline(long roleId) {
        return Roleonoffstate.get(roleId) == 2;
    }

    private boolean checkApplierNotInTeam(long applierRoleId) {
        return Roleid2teamid.get(applierRoleId) == null;
    }

    private boolean checkApplierStatusValid(long applierRoleId) {
        BuffAgent buffagent = new BuffRoleImpl(applierRoleId, true);
        if (!buffagent.canAddBuff(507006)) {
            TeamManager.logger.info("玩家(roleId=" + applierRoleId + ")处于不能组队的状态");
            return true;
        } else {
            return true;
        }
    }

    private boolean checkLeaderTeamFuncEnable(long leaderRoleId) {
        return true;
    }

    private boolean checkTeamFilter(Team team, long roleId) {
        TeamFilter filter = team.getFilter();
        return filter == null ? true : filter.checkRequestJoin(team.getTeamLeaderId(), roleId);
    }

    private boolean checkTeamNotFull(Team team) {
        return team.getTeamInfo().getMembers().size() < 4;
    }

    private boolean checkLevelRequirementValid(Team team, long applierRoleId) {
        int applierLevel = xtable.Properties.get(applierRoleId).getLevel();
        return applierLevel >= team.getTeamInfo().getMinlevel() && applierLevel <= team.getTeamInfo().getMaxlevel();
    }

    public int getType() {
        return 794449;
    }

    public CRequestJoinTeam() {
    }

    public CRequestJoinTeam(long _roleid_) {
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
        } else if (_o1_ instanceof CRequestJoinTeam) {
            CRequestJoinTeam _o_ = (CRequestJoinTeam)_o1_;
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

    public int compareTo(CRequestJoinTeam _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.roleid - _o_.roleid);
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
