//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.activity.winner.PWinnerCallPlayer;
import fire.pb.battle.pvp1.PvP1Control;
import fire.pb.battle.pvp3.PvP3Control;
import fire.pb.battle.pvp5.PvP5Control;
import gnet.link.Onlines;

public class CGeneralSummonCommand extends __CGeneralSummonCommand__ {
    public static final int PROTOCOL_TYPE = 795506;
    public int summontype;
    public long npckey;
    public int agree;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            if (this.summontype != 4) {
                if (this.summontype == 5 && this.agree == 1) {
                    (new PWinnerCallPlayer(roleid)).submit();
                } else if (this.summontype == 10 && this.agree == 1) {
                    PvP1Control.getInstance().applyEnter(roleid, 516014);
                } else if (this.summontype == 15 && this.agree == 1) {
                    PvP3Control.getInstance().applyEnter(roleid, 516014);
                } else if (this.summontype == 16 && this.agree == 1) {
                    PvP5Control.getInstance().applyEnter(roleid, 516014);
                }
            }
        }
    }

    public int getType() {
        return 795506;
    }

    public CGeneralSummonCommand() {
    }

    public CGeneralSummonCommand(int _summontype_, long _npckey_, int _agree_) {
        this.summontype = _summontype_;
        this.npckey = _npckey_;
        this.agree = _agree_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.summontype);
            _os_.marshal(this.npckey);
            _os_.marshal(this.agree);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.summontype = _os_.unmarshal_int();
        this.npckey = _os_.unmarshal_long();
        this.agree = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CGeneralSummonCommand) {
            CGeneralSummonCommand _o_ = (CGeneralSummonCommand)_o1_;
            if (this.summontype != _o_.summontype) {
                return false;
            } else if (this.npckey != _o_.npckey) {
                return false;
            } else {
                return this.agree == _o_.agree;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.summontype;
        _h_ += (int)this.npckey;
        _h_ += this.agree;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.summontype).append(",");
        _sb_.append(this.npckey).append(",");
        _sb_.append(this.agree).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CGeneralSummonCommand _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.summontype - _o_.summontype;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = Long.signum(this.npckey - _o_.npckey);
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.agree - _o_.agree;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}
