//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.jingmai;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class XingChenItem implements Marshal {
    public long id;
    public int pos;
    public int level;
    public int pinzhi;
    public int naijiu;
    public float shuxing;
    public float xishu;

    public XingChenItem() {
    }

    public XingChenItem(long _id_, int _pos_, int _level_, int _pinzhi_, int _naijiu_, float _shuxing_, float _xishu_) {
        this.id = _id_;
        this.pos = _pos_;
        this.level = _level_;
        this.pinzhi = _pinzhi_;
        this.naijiu = _naijiu_;
        this.shuxing = _shuxing_;
        this.xishu = _xishu_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.id);
        _os_.marshal(this.pos);
        _os_.marshal(this.level);
        _os_.marshal(this.pinzhi);
        _os_.marshal(this.naijiu);
        _os_.marshal(this.shuxing);
        _os_.marshal(this.xishu);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.id = _os_.unmarshal_long();
        this.pos = _os_.unmarshal_int();
        this.level = _os_.unmarshal_int();
        this.pinzhi = _os_.unmarshal_int();
        this.naijiu = _os_.unmarshal_int();
        this.shuxing = _os_.unmarshal_float();
        this.xishu = _os_.unmarshal_float();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof XingChenItem) {
            XingChenItem _o_ = (XingChenItem)_o1_;
            if (this.id != _o_.id) {
                return false;
            } else if (this.pos != _o_.pos) {
                return false;
            } else if (this.level != _o_.level) {
                return false;
            } else if (this.pinzhi != _o_.pinzhi) {
                return false;
            } else if (this.naijiu != _o_.naijiu) {
                return false;
            } else if (this.shuxing != _o_.shuxing) {
                return false;
            } else {
                return this.xishu == _o_.xishu;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ = (int)((long)_h_ + this.id);
        _h_ += this.pos;
        _h_ += this.level;
        _h_ += this.pinzhi;
        _h_ += this.naijiu;
        _h_ = (int)((float)_h_ + this.shuxing);
        _h_ = (int)((float)_h_ + this.xishu);
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.id).append(",");
        _sb_.append(this.pos).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.pinzhi).append(",");
        _sb_.append(this.naijiu).append(",");
        _sb_.append(this.shuxing).append(",");
        _sb_.append(this.xishu).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
