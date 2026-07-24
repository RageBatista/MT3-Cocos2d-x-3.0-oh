//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan.fight;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class RoleBattleFieldRank implements Marshal {
    public String rolename;
    public int rolescroe;

    public RoleBattleFieldRank() {
        this.rolename = "";
    }

    public RoleBattleFieldRank(String _rolename_, int _rolescroe_) {
        this.rolename = _rolename_;
        this.rolescroe = _rolescroe_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.rolescroe);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.rolescroe = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RoleBattleFieldRank) {
            RoleBattleFieldRank _o_ = (RoleBattleFieldRank)_o1_;
            if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else {
                return this.rolescroe == _o_.rolescroe;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.rolename.hashCode();
        _h_ += this.rolescroe;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.rolescroe).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
