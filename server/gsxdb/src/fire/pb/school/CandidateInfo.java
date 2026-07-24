//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.school;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class CandidateInfo implements Marshal {
    public long roleid;
    public String rolename;
    public int tickets;
    public String words;
    public int shape;
    public HashMap<Byte, Integer> components;

    public CandidateInfo() {
        this.rolename = "";
        this.words = "";
        this.components = new HashMap();
    }

    public CandidateInfo(long _roleid_, String _rolename_, int _tickets_, String _words_, int _shape_, HashMap<Byte, Integer> _components_) {
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.tickets = _tickets_;
        this.words = _words_;
        this.shape = _shape_;
        this.components = _components_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.tickets);
        _os_.marshal(this.words, "UTF-16LE");
        _os_.marshal(this.shape);
        _os_.compact_uint32(this.components.size());

        for(Map.Entry<Byte, Integer> _e_ : this.components.entrySet()) {
            _os_.marshal((Byte)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.tickets = _os_.unmarshal_int();
        this.words = _os_.unmarshal_String("UTF-16LE");
        this.shape = _os_.unmarshal_int();

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            byte _k_ = _os_.unmarshal_byte();
            int _v_ = _os_.unmarshal_int();
            this.components.put(_k_, _v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CandidateInfo) {
            CandidateInfo _o_ = (CandidateInfo)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else if (this.tickets != _o_.tickets) {
                return false;
            } else if (!this.words.equals(_o_.words)) {
                return false;
            } else if (this.shape != _o_.shape) {
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
        _h_ += (int)this.roleid;
        _h_ += this.rolename.hashCode();
        _h_ += this.tickets;
        _h_ += this.words.hashCode();
        _h_ += this.shape;
        _h_ += this.components.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.tickets).append(",");
        _sb_.append("T").append(this.words.length()).append(",");
        _sb_.append(this.shape).append(",");
        _sb_.append(this.components).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
