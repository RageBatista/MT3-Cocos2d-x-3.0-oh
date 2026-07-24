//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.school.change;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CChangeGem33 extends __CChangeGem33__ {
    public static final int PROTOCOL_TYPE = 817933;
    public int gemkey;
    public int newgemitemid;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            (new PChangeGem33(roleId, this.gemkey, this.newgemitemid)).submit();
        }
    }

    public int getType() {
        return 817933;
    }

    public CChangeGem33() {
    }

    public CChangeGem33(int _gemkey_, int _newgemitemid_) {
        this.gemkey = _gemkey_;
        this.newgemitemid = _newgemitemid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.gemkey);
            _os_.marshal(this.newgemitemid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.gemkey = _os_.unmarshal_int();
        this.newgemitemid = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CChangeGem33) {
            CChangeGem33 _o_ = (CChangeGem33)_o1_;
            if (this.gemkey != _o_.gemkey) {
                return false;
            } else {
                return this.newgemitemid == _o_.newgemitemid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.gemkey;
        _h_ += this.newgemitemid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.gemkey).append(",");
        _sb_.append(this.newgemitemid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CChangeGem33 _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.gemkey - _o_.gemkey;
            if (_c_ != 0) {
                return _c_;
            } else {
                _c_ = this.newgemitemid - _o_.newgemitemid;
                return _c_ != 0 ? _c_ : _c_;
            }
        }
    }
}
