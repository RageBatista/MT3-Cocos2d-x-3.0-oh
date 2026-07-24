//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.qiannengguo;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;
import mkdb.Procedure;
import xbean.ItemUse;
import xbean.ItemUseCount;
import xbean.Pod;
import xtable.Roleuseitemcount;

public class CEnterWorld extends __CEnterWorld__ {
    public static final int PROTOCOL_TYPE = 810500;

    protected void process() {
        final long var1 = Onlines.getInstance().findRoleid(this);
        if (var1 >= 0L) {
            (new Procedure() {
                protected boolean process() {
                    ItemUse var1x = Roleuseitemcount.get(var1);
                    if (var1x == null) {
                        var1x = Pod.newItemUse();
                        Roleuseitemcount.insert(var1, var1x);
                    }

                    ItemUseCount var2 = (ItemUseCount)var1x.getIteminfo().get(400156);
                    if (var2 == null) {
                        var2 = Pod.newItemUseCount();
                        var1x.getIteminfo().put(400156, var2);
                    }

                    int var3 = var2.getUsetimes();
                    Procedure.psendWhileCommit(var1, new SEnterWorld(new ReturnData(var3)));
                    return true;
                }
            }).submit();
        }
    }

    public int getType() {
        return 810500;
    }

    public CEnterWorld() {
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream var1) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return var1;
        }
    }

    public OctetsStream unmarshal(OctetsStream var1) throws MarshalException {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return var1;
        }
    }

    public boolean equals(Object var1) {
        if (var1 == this) {
            return true;
        } else {
            return var1 instanceof CEnterWorld;
        }
    }

    public int hashCode() {
        byte var1 = 0;
        return var1;
    }

    public String toString() {
        StringBuilder var1 = new StringBuilder();
        var1.append("(");
        var1.append(")");
        return var1.toString();
    }

    public int compareTo(CEnterWorld var1) {
        if (var1 == this) {
            return 0;
        } else {
            byte var2 = 0;
            if (0 != var2) {
                return var2;
            } else {
                return 0 != var2 ? var2 : var2;
            }
        }
    }
}
