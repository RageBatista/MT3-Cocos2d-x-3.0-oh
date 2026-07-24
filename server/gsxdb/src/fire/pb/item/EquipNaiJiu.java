//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class EquipNaiJiu implements Marshal, Comparable<EquipNaiJiu> {
    public int keyinpack;
    public int endure;

    public EquipNaiJiu() {
    }

    public EquipNaiJiu(int _keyinpack_, int _endure_) {
        this.keyinpack = _keyinpack_;
        this.endure = _endure_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.keyinpack);
        _os_.marshal(this.endure);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.keyinpack = _os_.unmarshal_int();
        this.endure = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof EquipNaiJiu) {
            EquipNaiJiu _o_ = (EquipNaiJiu)_o1_;
            if (this.keyinpack != _o_.keyinpack) {
                return false;
            } else {
                return this.endure == _o_.endure;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.keyinpack;
        _h_ += this.endure;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.keyinpack).append(",");
        _sb_.append(this.endure).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(EquipNaiJiu _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.keyinpack - _o_.keyinpack;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.endure - _o_.endure;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
