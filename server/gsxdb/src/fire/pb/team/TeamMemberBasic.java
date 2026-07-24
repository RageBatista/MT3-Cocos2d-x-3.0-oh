//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class TeamMemberBasic implements Marshal {
    public long roleid;
    public String rolename;
    public int level;
    public long sceneid;
    public Pos1 pos;
    public int school;
    public int hp;
    public int maxhp;
    public int mp;
    public int maxmp;
    public String title;
    public int state;
    public int shape;
    public byte hugindex;
    public HashMap<Byte, Integer> components;
    public byte camp;

    public TeamMemberBasic() {
        this.rolename = "";
        this.pos = new Pos1();
        this.title = "";
        this.components = new HashMap();
    }

    public TeamMemberBasic(long _roleid_, String _rolename_, int _level_, long _sceneid_, Pos1 _pos_, int _school_, int _hp_, int _maxhp_, int _mp_, int _maxmp_, String _title_, int _state_, int _shape_, byte _hugindex_, HashMap<Byte, Integer> _components_, byte _camp_) {
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.level = _level_;
        this.sceneid = _sceneid_;
        this.pos = _pos_;
        this.school = _school_;
        this.hp = _hp_;
        this.maxhp = _maxhp_;
        this.mp = _mp_;
        this.maxmp = _maxmp_;
        this.title = _title_;
        this.state = _state_;
        this.shape = _shape_;
        this.hugindex = _hugindex_;
        this.components = _components_;
        this.camp = _camp_;
    }

    public final boolean _validator_() {
        return this.pos._validator_();
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.level);
        _os_.marshal(this.sceneid);
        _os_.marshal(this.pos);
        _os_.marshal(this.school);
        _os_.marshal(this.hp);
        _os_.marshal(this.maxhp);
        _os_.marshal(this.mp);
        _os_.marshal(this.maxmp);
        _os_.marshal(this.title, "UTF-16LE");
        _os_.marshal(this.state);
        _os_.marshal(this.shape);
        _os_.marshal(this.hugindex);
        _os_.compact_uint32(this.components.size());

        for(Map.Entry<Byte, Integer> _e_ : this.components.entrySet()) {
            _os_.marshal((int)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        _os_.marshal((int)this.camp);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.level = _os_.unmarshal_int();
        this.sceneid = _os_.unmarshal_long();
        this.pos.unmarshal(_os_);
        this.school = _os_.unmarshal_int();
        this.hp = _os_.unmarshal_int();
        this.maxhp = _os_.unmarshal_int();
        this.mp = _os_.unmarshal_int();
        this.maxmp = _os_.unmarshal_int();
        this.title = _os_.unmarshal_String("UTF-16LE");
        this.state = _os_.unmarshal_int();
        this.shape = _os_.unmarshal_int();
        this.hugindex = _os_.unmarshal_byte();

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            byte _k_ = (byte)_os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.components.put(_k_, _v_);
        }

        this.camp = (byte)_os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof TeamMemberBasic) {
            TeamMemberBasic _o_ = (TeamMemberBasic)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else if (this.level != _o_.level) {
                return false;
            } else if (this.sceneid != _o_.sceneid) {
                return false;
            } else if (!this.pos.equals(_o_.pos)) {
                return false;
            } else if (this.school != _o_.school) {
                return false;
            } else if (this.hp != _o_.hp) {
                return false;
            } else if (this.maxhp != _o_.maxhp) {
                return false;
            } else if (this.mp != _o_.mp) {
                return false;
            } else if (this.maxmp != _o_.maxmp) {
                return false;
            } else if (!this.title.equals(_o_.title)) {
                return false;
            } else if (this.state != _o_.state) {
                return false;
            } else if (this.shape != _o_.shape) {
                return false;
            } else if (this.hugindex != _o_.hugindex) {
                return false;
            } else if (!this.components.equals(_o_.components)) {
                return false;
            } else {
                return this.camp == _o_.camp;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.rolename.hashCode();
        _h_ += this.level;
        _h_ += (int)this.sceneid;
        _h_ += this.pos.hashCode();
        _h_ += this.school;
        _h_ += this.hp;
        _h_ += this.maxhp;
        _h_ += this.mp;
        _h_ += this.maxmp;
        _h_ += this.title.hashCode();
        _h_ += this.state;
        _h_ += this.shape;
        _h_ += this.hugindex;
        _h_ += this.components.hashCode();
        _h_ += this.camp;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.sceneid).append(",");
        _sb_.append(this.pos).append(",");
        _sb_.append(this.school).append(",");
        _sb_.append(this.hp).append(",");
        _sb_.append(this.maxhp).append(",");
        _sb_.append(this.mp).append(",");
        _sb_.append(this.maxmp).append(",");
        _sb_.append("T").append(this.title.length()).append(",");
        _sb_.append(this.state).append(",");
        _sb_.append(this.shape).append(",");
        _sb_.append(this.hugindex).append(",");
        _sb_.append(this.components).append(",");
        _sb_.append(this.camp).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
