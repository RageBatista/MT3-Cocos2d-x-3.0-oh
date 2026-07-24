//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team.teammelon;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.team.STeamError;
import fire.pb.team.TeamManager;
import gnet.link.Onlines;
import java.util.ArrayList;
import mkdb.Procedure;
import xbean.ETeamMelon;
import xbean.Properties;
import xbean.TeamMelon;
import xtable.Battlemelonid2melon;
import xtable.Roleid2battlemelonid;

public class CTeamRollMelon extends __CTeamRollMelon__ {
    public static final int PROTOCOL_TYPE = 794523;
    public long melonid;
    public int status;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            Procedure teamrollmelon = new Procedure() {
                protected boolean process() {
                    Properties roleprop = xtable.Properties.select(roleid);
                    Long battlemelonid = Roleid2battlemelonid.select(roleid);
                    if (battlemelonid == null) {
                        psend(roleid, new STeamError(2));
                        TeamManager.logger.debug("CTeamRollMelon: " + roleid);
                        return true;
                    } else {
                        ETeamMelon eteammelon = Battlemelonid2melon.get(battlemelonid);
                        if (eteammelon == null) {
                            psend(roleid, new STeamError(2));
                            TeamManager.logger.debug("CTeamRollMelon:没有奖励可分配" + roleid);
                            return true;
                        } else {
                            TeamMelon teammelon = (TeamMelon)eteammelon.getMelonid2melons().get(CTeamRollMelon.this.melonid);
                            if (teammelon == null) {
                                psend(roleid, new STeamError(2));
                                TeamManager.logger.debug("CTeamRollMelon:没有奖励可分配" + roleid);
                                return true;
                            } else {
                                Integer rollpoint = (Integer)teammelon.getMelonroleids().get(roleid);
                                if (rollpoint == null) {
                                    psend(roleid, new STeamError(2));
                                    TeamManager.logger.debug("CTeamRollMelon:没有奖励可分配" + roleid);
                                    return true;
                                } else {
                                    Integer alreadroll = (Integer)teammelon.getOpmelonroleids().get(roleid);
                                    if (alreadroll != null) {
                                        TeamManager.logger.debug("CTeamRollMelon:已经ROLL过了" + roleid);
                                        return true;
                                    } else {
                                        if (CTeamRollMelon.this.status == 0) {
                                            teammelon.getMelonroleids().put(roleid, 0);
                                        }

                                        int num = teammelon.getOpnum();
                                        ++num;
                                        teammelon.setOpnum(num);
                                        teammelon.getOpmelonroleids().put(roleid, teammelon.getMelonroleids().get(roleid));
                                        SOneTeamRollMelonInfo msg = new SOneTeamRollMelonInfo();
                                        msg.itemid = teammelon.getItemid();
                                        msg.melonid = CTeamRollMelon.this.melonid;
                                        msg.rollinfo.roleid = roleid;
                                        msg.rollinfo.rolename = roleprop.getRolename();
                                        msg.rollinfo.roll = (Integer)teammelon.getMelonroleids().get(roleid);

                                        for(Long e : eteammelon.getMelonerlist()) {
                                            Procedure.psendWhileCommit(e, msg);
                                        }

                                        for(Long e : eteammelon.getWatchmelonerlist()) {
                                            if (e != null) {
                                                Procedure.psendWhileCommit(e, msg);
                                            }
                                        }

                                        if (num >= teammelon.getMelonroleids().size()) {
                                            (new PTeamRollMelonInfo(battlemelonid, 0)).call();
                                        }

                                        return true;
                                    }
                                }
                            }
                        }
                    }
                }
            };
            teamrollmelon.submit();
        }
    }

    public long calcMaxRollPoint(ArrayList<Long> roleids, TeamMelon teammelon) {
        int max = 0;
        long maxroleid = 0L;

        for(Long roleid : roleids) {
            Integer rollpoint = (Integer)teammelon.getMelonroleids().get(roleid);
            if (rollpoint >= max) {
                max = rollpoint;
                maxroleid = roleid;
            }
        }

        return maxroleid;
    }

    public int getType() {
        return 794523;
    }

    public CTeamRollMelon() {
    }

    public CTeamRollMelon(long _melonid_, int _status_) {
        this.melonid = _melonid_;
        this.status = _status_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.melonid);
            _os_.marshal(this.status);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.melonid = _os_.unmarshal_long();
        this.status = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CTeamRollMelon) {
            CTeamRollMelon _o_ = (CTeamRollMelon)_o1_;
            if (this.melonid != _o_.melonid) {
                return false;
            } else {
                return this.status == _o_.status;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.melonid;
        _h_ += this.status;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.melonid).append(",");
        _sb_.append(this.status).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CTeamRollMelon _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.melonid - _o_.melonid);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.status - _o_.status;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
