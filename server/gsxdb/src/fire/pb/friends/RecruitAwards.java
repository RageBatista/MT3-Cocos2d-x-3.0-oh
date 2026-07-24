//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.friends;

import java.util.Map;
import mytools.ConvMain;

public class RecruitAwards implements ConvMain.Checkable, Comparable<RecruitAwards> {
    public int id = 0;
    public int num = 0;
    public String awards = null;

    public int compareTo(RecruitAwards o) {
        return this.id - o.id;
    }

    public RecruitAwards() {
    }

    public RecruitAwards(RecruitAwards arg) {
        this.id = arg.id;
        this.num = arg.num;
        this.awards = arg.awards;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getNum() {
        return this.num;
    }

    public void setNum(int v) {
        this.num = v;
    }

    public String getAwards() {
        return this.awards;
    }

    public void setAwards(String v) {
        this.awards = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
