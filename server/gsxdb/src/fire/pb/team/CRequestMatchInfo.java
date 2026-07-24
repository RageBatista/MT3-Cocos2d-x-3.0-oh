//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;
import mkdb.Procedure;
import xbean.ETeamMatch;
import xtable.Targetid2teammatch;

public class CRequestMatchInfo extends __CRequestMatchInfo__ {
    public static final int PROTOCOL_TYPE = 794512;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            Procedure requestmatchinfo = new Procedure() {
                protected boolean process() {
                    SRequestMatchInfo msg = new SRequestMatchInfo();
                    ETeamMatch ematch = Targetid2teammatch.get(0);
                    if (ematch == null) {
                        msg.playermatchnum = 0;
                        msg.teammatchnum = 0;
                    } else {
                        msg.teammatchnum = ematch.getTeammatchdatalist().size();
                        msg.playermatchnum = ematch.getRolematchdatalist().size();
                    }

                    Procedure.psendWhileCommit(roleid, msg);
                    return true;
                }
            };
            requestmatchinfo.submit();
        }
    }

    public int getType() {
        return 794512;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else {
            return _o1_ instanceof CRequestMatchInfo;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CRequestMatchInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}
