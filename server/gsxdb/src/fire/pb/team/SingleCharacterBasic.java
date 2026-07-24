//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SingleCharacterBasic implements Marshal {
    public long roleid;
    public int level;
    public String name;
    public int school;
    public Pos1 position;
    public byte camp;

    public SingleCharacterBasic() {
        this.name = "";
        this.position = new Pos1();
    }

    public SingleCharacterBasic(long _roleid_, int _level_, String _name_, int _school_, Pos1 _position_, byte _camp_) {
        this.roleid = _roleid_;
        this.level = _level_;
        this.name = _name_;
        this.school = _school_;
        this.position = _position_;
        this.camp = _camp_;
    }

    public final boolean _validator_() {
        return this.position._validator_();
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.level);
        _os_.marshal(this.name, "UTF-16LE");
        _os_.marshal(this.school);
        _os_.marshal(this.position);
        _os_.marshal(this.camp);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.level = _os_.unmarshal_int();
        this.name = _os_.unmarshal_String("UTF-16LE");
        this.school = _os_.unmarshal_int();
        this.position.unmarshal(_os_);
        this.camp = _os_.unmarshal_byte();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SingleCharacterBasic) {
            SingleCharacterBasic _o_ = (SingleCharacterBasic)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (this.level != _o_.level) {
                return false;
            } else if (!this.name.equals(_o_.name)) {
                return false;
            } else if (this.school != _o_.school) {
                return false;
            } else if (!this.position.equals(_o_.position)) {
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
        _h_ += this.level;
        _h_ += this.name.hashCode();
        _h_ += this.school;
        _h_ += this.position.hashCode();
        _h_ += this.camp;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append("T").append(this.name.length()).append(",");
        _sb_.append(this.school).append(",");
        _sb_.append(this.position).append(",");
        _sb_.append(this.camp).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
