//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.main;

import java.util.Map;
import mytools.ConvMain;

public class LoginQueueUp implements ConvMain.Checkable, Comparable<LoginQueueUp> {
    public int id = 0;
    public int connectusernum = 0;
    public int time = 0;
    public int enterusernum = 0;

    public int compareTo(LoginQueueUp o) {
        return this.id - o.id;
    }

    public LoginQueueUp() {
    }

    public LoginQueueUp(LoginQueueUp arg) {
        this.id = arg.id;
        this.connectusernum = arg.connectusernum;
        this.time = arg.time;
        this.enterusernum = arg.enterusernum;
    }

    public void checkValid(Map<String, Map<Integer, ?>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getConnectusernum() {
        return this.connectusernum;
    }

    public void setConnectusernum(int v) {
        this.connectusernum = v;
    }

    public int getTime() {
        return this.time;
    }

    public void setTime(int v) {
        this.time = v;
    }

    public int getEnterusernum() {
        return this.enterusernum;
    }

    public void setEnterusernum(int v) {
        this.enterusernum = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
