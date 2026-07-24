//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.move;

import com.locojoy.base.Octets;
import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class RoleBasicOctets implements Marshal {
    public static final int SHOW_PET = 1;
    public static final int TEAM_INFO = 2;
    public static final int TITLE_ID = 3;
    public static final int TITLE_NAME = 4;
    public static final int STALL_NAME = 5;
    public static final int MODEL_TEMPLATE = 6;
    public static final int HEADRESS_SHAPE = 7;
    public static final int SCENE_STATE = 8;
    public static final int WEAPON_BASEID = 9;
    public static final int WEAPON_COLOR = 10;
    public static final int ROLE_ACTUALLY_SHAPE = 12;
    public static final int PLAYING_ACTION = 13;
    public static final int STALL_BOARD = 14;
    public static final int FOOT_LOGO_ID = 15;
    public static final int AWAKE_STATE = 16;
    public static final int FOLLOW_NPC = 17;
    public static final int CRUISE = 18;
    public static final int EFFECT_EQUIP = 19;
    public static final int CRUISE2 = 20;
    public static final int CRUISE3 = 21;
    public long roleid;
    public String rolename;
    public byte dirandschool;
    public int shape;
    public int level;
    public byte camp;
    public HashMap<Byte, Integer> components;
    public HashMap<Byte, Octets> datas;

    public RoleBasicOctets() {
        this.rolename = "";
        this.components = new HashMap();
        this.datas = new HashMap();
    }

    public RoleBasicOctets(long _roleid_, String _rolename_, byte _dirandschool_, int _shape_, int _level_, byte _camp_, HashMap<Byte, Integer> _components_, HashMap<Byte, Octets> _datas_) {
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.dirandschool = _dirandschool_;
        this.shape = _shape_;
        this.level = _level_;
        this.camp = _camp_;
        this.components = _components_;
        this.datas = _datas_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.dirandschool);
        _os_.marshal(this.shape);
        _os_.marshal(this.level);
        _os_.marshal(this.camp);
        _os_.compact_uint32(this.components.size());

        for(Map.Entry<Byte, Integer> _e_ : this.components.entrySet()) {
            _os_.marshal((Byte)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        _os_.compact_uint32(this.datas.size());

        for(Map.Entry<Byte, Octets> _e_ : this.datas.entrySet()) {
            _os_.marshal((Byte)_e_.getKey());
            _os_.marshal((Octets)_e_.getValue());
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.dirandschool = _os_.unmarshal_byte();
        this.shape = _os_.unmarshal_int();
        this.level = _os_.unmarshal_int();
        this.camp = _os_.unmarshal_byte();

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            byte _k_ = _os_.unmarshal_byte();
            int _v_ = _os_.unmarshal_int();
            this.components.put(_k_, _v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            byte _k_ = _os_.unmarshal_byte();
            Octets _v_ = _os_.unmarshal_Octets();
            this.datas.put(_k_, _v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RoleBasicOctets) {
            RoleBasicOctets _o_ = (RoleBasicOctets)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else if (this.dirandschool != _o_.dirandschool) {
                return false;
            } else if (this.shape != _o_.shape) {
                return false;
            } else if (this.level != _o_.level) {
                return false;
            } else if (this.camp != _o_.camp) {
                return false;
            } else if (!this.components.equals(_o_.components)) {
                return false;
            } else {
                return this.datas.equals(_o_.datas);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.rolename.hashCode();
        _h_ += this.dirandschool;
        _h_ += this.shape;
        _h_ += this.level;
        _h_ += this.camp;
        _h_ += this.components.hashCode();
        _h_ += this.datas.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.dirandschool).append(",");
        _sb_.append(this.shape).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.camp).append(",");
        _sb_.append(this.components).append(",");
        _sb_.append(this.datas).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
