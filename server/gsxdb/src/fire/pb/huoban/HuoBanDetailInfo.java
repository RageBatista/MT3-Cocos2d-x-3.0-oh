//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.huoban;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.ArrayList;

public class HuoBanDetailInfo implements Marshal {
    public int huobanid;
    public int infight;
    public long state;
    public int weekfree;
    public ArrayList<Integer> datas;

    public HuoBanDetailInfo() {
        this.datas = new ArrayList<>();
    }

    public HuoBanDetailInfo(int _huobanid_, int _infight_, long _state_, int _weekfree_, ArrayList<Integer> _datas_) {
        this.huobanid = _huobanid_;
        this.infight = _infight_;
        this.state = _state_;
        this.weekfree = _weekfree_;
        this.datas = _datas_;
    }

    public final boolean _validator_() {
        return this.weekfree >= 0 && this.weekfree <= 1;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.huobanid);
        _os_.marshal(this.infight);
        _os_.marshal(this.state);
        _os_.marshal(this.weekfree);
        _os_.compact_uint32(this.datas.size());

        for(Integer _v_ : this.datas) {
            _os_.marshal(_v_);
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.huobanid = _os_.unmarshal_int();
        this.infight = _os_.unmarshal_int();
        this.state = _os_.unmarshal_long();
        this.weekfree = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            int _v_ = _os_.unmarshal_int();
            this.datas.add(_v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof HuoBanDetailInfo) {
            HuoBanDetailInfo _o_ = (HuoBanDetailInfo)_o1_;
            if (this.huobanid != _o_.huobanid) {
                return false;
            } else if (this.infight != _o_.infight) {
                return false;
            } else if (this.state != _o_.state) {
                return false;
            } else if (this.weekfree != _o_.weekfree) {
                return false;
            } else {
                return this.datas.equals(_o_.datas);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.huobanid;
        _h_ += this.infight;
        _h_ += (int)this.state;
        _h_ += this.weekfree;
        _h_ += this.datas.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.huobanid).append(",");
        _sb_.append(this.infight).append(",");
        _sb_.append(this.state).append(",");
        _sb_.append(this.weekfree).append(",");
        _sb_.append(this.datas).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
