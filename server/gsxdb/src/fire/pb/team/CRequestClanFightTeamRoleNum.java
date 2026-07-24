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
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import mkdb.Procedure;
import xtable.Roleid2clanfightid;
import xtable.Roleid2teamid;
import xtable.Roleidclan;

public class CRequestClanFightTeamRoleNum extends __CRequestClanFightTeamRoleNum__ {
    public static final int PROTOCOL_TYPE = 794561;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            Procedure r = new Procedure() {
                protected boolean process() {
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

                            SRequestClanFightTeamRoleNum msg = new SRequestClanFightTeamRoleNum();
                            Map<Long, Integer> v = bf.getClanroleidsByWhich(side);
                            if (v != null) {
                                Set<Long> teamidset = new HashSet();

                                for(Long e : v.keySet()) {
                                    Long teamid = Roleid2teamid.select(e);
                                    if (teamid != null) {
                                        if (!teamidset.contains(teamid)) {
                                            ++msg.teamnum;
                                        }

                                        teamidset.add(teamid);
                                    } else {
                                        ++msg.rolenum;
                                    }
                                }
                            }

                            Procedure.psendWhileCommit(roleid, msg);
                        }

                        return true;
                    }
                }
            };
            r.submit();
        }
    }

    public int getType() {
        return 794561;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else {
            return _o1_ instanceof CRequestClanFightTeamRoleNum;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CRequestClanFightTeamRoleNum _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}
