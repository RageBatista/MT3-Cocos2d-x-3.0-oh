//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;
import java.util.Map;
import mkdb.Procedure;
import xbean.ETeamMatch;
import xbean.Properties;
import xbean.TeamInfo;
import xbean.TeamMatch;
import xbean.TeamMember;
import xtable.Roleid2teamid;
import xtable.Targetid2teammatch;

public class CRequestTeamMatchList extends __CRequestTeamMatchList__ {
    public static TeamInfoBasic tmp;
    public static final int PROTOCOL_TYPE = 794509;
    public int targetid;
    public long startteamid;
    public int num;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            Procedure requestteammatchlist = new Procedure() {
                protected boolean process() {
                    SRequestTeamMatchList msg = new SRequestTeamMatchList();
                    Properties prop = xtable.Properties.select(roleid);
                    if (prop == null) {
                        msg.targetid = CRequestTeamMatchList.this.targetid;
                        msg.ret = 0;
                        Procedure.psendWhileCommit(roleid, msg);
                        return true;
                    } else {
                        int level = prop.getLevel();
                        ETeamMatch ematch = Targetid2teammatch.select(0);
                        if (ematch == null) {
                            msg.targetid = CRequestTeamMatchList.this.targetid;
                            msg.ret = 0;
                            Procedure.psendWhileCommit(roleid, msg);
                            return true;
                        } else if (CRequestTeamMatchList.this.num <= 0) {
                            msg.targetid = CRequestTeamMatchList.this.targetid;
                            msg.ret = 2;
                            Procedure.psendWhileCommit(roleid, msg);
                            return true;
                        } else {
                            int curnum = 0;

                            for(Map.Entry<Long, TeamMatch> e : ematch.getTeamid2matchdata().entrySet()) {
                                TeamMatch teammatch = (TeamMatch)e.getValue();
                                if (CRequestTeamMatchList.this.targetid == 0 || teammatch.getTargetid() == CRequestTeamMatchList.this.targetid && teammatch.getMatchtype() == 1) {
                                    Long teamid = Roleid2teamid.select(teammatch.getRoleid());
                                    if (teamid != null && teamid > CRequestTeamMatchList.this.startteamid) {
                                        Team team = new Team(teamid, true);
                                        if (CRequestTeamMatchList.this.checkTeamFull(team.getTeamInfo()) && CRequestTeamMatchList.this.checkLevel(teammatch, level)) {
                                            if (curnum >= CRequestTeamMatchList.this.num || curnum >= 10) {
                                                break;
                                            }

                                            TeamInfoBasicWithMembers t = new TeamInfoBasicWithMembers();
                                            t.teaminfobasic = CRequestTeamMatchList.this.newTeamInfoBasic(teamid, teammatch, team.getTeamInfo());
                                            boolean ok = team.getTeamInfo().getApplierids().containsKey(roleid);
                                            if (ok) {
                                                t.status = 1;
                                            }

                                            t.memberlist.add(team.getTeamMemeberSimple(team.getTeamInfo().getTeamleaderid()));

                                            for(TeamMember e1 : team.getTeamInfo().getMembers()) {
                                                t.memberlist.add(team.getTeamMemeberSimple(e1.getRoleid()));
                                            }

                                            msg.teamlist.add(t);
                                            ++curnum;
                                        }
                                    }
                                }
                            }

                            msg.targetid = CRequestTeamMatchList.this.targetid;
                            msg.ret = 0;
                            Procedure.psendWhileCommit(roleid, msg);
                            return true;
                        }
                    }
                }
            };
            requestteammatchlist.submit();
        }
    }

    public boolean checkLevel(TeamMatch teammatch, int level) {
        return level >= teammatch.getLevelmin() && level <= teammatch.getLevelmax();
    }

    public boolean checkTeamFull(TeamInfo teaminfo) {
        return teaminfo.getMembers().size() < 4;
    }

    public TeamInfoBasic newTeamInfoBasic(long teamid, TeamMatch teammatch, TeamInfo teaminfo) {
        Properties leaderprop = xtable.Properties.select(teaminfo.getTeamleaderid());
        TeamInfoBasic teamInfoBasic = new TeamInfoBasic();
        teamInfoBasic.leaderid = teaminfo.getTeamleaderid();
        teamInfoBasic.leaderlevel = leaderprop.getLevel();
        teamInfoBasic.leadername = leaderprop.getRolename();
        teamInfoBasic.leaderschool = leaderprop.getSchool();
        teamInfoBasic.minlevel = teammatch.getLevelmin();
        teamInfoBasic.maxlevel = teammatch.getLevelmax();
        teamInfoBasic.membernum = teaminfo.getMembers().size() + 1;
        teamInfoBasic.teamid = teamid;
        teamInfoBasic.membermaxnum = 5;
        teamInfoBasic.targetid = teammatch.getTargetid();
        return teamInfoBasic;
    }

    public int getType() {
        return 794509;
    }

    public CRequestTeamMatchList() {
    }

    public CRequestTeamMatchList(int _targetid_, long _startteamid_, int _num_) {
        this.targetid = _targetid_;
        this.startteamid = _startteamid_;
        this.num = _num_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.targetid);
            _os_.marshal(this.startteamid);
            _os_.marshal(this.num);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.targetid = _os_.unmarshal_int();
        this.startteamid = _os_.unmarshal_long();
        this.num = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CRequestTeamMatchList) {
            CRequestTeamMatchList _o_ = (CRequestTeamMatchList)_o1_;
            if (this.targetid != _o_.targetid) {
                return false;
            } else if (this.startteamid != _o_.startteamid) {
                return false;
            } else {
                return this.num == _o_.num;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.targetid;
        _h_ += (int)this.startteamid;
        _h_ += this.num;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.targetid).append(",");
        _sb_.append(this.startteamid).append(",");
        _sb_.append(this.num).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CRequestTeamMatchList _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.targetid - _o_.targetid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = Long.signum(this.startteamid - _o_.startteamid);
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.num - _o_.num;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}
