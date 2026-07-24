//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.zuoqi;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class SZuoQiYongYou extends __SZuoQiYongYou__ {
    public static final int PROTOCOL_TYPE = 800022;
    public Map<Integer, Integer> zuoqi;

    protected void process() {
    }

    public int getType() {
        return 800022;
    }

    public SZuoQiYongYou() {
        this.zuoqi = new HashMap();
    }

    public SZuoQiYongYou(HashMap<Integer, Integer> _sysconfigmap_) {
        this.zuoqi = _sysconfigmap_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.compact_uint32(this.zuoqi.size());

            for(Map.Entry<Integer, Integer> _e_ : this.zuoqi.entrySet()) {
                _os_.marshal((Integer)_e_.getKey());
                _os_.marshal((Integer)_e_.getValue());
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.zuoqi.put(_k_, _v_);
        }

        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SZuoQiYongYou) {
            SZuoQiYongYou _o_ = (SZuoQiYongYou)_o1_;
            return this.zuoqi.equals(_o_.zuoqi);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.zuoqi.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.zuoqi).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SZuoQiYongYou paramSXiLianEquip) {
        if (paramSXiLianEquip == this) {
            return 0;
        } else {
            int i = 0;
            return i;
        }
    }
}
