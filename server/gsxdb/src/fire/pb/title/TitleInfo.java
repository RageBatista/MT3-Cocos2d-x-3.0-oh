//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.title;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class TitleInfo implements Marshal {
    public int titleid;
    public String name;
    public long availtime;

    public TitleInfo() {
        this.name = "";
    }

    public TitleInfo(int _titleid_, String _name_, long _availtime_) {
        this.titleid = _titleid_;
        this.name = _name_;
        this.availtime = _availtime_;
    }

    public final boolean _validator_() {
        if (this.titleid < 0) {
            return false;
        } else {
            return this.availtime >= -1L;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.titleid);
        _os_.marshal(this.name, "UTF-16LE");
        _os_.marshal(this.availtime);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.titleid = _os_.unmarshal_int();
        this.name = _os_.unmarshal_String("UTF-16LE");
        this.availtime = _os_.unmarshal_long();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof TitleInfo) {
            TitleInfo _o_ = (TitleInfo)_o1_;
            if (this.titleid != _o_.titleid) {
                return false;
            } else if (!this.name.equals(_o_.name)) {
                return false;
            } else {
                return this.availtime == _o_.availtime;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.titleid;
        _h_ += this.name.hashCode();
        _h_ += (int)this.availtime;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.titleid).append(",");
        _sb_.append("T").append(this.name.length()).append(",");
        _sb_.append(this.availtime).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
