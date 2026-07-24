//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.StateCommon;
import gnet.link.Onlines;
import java.util.ArrayList;

public class CFreePet1 extends __CFreePet1__ {
    public static final int PROTOCOL_TYPE = 788497;
    public ArrayList<Integer> petkeys;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L && StateCommon.isOnline(roleid)) {
            PFreePet proc = new PFreePet(roleid, this.petkeys);
            proc.submit();
        }
    }

    public int getType() {
        return 788497;
    }

    public CFreePet1() {
        this.petkeys = new ArrayList();
    }

    public CFreePet1(ArrayList<Integer> _petkeys_) {
        this.petkeys = _petkeys_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.compact_uint32(this.petkeys.size());

            for(Integer _v_ : this.petkeys) {
                _os_.marshal(_v_);
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            int _v_ = _os_.unmarshal_int();
            this.petkeys.add(_v_);
        }

        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CFreePet1) {
            CFreePet1 _o_ = (CFreePet1)_o1_;
            return this.petkeys.equals(_o_.petkeys);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkeys.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkeys).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
