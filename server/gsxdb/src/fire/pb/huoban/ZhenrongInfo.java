//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.huoban;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.ArrayList;

public class ZhenrongInfo implements Marshal {
    public int zhenfa;
    public ArrayList<Integer> huobanlist;

    public ZhenrongInfo() {
        this.huobanlist = new ArrayList<>();
    }

    public ZhenrongInfo(int _zhenfa_, ArrayList<Integer> _huobanlist_) {
        this.zhenfa = _zhenfa_;
        this.huobanlist = _huobanlist_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.zhenfa);
        _os_.compact_uint32(this.huobanlist.size());

        for(Integer _v_ : this.huobanlist) {
            _os_.marshal(_v_);
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.zhenfa = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            int _v_ = _os_.unmarshal_int();
            this.huobanlist.add(_v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ZhenrongInfo) {
            ZhenrongInfo _o_ = (ZhenrongInfo)_o1_;
            if (this.zhenfa != _o_.zhenfa) {
                return false;
            } else {
                return this.huobanlist.equals(_o_.huobanlist);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.zhenfa;
        _h_ += this.huobanlist.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.zhenfa).append(",");
        _sb_.append(this.huobanlist).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
