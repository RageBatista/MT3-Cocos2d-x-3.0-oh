//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.battle.pvp.PvPTeamHandle;
import fire.pb.fushi.Module;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.List;
import mkdb.Procedure;
import xbean.Pod;
import xbean.TeamMatch;
import xtable.Locks;
import xtable.Roleid2clanfightid;
import xtable.Roleid2teamid;

public class CRequestTeamMatch extends __CRequestTeamMatch__ {
    public static final int PROTOCOL_TYPE = 794494;
    public int typematch;
    public int targetid;
    public int levelmin;
    public int levelmax;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            Procedure requestteammatch = new Procedure() {
                protected boolean process() {
                    if (!CRequestTeamMatch.this.checkLevel()) {
                        psend(roleid, new STeamError(33));
                        TeamManager.logger.debug("FAIL:CRequestTeamMatch匹配等级设置错误 " + roleid);
                        return true;
                    } else {
                        if (Module.GetPayServiceType() == 1) {
                            DSTeamMatchInfo config = (DSTeamMatchInfo)ConfigManager.getInstance().getConf(DSTeamMatchInfo.class).get(CRequestTeamMatch.this.targetid);
                            if (config == null) {
                                psend(roleid, new STeamError(34));
                                TeamManager.logger.debug("FAIL:CRequestTeamMatch:目标ID错误 " + roleid);
                                return true;
                            }
                        } else {
                            STeamMatchInfo config = (STeamMatchInfo)ConfigManager.getInstance().getConf(STeamMatchInfo.class).get(CRequestTeamMatch.this.targetid);
                            if (config == null) {
                                psend(roleid, new STeamError(34));
                                TeamManager.logger.debug("FAIL:CRequestTeamMatch:目标ID错误 " + roleid);
                                return true;
                            }
                        }

                        Long clanfightid = Roleid2clanfightid.select(roleid);
                        if (clanfightid != null) {
                            MessageMgr.sendMsgNotify(roleid, 410040, (List)null);
                            return true;
                        } else {
                            Long teamid = Roleid2teamid.select(roleid);
                            Team team = null;
                            ArrayList<Long> roleids = new ArrayList();
                            if (teamid != null) {
                                team = TeamManager.getTeamByTeamID(teamid);
                                if (!team.isTeamLeader(roleid)) {
                                    psend(roleid, new STeamError(4));
                                    TeamManager.logger.debug("FAIL:CRequestTeamMatch:不是队长不能自动匹配 " + roleid);
                                    return true;
                                }

                                if (team.getTeamInfo().getMembers().size() >= 4) {
                                    psend(roleid, new STeamError(11));
                                    TeamManager.logger.debug("FAIL:CRequestTeamMatch:队伍满了 " + roleid);
                                    return true;
                                }

                                team.getTeamInfo().setTargetid(CRequestTeamMatch.this.targetid);
                                team.getTeamInfo().setMinlevel(CRequestTeamMatch.this.levelmin);
                                team.getTeamInfo().setMaxlevel(CRequestTeamMatch.this.levelmax);
                                roleids.addAll(team.getAllMemberIds());
                                this.lock(Locks.ROLELOCK, roleids);
                            } else {
                                roleids.add(roleid);
                            }

                            Long roleidteamId = Roleid2teamid.get(roleid);
                            if (teamid != roleidteamId) {
                                psend(roleid, new STeamError(0));
                                TeamManager.logger.debug("FAIL:CRequestTeamMatch:队伍ID有变化 " + roleid);
                                return true;
                            } else if (!CRequestTeamMatch.this.checkTeamState(team, roleid)) {
                                psend(roleid, new STeamError(39));
                                TeamManager.logger.debug("FAIL:CRequestTeamMatch组队匹配客户端服务器不同步 " + roleid);
                                return true;
                            } else if (!CRequestTeamMatch.this.checkTeamMemberNum(team)) {
                                psend(roleid, new STeamError(35));
                                TeamManager.logger.debug("FAIL:CRequestTeamMatch队伍已经组满 " + roleid);
                                return true;
                            } else if (!CRequestTeamMatch.this.checkFaction(roleid)) {
                                psend(roleid, new STeamError(38));
                                TeamManager.logger.debug("FAIL:CRequestTeamMatch没有工会 " + roleid);
                                return true;
                            } else if (!CRequestTeamMatch.this.checkActiveTime()) {
                                psend(roleid, new STeamError(37));
                                TeamManager.logger.debug("FAIL:CRequestTeamMatch活动未开放 " + roleid);
                                return true;
                            } else if (CRequestTeamMatch.checkPvP(roleid) != 0) {
                                return true;
                            } else {
                                CRequestTeamMatch.this.addTeamMatch(roleid, roleidteamId);
                                SRequestTeamMatch msg = new SRequestTeamMatch();
                                msg.levelmin = CRequestTeamMatch.this.levelmin;
                                msg.levelmax = CRequestTeamMatch.this.levelmax;
                                msg.targetid = CRequestTeamMatch.this.targetid;
                                msg.typematch = CRequestTeamMatch.this.typematch;

                                for(Long roleid : roleids) {
                                    Procedure.psendWhileCommit(roleid, msg);
                                }

                                return true;
                            }
                        }
                    }
                }
            };
            requestteammatch.submit();
        }
    }

    private void addTeamMatch(long roleid, Long teamid) {
        TeamMatch teammatch = Pod.newTeamMatch();
        teammatch.setRoleid(roleid);
        teammatch.setLevelmin(this.levelmin);
        teammatch.setLevelmax(this.levelmax);
        teammatch.setTargetid(this.targetid);
        teammatch.setMatchtype(this.typematch);
        teammatch.setOnekeytimestamp(0L);
        teammatch.setTimestamp(0L);
        TeamManager.getInstance().addTeamMatch(teammatch, teamid);
    }

    private boolean checkTeamState(Team team, long roleid) {
        if (this.typematch == 0 && team == null) {
            return true;
        } else {
            return this.typematch == 1 && team != null ? team.isTeamLeader(roleid) : false;
        }
    }

    private boolean checkLevel() {
        if (this.levelmin > this.levelmax) {
            return false;
        } else {
            return this.levelmin > 0 && this.levelmax > 0;
        }
    }

    private boolean checkTeamMemberNum(Team team) {
        return true;
    }

    private boolean checkFaction(long roleid) {
        return true;
    }

    private boolean checkActiveTime() {
        return true;
    }

    private static int checkPvP(long roleId) {
        return PvPTeamHandle.onRequestTeamMatch(roleId);
    }

    public int getType() {
        return 794494;
    }

    public CRequestTeamMatch() {
    }

    public CRequestTeamMatch(int _typematch_, int _targetid_, int _levelmin_, int _levelmax_) {
        this.typematch = _typematch_;
        this.targetid = _targetid_;
        this.levelmin = _levelmin_;
        this.levelmax = _levelmax_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.typematch);
            _os_.marshal(this.targetid);
            _os_.marshal(this.levelmin);
            _os_.marshal(this.levelmax);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.typematch = _os_.unmarshal_int();
        this.targetid = _os_.unmarshal_int();
        this.levelmin = _os_.unmarshal_int();
        this.levelmax = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CRequestTeamMatch) {
            CRequestTeamMatch _o_ = (CRequestTeamMatch)_o1_;
            if (this.typematch != _o_.typematch) {
                return false;
            } else if (this.targetid != _o_.targetid) {
                return false;
            } else if (this.levelmin != _o_.levelmin) {
                return false;
            } else {
                return this.levelmax == _o_.levelmax;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.typematch;
        _h_ += this.targetid;
        _h_ += this.levelmin;
        _h_ += this.levelmax;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.typematch).append(",");
        _sb_.append(this.targetid).append(",");
        _sb_.append(this.levelmin).append(",");
        _sb_.append(this.levelmax).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CRequestTeamMatch _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.typematch - _o_.typematch;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.targetid - _o_.targetid;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.levelmin - _o_.levelmin;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.levelmax - _o_.levelmax;
                        return 0 != _c_ ? _c_ : _c_;
                    }
                }
            }
        }
    }
}
