//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class EquipSkill implements Marshal, Comparable<EquipSkill> {
    public int skill;
    public int effect;

    public EquipSkill() {
    }

    public EquipSkill(int _skill_, int _effect_) {
        this.skill = _skill_;
        this.effect = _effect_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.skill);
        _os_.marshal(this.effect);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.skill = _os_.unmarshal_int();
        this.effect = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof EquipSkill) {
            EquipSkill _o_ = (EquipSkill)_o1_;
            if (this.skill != _o_.skill) {
                return false;
            } else {
                return this.effect == _o_.effect;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.skill;
        _h_ += this.effect;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.skill).append(",");
        _sb_.append(this.effect).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(EquipSkill _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.skill - _o_.skill;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.effect - _o_.effect;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
