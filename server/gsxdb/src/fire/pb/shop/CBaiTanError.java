//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.shop.srv.market.MarketManager;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.Arrays;
import mkdb.Procedure;

public class CBaiTanError extends __CBaiTanError__ {
    public static final int PROTOCOL_TYPE = 817960;

    protected void process() {
        final long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            (new Procedure() {
                protected boolean process() {
                    MarketManager localMarketManager = MarketManager.getInstance();
                    boolean bool = localMarketManager.TempTakeBackMarketContainerAndRides(roleId);
                    if (bool) {
                        MessageMgr.psendMsgNotifyWhileCommit(roleId, 191226,Arrays.<String>asList("问题处理完成！"));
                    } else {
                        MessageMgr.psendMsgNotifyWhileCommit(roleId, 191226,Arrays.<String>asList("已经解决完成！"));
                    }

                    return true;
                }
            }).submit();
        }
    }

    public int getType() {
        return 817960;
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
            return _o1_ instanceof CBaiTanError;
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

    public int compareTo(CBaiTanError _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}
