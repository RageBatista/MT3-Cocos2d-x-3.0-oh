//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.fushi.Module;
import fire.pb.main.ConfigManager;
import gnet.link.Onlines;
import mkdb.Procedure;
import xtable.Roleid2teamid;

public class CRequestSetTeamMatchInfo extends __CRequestSetTeamMatchInfo__ {
    public static final int PROTOCOL_TYPE = 794499;
    public int targetid;
    public int levelmin;
    public int levelmax;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            Procedure requestsetteammatchinfo = new Procedure() {
                protected boolean process() {
                    if (!CRequestSetTeamMatchInfo.this.checkLevel()) {
                        psend(roleid, new STeamError(33));
                        TeamManager.logger.debug("CRequestSetTeamMatchInfo匹配等级设置错误 " + roleid);
                        return true;
                    } else {
                        if (CRequestSetTeamMatchInfo.this.targetid != 0) {
                            if (Module.GetPayServiceType() == 1) {
                                DSTeamMatchInfo config = (DSTeamMatchInfo)ConfigManager.getInstance().getConf(DSTeamMatchInfo.class).get(CRequestSetTeamMatchInfo.this.targetid);
                                if (config == null) {
                                    psend(roleid, new STeamError(34));
                                    TeamManager.logger.debug("CRequestSetTeamMatchInfo:目标ID错误 " + roleid);
                                    return true;
                                }
                            } else {
                                STeamMatchInfo config = (STeamMatchInfo)ConfigManager.getInstance().getConf(STeamMatchInfo.class).get(CRequestSetTeamMatchInfo.this.targetid);
                                if (config == null) {
                                    psend(roleid, new STeamError(34));
                                    TeamManager.logger.debug("CRequestSetTeamMatchInfo:目标ID错误 " + roleid);
                                    return true;
                                }
                            }
                        }

                        Long teamid = Roleid2teamid.select(roleid);
                        Team team = null;
                        if (teamid != null) {
                            team = TeamManager.getTeamByTeamID(teamid);
                            team.getTeamInfo().setTargetid(CRequestSetTeamMatchInfo.this.targetid);
                            team.getTeamInfo().setMinlevel(CRequestSetTeamMatchInfo.this.levelmin);
                            team.getTeamInfo().setMaxlevel(CRequestSetTeamMatchInfo.this.levelmax);
                        }

                        Long roleidteamId = Roleid2teamid.get(roleid);
                        if (teamid != roleidteamId) {
                            psend(roleid, new STeamError(0));
                            TeamManager.logger.debug("CRequestSetTeamMatchInfo:队伍ID有变化 " + roleid);
                            return true;
                        } else {
                            SRequestTeamMatch msg = new SRequestTeamMatch();
                            msg.levelmin = CRequestSetTeamMatchInfo.this.levelmin;
                            msg.levelmax = CRequestSetTeamMatchInfo.this.levelmax;
                            msg.targetid = CRequestSetTeamMatchInfo.this.targetid;
                            msg.typematch = 3;
                            Procedure.psendWhileCommit(roleid, msg);
                            return true;
                        }
                    }
                }
            };
            requestsetteammatchinfo.submit();
        }
    }

    private boolean checkLevel() {
        if (this.levelmin > this.levelmax) {
            return false;
        } else {
            return this.levelmin > 0 && this.levelmax > 0;
        }
    }

    public int getType() {
        return 794499;
    }

    public CRequestSetTeamMatchInfo() {
    }

    public CRequestSetTeamMatchInfo(int _targetid_, int _levelmin_, int _levelmax_) {
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
            _os_.marshal(this.targetid);
            _os_.marshal(this.levelmin);
            _os_.marshal(this.levelmax);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
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
        } else if (_o1_ instanceof CRequestSetTeamMatchInfo) {
            CRequestSetTeamMatchInfo _o_ = (CRequestSetTeamMatchInfo)_o1_;
            if (this.targetid != _o_.targetid) {
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
        _h_ += this.targetid;
        _h_ += this.levelmin;
        _h_ += this.levelmax;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.targetid).append(",");
        _sb_.append(this.levelmin).append(",");
        _sb_.append(this.levelmax).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CRequestSetTeamMatchInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
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
