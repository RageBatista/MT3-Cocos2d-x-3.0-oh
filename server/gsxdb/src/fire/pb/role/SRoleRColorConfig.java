//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.role;

import java.util.Map;
import mytools.ConvMain;

public class SRoleRColorConfig implements ConvMain.Checkable, Comparable<SRoleRColorConfig> {
    public int id = 0;
    public int rolepos = 0;
    public int modeltype = 0;
    public String res = null;
    public int itemcode = 0;
    public int itemnum = 0;
    public int itemcode2 = 0;
    public int itemnum2 = 0;

    public int compareTo(SRoleRColorConfig o) {
        return this.id - o.id;
    }

    public SRoleRColorConfig() {
    }

    public SRoleRColorConfig(SRoleRColorConfig arg) {
        this.id = arg.id;
        this.rolepos = arg.rolepos;
        this.modeltype = arg.modeltype;
        this.res = arg.res;
        this.itemcode = arg.itemcode;
        this.itemnum = arg.itemnum;
        this.itemcode2 = arg.itemcode2;
        this.itemnum2 = arg.itemnum2;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getRolepos() {
        return this.rolepos;
    }

    public void setRolepos(int v) {
        this.rolepos = v;
    }

    public int getModeltype() {
        return this.modeltype;
    }

    public void setModeltype(int v) {
        this.modeltype = v;
    }

    public String getRes() {
        return this.res;
    }

    public void setRes(String v) {
        this.res = v;
    }

    public int getItemcode() {
        return this.itemcode;
    }

    public void setItemcode(int v) {
        this.itemcode = v;
    }

    public int getItemnum() {
        return this.itemnum;
    }

    public void setItemnum(int v) {
        this.itemnum = v;
    }

    public int getItemcode2() {
        return this.itemcode2;
    }

    public void setItemcode2(int v) {
        this.itemcode2 = v;
    }

    public int getItemnum2() {
        return this.itemnum2;
    }

    public void setItemnum2(int v) {
        this.itemnum2 = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
