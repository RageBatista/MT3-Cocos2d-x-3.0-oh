//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.qiannengguo;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class SyncPotentialFruit extends __SyncPotentialFruit__ {
    public static final int PROTOCOL_TYPE = 810500;
    public HashMap<Integer, Integer> locations;
    public HashMap<Integer, Integer> props;
    public HashMap<Integer, Integer> extraprops;

    protected void process() {
    }

    public int getType() {
        return 810500;
    }

    public SyncPotentialFruit() {
        this.locations = new HashMap();
        this.props = new HashMap();
        this.extraprops = new HashMap();
    }

    public SyncPotentialFruit(HashMap<Integer, Integer> _locations_, HashMap<Integer, Integer> _props_, HashMap<Integer, Integer> _extraprops_) {
        this.locations = _locations_;
        this.props = _props_;
        this.extraprops = _extraprops_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.compact_uint32(this.locations.size());

            for(Map.Entry<Integer, Integer> _e_ : this.locations.entrySet()) {
                _os_.marshal((Integer)_e_.getKey());
                _os_.marshal((Integer)_e_.getValue());
            }

            _os_.compact_uint32(this.props.size());

            for(Map.Entry<Integer, Integer> _e_ : this.props.entrySet()) {
                _os_.marshal((Integer)_e_.getKey());
                _os_.marshal((Integer)_e_.getValue());
            }

            _os_.compact_uint32(this.extraprops.size());

            for(Map.Entry<Integer, Integer> _e_ : this.extraprops.entrySet()) {
                _os_.marshal((Integer)_e_.getKey());
                _os_.marshal((Integer)_e_.getValue());
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            this.locations.put(_k_, _os_.unmarshal_int());
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            this.props.put(_k_, _os_.unmarshal_int());
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            this.extraprops.put(_k_, _os_.unmarshal_int());
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
        } else if (!(_o1_ instanceof SyncPotentialFruit)) {
            return false;
        } else {
            SyncPotentialFruit _o_ = (SyncPotentialFruit)_o1_;
            return this.locations.equals(_o_.locations) && this.props.equals(_o_.props) && this.extraprops.equals(_o_.extraprops);
        }
    }

    public int hashCode() {
        return this.locations.hashCode() + this.props.hashCode() + this.extraprops.hashCode();
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.locations).append(",");
        _sb_.append(this.props).append(",");
        _sb_.append(this.extraprops).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
