package fire.pb.npc;

import java.util.ArrayList;
import java.util.Map;

// 重写为干净文件，保留原始中文变量名，保证数据映射。
public class SMonstershowConfig implements mytools.ConvMain.Checkable, Comparable<SMonstershowConfig> {

    public int id = 0;
    public String 宝宝战斗概率 = null;
    public String BOSS战斗概率 = null;
    public String 普通战斗概率 = null;
    public int 指定怪id = 0;
    public ArrayList<Integer> 宝宝;
    public ArrayList<Integer> 宝宝概率;
    public ArrayList<Integer> 精英;
    public ArrayList<Integer> 精英概率;
    public ArrayList<Integer> 怪物;
    public ArrayList<Integer> 怪物概率;
    public int 掉落id = 0;
    public int bossbattleid = 0;

    public SMonstershowConfig() {
    }

    public SMonstershowConfig(SMonstershowConfig arg) {
        this.id = arg.id;
        this.宝宝战斗概率 = arg.宝宝战斗概率;
        this.BOSS战斗概率 = arg.BOSS战斗概率;
        this.普通战斗概率 = arg.普通战斗概率;
        this.指定怪id = arg.指定怪id;
        this.宝宝 = arg.宝宝;
        this.宝宝概率 = arg.宝宝概率;
        this.精英 = arg.精英;
        this.精英概率 = arg.精英概率;
        this.怪物 = arg.怪物;
        this.怪物概率 = arg.怪物概率;
        this.掉落id = arg.掉落id;
        this.bossbattleid = arg.bossbattleid;
    }

    @Override
    public int compareTo(SMonstershowConfig o) {
        return this.id - o.id;
    }

    @Override
    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        // 如果需要，可以在此处添加验证逻辑。
    }

    // Getter 和 Setter
    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String get宝宝战斗概率() {
        return this.宝宝战斗概率;
    }

    public void set宝宝战斗概率(String v) {
        this.宝宝战斗概率 = v;
    }

    public String getBOSS战斗概率() {
        return this.BOSS战斗概率;
    }

    public void setBOSS战斗概率(String v) {
        this.BOSS战斗概率 = v;
    }

    public String get普通战斗概率() {
        return this.普通战斗概率;
    }

    public void set普通战斗概率(String v) {
        this.普通战斗概率 = v;
    }

    public int get指定怪id() {
        return this.指定怪id;
    }

    public void set指定怪id(int v) {
        this.指定怪id = v;
    }

    public ArrayList<Integer> get宝宝() {
        return this.宝宝;
    }

    public void set宝宝(ArrayList<Integer> v) {
        this.宝宝 = v;
    }

    public ArrayList<Integer> get宝宝概率() {
        return this.宝宝概率;
    }

    public void set宝宝概率(ArrayList<Integer> v) {
        this.宝宝概率 = v;
    }

    public ArrayList<Integer> get精英() {
        return this.精英;
    }

    public void set精英(ArrayList<Integer> v) {
        this.精英 = v;
    }

    public ArrayList<Integer> get精英概率() {
        return this.精英概率;
    }

    public void set精英概率(ArrayList<Integer> v) {
        this.精英概率 = v;
    }

    public ArrayList<Integer> get怪物() {
        return this.怪物;
    }

    public void set怪物(ArrayList<Integer> v) {
        this.怪物 = v;
    }

    public ArrayList<Integer> get怪物概率() {
        return this.怪物概率;
    }

    public void set怪物概率(ArrayList<Integer> v) {
        this.怪物概率 = v;
    }

    public int get掉落id() {
        return this.掉落id;
    }

    public void set掉落id(int v) {
        this.掉落id = v;
    }

    public int getBossbattleid() {
        return this.bossbattleid;
    }

    public void setBossbattleid(int v) {
        this.bossbattleid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
