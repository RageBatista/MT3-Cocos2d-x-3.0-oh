//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class STongYiJieBai extends __STongYiJieBai__ {
    public static final int PROTOCOL_TYPE = 817951;
    public String titlename;
    public long roleid;
    public int answer;

    protected void process() {
    }

    public int getType() {
        return 817951;
    }

    public STongYiJieBai() {
        this.titlename = "";
    }

    public STongYiJieBai(String _titlename_, long _roleid_, int _answer_) {
        this.titlename = _titlename_;
        this.answer = _answer_;
        this.roleid = _roleid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.titlename, "UTF-16LE");
            _os_.marshal(this.roleid);
            _os_.marshal(this.answer);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.titlename = _os_.unmarshal_String("UTF-16LE");
        this.roleid = _os_.unmarshal_long();
        this.answer = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof STongYiJieBai) {
            STongYiJieBai _o_ = (STongYiJieBai)_o1_;
            if (!this.titlename.equals(_o_.titlename)) {
                return false;
            } else if (this.roleid != _o_.roleid) {
                return false;
            } else {
                return this.answer == _o_.answer;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.titlename.hashCode();
        _h_ += (int)this.roleid;
        _h_ += this.answer;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append("T").append(this.titlename.length()).append(",");
        _sb_.append(this.roleid).append(",");
        _sb_.append(this.answer).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
