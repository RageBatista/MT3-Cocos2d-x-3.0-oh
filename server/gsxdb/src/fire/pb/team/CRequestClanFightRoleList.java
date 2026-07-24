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
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import xbean.Properties;
import xtable.Roleid2clanfightid;
import xtable.Roleid2teamid;
import xtable.Roleidclan;

public class CRequestClanFightRoleList extends __CRequestClanFightRoleList__ {
    public static final int PROTOCOL_TYPE = 794559;
    public int isfresh;
    public long start;
    public int num;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            Procedure r = new Procedure() {
                protected boolean process() {
                    if (CRequestClanFightRoleList.this.num > 20) {
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

                                SRequestClanFightRoleList msg = new SRequestClanFightRoleList();
                                Map<Long, Integer> v = bf.getClanroleidsByWhich(side);
                                List<Long> sortdata = new ArrayList();
                                if (v != null) {
                                    sortdata.addAll(v.keySet());
                                }

                                sortdata.sort(new Comparator<Long>() {
                                    public int compare(Long o1, Long o2) {
                                        return o1 > o2 ? 1 : -1;
                                    }
                                });
                                if (v != null) {
                                    int curnum = 0;

                                    for(Long e : sortdata) {
                                        if (CRequestClanFightRoleList.this.start == 0L || e > CRequestClanFightRoleList.this.start) {
                                            Long teamid = Roleid2teamid.select(e);
                                            if (teamid == null) {
                                                Properties prop = xtable.Properties.select(e);
                                                if (prop != null) {
                                                    RoleSimapleInfo info = new RoleSimapleInfo();
                                                    info.roleid = e;
                                                    info.rolename = prop.getRolename();
                                                    info.level = prop.getLevel();
                                                    info.schoold = prop.getSchool();
                                                    info.shape = prop.getShape();
                                                    msg.rolelist.add(info);
                                                    ++curnum;
                                                    if (curnum >= CRequestClanFightRoleList.this.num) {
                                                        break;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                msg.isfresh = CRequestClanFightRoleList.this.isfresh;
                                if (msg.rolelist.size() == 0) {
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

    public int getType() {
        return 794559;
    }

    public CRequestClanFightRoleList() {
    }

    public CRequestClanFightRoleList(int _isfresh_, long _start_, int _num_) {
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
        } else if (_o1_ instanceof CRequestClanFightRoleList) {
            CRequestClanFightRoleList _o_ = (CRequestClanFightRoleList)_o1_;
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

    public int compareTo(CRequestClanFightRoleList _o_) {
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
