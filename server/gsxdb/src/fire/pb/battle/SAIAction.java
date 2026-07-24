//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import java.util.Map;
import mytools.ConvMain;

public class SAIAction implements ConvMain.Checkable, Comparable<SAIAction> {
    public int id = 0;
    public boolean clientAction = false;
    public String changeshape = null;
    public int changeground = 0;
    public int changebgm = 0;
    public String optiontype = null;
    public String optionid = null;
    public String skillsoltid = null;
    public String skillfactor = null;
    public String skillconstant = null;
    public String escapeodds = null;
    public String summons = null;
    public String target = null;
    public String bonustask = null;
    public int changeaim = 0;

    public int compareTo(SAIAction o) {
        return this.id - o.id;
    }

    public SAIAction() {
    }

    public SAIAction(SAIAction arg) {
        this.id = arg.id;
        this.clientAction = arg.clientAction;
        this.changeshape = arg.changeshape;
        this.changeground = arg.changeground;
        this.changebgm = arg.changebgm;
        this.optiontype = arg.optiontype;
        this.optionid = arg.optionid;
        this.skillsoltid = arg.skillsoltid;
        this.skillfactor = arg.skillfactor;
        this.skillconstant = arg.skillconstant;
        this.escapeodds = arg.escapeodds;
        this.summons = arg.summons;
        this.target = arg.target;
        this.bonustask = arg.bonustask;
        this.changeaim = arg.changeaim;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public boolean getClientAction() {
        return this.clientAction;
    }

    public void setClientAction(boolean v) {
        this.clientAction = v;
    }

    public String getChangeshape() {
        return this.changeshape;
    }

    public void setChangeshape(String v) {
        this.changeshape = v;
    }

    public int getChangeground() {
        return this.changeground;
    }

    public void setChangeground(int v) {
        this.changeground = v;
    }

    public int getChangebgm() {
        return this.changebgm;
    }

    public void setChangebgm(int v) {
        this.changebgm = v;
    }

    public String getOptiontype() {
        return this.optiontype;
    }

    public void setOptiontype(String v) {
        this.optiontype = v;
    }

    public String getOptionid() {
        return this.optionid;
    }

    public void setOptionid(String v) {
        this.optionid = v;
    }

    public String getSkillsoltid() {
        return this.skillsoltid;
    }

    public void setSkillsoltid(String v) {
        this.skillsoltid = v;
    }

    public String getSkillfactor() {
        return this.skillfactor;
    }

    public void setSkillfactor(String v) {
        this.skillfactor = v;
    }

    public String getSkillconstant() {
        return this.skillconstant;
    }

    public void setSkillconstant(String v) {
        this.skillconstant = v;
    }

    public String getEscapeodds() {
        return this.escapeodds;
    }

    public void setEscapeodds(String v) {
        this.escapeodds = v;
    }

    public String getSummons() {
        return this.summons;
    }

    public void setSummons(String v) {
        this.summons = v;
    }

    public String getTarget() {
        return this.target;
    }

    public void setTarget(String v) {
        this.target = v;
    }

    public String getBonustask() {
        return this.bonustask;
    }

    public void setBonustask(String v) {
        this.bonustask = v;
    }

    public int getChangeaim() {
        return this.changeaim;
    }

    public void setChangeaim(int v) {
        this.changeaim = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
