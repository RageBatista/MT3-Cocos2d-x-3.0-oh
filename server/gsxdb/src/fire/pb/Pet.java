//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class Pet implements Marshal, Comparable<Pet> {
    public PetBean petdata;

    public Pet() {
        this.petdata = new PetBean();
    }

    public Pet(PetBean _petdata_) {
        this.petdata = _petdata_;
    }

    public final boolean _validator_() {
        return this.petdata._validator_();
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.petdata);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petdata.unmarshal(_os_);
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof Pet) {
            Pet _o_ = (Pet)_o1_;
            return this.petdata.equals(_o_.petdata);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petdata.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petdata).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(Pet _o_) {
        return this.petdata.id - _o_.petdata.id;
    }
}

