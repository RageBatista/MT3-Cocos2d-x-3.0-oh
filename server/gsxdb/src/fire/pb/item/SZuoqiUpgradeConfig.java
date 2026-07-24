//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SZuoqiUpgradeConfig implements ConvMain.Checkable, Comparable<SZuoqiUpgradeConfig> {
    public int id = 0;
    public int oldEquipzID = 0;
    public int newEquipzID = 0;
    public int needCold = 0;
    public int needitemid = 0;
    public int needitemcount = 0;
    public int needweaponcount = 0;
    public int shibainewEquipzID = 0;
    public int jilvz = 0;
    public int shibaijilvz = 0;
    public int cgonggao = 0;
    public int sgonggao = 0;
    public ArrayList<Integer> items;
    public ArrayList<Integer> itemsrate;

    public int compareTo(SZuoqiUpgradeConfig o) {
        return this.id - o.id;
    }

    public SZuoqiUpgradeConfig() {
    }

    public SZuoqiUpgradeConfig(SZuoqiUpgradeConfig arg) {
        this.id = arg.id;
        this.oldEquipzID = arg.oldEquipzID;
        this.newEquipzID = arg.newEquipzID;
        this.needCold = arg.needCold;
        this.needitemid = arg.needitemid;
        this.needitemcount = arg.needitemcount;
        this.needweaponcount = arg.needweaponcount;
        this.shibainewEquipzID = arg.shibainewEquipzID;
        this.jilvz = arg.jilvz;
        this.shibaijilvz = arg.shibaijilvz;
        this.cgonggao = arg.cgonggao;
        this.sgonggao = arg.sgonggao;
        this.items = arg.items;
        this.itemsrate = arg.itemsrate;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int setOldEquipzID() {
        return this.oldEquipzID;
    }

    public void setOldEquipzID(int v) {
        this.oldEquipzID = v;
    }

    public int getNewEquipzID() {
        return this.newEquipzID;
    }

    public void setNewEquipzID(int v) {
        this.newEquipzID = v;
    }

    public int getNeedCold() {
        return this.needCold;
    }

    public void setNeedCold(int v) {
        this.needCold = v;
    }

    public int getNeeditemid() {
        return this.needitemid;
    }

    public void setNeeditemid(int v) {
        this.needitemid = v;
    }

    public int getNeeditemcount() {
        return this.needitemcount;
    }

    public void setNeeditemcount(int v) {
        this.needitemcount = v;
    }

    public int getNeedweaponcount() {
        return this.needweaponcount;
    }

    public void setNeedweaponcount(int v) {
        this.needweaponcount = v;
    }

    public int getShibainewEquipzID() {
        return this.shibainewEquipzID;
    }

    public void setShibainewEquipzID(int v) {
        this.shibainewEquipzID = v;
    }

    public int getJilv() {
        return this.jilvz;
    }

    public void setJilv(int v) {
        this.jilvz = v;
    }

    public int getShibaijilvz() {
        return this.shibaijilvz;
    }

    public void setShibaijilvz(int v) {
        this.shibaijilvz = v;
    }

    public int getCgonggao() {
        return this.cgonggao;
    }

    public void setCgonggao(int v) {
        this.cgonggao = v;
    }

    public int getSgonggao() {
        return this.sgonggao;
    }

    public void setSgonggao(int v) {
        this.sgonggao = v;
    }

    public ArrayList<Integer> getItems() {
        return this.items;
    }

    public void setItems(ArrayList<Integer> v) {
        this.items = v;
    }

    public ArrayList<Integer> getItemsrate() {
        return this.itemsrate;
    }

    public void setItemsrate(ArrayList<Integer> v) {
        this.itemsrate = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;

        NeedId() {
        }
    }
}
