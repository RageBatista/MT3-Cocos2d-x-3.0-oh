//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SGatherConfig implements ConvMain.Checkable, Comparable<SGatherConfig> {
    public int id = 0;
    public int progresstime = 0;
    public int coolingtime = 0;
    public ArrayList<Integer> tasks;
    public int 战斗概率 = 0;
    public int 战斗ID = 0;
    public int 获得概率 = 0;
    public int 奖励 = 0;
    public int 可采集次数 = 0;
    public int 是否消失 = 0;

    public int compareTo(SGatherConfig o) {
        return this.id - o.id;
    }

    public SGatherConfig() {
    }

    public SGatherConfig(SGatherConfig arg) {
        this.id = arg.id;
        this.progresstime = arg.progresstime;
        this.coolingtime = arg.coolingtime;
        this.tasks = arg.tasks;
        this.战斗概率 = arg.战斗概率;
        this.战斗ID = arg.战斗ID;
        this.获得概率 = arg.获得概率;
        this.奖励 = arg.奖励;
        this.可采集次数 = arg.可采集次数;
        this.是否消失 = arg.是否消失;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getProgresstime() {
        return this.progresstime;
    }

    public void setProgresstime(int v) {
        this.progresstime = v;
    }

    public int getCoolingtime() {
        return this.coolingtime;
    }

    public void setCoolingtime(int v) {
        this.coolingtime = v;
    }

    public ArrayList<Integer> getTasks() {
        return this.tasks;
    }

    public void setTasks(ArrayList<Integer> v) {
        this.tasks = v;
    }

    public int get战斗概率() {
        return this.战斗概率;
    }

    public void set战斗概率(int v) {
        this.战斗概率 = v;
    }

    public int get战斗ID() {
        return this.战斗ID;
    }

    public void set战斗ID(int v) {
        this.战斗ID = v;
    }

    public int get获得概率() {
        return this.获得概率;
    }

    public void set获得概率(int v) {
        this.获得概率 = v;
    }

    public int get奖励() {
        return this.奖励;
    }

    public void set奖励(int v) {
        this.奖励 = v;
    }

    public int get可采集次数() {
        return this.可采集次数;
    }

    public void set可采集次数(int v) {
        this.可采集次数 = v;
    }

    public int get是否消失() {
        return this.是否消失;
    }

    public void set是否消失(int v) {
        this.是否消失 = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
