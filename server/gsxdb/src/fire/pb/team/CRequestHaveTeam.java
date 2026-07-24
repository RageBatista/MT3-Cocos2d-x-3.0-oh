//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;
import xtable.Roleid2teamid;

public class CRequestHaveTeam extends __CRequestHaveTeam__ {
    public static final int PROTOCOL_TYPE = 794515;
    public long roleid;

    protected void process() {
        Long teamid = Roleid2teamid.select(this.roleid);
        SRequestHaveTeam msg = new SRequestHaveTeam();
        msg.ret = 0;
        if (teamid != null) {
            msg.ret = 1;
        }

        long r = Onlines.getInstance().findRoleid(this);
        if (r >= 0L) {
            Onlines.getInstance().send(r, msg);
        }
    }

    public int getType() {
        return 794515;
    }

    public CRequestHaveTeam() {
    }

    public CRequestHaveTeam(long _roleid_) {
        this.roleid = _roleid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.roleid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CRequestHaveTeam) {
            CRequestHaveTeam _o_ = (CRequestHaveTeam)_o1_;
            return this.roleid == _o_.roleid;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CRequestHaveTeam _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.roleid - _o_.roleid);
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
