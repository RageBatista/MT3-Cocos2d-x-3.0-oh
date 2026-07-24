//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan;

import java.util.Map;
import mytools.ConvMain;

public class SClanyaofang implements ConvMain.Checkable, Comparable<SClanyaofang> {
    public int id = 0;
    public String mingzi = null;
    public int money = 0;
    public int banggong = 0;
    public int randomgroup = 0;

    public int compareTo(SClanyaofang o) {
        return this.id - o.id;
    }

    public SClanyaofang() {
    }

    public SClanyaofang(SClanyaofang arg) {
        this.id = arg.id;
        this.mingzi = arg.mingzi;
        this.money = arg.money;
        this.banggong = arg.banggong;
        this.randomgroup = arg.randomgroup;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getMingzi() {
        return this.mingzi;
    }

    public void setMingzi(String v) {
        this.mingzi = v;
    }

    public int getMoney() {
        return this.money;
    }

    public void setMoney(int v) {
        this.money = v;
    }

    public int getBanggong() {
        return this.banggong;
    }

    public void setBanggong(int v) {
        this.banggong = v;
    }

    public int getRandomgroup() {
        return this.randomgroup;
    }

    public void setRandomgroup(int v) {
        this.randomgroup = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
