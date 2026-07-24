//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.PetBean;

public class SShowPetInfo extends __SShowPetInfo__ {
    public static final int PROTOCOL_TYPE = 788457;
    public int isxunbaopet;
    public PetBean petdata;

    protected void process() {
    }

    public int getType() {
        return 788457;
    }

    public SShowPetInfo() {
        this.petdata = new PetBean();
    }

    public SShowPetInfo(int _isxunbaopet_, PetBean _petdata_) {
        this.isxunbaopet = _isxunbaopet_;
        this.petdata = _petdata_;
    }

    public final boolean _validator_() {
        return this.petdata._validator_();
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.isxunbaopet);
            _os_.marshal(this.petdata);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.isxunbaopet = _os_.unmarshal_int();
        this.petdata.unmarshal(_os_);
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SShowPetInfo) {
            SShowPetInfo _o_ = (SShowPetInfo)_o1_;
            if (this.isxunbaopet != _o_.isxunbaopet) {
                return false;
            } else {
                return this.petdata.equals(_o_.petdata);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.isxunbaopet;
        _h_ += this.petdata.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.isxunbaopet).append(",");
        _sb_.append(this.petdata).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
