//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.master;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class PBaseInfo implements Marshal {
    public long roleid;
    public String rolename;
    public int level;
    public int school;
    public int camp;
    public int shap;

    public PBaseInfo() {
        this.rolename = "";
    }

    public PBaseInfo(long _roleid_, String _rolename_, int _level_, int _school_, int _camp_, int _shap_) {
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.level = _level_;
        this.school = _school_;
        this.camp = _camp_;
        this.shap = _shap_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.level);
        _os_.marshal(this.school);
        _os_.marshal(this.camp);
        _os_.marshal(this.shap);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.level = _os_.unmarshal_int();
        this.school = _os_.unmarshal_int();
        this.camp = _os_.unmarshal_int();
        this.shap = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof PBaseInfo) {
            PBaseInfo _o_ = (PBaseInfo)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else if (this.level != _o_.level) {
                return false;
            } else if (this.school != _o_.school) {
                return false;
            } else if (this.camp != _o_.camp) {
                return false;
            } else {
                return this.shap == _o_.shap;
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
        _h_ += this.school;
        _h_ += this.camp;
        _h_ += this.shap;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.school).append(",");
        _sb_.append(this.camp).append(",");
        _sb_.append(this.shap).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
