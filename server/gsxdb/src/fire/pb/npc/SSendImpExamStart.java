//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SSendImpExamStart extends __SSendImpExamStart__ {
    public static final int PROTOCOL_TYPE = 795465;
    public long remaintime;
    public byte impexamtype;
    public int historymaxright;
    public long historymintime;

    protected void process() {
    }

    public int getType() {
        return 795465;
    }

    public SSendImpExamStart() {
    }

    public SSendImpExamStart(long _remaintime_, byte _impexamtype_, int _historymaxright_, long _historymintime_) {
        this.remaintime = _remaintime_;
        this.impexamtype = _impexamtype_;
        this.historymaxright = _historymaxright_;
        this.historymintime = _historymintime_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.remaintime);
            _os_.marshal(this.impexamtype);
            _os_.marshal(this.historymaxright);
            _os_.marshal(this.historymintime);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.remaintime = _os_.unmarshal_long();
        this.impexamtype = _os_.unmarshal_byte();
        this.historymaxright = _os_.unmarshal_int();
        this.historymintime = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SSendImpExamStart) {
            SSendImpExamStart _o_ = (SSendImpExamStart)_o1_;
            if (this.remaintime != _o_.remaintime) {
                return false;
            } else if (this.impexamtype != _o_.impexamtype) {
                return false;
            } else if (this.historymaxright != _o_.historymaxright) {
                return false;
            } else {
                return this.historymintime == _o_.historymintime;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.remaintime;
        _h_ += this.impexamtype;
        _h_ += this.historymaxright;
        _h_ += (int)this.historymintime;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.remaintime).append(",");
        _sb_.append(this.impexamtype).append(",");
        _sb_.append(this.historymaxright).append(",");
        _sb_.append(this.historymintime).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SSendImpExamStart _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.remaintime - _o_.remaintime);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.impexamtype - _o_.impexamtype;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.historymaxright - _o_.historymaxright;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = Long.signum(this.historymintime - _o_.historymintime);
                        return 0 != _c_ ? _c_ : _c_;
                    }
                }
            }
        }
    }
}
