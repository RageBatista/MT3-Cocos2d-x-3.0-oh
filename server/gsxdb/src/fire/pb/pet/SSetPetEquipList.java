//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SSetPetEquipList extends __SSetPetEquipList__ {
    public static final int PROTOCOL_TYPE = 817940;
    public int petkey;
    public int xiangquanid;
    public int hujiaid;
    public int hufuid;

    protected void process() {
    }

    public int getType() {
        return 817940;
    }

    public SSetPetEquipList() {
    }

    public SSetPetEquipList(int _columnid_, int _petkey_) {
        this.petkey = _petkey_;
    }

    public final boolean _validator_() {
        return this.petkey >= 1;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey);
            _os_.marshal(this.xiangquanid);
            _os_.marshal(this.hujiaid);
            _os_.marshal(this.hufuid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey = _os_.unmarshal_int();
        this.xiangquanid = _os_.unmarshal_int();
        this.hujiaid = _os_.unmarshal_int();
        this.hufuid = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SSetPetEquipList) {
            SSetPetEquipList _o_ = (SSetPetEquipList)_o1_;
            if (this.petkey != _o_.petkey) {
                return false;
            } else if (this.xiangquanid != _o_.xiangquanid) {
                return false;
            } else if (this.hujiaid != _o_.hujiaid) {
                return false;
            } else {
                return this.hufuid == _o_.hufuid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey;
        _h_ += this.xiangquanid;
        _h_ += this.hujiaid;
        _h_ += this.hufuid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey).append(",");
        _sb_.append(this.xiangquanid).append(",");
        _sb_.append(this.hujiaid).append(",");
        _sb_.append(this.hufuid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SSetPetEquipList _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            if (0 != _c_) {
                return _c_;
            } else {
                int var10000 = this.petkey - _o_.petkey;
                var10000 = this.xiangquanid - _o_.xiangquanid;
                var10000 = this.hujiaid - _o_.hujiaid;
                _c_ = this.hufuid - _o_.hufuid;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
