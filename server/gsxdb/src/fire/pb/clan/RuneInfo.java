//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class RuneInfo implements Marshal {
    public long roleid;
    public String rolename;
    public long targetroleid;
    public String targetrolename;
    public int level;
    public int school;
    public int shape;
    public int givenum;
    public int acceptnum;
    public int actiontype;
    public long requesttime;
    public int itemid;
    public int itemlevel;

    public RuneInfo() {
        this.rolename = "";
        this.targetrolename = "";
    }

    public RuneInfo(long _roleid_, String _rolename_, long _targetroleid_, String _targetrolename_, int _level_, int _school_, int _shape_, int _givenum_, int _acceptnum_, int _actiontype_, long _requesttime_, int _itemid_, int _itemlevel_) {
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.targetroleid = _targetroleid_;
        this.targetrolename = _targetrolename_;
        this.level = _level_;
        this.school = _school_;
        this.shape = _shape_;
        this.givenum = _givenum_;
        this.acceptnum = _acceptnum_;
        this.actiontype = _actiontype_;
        this.requesttime = _requesttime_;
        this.itemid = _itemid_;
        this.itemlevel = _itemlevel_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.targetroleid);
        _os_.marshal(this.targetrolename, "UTF-16LE");
        _os_.marshal(this.level);
        _os_.marshal(this.school);
        _os_.marshal(this.shape);
        _os_.marshal(this.givenum);
        _os_.marshal(this.acceptnum);
        _os_.marshal(this.actiontype);
        _os_.marshal(this.requesttime);
        _os_.marshal(this.itemid);
        _os_.marshal(this.itemlevel);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.targetroleid = _os_.unmarshal_long();
        this.targetrolename = _os_.unmarshal_String("UTF-16LE");
        this.level = _os_.unmarshal_int();
        this.school = _os_.unmarshal_int();
        this.shape = _os_.unmarshal_int();
        this.givenum = _os_.unmarshal_int();
        this.acceptnum = _os_.unmarshal_int();
        this.actiontype = _os_.unmarshal_int();
        this.requesttime = _os_.unmarshal_long();
        this.itemid = _os_.unmarshal_int();
        this.itemlevel = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RuneInfo) {
            RuneInfo _o_ = (RuneInfo)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else if (this.targetroleid != _o_.targetroleid) {
                return false;
            } else if (!this.targetrolename.equals(_o_.targetrolename)) {
                return false;
            } else if (this.level != _o_.level) {
                return false;
            } else if (this.school != _o_.school) {
                return false;
            } else if (this.shape != _o_.shape) {
                return false;
            } else if (this.givenum != _o_.givenum) {
                return false;
            } else if (this.acceptnum != _o_.acceptnum) {
                return false;
            } else if (this.actiontype != _o_.actiontype) {
                return false;
            } else if (this.requesttime != _o_.requesttime) {
                return false;
            } else if (this.itemid != _o_.itemid) {
                return false;
            } else {
                return this.itemlevel == _o_.itemlevel;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.rolename.hashCode();
        _h_ += (int)this.targetroleid;
        _h_ += this.targetrolename.hashCode();
        _h_ += this.level;
        _h_ += this.school;
        _h_ += this.shape;
        _h_ += this.givenum;
        _h_ += this.acceptnum;
        _h_ += this.actiontype;
        _h_ += (int)this.requesttime;
        _h_ += this.itemid;
        _h_ += this.itemlevel;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.targetroleid).append(",");
        _sb_.append("T").append(this.targetrolename.length()).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.school).append(",");
        _sb_.append(this.shape).append(",");
        _sb_.append(this.givenum).append(",");
        _sb_.append(this.acceptnum).append(",");
        _sb_.append(this.actiontype).append(",");
        _sb_.append(this.requesttime).append(",");
        _sb_.append(this.itemid).append(",");
        _sb_.append(this.itemlevel).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
