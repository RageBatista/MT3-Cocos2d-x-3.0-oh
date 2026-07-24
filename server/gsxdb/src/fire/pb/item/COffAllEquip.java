//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import mkdb.Procedure;

public class COffAllEquip extends __COffAllEquip__ {
    public static final int PROTOCOL_TYPE = 817972;

    protected void process() {
        final long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            (new Procedure() {
                protected boolean process() throws Exception {
                    List<Integer> integers = new LinkedList();
                    Pack bag = new Pack(roleId, false);
                    Equip equip = new Equip(roleId, false);
                    int posinpack = 0;

                    for(ItemBase itemBase : equip) {
                        if (itemBase instanceof EquipItem) {
                            integers.add(itemBase.getKey());
                            equip.onUnequip((EquipItem)itemBase);
                        }
                    }

                    for(Integer integer : integers) {
                        ItemBase bi = equip.TransOut(integer, -1, "卸下装备");
                        if (bi == null) {
                            return false;
                        }

                        ArrayList<Integer> freepos = bag.getFreepos();
                        if (freepos.size() <= 0) {
                            return false;
                        }

                        posinpack = (Integer)freepos.get(0);
                        ItemBase dstitem;
                        if (posinpack != -1) {
                            dstitem = bag.getItemByPos(posinpack);
                        } else {
                            dstitem = null;
                        }

                        if (dstitem != null) {
                            return false;
                        }

                        if (!bag.TransIn(bi, posinpack)) {
                            return false;
                        }

                        if (bi instanceof EquipItem) {
                            equip.onUnequip((EquipItem)bi);
                        }
                    }

                    return true;
                }
            }).submit();
        }
    }

    public int getType() {
        return 817972;
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
        } else if (_o1_ instanceof COffAllEquip) {
            COffAllEquip _o_ = (COffAllEquip)_o1_;
            return true;
        } else {
            return false;
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

    public int compareTo(COffAllEquip _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}
