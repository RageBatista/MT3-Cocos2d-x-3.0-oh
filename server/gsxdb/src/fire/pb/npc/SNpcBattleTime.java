//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SNpcBattleTime extends __SNpcBattleTime__ {
    public static final int PROTOCOL_TYPE = 795669;
    public int npcid;
    public long npckey;
    public long usetime;
    public long lasttime;

    protected void process() {
    }

    public int getType() {
        return 795669;
    }

    public SNpcBattleTime() {
    }

    public SNpcBattleTime(int _npcid_, long _npckey_, long _usetime_, long _lasttime_) {
        this.npcid = _npcid_;
        this.npckey = _npckey_;
        this.usetime = _usetime_;
        this.lasttime = _lasttime_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.npcid);
            _os_.marshal(this.npckey);
            _os_.marshal(this.usetime);
            _os_.marshal(this.lasttime);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.npcid = _os_.unmarshal_int();
        this.npckey = _os_.unmarshal_long();
        this.usetime = _os_.unmarshal_long();
        this.lasttime = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SNpcBattleTime) {
            SNpcBattleTime _o_ = (SNpcBattleTime)_o1_;
            if (this.npcid != _o_.npcid) {
                return false;
            } else if (this.npckey != _o_.npckey) {
                return false;
            } else if (this.usetime != _o_.usetime) {
                return false;
            } else {
                return this.lasttime == _o_.lasttime;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.npcid;
        _h_ += (int)this.npckey;
        _h_ += (int)this.usetime;
        _h_ += (int)this.lasttime;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.npcid).append(",");
        _sb_.append(this.npckey).append(",");
        _sb_.append(this.usetime).append(",");
        _sb_.append(this.lasttime).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SNpcBattleTime _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.npcid - _o_.npcid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = Long.signum(this.npckey - _o_.npckey);
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = Long.signum(this.usetime - _o_.usetime);
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = Long.signum(this.lasttime - _o_.lasttime);
                        return 0 != _c_ ? _c_ : _c_;
                    }
                }
            }
        }
    }
}
