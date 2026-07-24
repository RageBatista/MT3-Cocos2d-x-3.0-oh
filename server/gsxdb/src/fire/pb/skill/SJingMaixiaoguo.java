//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SJingMaixiaoguo implements ConvMain.Checkable, Comparable<SJingMaixiaoguo> {
    public int id = 0;
    public int zhiye = 0;
    public int jingmaiid = 0;
    public ArrayList<Integer> jingmais;
    public ArrayList<Integer> xingchens;

    public int compareTo(SJingMaixiaoguo o) {
        return this.id - o.id;
    }

    public SJingMaixiaoguo() {
    }

    public SJingMaixiaoguo(SJingMaixiaoguo arg) {
        this.id = arg.id;
        this.zhiye = arg.zhiye;
        this.jingmaiid = arg.jingmaiid;
        this.jingmais = arg.jingmais;
        this.xingchens = arg.xingchens;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getZhiye() {
        return this.zhiye;
    }

    public void setZhiye(int v) {
        this.zhiye = v;
    }

    public int getJingmaiid() {
        return this.jingmaiid;
    }

    public void setJingmaiid(int v) {
        this.jingmaiid = v;
    }

    public ArrayList<Integer> getJingmais() {
        return this.jingmais;
    }

    public void setJingmais(ArrayList<Integer> v) {
        this.jingmais = v;
    }

    public ArrayList<Integer> getXingchens() {
        return this.xingchens;
    }

    public void setXingchens(ArrayList<Integer> v) {
        this.xingchens = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
