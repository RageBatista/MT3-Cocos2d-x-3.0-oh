//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import java.util.Map;
import mytools.ConvMain;

public class Squestions implements ConvMain.Checkable, Comparable<Squestions> {
    public int id = 0;
    public int questionsid = 0;
    public int correct = 0;

    public int compareTo(Squestions o) {
        return this.id - o.id;
    }

    public Squestions() {
    }

    public Squestions(Squestions arg) {
        this.id = arg.id;
        this.questionsid = arg.questionsid;
        this.correct = arg.correct;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getQuestionsid() {
        return this.questionsid;
    }

    public void setQuestionsid(int v) {
        this.questionsid = v;
    }

    public int getCorrect() {
        return this.correct;
    }

    public void setCorrect(int v) {
        this.correct = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
