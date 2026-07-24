//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.message;

import java.util.Map;
import mytools.ConvMain;

public class SStringRes implements ConvMain.Checkable, Comparable<SStringRes> {
    public int id = 0;
    public String msg = null;

    public int compareTo(SStringRes o) {
        return this.id - o.id;
    }

    public SStringRes() {
    }

    public SStringRes(SStringRes arg) {
        this.id = arg.id;
        this.msg = arg.msg;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getMsg() {
        return this.msg;
    }

    public void setMsg(String v) {
        this.msg = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
