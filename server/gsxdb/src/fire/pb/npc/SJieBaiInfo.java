//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SJieBaiInfo extends __SJieBaiInfo__ {
    public static final int PROTOCOL_TYPE = 817947;
    public String titlename;
    public long teamid;

    protected void process() {
    }

    public int getType() {
        return 817947;
    }

    public SJieBaiInfo() {
        this.titlename = "";
    }

    public SJieBaiInfo(String _titlename_, long _teamid_) {
        this.titlename = _titlename_;
        this.teamid = _teamid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.titlename, "UTF-16LE");
            _os_.marshal(this.teamid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.titlename = _os_.unmarshal_String("UTF-16LE");
        this.teamid = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SJieBaiInfo) {
            SJieBaiInfo _o_ = (SJieBaiInfo)_o1_;
            if (!this.titlename.equals(_o_.titlename)) {
                return false;
            } else {
                return this.teamid == _o_.teamid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.titlename.hashCode();
        _h_ += (int)this.teamid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append("T").append(this.titlename.length()).append(",");
        _sb_.append(this.teamid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
