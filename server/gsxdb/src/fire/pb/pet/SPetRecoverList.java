//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.LinkedList;

public class SPetRecoverList extends __SPetRecoverList__ {
    public static final int PROTOCOL_TYPE = 788584;
    public LinkedList<PetRecoverInfoBean> pets;

    protected void process() {
    }

    public int getType() {
        return 788584;
    }

    public SPetRecoverList() {
        this.pets = new LinkedList();
    }

    public SPetRecoverList(LinkedList<PetRecoverInfoBean> _pets_) {
        this.pets = _pets_;
    }

    public final boolean _validator_() {
        for(PetRecoverInfoBean _v_ : this.pets) {
            if (!_v_._validator_()) {
                return false;
            }
        }

        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.compact_uint32(this.pets.size());

            for(PetRecoverInfoBean _v_ : this.pets) {
                _os_.marshal(_v_);
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            PetRecoverInfoBean _v_ = new PetRecoverInfoBean();
            _v_.unmarshal(_os_);
            this.pets.add(_v_);
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
        } else if (_o1_ instanceof SPetRecoverList) {
            SPetRecoverList _o_ = (SPetRecoverList)_o1_;
            return this.pets.equals(_o_.pets);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.pets.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.pets).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
