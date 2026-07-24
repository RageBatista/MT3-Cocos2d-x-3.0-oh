//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.main;

import java.util.Map;
import mytools.ConvMain;

public class LoginLimit implements ConvMain.Checkable, Comparable<LoginLimit> {
    public int id = 0;
    public int serverid = 0;
    public int loginlimittype = 0;
    public String whitelist = null;
    public String blacklist = null;
    public int msgid = 0;

    public int compareTo(LoginLimit o) {
        return this.id - o.id;
    }

    public LoginLimit() {
    }

    public LoginLimit(LoginLimit arg) {
        this.id = arg.id;
        this.serverid = arg.serverid;
        this.loginlimittype = arg.loginlimittype;
        this.whitelist = arg.whitelist;
        this.blacklist = arg.blacklist;
        this.msgid = arg.msgid;
    }

    public void checkValid(Map<String, Map<Integer, ?>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getServerid() {
        return this.serverid;
    }

    public void setServerid(int v) {
        this.serverid = v;
    }

    public int getLoginlimittype() {
        return this.loginlimittype;
    }

    public void setLoginlimittype(int v) {
        this.loginlimittype = v;
    }

    public String getWhitelist() {
        return this.whitelist;
    }

    public void setWhitelist(String v) {
        this.whitelist = v;
    }

    public String getBlacklist() {
        return this.blacklist;
    }

    public void setBlacklist(String v) {
        this.blacklist = v;
    }

    public int getMsgid() {
        return this.msgid;
    }

    public void setMsgid(int v) {
        this.msgid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
