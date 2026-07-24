//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.master;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class MasterPrenticeBaseData implements Marshal {
    public long roleid;
    public String nickname;
    public int level;

    public MasterPrenticeBaseData() {
        this.nickname = "";
    }

    public MasterPrenticeBaseData(long _roleid_, String _nickname_, int _level_) {
        this.roleid = _roleid_;
        this.nickname = _nickname_;
        this.level = _level_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.nickname, "UTF-16LE");
        _os_.marshal(this.level);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.nickname = _os_.unmarshal_String("UTF-16LE");
        this.level = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof MasterPrenticeBaseData) {
            MasterPrenticeBaseData _o_ = (MasterPrenticeBaseData)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.nickname.equals(_o_.nickname)) {
                return false;
            } else {
                return this.level == _o_.level;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.nickname.hashCode();
        _h_ += this.level;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.nickname.length()).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
