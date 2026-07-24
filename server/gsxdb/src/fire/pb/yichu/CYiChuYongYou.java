//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.yichu;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;
import mkdb.Procedure;
import xbean.Properties;

public class CYiChuYongYou extends __CYiChuYongYou__ {
    public static final int PROTOCOL_TYPE = 800014;

    protected void process() {
        final long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            (new Procedure() {
                protected boolean process() {
                    Properties pro = xtable.Properties.get(roleId);
                    SYiChuYongYou sshizhuang = new SYiChuYongYou();
                    sshizhuang.yichu.putAll(pro.getShizhuang());
                    Procedure.psendWhileCommit(roleId, sshizhuang);
                    return true;
                }
            }).submit();
        }
    }

    public int getType() {
        return 800014;
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
        } else if (_o1_ instanceof CYiChuYongYou) {
            CYiChuYongYou cYiChuYongYou = (CYiChuYongYou)_o1_;
            return true;
        } else {
            return false;
        }
    }

    public int hashCode() {
        return 0;
    }

    public String toString() {
        return "()";
    }

    public int compareTo(CYiChuYongYou _o_) {
        return 0;
    }
}
