//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SEquipUpgradeConfig implements ConvMain.Checkable, Comparable<SEquipUpgradeConfig> {
    public int id = 0;
    public int oldEquipID = 0;
    public int newEquipID = 0;
    public int needCold = 0;
    public int needitemid = 0;
    public int needitemcount = 0;
    public int needweaponcount = 0;
    public int shibainewEquipID = 0;
    public int jilv = 0;
    public int shibaijilv = 0;
    public int cgonggao = 0;
    public int sgonggao = 0;
    public ArrayList<Integer> items;
    public ArrayList<Integer> itemsrate;

    public int compareTo(SEquipUpgradeConfig o) {
        return this.id - o.id;
    }

    public SEquipUpgradeConfig() {
    }

    public SEquipUpgradeConfig(SEquipUpgradeConfig arg) {
        this.id = arg.id;
        this.oldEquipID = arg.oldEquipID;
        this.newEquipID = arg.newEquipID;
        this.needCold = arg.needCold;
        this.needitemid = arg.needitemid;
        this.needitemcount = arg.needitemcount;
        this.needweaponcount = arg.needweaponcount;
        this.shibainewEquipID = arg.shibainewEquipID;
        this.jilv = arg.jilv;
        this.shibaijilv = arg.shibaijilv;
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

    public int getOldEquipID() {
        return this.oldEquipID;
    }

    public void setOldEquipID(int v) {
        this.oldEquipID = v;
    }

    public int getNewEquipID() {
        return this.newEquipID;
    }

    public void setNewEquipID(int v) {
        this.newEquipID = v;
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

    public int getShibainewEquipID() {
        return this.shibainewEquipID;
    }

    public void setShibainewEquipID(int v) {
        this.shibainewEquipID = v;
    }

    public int getJilv() {
        return this.jilv;
    }

    public void setJilv(int v) {
        this.jilv = v;
    }

    public int getShibaijilv() {
        return this.shibaijilv;
    }

    public void setShibaijilv(int v) {
        this.shibaijilv = v;
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
    }
}
