//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.master;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class PInfo implements Marshal {
    public PBaseInfo prentice;
    public HashMap<Integer, Achive> achivemap;

    public PInfo() {
        this.prentice = new PBaseInfo();
        this.achivemap = new HashMap();
    }

    public PInfo(PBaseInfo _prentice_, HashMap<Integer, Achive> _achivemap_) {
        this.prentice = _prentice_;
        this.achivemap = _achivemap_;
    }

    public final boolean _validator_() {
        if (!this.prentice._validator_()) {
            return false;
        } else {
            for(Map.Entry<Integer, Achive> _e_ : this.achivemap.entrySet()) {
                if (!((Achive)_e_.getValue())._validator_()) {
                    return false;
                }
            }

            return true;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.prentice);
        _os_.compact_uint32(this.achivemap.size());

        for(Map.Entry<Integer, Achive> _e_ : this.achivemap.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Marshal)_e_.getValue());
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.prentice.unmarshal(_os_);

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            Achive _v_ = new Achive();
            _v_.unmarshal(_os_);
            this.achivemap.put(_k_, _v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof PInfo) {
            PInfo _o_ = (PInfo)_o1_;
            if (!this.prentice.equals(_o_.prentice)) {
                return false;
            } else {
                return this.achivemap.equals(_o_.achivemap);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.prentice.hashCode();
        _h_ += this.achivemap.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.prentice).append(",");
        _sb_.append(this.achivemap).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
