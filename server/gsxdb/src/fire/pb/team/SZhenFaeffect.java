//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SZhenFaeffect implements ConvMain.Checkable, Comparable<SZhenFaeffect> {
    public int id = 0;
    public int zhenfaid = 0;
    public int zhenfaLv = 0;
    public int zhenfaExp = 0;
    public ArrayList<String> effect;
    public ArrayList<String> effectloss;

    public int compareTo(SZhenFaeffect o) {
        return this.id - o.id;
    }

    public SZhenFaeffect() {
    }

    public SZhenFaeffect(SZhenFaeffect arg) {
        this.id = arg.id;
        this.zhenfaid = arg.zhenfaid;
        this.zhenfaLv = arg.zhenfaLv;
        this.zhenfaExp = arg.zhenfaExp;
        this.effect = arg.effect;
        this.effectloss = arg.effectloss;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getZhenfaid() {
        return this.zhenfaid;
    }

    public void setZhenfaid(int v) {
        this.zhenfaid = v;
    }

    public int getZhenfaLv() {
        return this.zhenfaLv;
    }

    public void setZhenfaLv(int v) {
        this.zhenfaLv = v;
    }

    public int getZhenfaExp() {
        return this.zhenfaExp;
    }

    public void setZhenfaExp(int v) {
        this.zhenfaExp = v;
    }

    public ArrayList<String> getEffect() {
        return this.effect;
    }

    public void setEffect(ArrayList<String> v) {
        this.effect = v;
    }

    public ArrayList<String> getEffectloss() {
        return this.effectloss;
    }

    public void setEffectloss(ArrayList<String> v) {
        this.effectloss = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
