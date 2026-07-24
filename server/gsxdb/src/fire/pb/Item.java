//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class Item implements Marshal, Comparable<Item> {
    public static final int BIND = 1;
    public static final int FUSHI = 2;
    public static final int ONSTALL = 4;
    public static final int ONCOFCSELL = 8;
    public static final int CANNOTONSTALL = 16;
    public static final int LOCK = 32;
    public static final int TIMEOUT = 64;
    public int id;
    public int flags;
    public int key;
    public int position;
    public int number;
    public long timeout;
    public int isnew;
    public long loseeffecttime;
    public long markettime;

    public Item() {
    }

    public Item(int _id_, int _flags_, int _key_, int _position_, int _number_, long _timeout_, int _isnew_, long _loseeffecttime_, long _markettime_) {
        this.id = _id_;
        this.flags = _flags_;
        this.key = _key_;
        this.position = _position_;
        this.number = _number_;
        this.timeout = _timeout_;
        this.isnew = _isnew_;
        this.loseeffecttime = _loseeffecttime_;
        this.markettime = _markettime_;
    }

    public final boolean _validator_() {
        if (this.id < 1) {
            return false;
        } else if (this.key < 1) {
            return false;
        } else if (this.position < 0) {
            return false;
        } else if (this.number < 1) {
            return false;
        } else {
            return this.isnew >= 0 && this.isnew <= 1;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.id);
        _os_.marshal(this.flags);
        _os_.marshal(this.key);
        _os_.marshal(this.position);
        _os_.marshal(this.number);
        _os_.marshal(this.timeout);
        _os_.marshal(this.isnew);
        _os_.marshal(this.loseeffecttime);
        _os_.marshal(this.markettime);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.id = _os_.unmarshal_int();
        this.flags = _os_.unmarshal_int();
        this.key = _os_.unmarshal_int();
        this.position = _os_.unmarshal_int();
        this.number = _os_.unmarshal_int();
        this.timeout = _os_.unmarshal_long();
        this.isnew = _os_.unmarshal_int();
        this.loseeffecttime = _os_.unmarshal_long();
        this.markettime = _os_.unmarshal_long();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof Item) {
            Item _o_ = (Item)_o1_;
            if (this.id != _o_.id) {
                return false;
            } else if (this.flags != _o_.flags) {
                return false;
            } else if (this.key != _o_.key) {
                return false;
            } else if (this.position != _o_.position) {
                return false;
            } else if (this.number != _o_.number) {
                return false;
            } else if (this.timeout != _o_.timeout) {
                return false;
            } else if (this.isnew != _o_.isnew) {
                return false;
            } else if (this.loseeffecttime != _o_.loseeffecttime) {
                return false;
            } else {
                return this.markettime == _o_.markettime;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.id;
        _h_ += this.flags;
        _h_ += this.key;
        _h_ += this.position;
        _h_ += this.number;
        _h_ += (int)this.timeout;
        _h_ += this.isnew;
        _h_ += (int)this.loseeffecttime;
        _h_ += (int)this.markettime;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.id).append(",");
        _sb_.append(this.flags).append(",");
        _sb_.append(this.key).append(",");
        _sb_.append(this.position).append(",");
        _sb_.append(this.number).append(",");
        _sb_.append(this.timeout).append(",");
        _sb_.append(this.isnew).append(",");
        _sb_.append(this.loseeffecttime).append(",");
        _sb_.append(this.markettime).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(Item _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.id - _o_.id;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.flags - _o_.flags;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.key - _o_.key;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.position - _o_.position;
                        if (0 != _c_) {
                            return _c_;
                        } else {
                            _c_ = this.number - _o_.number;
                            if (0 != _c_) {
                                return _c_;
                            } else {
                                _c_ = Long.signum(this.timeout - _o_.timeout);
                                if (0 != _c_) {
                                    return _c_;
                                } else {
                                    _c_ = this.isnew - _o_.isnew;
                                    if (0 != _c_) {
                                        return _c_;
                                    } else {
                                        _c_ = Long.signum(this.loseeffecttime - _o_.loseeffecttime);
                                        if (0 != _c_) {
                                            return _c_;
                                        } else {
                                            _c_ = Long.signum(this.markettime - _o_.markettime);
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
