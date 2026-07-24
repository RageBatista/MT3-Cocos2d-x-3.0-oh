//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.attr;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class RoleBasicFightProperties implements Marshal {
    public short cons;
    public short iq;
    public short str;
    public short endu;
    public short agi;
    public HashMap<Integer, Integer> cons_save;
    public HashMap<Integer, Integer> iq_save;
    public HashMap<Integer, Integer> str_save;
    public HashMap<Integer, Integer> endu_save;
    public HashMap<Integer, Integer> agi_save;

    public RoleBasicFightProperties() {
        this.cons_save = new HashMap<>();
        this.iq_save = new HashMap<>();
        this.str_save = new HashMap<>();
        this.endu_save = new HashMap<>();
        this.agi_save = new HashMap<>();
    }

    public RoleBasicFightProperties(short _cons_, short _iq_, short _str_, short _endu_, short _agi_, HashMap<Integer, Integer> _cons_save_, HashMap<Integer, Integer> _iq_save_, HashMap<Integer, Integer> _str_save_, HashMap<Integer, Integer> _endu_save_, HashMap<Integer, Integer> _agi_save_) {
        this.cons = _cons_;
        this.iq = _iq_;
        this.str = _str_;
        this.endu = _endu_;
        this.agi = _agi_;
        this.cons_save = _cons_save_;
        this.iq_save = _iq_save_;
        this.str_save = _str_save_;
        this.endu_save = _endu_save_;
        this.agi_save = _agi_save_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.cons);
        _os_.marshal(this.iq);
        _os_.marshal(this.str);
        _os_.marshal(this.endu);
        _os_.marshal(this.agi);
        _os_.compact_uint32(this.cons_save.size());

        for(Map.Entry<Integer, Integer> _e_ : this.cons_save.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        _os_.compact_uint32(this.iq_save.size());

        for(Map.Entry<Integer, Integer> _e_ : this.iq_save.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        _os_.compact_uint32(this.str_save.size());

        for(Map.Entry<Integer, Integer> _e_ : this.str_save.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        _os_.compact_uint32(this.endu_save.size());

        for(Map.Entry<Integer, Integer> _e_ : this.endu_save.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        _os_.compact_uint32(this.agi_save.size());

        for(Map.Entry<Integer, Integer> _e_ : this.agi_save.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.cons = _os_.unmarshal_short();
        this.iq = _os_.unmarshal_short();
        this.str = _os_.unmarshal_short();
        this.endu = _os_.unmarshal_short();
        this.agi = _os_.unmarshal_short();

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.cons_save.put(_k_, _v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.iq_save.put(_k_, _v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.str_save.put(_k_, _v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.endu_save.put(_k_, _v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.agi_save.put(_k_, _v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RoleBasicFightProperties) {
            RoleBasicFightProperties _o_ = (RoleBasicFightProperties)_o1_;
            if (this.cons != _o_.cons) {
                return false;
            } else if (this.iq != _o_.iq) {
                return false;
            } else if (this.str != _o_.str) {
                return false;
            } else if (this.endu != _o_.endu) {
                return false;
            } else if (this.agi != _o_.agi) {
                return false;
            } else if (!this.cons_save.equals(_o_.cons_save)) {
                return false;
            } else if (!this.iq_save.equals(_o_.iq_save)) {
                return false;
            } else if (!this.str_save.equals(_o_.str_save)) {
                return false;
            } else if (!this.endu_save.equals(_o_.endu_save)) {
                return false;
            } else {
                return this.agi_save.equals(_o_.agi_save);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.cons;
        _h_ += this.iq;
        _h_ += this.str;
        _h_ += this.endu;
        _h_ += this.agi;
        _h_ += this.cons_save.hashCode();
        _h_ += this.iq_save.hashCode();
        _h_ += this.str_save.hashCode();
        _h_ += this.endu_save.hashCode();
        _h_ += this.agi_save.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.cons).append(",");
        _sb_.append(this.iq).append(",");
        _sb_.append(this.str).append(",");
        _sb_.append(this.endu).append(",");
        _sb_.append(this.agi).append(",");
        _sb_.append(this.cons_save).append(",");
        _sb_.append(this.iq_save).append(",");
        _sb_.append(this.str_save).append(",");
        _sb_.append(this.endu_save).append(",");
        _sb_.append(this.agi_save).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
