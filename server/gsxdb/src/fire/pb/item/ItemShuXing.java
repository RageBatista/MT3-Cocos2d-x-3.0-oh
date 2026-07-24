//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class ItemShuXing implements ConvMain.Checkable, Comparable<ItemShuXing> {
    public int id = 0;
    public String name = null;
    public String unit = null;
    public int typeid = 0;
    public int level = 0;
    public boolean pickupbind = false;
    public int maxstack = 0;
    public int maxown = 0;
    public int inbattle = 0;
    public int outbattle = 0;
    public int inbattleuseto = 0;
    public int useup = 0;
    public int needlevel = 0;
    public boolean offlineclear = false;
    public boolean bindable = false;
    public boolean destroy = false;
    public int validtime = 0;
    public int sortid = 0;
    public int cansale = 0;
    public int canstore = 0;
    public int recycletime = 0;
    public int recovercost = 0;
    public int salefreezetime = 0;
    public String namecolor = null;
    public int nquality = 0;
    public int rare = 0;
    public int dcansale = 0;

    public int compareTo(ItemShuXing o) {
        return this.id - o.id;
    }

    public ItemShuXing() {
    }

    public ItemShuXing(ItemShuXing arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.unit = arg.unit;
        this.typeid = arg.typeid;
        this.level = arg.level;
        this.pickupbind = arg.pickupbind;
        this.maxstack = arg.maxstack;
        this.maxown = arg.maxown;
        this.inbattle = arg.inbattle;
        this.outbattle = arg.outbattle;
        this.inbattleuseto = arg.inbattleuseto;
        this.useup = arg.useup;
        this.needlevel = arg.needlevel;
        this.offlineclear = arg.offlineclear;
        this.bindable = arg.bindable;
        this.destroy = arg.destroy;
        this.validtime = arg.validtime;
        this.sortid = arg.sortid;
        this.cansale = arg.cansale;
        this.canstore = arg.canstore;
        this.recycletime = arg.recycletime;
        this.recovercost = arg.recovercost;
        this.salefreezetime = arg.salefreezetime;
        this.namecolor = arg.namecolor;
        this.nquality = arg.nquality;
        this.rare = arg.rare;
        this.dcansale = arg.dcansale;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        int tmprefvalue = this.typeid;
        if (tmprefvalue < 1) {
            throw new RuntimeException("物品属性.typeid=" + tmprefvalue + ",所以不满足条件 物品属性.typeid < 1");
        } else {
            tmprefvalue = this.maxstack;
            if (tmprefvalue < 1) {
                throw new RuntimeException("物品属性.maxstack=" + tmprefvalue + ",所以不满足条件 物品属性.maxstack < 1");
            } else if (tmprefvalue > 9999) {
                throw new RuntimeException("物品属性.maxstack=" + tmprefvalue + ",所以不满足条件 物品属性.maxstack > 9999");
            } else {
                tmprefvalue = this.needlevel;
                if (tmprefvalue < 1) {
                    throw new RuntimeException("物品属性.needlevel=" + tmprefvalue + ",所以不满足条件 物品属性.needlevel < 1");
                } else {
                    tmprefvalue = this.validtime;
                    if (tmprefvalue < 0) {
                        throw new RuntimeException("物品属性.validtime=" + tmprefvalue + ",所以不满足条件 物品属性.validtime < 0");
                    }
                }
            }
        }
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String v) {
        this.name = v;
    }

    public String getUnit() {
        return this.unit;
    }

    public void setUnit(String v) {
        this.unit = v;
    }

    public int getTypeid() {
        return this.typeid;
    }

    public void setTypeid(int v) {
        this.typeid = v;
    }

    public int getLevel() {
        return this.level;
    }

    public void setLevel(int v) {
        this.level = v;
    }

    public boolean getPickupbind() {
        return this.pickupbind;
    }

    public void setPickupbind(boolean v) {
        this.pickupbind = v;
    }

    public int getMaxstack() {
        return this.maxstack;
    }

    public void setMaxstack(int v) {
        this.maxstack = v;
    }

    public int getMaxown() {
        return this.maxown;
    }

    public void setMaxown(int v) {
        this.maxown = v;
    }

    public int getInbattle() {
        return this.inbattle;
    }

    public void setInbattle(int v) {
        this.inbattle = v;
    }

    public int getOutbattle() {
        return this.outbattle;
    }

    public void setOutbattle(int v) {
        this.outbattle = v;
    }

    public int getInbattleuseto() {
        return this.inbattleuseto;
    }

    public void setInbattleuseto(int v) {
        this.inbattleuseto = v;
    }

    public int getUseup() {
        return this.useup;
    }

    public void setUseup(int v) {
        this.useup = v;
    }

    public int getNeedlevel() {
        return this.needlevel;
    }

    public void setNeedlevel(int v) {
        this.needlevel = v;
    }

    public boolean getOfflineclear() {
        return this.offlineclear;
    }

    public void setOfflineclear(boolean v) {
        this.offlineclear = v;
    }

    public boolean getBindable() {
        return this.bindable;
    }

    public void setBindable(boolean v) {
        this.bindable = v;
    }

    public boolean getDestroy() {
        return this.destroy;
    }

    public void setDestroy(boolean v) {
        this.destroy = v;
    }

    public int getValidtime() {
        return this.validtime;
    }

    public void setValidtime(int v) {
        this.validtime = v;
    }

    public int getSortid() {
        return this.sortid;
    }

    public void setSortid(int v) {
        this.sortid = v;
    }

    public int getCansale() {
        return this.cansale;
    }

    public void setCansale(int v) {
        this.cansale = v;
    }

    public int getCanstore() {
        return this.canstore;
    }

    public void setCanstore(int v) {
        this.canstore = v;
    }

    public int getRecycletime() {
        return this.recycletime;
    }

    public void setRecycletime(int v) {
        this.recycletime = v;
    }

    public int getRecovercost() {
        return this.recovercost;
    }

    public void setRecovercost(int v) {
        this.recovercost = v;
    }

    public int getSalefreezetime() {
        return this.salefreezetime;
    }

    public void setSalefreezetime(int v) {
        this.salefreezetime = v;
    }

    public String getNamecolor() {
        return this.namecolor;
    }

    public void setNamecolor(String v) {
        this.namecolor = v;
    }

    public int getNquality() {
        return this.nquality;
    }

    public void setNquality(int v) {
        this.nquality = v;
    }

    public int getRare() {
        return this.rare;
    }

    public void setRare(int v) {
        this.rare = v;
    }

    public int getDcansale() {
        return this.dcansale;
    }

    public void setDcansale(int v) {
        this.dcansale = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
