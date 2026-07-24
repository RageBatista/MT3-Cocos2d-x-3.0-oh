//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.title;

import java.util.Map;
import mytools.ConvMain;

public class STitleConfig implements ConvMain.Checkable, Comparable<STitleConfig> {
    public int id = 0;
    public boolean chatsee = false;
    public int availtime = 0;
    public String titlename = null;
    public int buff;

    public int compareTo(STitleConfig var1) {
        return this.id - var1.id;
    }

    public STitleConfig() {
        this.buff = 0;
    }

    public STitleConfig(STitleConfig var1) {
        this.id = var1.id;
        this.chatsee = var1.chatsee;
        this.availtime = var1.availtime;
        this.titlename = var1.titlename;
        this.buff = var1.buff;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> var1) {
    }

    public String getTitlename() {
        return this.titlename;
    }

    public int getId() {
        return this.id;
    }

    public void setId(int var1) {
        this.id = var1;
    }

    public boolean getChatsee() {
        return this.chatsee;
    }

    public void setChatsee(boolean var1) {
        this.chatsee = var1;
    }

    public int getAvailtime() {
        return this.availtime;
    }

    public void setAvailtime(int var1) {
        this.availtime = var1;
    }

    public void setTitlename(String var1) {
        this.titlename = var1;
    }

    public int getBuff() {
        return this.buff;
    }

    public void setBuff(int var1) {
        this.buff = var1;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
