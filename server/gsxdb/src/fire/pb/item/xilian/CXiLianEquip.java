/*
 * @作者：kevinsuperme kevinsuperme@users.noreply.github.com
 * @日期：2026-01-13 15:44:25
 * @LastEditors：kevinsuperme kevinsuperme@users.noreply.github.com
 * @LastEditTime: 2026-01-13 16:56:58
 * @FilePath: \gsxdb-Sq2build\src\fire\pb\item\xilian\CXiLianEquip.java
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.xilian;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CXiLianEquip extends __CXiLianEquip__ {
    public static final int PROTOCOL_TYPE = 810493;
    public int srcweaponkey;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            System.out.println("准备执行装备洗练");
            (new PXiLianEquip(roleId, this.srcweaponkey)).submit();
        }
    }

    public int getType() {
        return 810493;
    }

    public CXiLianEquip() {
    }

    public CXiLianEquip(int srcWeaponKey, int unused) {
        this.srcweaponkey = srcWeaponKey;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream var1) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            var1.marshal(this.srcweaponkey);
            return var1;
        }
    }

    public OctetsStream unmarshal(OctetsStream var1) throws MarshalException {
        this.srcweaponkey = var1.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return var1;
        }
    }

    public boolean equals(Object var1) {
        if (var1 == this) {
            return true;
        } else if (var1 instanceof CXiLianEquip) {
            CXiLianEquip var2 = (CXiLianEquip)var1;
            return this.srcweaponkey == var2.srcweaponkey;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int var1 = 0;
        var1 += this.srcweaponkey;
        return var1;
    }

    public String toString() {
        StringBuilder var1 = new StringBuilder();
        var1.append("(");
        var1.append(this.srcweaponkey).append(",");
        var1.append(")");
        return var1.toString();
    }

    public int compareTo(CXiLianEquip var1) {
        if (var1 == this) {
            return 0;
        } else {
            boolean var2 = false;
            int var3 = this.srcweaponkey - var1.srcweaponkey;
            if (0 != var3) {
                return var3;
            } else {
                return 0 != var3 ? var3 : var3;
            }
        }
    }
}
