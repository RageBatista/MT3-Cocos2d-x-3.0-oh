//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import java.util.Map;
import mytools.ConvMain;

public class STeamListInfo implements ConvMain.Checkable, Comparable<STeamListInfo> {
    public int id = 0;
    public String content = null;
    public String target = null;
    public int type = 0;
    public int minlevel = 0;
    public int maxlevel = 0;
    public int minMember = 0;
    public int maxMember = 0;
    public int additional = 0;

    public int compareTo(STeamListInfo o) {
        return this.id - o.id;
    }

    public STeamListInfo() {
    }

    public STeamListInfo(STeamListInfo arg) {
        this.id = arg.id;
        this.content = arg.content;
        this.target = arg.target;
        this.type = arg.type;
        this.minlevel = arg.minlevel;
        this.maxlevel = arg.maxlevel;
        this.minMember = arg.minMember;
        this.maxMember = arg.maxMember;
        this.additional = arg.additional;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getContent() {
        return this.content;
    }

    public void setContent(String v) {
        this.content = v;
    }

    public String getTarget() {
        return this.target;
    }

    public void setTarget(String v) {
        this.target = v;
    }

    public int getType() {
        return this.type;
    }

    public void setType(int v) {
        this.type = v;
    }

    public int getMinlevel() {
        return this.minlevel;
    }

    public void setMinlevel(int v) {
        this.minlevel = v;
    }

    public int getMaxlevel() {
        return this.maxlevel;
    }

    public void setMaxlevel(int v) {
        this.maxlevel = v;
    }

    public int getMinMember() {
        return this.minMember;
    }

    public void setMinMember(int v) {
        this.minMember = v;
    }

    public int getMaxMember() {
        return this.maxMember;
    }

    public void setMaxMember(int v) {
        this.maxMember = v;
    }

    public int getAdditional() {
        return this.additional;
    }

    public void setAdditional(int v) {
        this.additional = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
