//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.baichong;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class SWishRet extends __SWishRet__ {
    public static final int PROTOCOL_TYPE = 810021;
    public HashMap<Integer, Integer> datas;
    public int gettype;

    protected void process() {
    }

    public int getType() {
        return 810021;
    }

    public SWishRet() {
        this.datas = new HashMap<>();
    }

    public SWishRet(HashMap<Integer, Integer> _datas_, int _gettype_) {
        this.datas = _datas_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.compact_uint32(this.datas.size());

            for(Map.Entry<Integer, Integer> _e_ : this.datas.entrySet()) {
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
            this.datas.put(_k_, _v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SWishRet) {
            SWishRet _o_ = (SWishRet)_o1_;
            return this.datas.equals(_o_.datas);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0 + this.datas.hashCode();
        return _h_ + this.gettype;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.datas).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
