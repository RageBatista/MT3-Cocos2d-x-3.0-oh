//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import java.util.Map;
import mytools.ConvMain;

public class SActivityQuestion implements ConvMain.Checkable, Comparable<SActivityQuestion> {
    public int id = 0;
    public int questionid = 0;
    public int step = 0;
    public String question = null;
    public String answer1 = null;
    public String answer2 = null;
    public String answer3 = null;
    public int rightanswer = 0;
    public int rightrewardid = 0;
    public int errorrewardid = 0;

    public int compareTo(SActivityQuestion o) {
        return this.id - o.id;
    }

    public SActivityQuestion() {
    }

    public SActivityQuestion(SActivityQuestion arg) {
        this.id = arg.id;
        this.questionid = arg.questionid;
        this.step = arg.step;
        this.question = arg.question;
        this.answer1 = arg.answer1;
        this.answer2 = arg.answer2;
        this.answer3 = arg.answer3;
        this.rightanswer = arg.rightanswer;
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

    public int getQuestionid() {
        return this.questionid;
    }

    public void setQuestionid(int v) {
        this.questionid = v;
    }

    public int getStep() {
        return this.step;
    }

    public void setStep(int v) {
        this.step = v;
    }

    public String getQuestion() {
        return this.question;
    }

    public void setQuestion(String v) {
        this.question = v;
    }

    public String getAnswer1() {
        return this.answer1;
    }

    public void setAnswer1(String v) {
        this.answer1 = v;
    }

    public String getAnswer2() {
        return this.answer2;
    }

    public void setAnswer2(String v) {
        this.answer2 = v;
    }

    public String getAnswer3() {
        return this.answer3;
    }

    public void setAnswer3(String v) {
        this.answer3 = v;
    }

    public int getRightanswer() {
        return this.rightanswer;
    }

    public void setRightanswer(int v) {
        this.rightanswer = v;
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
