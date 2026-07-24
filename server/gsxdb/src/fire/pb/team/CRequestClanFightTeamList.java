//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.clan.fight.ClanFightBattleField;
import fire.pb.clan.fight.ClanFightFactory;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import mkdb.Procedure;
import xbean.Properties;
import xbean.TeamInfo;
import xbean.TeamMember;
import xtable.Roleid2clanfightid;
import xtable.Roleid2teamid;
import xtable.Roleidclan;
import xtable.Team;

public class CRequestClanFightTeamList extends __CRequestClanFightTeamList__ {
    public static final int PROTOCOL_TYPE = 794557;
    public int isfresh;
    public long start;
    public int num;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            Procedure r = new Procedure() {
                protected boolean process() {
                    if (CRequestClanFightTeamList.this.num > 20) {
                        return false;
                    } else {
                        int side = 0;
                        Long c1 = Roleid2clanfightid.select(roleid);
                        if (c1 == null) {
                            return false;
                        } else {
                            ClanFightBattleField bf = ClanFightFactory.getClanFightBattleField(c1, true);
                            if (bf != null) {
                                Long clanid = Roleidclan.select(roleid);
                                if (clanid == null) {
                                    return false;
                                }

                                if (clanid == bf.getClanfightBean().getClanid1()) {
                                    side = 0;
                                } else {
                                    if (clanid != bf.getClanfightBean().getClanid2()) {
                                        return false;
                                    }

                                    side = 1;
                                }

                                SRequestClanFightTeamList msg = new SRequestClanFightTeamList();
                                Map<Long, Integer> v = bf.getClanroleidsByWhich(side);
                                List<Long> teamlist = new ArrayList();
                                if (v != null) {
                                    for(Long e : v.keySet()) {
                                        Long teamid = Roleid2teamid.select(e);
                                        if (teamid != null) {
                                            teamlist.add(teamid);
                                        }
                                    }

                                    teamlist.sort(new Comparator<Long>() {
                                        public int compare(Long o1, Long o2) {
                                            return o1 > o2 ? 1 : -1;
                                        }
                                    });
                                    int curnum = 0;
                                    Set<Long> teamidset = new HashSet();

                                    for(Long teamid : teamlist) {
                                        if (teamid != null && (CRequestClanFightTeamList.this.start == 0L || teamid > CRequestClanFightTeamList.this.start)) {
                                            TeamInfo teaminfo = Team.select(teamid);
                                            if (teaminfo != null && !teamidset.contains(teamid)) {
                                                TeamInfoBasicWithMembers t = new TeamInfoBasicWithMembers();
                                                t.teaminfobasic = CRequestClanFightTeamList.this.newTeamInfoBasic(teamid, teaminfo);
                                                msg.teamlist.add(t);
                                                t.memberlist.add(CRequestClanFightTeamList.this.getTeamMemeberSimple(teaminfo.getTeamleaderid()));

                                                for(TeamMember e1 : teaminfo.getMembers()) {
                                                    t.memberlist.add(CRequestClanFightTeamList.this.getTeamMemeberSimple(e1.getRoleid()));
                                                }

                                                ++curnum;
                                                teamidset.add(teamid);
                                                if (curnum >= CRequestClanFightTeamList.this.num) {
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }

                                msg.isfresh = CRequestClanFightTeamList.this.isfresh;
                                if (msg.teamlist.size() == 0) {
                                    msg.ret = -1;
                                }

                                Procedure.psendWhileCommit(roleid, msg);
                            }

                            return true;
                        }
                    }
                }
            };
            r.submit();
        }
    }

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

    public TeamInfoBasic newTeamInfoBasic(long teamid, TeamInfo teaminfo) {
        Properties leaderprop = xtable.Properties.select(teaminfo.getTeamleaderid());
        TeamInfoBasic teamInfoBasic = new TeamInfoBasic();
        teamInfoBasic.leaderid = teaminfo.getTeamleaderid();
        teamInfoBasic.leaderlevel = leaderprop.getLevel();
        teamInfoBasic.leadername = leaderprop.getRolename();
        teamInfoBasic.leaderschool = leaderprop.getSchool();
        teamInfoBasic.minlevel = 0;
        teamInfoBasic.maxlevel = 0;
        teamInfoBasic.membernum = teaminfo.getMembers().size() + 1;
        teamInfoBasic.teamid = teamid;
        teamInfoBasic.membermaxnum = 5;
        teamInfoBasic.targetid = 0;
        return teamInfoBasic;
    }

    public int getType() {
        return 794557;
    }

    public CRequestClanFightTeamList() {
    }

    public CRequestClanFightTeamList(int _isfresh_, long _start_, int _num_) {
        this.isfresh = _isfresh_;
        this.start = _start_;
        this.num = _num_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.isfresh);
            _os_.marshal(this.start);
            _os_.marshal(this.num);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.isfresh = _os_.unmarshal_int();
        this.start = _os_.unmarshal_long();
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
        } else if (_o1_ instanceof CRequestClanFightTeamList) {
            CRequestClanFightTeamList _o_ = (CRequestClanFightTeamList)_o1_;
            if (this.isfresh != _o_.isfresh) {
                return false;
            } else if (this.start != _o_.start) {
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
        _h_ += this.isfresh;
        _h_ += (int)this.start;
        _h_ += this.num;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.isfresh).append(",");
        _sb_.append(this.start).append(",");
        _sb_.append(this.num).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CRequestClanFightTeamList _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.isfresh - _o_.isfresh;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = Long.signum(this.start - _o_.start);
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
