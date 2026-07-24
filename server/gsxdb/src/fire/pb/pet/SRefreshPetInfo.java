//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.PetBean;

public class SRefreshPetInfo extends __SRefreshPetInfo__ {
    public static final int PROTOCOL_TYPE = 788437;
    public PetBean petinfo;

    protected void process() {
    }

    public int getType() {
        return 788437;
    }

    public SRefreshPetInfo() {
        this.petinfo = new PetBean();
    }

    public SRefreshPetInfo(PetBean _petinfo_) {
        this.petinfo = _petinfo_;
    }

    public final boolean _validator_() {
        return this.petinfo._validator_();
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petinfo);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petinfo.unmarshal(_os_);
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SRefreshPetInfo) {
            SRefreshPetInfo _o_ = (SRefreshPetInfo)_o1_;
            return this.petinfo.equals(_o_.petinfo);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petinfo.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petinfo).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
