//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import java.util.Map;
import mytools.ConvMain;

public class SPVPCrossWhiteList implements ConvMain.Checkable, Comparable<SPVPCrossWhiteList> {
    public int id = 0;
    public int userid = 0;
    public long roleid = 0L;

    public int compareTo(SPVPCrossWhiteList o) {
        return this.id - o.id;
    }

    public SPVPCrossWhiteList() {
    }

    public SPVPCrossWhiteList(SPVPCrossWhiteList arg) {
        this.id = arg.id;
        this.userid = arg.userid;
        this.roleid = arg.roleid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getUserid() {
        return this.userid;
    }

    public void setUserid(int v) {
        this.userid = v;
    }

    public long getRoleid() {
        return this.roleid;
    }

    public void setRoleid(long v) {
        this.roleid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
