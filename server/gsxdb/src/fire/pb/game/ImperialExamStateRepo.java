//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import java.util.Map;
import mytools.ConvMain;

public class ImperialExamStateRepo implements ConvMain.Checkable {
    public int id = 0;
    public int answer = 0;
    public int rightrewardid = 0;
    public int errorrewardid = 0;

    public ImperialExamStateRepo() {
    }

    public ImperialExamStateRepo(ImperialExamStateRepo arg) {
        this.id = arg.id;
        this.answer = arg.answer;
        this.rightrewardid = arg.rightrewardid;
        this.errorrewardid = arg.errorrewardid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getAnswer() {
        return this.answer;
    }

    public void setAnswer(int v) {
        this.answer = v;
    }

    public int getRightrewardid() {
        return this.rightrewardid;
    }

    public void setRightrewardid(int v) {
        this.rightrewardid = v;
    }

    public int getErrorrewardid() {
        return this.errorrewardid;
    }

    public void setErrorrewardid(int v) {
        this.errorrewardid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
