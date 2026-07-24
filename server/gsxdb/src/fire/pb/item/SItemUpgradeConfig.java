//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SItemUpgradeConfig implements ConvMain.Checkable, Comparable<SItemUpgradeConfig> {
    public int id = 0;
    public int oldItemID = 0;
    public int newItemID = 0;
    public int needCold = 0;
    public int needitemid = 0;
    public int needitemcount = 0;
    public int needolditemcount = 0;

    public int compareTo(SItemUpgradeConfig o) {
        return this.id - o.id;
    }

    public SItemUpgradeConfig() {
    }

    public SItemUpgradeConfig(SItemUpgradeConfig arg) {
        this.id = arg.id;
        this.oldItemID = arg.oldItemID;
        this.newItemID = arg.newItemID;
        this.needCold = arg.needCold;
        this.needitemid = arg.needitemid;
        this.needitemcount = arg.needitemcount;
        this.needolditemcount = arg.needolditemcount;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getOldItemID() {
        return this.oldItemID;
    }

    public void setOldItemID(int v) {
        this.oldItemID = v;
    }

    public int getNewItemID() {
        return this.newItemID;
    }

    public void setNewItemID(int v) {
        this.newItemID = v;
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

    public int getNeedolditemcount() {
        return this.needolditemcount;
    }

    public void setNeedolditemcount(int v) {
        this.needolditemcount = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;

        NeedId() {
        }
    }
}
