//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.buff;

import com.locojoy.base.Octets;
import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.LinkedList;

public class Buff implements Marshal {
    public long time;
    public int count;
    public LinkedList<Octets> tipargs;

    public Buff() {
        this.tipargs = new LinkedList<>();
    }

    public Buff(long _time_, int _count_, LinkedList<Octets> _tipargs_) {
        this.time = _time_;
        this.count = _count_;
        this.tipargs = _tipargs_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.time);
        _os_.marshal(this.count);
        _os_.compact_uint32(this.tipargs.size());

        for(Octets _v_ : this.tipargs) {
            _os_.marshal(_v_);
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.time = _os_.unmarshal_long();
        this.count = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            Octets _v_ = _os_.unmarshal_Octets();
            this.tipargs.add(_v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof Buff) {
            Buff _o_ = (Buff)_o1_;
            if (this.time != _o_.time) {
                return false;
            } else if (this.count != _o_.count) {
                return false;
            } else {
                return this.tipargs.equals(_o_.tipargs);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.time;
        _h_ += this.count;
        _h_ += this.tipargs.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.time).append(",");
        _sb_.append(this.count).append(",");
        _sb_.append(this.tipargs).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
