//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SEquipNaiJiuXiaoHao implements ConvMain.Checkable, Comparable<SEquipNaiJiuXiaoHao> {
    public int id = 0;
    public ArrayList<Integer> yuanyin;
    public ArrayList<Integer> cishu;

    public int compareTo(SEquipNaiJiuXiaoHao o) {
        return this.id - o.id;
    }

    public SEquipNaiJiuXiaoHao() {
    }

    public SEquipNaiJiuXiaoHao(SEquipNaiJiuXiaoHao arg) {
        this.id = arg.id;
        this.yuanyin = arg.yuanyin;
        this.cishu = arg.cishu;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<Integer> getYuanyin() {
        return this.yuanyin;
    }

    public void setYuanyin(ArrayList<Integer> v) {
        this.yuanyin = v;
    }

    public ArrayList<Integer> getCishu() {
        return this.cishu;
    }

    public void setCishu(ArrayList<Integer> v) {
        this.cishu = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
