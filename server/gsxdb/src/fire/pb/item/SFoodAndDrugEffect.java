//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.ArrayList;
import java.util.Map;

public class SFoodAndDrugEffect extends FoodItemAttr {
    public String effectdescribe = null;
    public ArrayList<Integer> effect;
    public int funtionid = 0;
    public int needPengrenLevel = 0;
    public int pengrenWeight = 0;
    public int needLianyaoLevel = 0;
    public int lianyaoWeight = 0;
    public int lianyaoMaterialWeight = 0;

    public int compareTo(SFoodAndDrugEffect o) {
        return this.id - o.id;
    }

    public SFoodAndDrugEffect(FoodItemAttr arg) {
        super(arg);
    }

    public SFoodAndDrugEffect() {
    }

    public SFoodAndDrugEffect(SFoodAndDrugEffect arg) {
        super(arg);
        this.effectdescribe = arg.effectdescribe;
        this.effect = arg.effect;
        this.funtionid = arg.funtionid;
        this.needPengrenLevel = arg.needPengrenLevel;
        this.pengrenWeight = arg.pengrenWeight;
        this.needLianyaoLevel = arg.needLianyaoLevel;
        this.lianyaoWeight = arg.lianyaoWeight;
        this.lianyaoMaterialWeight = arg.lianyaoMaterialWeight;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    public String getEffectdescribe() {
        return this.effectdescribe;
    }

    public void setEffectdescribe(String v) {
        this.effectdescribe = v;
    }

    public ArrayList<Integer> getEffect() {
        return this.effect;
    }

    public void setEffect(ArrayList<Integer> v) {
        this.effect = v;
    }

    public int getFuntionid() {
        return this.funtionid;
    }

    public void setFuntionid(int v) {
        this.funtionid = v;
    }

    public int getNeedPengrenLevel() {
        return this.needPengrenLevel;
    }

    public void setNeedPengrenLevel(int v) {
        this.needPengrenLevel = v;
    }

    public int getPengrenWeight() {
        return this.pengrenWeight;
    }

    public void setPengrenWeight(int v) {
        this.pengrenWeight = v;
    }

    public int getNeedLianyaoLevel() {
        return this.needLianyaoLevel;
    }

    public void setNeedLianyaoLevel(int v) {
        this.needLianyaoLevel = v;
    }

    public int getLianyaoWeight() {
        return this.lianyaoWeight;
    }

    public void setLianyaoWeight(int v) {
        this.lianyaoWeight = v;
    }

    public int getLianyaoMaterialWeight() {
        return this.lianyaoMaterialWeight;
    }

    public void setLianyaoMaterialWeight(int v) {
        this.lianyaoMaterialWeight = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
