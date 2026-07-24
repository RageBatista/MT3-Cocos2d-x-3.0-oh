//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.yichu;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class SYiChuYongYou extends __SYiChuYongYou__ {
    public static final int PROTOCOL_TYPE = 800013;
    public Map<Integer, Integer> yichu;

    protected void process() {
    }

    public int getType() {
        return 800013;
    }

    public SYiChuYongYou() {
        this.yichu = new HashMap();
    }

    public SYiChuYongYou(HashMap<Integer, Integer> _sysconfigmap_) {
        this.yichu = _sysconfigmap_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.compact_uint32(this.yichu.size());

            for(Map.Entry<Integer, Integer> _e_ : this.yichu.entrySet()) {
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
            this.yichu.put(_k_, _v_);
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
        } else if (_o1_ instanceof SYiChuYongYou) {
            SYiChuYongYou _o_ = (SYiChuYongYou)_o1_;
            return this.yichu.equals(_o_.yichu);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0 + this.yichu.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.yichu).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SYiChuYongYou paramSXiLianEquip) {
        return paramSXiLianEquip == this ? 0 : 0;
    }
}
