//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.FormBean;
import java.util.HashMap;
import java.util.Map;

public class SFormationsMap extends __SFormationsMap__ {
    public static final int PROTOCOL_TYPE = 794551;
    public HashMap<Integer, FormBean> formationmap;

    protected void process() {
    }

    public int getType() {
        return 794551;
    }

    public SFormationsMap() {
        this.formationmap = new HashMap();
    }

    public SFormationsMap(HashMap<Integer, FormBean> _formationmap_) {
        this.formationmap = _formationmap_;
    }

    public final boolean _validator_() {
        for(Map.Entry<Integer, FormBean> _e_ : this.formationmap.entrySet()) {
            if (!((FormBean)_e_.getValue())._validator_()) {
                return false;
            }
        }

        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.compact_uint32(this.formationmap.size());

            for(Map.Entry<Integer, FormBean> _e_ : this.formationmap.entrySet()) {
                _os_.marshal((Integer)_e_.getKey());
                _os_.marshal((Marshal)_e_.getValue());
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            FormBean _v_ = new FormBean();
            _v_.unmarshal(_os_);
            this.formationmap.put(_k_, _v_);
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
        } else if (_o1_ instanceof SFormationsMap) {
            SFormationsMap _o_ = (SFormationsMap)_o1_;
            return this.formationmap.equals(_o_.formationmap);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.formationmap.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.formationmap).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
