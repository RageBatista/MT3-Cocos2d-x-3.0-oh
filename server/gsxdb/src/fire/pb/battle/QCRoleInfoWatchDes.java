//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class QCRoleInfoWatchDes implements Marshal {
    public QCRoleInfoDes role1;
    public QCRoleInfoDes role2;

    public QCRoleInfoWatchDes() {
        this.role1 = new QCRoleInfoDes();
        this.role2 = new QCRoleInfoDes();
    }

    public QCRoleInfoWatchDes(QCRoleInfoDes _role1_, QCRoleInfoDes _role2_) {
        this.role1 = _role1_;
        this.role2 = _role2_;
    }

    public final boolean _validator_() {
        if (!this.role1._validator_()) {
            return false;
        } else {
            return this.role2._validator_();
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.role1);
        _os_.marshal(this.role2);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.role1.unmarshal(_os_);
        this.role2.unmarshal(_os_);
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof QCRoleInfoWatchDes) {
            QCRoleInfoWatchDes _o_ = (QCRoleInfoWatchDes)_o1_;
            if (!this.role1.equals(_o_.role1)) {
                return false;
            } else {
                return this.role2.equals(_o_.role2);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.role1.hashCode();
        _h_ += this.role2.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.role1).append(",");
        _sb_.append(this.role2).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
