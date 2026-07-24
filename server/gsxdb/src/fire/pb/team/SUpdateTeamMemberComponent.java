//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class SUpdateTeamMemberComponent extends __SUpdateTeamMemberComponent__ {
    public static final int PROTOCOL_TYPE = 794488;
    public long memberid;
    public HashMap<Byte, Integer> components;

    protected void process() {
    }

    public int getType() {
        return 794488;
    }

    public SUpdateTeamMemberComponent() {
        this.components = new HashMap();
    }

    public SUpdateTeamMemberComponent(long _memberid_, HashMap<Byte, Integer> _components_) {
        this.memberid = _memberid_;
        this.components = _components_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.memberid);
            _os_.compact_uint32(this.components.size());

            for(Map.Entry<Byte, Integer> _e_ : this.components.entrySet()) {
                _os_.marshal((int)_e_.getKey());
                _os_.marshal((Integer)_e_.getValue());
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.memberid = _os_.unmarshal_long();

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            byte _k_ = (byte)_os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.components.put(_k_, _v_);
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
        } else if (_o1_ instanceof SUpdateTeamMemberComponent) {
            SUpdateTeamMemberComponent _o_ = (SUpdateTeamMemberComponent)_o1_;
            if (this.memberid != _o_.memberid) {
                return false;
            } else {
                return this.components.equals(_o_.components);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.memberid;
        _h_ += this.components.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.memberid).append(",");
        _sb_.append(this.components).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
