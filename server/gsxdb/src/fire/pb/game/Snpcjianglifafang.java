//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import java.util.Map;
import mytools.ConvMain;

public class Snpcjianglifafang implements ConvMain.Checkable, Comparable<Snpcjianglifafang> {
    public int id = 0;
    public int jiangliid = 0;
    public int jianglicishu = 0;
    public int lvxianzhi = 0;

    public int compareTo(Snpcjianglifafang o) {
        return this.id - o.id;
    }

    public Snpcjianglifafang() {
    }

    public Snpcjianglifafang(Snpcjianglifafang arg) {
        this.id = arg.id;
        this.jiangliid = arg.jiangliid;
        this.jianglicishu = arg.jianglicishu;
        this.lvxianzhi = arg.lvxianzhi;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getJiangliid() {
        return this.jiangliid;
    }

    public void setJiangliid(int v) {
        this.jiangliid = v;
    }

    public int getJianglicishu() {
        return this.jianglicishu;
    }

    public void setJianglicishu(int v) {
        this.jianglicishu = v;
    }

    public int getLvxianzhi() {
        return this.lvxianzhi;
    }

    public void setLvxianzhi(int v) {
        this.lvxianzhi = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
