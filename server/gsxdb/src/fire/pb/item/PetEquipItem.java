//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Octets;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;
import mkdb.Bean;
import xbean.Item;
import xbean.Pod;
import xtable.Petequips;

public class PetEquipItem extends ItemBase {
    private xbean.PetEquipItem petequipAttr;

    public PetEquipItem(ItemMgr im, int itemid) {
        super(im, itemid);
        this.petequipAttr = Pod.newPetEquipItem();
        Long nextkey = Petequips.insert(this.petequipAttr);
        this.itemData.setExtid(nextkey);
    }

    public PetEquipItem(ItemMgr im, int itemid, Bean extinfo) {
        super(im, itemid);
        this.petequipAttr = Pod.newPetEquipItem();
        Long nextkey = Petequips.insert(this.petequipAttr);
        this.itemData.setExtid(nextkey);
        this.setExtinfo(extinfo);
    }

    public PetEquipItem(ItemMgr im, Item item) {
        super(im, item);
        if (!item.isData()) {
            this.petequipAttr = Petequips.get(item.getExtid());
        } else {
            this.petequipAttr = Petequips.select(item.getExtid());
        }

        if (this.petequipAttr == null) {
            throw new RuntimeException("PetEquip data missing: extid=" + item.getExtid()
                + ", itemId=" + item.getId() + ", isData=" + item.isData());
        }

    }

    public Map<Integer, Integer> getBaseAttr() {
        Map<Integer, Integer> baseAttr = new HashMap();
        baseAttr.putAll(this.petequipAttr.getPro());
        return baseAttr;
    }

    public xbean.PetEquipItem getEquipAttr() {
        return this.petequipAttr;
    }

    public xbean.PetEquipItem getExtInfo() {
        return this.petequipAttr;
    }

    public PetEquipItemShuXing getItemAttr() {
        return (PetEquipItemShuXing)this.itemAttr;
    }

    public String getName() {
        return this.itemAttr.name;
    }

    public Octets getTips() {
        return this.getTipsAgain();
    }

    public Octets getTipsAgain() {
        if (this.os == null) {
            this.os = new OctetsStream();
            this.os.marshal(this.petequipAttr.getPos());
            this.os.marshal(this.petequipAttr.getTaozhuangid());
            Map<Integer, Integer> baseMap = this.petequipAttr.getPro();
            int baseAttrNum = baseMap.size();
            this.os.marshal(baseAttrNum);

            for(Map.Entry<Integer, Integer> current : baseMap.entrySet()) {
                this.os.marshal((Integer)current.getKey() - (Integer)current.getKey() % 10);
                this.os.marshal((Integer)current.getValue());
            }
        }

        return this.os;
    }

    protected int getGrowattr(int type) {
        Map<Integer, Integer> baseAttr = this.getBaseAttr();
        Integer value = (Integer)baseAttr.get(type);
        return value == null ? 0 : value;
    }

    public void Setpro(Map<Integer, Integer> baseAttrs) {
        this.petequipAttr.getPro().putAll(baseAttrs);
    }

    public void Setskill(Map<Integer, Integer> baseAttrs) {
        this.petequipAttr.getSkill().putAll(baseAttrs);
    }

    public int getPos() {
        return this.petequipAttr.getPos();
    }

    public void setPos(int i) {
        this.petequipAttr.setPos(i);
    }

    public int gettaozhuangid() {
        return this.petequipAttr.getTaozhuangid();
    }

    public void settaozhuangid(int i) {
        this.petequipAttr.setTaozhuangid(i);
    }

    public int getTaozhuangid() {
        return this.petequipAttr.getTaozhuangid();
    }

    public void setTaozhuangid(int i) {
        this.petequipAttr.setTaozhuangid(i);
    }

    public void onDeleted() {
    }

    public void onInserted() {
    }

    private void setExtinfo(Bean extinfo) {
        if (extinfo instanceof xbean.PetEquipItem) {
            this.petequipAttr = (xbean.PetEquipItem)extinfo;
            Long nextkey = Petequips.insert(this.petequipAttr);
            this.itemData.setExtid(nextkey);
        }

    }

    public void SetBaseAttr(Map<Integer, Integer> baseAttrs) {
        this.petequipAttr.getPro().putAll(baseAttrs);
    }

    public void Setskills(Map<Integer, Integer> skills) {
        this.petequipAttr.getSkill().putAll(skills);
    }
}
