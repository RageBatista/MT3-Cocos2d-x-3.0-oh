/*
 * @作者：kevinsuperme kevinsuperme@users.noreply.github.com
 * @日期：2026-01-13 15:44:25
 * @LastEditors：kevinsuperme kevinsuperme@users.noreply.github.com
 * @LastEditTime: 2026-01-13 16:55:51
 * @FilePath: \gsxdb-Sq2build\src\fire\pb\item\CCleanMainPack.java
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.buff.Module;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.List;
import mkdb.Procedure;

public class CCleanMainPack extends __CCleanMainPack__ {
    public static final int PROTOCOL_TYPE = 787480;

    protected void process() {
        final long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            (new Procedure() {
                protected boolean process() {
                    if (Module.existState(roleId, 507004)) {
                        MessageMgr.psendMsgNotify(roleId, 191110, (List)null);
                        return false;
                    } else {
                        Pack pack = (Pack)fire.pb.item.Module.getInstance().getItemMaps(roleId, 1, false);
                        ArrayList msgParams = new ArrayList();
                        msgParams.add(String.valueOf(pack.size()));
                        pack.clear();
                        MessageMgr.sendMsgNotify(roleId, 191104, msgParams);
                        return true;
                    }
                }
            }).submit();
        }
    }

    public int getType() {
        return 787480;
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
            return var1 instanceof CCleanMainPack;
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

    public int compareTo(CCleanMainPack var1) {
        if (var1 == this) {
            return 0;
        } else {
            byte var2 = 0;
            return var2;
        }
    }
}
