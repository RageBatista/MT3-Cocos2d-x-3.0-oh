//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.PetBean;

public class SAddPetToColumn extends __SAddPetToColumn__ {
    public static final int PROTOCOL_TYPE = 788444;
    public int columnid;
    public PetBean petdata;

    protected void process() {
    }

    public int getType() {
        return 788444;
    }

    public SAddPetToColumn() {
        this.petdata = new PetBean();
    }

    public SAddPetToColumn(int _columnid_, PetBean _petdata_) {
        this.columnid = _columnid_;
        this.petdata = _petdata_;
    }

    public final boolean _validator_() {
        if (this.columnid < 1) {
            return false;
        } else {
            return this.petdata._validator_();
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.columnid);
            _os_.marshal(this.petdata);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.columnid = _os_.unmarshal_int();
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
        } else if (_o1_ instanceof SAddPetToColumn) {
            SAddPetToColumn _o_ = (SAddPetToColumn)_o1_;
            if (this.columnid != _o_.columnid) {
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
        _h_ += this.columnid;
        _h_ += this.petdata.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.columnid).append(",");
        _sb_.append(this.petdata).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
