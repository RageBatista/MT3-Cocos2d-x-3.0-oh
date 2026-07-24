//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class MarketGoods implements Marshal, Comparable<MarketGoods> {
    public long id;
    public long saleroleid;
    public int itemid;
    public int num;
    public int noticenum;
    public int key;
    public int price;
    public long showtime;
    public long expiretime;
    public int itemtype;
    public int level;
    public int attentionnumber;

    public MarketGoods() {
    }

    public MarketGoods(long _id_, long _saleroleid_, int _itemid_, int _num_, int _noticenum_, int _key_, int _price_, long _showtime_, long _expiretime_, int _itemtype_, int _level_, int _attentionnumber_) {
        this.id = _id_;
        this.saleroleid = _saleroleid_;
        this.itemid = _itemid_;
        this.num = _num_;
        this.noticenum = _noticenum_;
        this.key = _key_;
        this.price = _price_;
        this.showtime = _showtime_;
        this.expiretime = _expiretime_;
        this.itemtype = _itemtype_;
        this.level = _level_;
        this.attentionnumber = _attentionnumber_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.id);
        _os_.marshal(this.saleroleid);
        _os_.marshal(this.itemid);
        _os_.marshal(this.num);
        _os_.marshal(this.noticenum);
        _os_.marshal(this.key);
        _os_.marshal(this.price);
        _os_.marshal(this.showtime);
        _os_.marshal(this.expiretime);
        _os_.marshal(this.itemtype);
        _os_.marshal(this.level);
        _os_.marshal(this.attentionnumber);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.id = _os_.unmarshal_long();
        this.saleroleid = _os_.unmarshal_long();
        this.itemid = _os_.unmarshal_int();
        this.num = _os_.unmarshal_int();
        this.noticenum = _os_.unmarshal_int();
        this.key = _os_.unmarshal_int();
        this.price = _os_.unmarshal_int();
        this.showtime = _os_.unmarshal_long();
        this.expiretime = _os_.unmarshal_long();
        this.itemtype = _os_.unmarshal_int();
        this.level = _os_.unmarshal_int();
        this.attentionnumber = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof MarketGoods) {
            MarketGoods _o_ = (MarketGoods)_o1_;
            if (this.id != _o_.id) {
                return false;
            } else if (this.saleroleid != _o_.saleroleid) {
                return false;
            } else if (this.itemid != _o_.itemid) {
                return false;
            } else if (this.num != _o_.num) {
                return false;
            } else if (this.noticenum != _o_.noticenum) {
                return false;
            } else if (this.key != _o_.key) {
                return false;
            } else if (this.price != _o_.price) {
                return false;
            } else if (this.showtime != _o_.showtime) {
                return false;
            } else if (this.expiretime != _o_.expiretime) {
                return false;
            } else if (this.itemtype != _o_.itemtype) {
                return false;
            } else if (this.level != _o_.level) {
                return false;
            } else {
                return this.attentionnumber == _o_.attentionnumber;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.id;
        _h_ += (int)this.saleroleid;
        _h_ += this.itemid;
        _h_ += this.num;
        _h_ += this.noticenum;
        _h_ += this.key;
        _h_ += this.price;
        _h_ += (int)this.showtime;
        _h_ += (int)this.expiretime;
        _h_ += this.itemtype;
        _h_ += this.level;
        _h_ += this.attentionnumber;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.id).append(",");
        _sb_.append(this.saleroleid).append(",");
        _sb_.append(this.itemid).append(",");
        _sb_.append(this.num).append(",");
        _sb_.append(this.noticenum).append(",");
        _sb_.append(this.key).append(",");
        _sb_.append(this.price).append(",");
        _sb_.append(this.showtime).append(",");
        _sb_.append(this.expiretime).append(",");
        _sb_.append(this.itemtype).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.attentionnumber).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(MarketGoods _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.id - _o_.id);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = Long.signum(this.saleroleid - _o_.saleroleid);
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.itemid - _o_.itemid;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.num - _o_.num;
                        if (0 != _c_) {
                            return _c_;
                        } else {
                            _c_ = this.noticenum - _o_.noticenum;
                            if (0 != _c_) {
                                return _c_;
                            } else {
                                _c_ = this.key - _o_.key;
                                if (0 != _c_) {
                                    return _c_;
                                } else {
                                    _c_ = this.price - _o_.price;
                                    if (0 != _c_) {
                                        return _c_;
                                    } else {
                                        _c_ = Long.signum(this.showtime - _o_.showtime);
                                        if (0 != _c_) {
                                            return _c_;
                                        } else {
                                            _c_ = Long.signum(this.expiretime - _o_.expiretime);
                                            if (0 != _c_) {
                                                return _c_;
                                            } else {
                                                _c_ = this.itemtype - _o_.itemtype;
                                                if (0 != _c_) {
                                                    return _c_;
                                                } else {
                                                    _c_ = this.level - _o_.level;
                                                    if (0 != _c_) {
                                                        return _c_;
                                                    } else {
                                                        _c_ = this.attentionnumber - _o_.attentionnumber;
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
        }
    }
}
