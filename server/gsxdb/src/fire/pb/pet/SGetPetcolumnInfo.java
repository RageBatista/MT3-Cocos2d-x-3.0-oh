//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.PetBean;
import java.util.ArrayList;

public class SGetPetcolumnInfo extends __SGetPetcolumnInfo__ {
    public static final int PROTOCOL_TYPE = 788447;
    public int columnid;
    public ArrayList<PetBean> pets;
    public int colunmsize;

    protected void process() {
    }

    public int getType() {
        return 788447;
    }

    public SGetPetcolumnInfo() {
        this.pets = new ArrayList();
    }

    public SGetPetcolumnInfo(int _columnid_, ArrayList<PetBean> _pets_, int _colunmsize_) {
        this.columnid = _columnid_;
        this.pets = _pets_;
        this.colunmsize = _colunmsize_;
    }

    public final boolean _validator_() {
        if (this.columnid < 1) {
            return false;
        } else {
            for(PetBean _v_ : this.pets) {
                if (!_v_._validator_()) {
                    return false;
                }
            }

            if (this.colunmsize < 0) {
                return false;
            } else {
                return true;
            }
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.columnid);
            _os_.compact_uint32(this.pets.size());

            for(PetBean _v_ : this.pets) {
                _os_.marshal(_v_);
            }

            _os_.marshal(this.colunmsize);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.columnid = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            PetBean _v_ = new PetBean();
            _v_.unmarshal(_os_);
            this.pets.add(_v_);
        }

        this.colunmsize = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SGetPetcolumnInfo) {
            SGetPetcolumnInfo _o_ = (SGetPetcolumnInfo)_o1_;
            if (this.columnid != _o_.columnid) {
                return false;
            } else if (!this.pets.equals(_o_.pets)) {
                return false;
            } else {
                return this.colunmsize == _o_.colunmsize;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.columnid;
        _h_ += this.pets.hashCode();
        _h_ += this.colunmsize;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.columnid).append(",");
        _sb_.append(this.pets).append(",");
        _sb_.append(this.colunmsize).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
