//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.Map;
import mytools.ConvMain;

public class SNpcNameRandom implements ConvMain.Checkable, Comparable<SNpcNameRandom> {
    public int id = 0;
    public String firstName = null;
    public String secondName = null;
    public int group = 0;

    public int compareTo(SNpcNameRandom o) {
        return this.id - o.id;
    }

    public SNpcNameRandom() {
    }

    public SNpcNameRandom(SNpcNameRandom arg) {
        this.id = arg.id;
        this.firstName = arg.firstName;
        this.secondName = arg.secondName;
        this.group = arg.group;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getFirstName() {
        return this.firstName;
    }

    public void setFirstName(String v) {
        this.firstName = v;
    }

    public String getSecondName() {
        return this.secondName;
    }

    public void setSecondName(String v) {
        this.secondName = v;
    }

    public int getGroup() {
        return this.group;
    }

    public void setGroup(int v) {
        this.group = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
