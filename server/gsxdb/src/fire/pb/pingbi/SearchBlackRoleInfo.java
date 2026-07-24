//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pingbi;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SearchBlackRoleInfo implements Marshal {
    public long roleid;
    public String name;
    public short rolelevel;
    public byte school;
    public byte online;
    public int shape;
    public byte camp;

    public SearchBlackRoleInfo() {
        this.name = "";
    }

    public SearchBlackRoleInfo(long _roleid_, String _name_, short _rolelevel_, byte _school_, byte _online_, int _shape_, byte _camp_) {
        this.roleid = _roleid_;
        this.name = _name_;
        this.rolelevel = _rolelevel_;
        this.school = _school_;
        this.online = _online_;
        this.shape = _shape_;
        this.camp = _camp_;
    }

    public final boolean _validator_() {
        return this.roleid >= 0L;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.name, "UTF-16LE");
        _os_.marshal(this.rolelevel);
        _os_.marshal(this.school);
        _os_.marshal(this.online);
        _os_.marshal(this.shape);
        _os_.marshal(this.camp);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.name = _os_.unmarshal_String("UTF-16LE");
        this.rolelevel = _os_.unmarshal_short();
        this.school = _os_.unmarshal_byte();
        this.online = _os_.unmarshal_byte();
        this.shape = _os_.unmarshal_int();
        this.camp = _os_.unmarshal_byte();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SearchBlackRoleInfo) {
            SearchBlackRoleInfo _o_ = (SearchBlackRoleInfo)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.name.equals(_o_.name)) {
                return false;
            } else if (this.rolelevel != _o_.rolelevel) {
                return false;
            } else if (this.school != _o_.school) {
                return false;
            } else if (this.online != _o_.online) {
                return false;
            } else if (this.shape != _o_.shape) {
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
        _h_ += this.name.hashCode();
        _h_ += this.rolelevel;
        _h_ += this.school;
        _h_ += this.online;
        _h_ += this.shape;
        _h_ += this.camp;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.name.length()).append(",");
        _sb_.append(this.rolelevel).append(",");
        _sb_.append(this.school).append(",");
        _sb_.append(this.online).append(",");
        _sb_.append(this.shape).append(",");
        _sb_.append(this.camp).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
