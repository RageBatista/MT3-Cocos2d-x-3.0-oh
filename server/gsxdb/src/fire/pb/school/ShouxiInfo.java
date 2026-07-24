//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.school;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ShouxiInfo implements Marshal, Comparable<ShouxiInfo> {
    public int maxhp;
    public int maxmp;
    public int hitrate;
    public int attack;
    public int defend;
    public int magicattack;
    public int magicdef;
    public int speed;
    public int dodge;

    public ShouxiInfo() {
    }

    public ShouxiInfo(int _maxhp_, int _maxmp_, int _hitrate_, int _attack_, int _defend_, int _magicattack_, int _magicdef_, int _speed_, int _dodge_) {
        this.maxhp = _maxhp_;
        this.maxmp = _maxmp_;
        this.hitrate = _hitrate_;
        this.attack = _attack_;
        this.defend = _defend_;
        this.magicattack = _magicattack_;
        this.magicdef = _magicdef_;
        this.speed = _speed_;
        this.dodge = _dodge_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.maxhp);
        _os_.marshal(this.maxmp);
        _os_.marshal(this.hitrate);
        _os_.marshal(this.attack);
        _os_.marshal(this.defend);
        _os_.marshal(this.magicattack);
        _os_.marshal(this.magicdef);
        _os_.marshal(this.speed);
        _os_.marshal(this.dodge);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.maxhp = _os_.unmarshal_int();
        this.maxmp = _os_.unmarshal_int();
        this.hitrate = _os_.unmarshal_int();
        this.attack = _os_.unmarshal_int();
        this.defend = _os_.unmarshal_int();
        this.magicattack = _os_.unmarshal_int();
        this.magicdef = _os_.unmarshal_int();
        this.speed = _os_.unmarshal_int();
        this.dodge = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ShouxiInfo) {
            ShouxiInfo _o_ = (ShouxiInfo)_o1_;
            if (this.maxhp != _o_.maxhp) {
                return false;
            } else if (this.maxmp != _o_.maxmp) {
                return false;
            } else if (this.hitrate != _o_.hitrate) {
                return false;
            } else if (this.attack != _o_.attack) {
                return false;
            } else if (this.defend != _o_.defend) {
                return false;
            } else if (this.magicattack != _o_.magicattack) {
                return false;
            } else if (this.magicdef != _o_.magicdef) {
                return false;
            } else if (this.speed != _o_.speed) {
                return false;
            } else {
                return this.dodge == _o_.dodge;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.maxhp;
        _h_ += this.maxmp;
        _h_ += this.hitrate;
        _h_ += this.attack;
        _h_ += this.defend;
        _h_ += this.magicattack;
        _h_ += this.magicdef;
        _h_ += this.speed;
        _h_ += this.dodge;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.maxhp).append(",");
        _sb_.append(this.maxmp).append(",");
        _sb_.append(this.hitrate).append(",");
        _sb_.append(this.attack).append(",");
        _sb_.append(this.defend).append(",");
        _sb_.append(this.magicattack).append(",");
        _sb_.append(this.magicdef).append(",");
        _sb_.append(this.speed).append(",");
        _sb_.append(this.dodge).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(ShouxiInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.maxhp - _o_.maxhp;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.maxmp - _o_.maxmp;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.hitrate - _o_.hitrate;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.attack - _o_.attack;
                        if (0 != _c_) {
                            return _c_;
                        } else {
                            _c_ = this.defend - _o_.defend;
                            if (0 != _c_) {
                                return _c_;
                            } else {
                                _c_ = this.magicattack - _o_.magicattack;
                                if (0 != _c_) {
                                    return _c_;
                                } else {
                                    _c_ = this.magicdef - _o_.magicdef;
                                    if (0 != _c_) {
                                        return _c_;
                                    } else {
                                        _c_ = this.speed - _o_.speed;
                                        if (0 != _c_) {
                                            return _c_;
                                        } else {
                                            _c_ = this.dodge - _o_.dodge;
                                            return 0 != _c_ ? _c_ : _c_;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
