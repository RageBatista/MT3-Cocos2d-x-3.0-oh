//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ComposeGemInfoBean implements Marshal, Comparable<ComposeGemInfoBean> {
    public int itemidorgoodid;
    public int num;

    public ComposeGemInfoBean() {
    }

    public ComposeGemInfoBean(int _itemidorgoodid_, int _num_) {
        this.itemidorgoodid = _itemidorgoodid_;
        this.num = _num_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.itemidorgoodid);
        _os_.marshal(this.num);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.itemidorgoodid = _os_.unmarshal_int();
        this.num = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ComposeGemInfoBean) {
            ComposeGemInfoBean _o_ = (ComposeGemInfoBean)_o1_;
            if (this.itemidorgoodid != _o_.itemidorgoodid) {
                return false;
            } else {
                return this.num == _o_.num;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.itemidorgoodid;
        _h_ += this.num;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.itemidorgoodid).append(",");
        _sb_.append(this.num).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(ComposeGemInfoBean _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.itemidorgoodid - _o_.itemidorgoodid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.num - _o_.num;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}
