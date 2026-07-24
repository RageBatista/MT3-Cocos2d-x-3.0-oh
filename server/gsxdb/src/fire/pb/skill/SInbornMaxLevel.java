//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SInbornMaxLevel implements ConvMain.Checkable, Comparable<SInbornMaxLevel> {
    public int id = 0;
    public ArrayList<Integer> inbornMaxLevel;

    public int compareTo(SInbornMaxLevel o) {
        return this.id - o.id;
    }

    public SInbornMaxLevel() {
    }

    public SInbornMaxLevel(SInbornMaxLevel arg) {
        this.id = arg.id;
        this.inbornMaxLevel = arg.inbornMaxLevel;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<Integer> getInbornMaxLevel() {
        return this.inbornMaxLevel;
    }

    public void setInbornMaxLevel(ArrayList<Integer> v) {
        this.inbornMaxLevel = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
