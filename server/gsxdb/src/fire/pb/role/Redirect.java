//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.role;

import java.util.Map;
import mytools.ConvMain;

public class Redirect implements ConvMain.Checkable, Comparable<Redirect> {
    public int id = 0;
    public int remapid = 0;
    public int reposx = 0;
    public int reposy = 0;

    public int compareTo(Redirect o) {
        return this.id - o.id;
    }

    public Redirect() {
    }

    public Redirect(Redirect arg) {
        this.id = arg.id;
        this.remapid = arg.remapid;
        this.reposx = arg.reposx;
        this.reposy = arg.reposy;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getRemapid() {
        return this.remapid;
    }

    public void setRemapid(int v) {
        this.remapid = v;
    }

    public int getReposx() {
        return this.reposx;
    }

    public void setReposx(int v) {
        this.reposx = v;
    }

    public int getReposy() {
        return this.reposy;
    }

    public void setReposy(int v) {
        this.reposy = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
