//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle.pvp3;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class PvP3RoleSingleScoreMid implements Marshal {
    public short index;
    public long roleid;
    public String rolename;
    public int score;

    public PvP3RoleSingleScoreMid() {
        this.rolename = "";
    }

    public PvP3RoleSingleScoreMid(short _index_, long _roleid_, String _rolename_, int _score_) {
        this.index = _index_;
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.score = _score_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.index);
        _os_.marshal(this.roleid);
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.score);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.index = _os_.unmarshal_short();
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.score = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof PvP3RoleSingleScoreMid) {
            PvP3RoleSingleScoreMid _o_ = (PvP3RoleSingleScoreMid)_o1_;
            if (this.index != _o_.index) {
                return false;
            } else if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else {
                return this.score == _o_.score;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.index;
        _h_ += (int)this.roleid;
        _h_ += this.rolename.hashCode();
        _h_ += this.score;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.index).append(",");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.score).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
