//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import java.util.Map;
import mytools.ConvMain;

public class Srankawardrewardrw implements ConvMain.Checkable, Comparable<Srankawardrewardrw> {
    public int id = 0;
    public String dayimg = null;
    public String ganxie = null;
    public String zhufu = null;
    public int item1id = 0;
    public int item1num = 0;
    public int item2id = 0;
    public int item2num = 0;
    public int item3id = 0;
    public int item3num = 0;
    public int item4id = 0;
    public int item4num = 0;
    public int item5id = 0;
    public int item5num = 0;
    public int item6id = 0;
    public int item6num = 0;
    public int ptb = 0;
    public int needcapacity = 0;

    public int compareTo(Srankawardrewardrw srankawardreward) {
        return this.id - srankawardreward.id;
    }

    public Srankawardrewardrw() {
    }

    public Srankawardrewardrw(Srankawardrewardrw srankawardreward) {
        this.id = srankawardreward.id;
        this.dayimg = srankawardreward.dayimg;
        this.zhufu = srankawardreward.zhufu;
        this.ganxie = srankawardreward.ganxie;
        this.item1id = srankawardreward.item1id;
        this.item1num = srankawardreward.item1num;
        this.item2id = srankawardreward.item2id;
        this.item2num = srankawardreward.item2num;
        this.item3id = srankawardreward.item3id;
        this.item3num = srankawardreward.item3num;
        this.item4id = srankawardreward.item4id;
        this.item4num = srankawardreward.item4num;
        this.item5id = srankawardreward.item5id;
        this.item5num = srankawardreward.item5num;
        this.item6id = srankawardreward.item6id;
        this.item6num = srankawardreward.item6num;
        this.ptb = srankawardreward.ptb;
        this.needcapacity = srankawardreward.needcapacity;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> map) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int i) {
        this.id = i;
    }

    public String getdayimg() {
        return this.dayimg;
    }

    public String getganxie() {
        return this.ganxie;
    }

    public String getzhufu() {
        return this.zhufu;
    }

    public int getItem1id() {
        return this.item1id;
    }

    public void setItem1id(int i) {
        this.item1id = i;
    }

    public int getItem1num() {
        return this.item1num;
    }

    public void setItem1num(int i) {
        this.item1num = i;
    }

    public int getItem2id() {
        return this.item2id;
    }

    public void setItem2id(int i) {
        this.item2id = i;
    }

    public int getItem2num() {
        return this.item2num;
    }

    public void setItem2num(int i) {
        this.item2num = i;
    }

    public int getItem3id() {
        return this.item3id;
    }

    public void setItem3id(int i) {
        this.item3id = i;
    }

    public int getItem3num() {
        return this.item3num;
    }

    public void setItem3num(int i) {
        this.item3num = i;
    }

    public int getItem4id() {
        return this.item4id;
    }

    public void setItem4id(int i) {
        this.item4id = i;
    }

    public int getItem4num() {
        return this.item4num;
    }

    public void setItem4num(int i) {
        this.item4num = i;
    }

    public int getItem5id() {
        return this.item5id;
    }

    public void setItem5id(int i) {
        this.item5id = i;
    }

    public int getItem5num() {
        return this.item5num;
    }

    public void setItem5num(int i) {
        this.item5num = i;
    }

    public int getItem6id() {
        return this.item6id;
    }

    public void setItem6id(int i) {
        this.item6id = i;
    }

    public int getItem6num() {
        return this.item6num;
    }

    public void setItem6num(int i) {
        this.item6num = i;
    }

    public int getptb() {
        return this.ptb;
    }

    public void setptb(int i) {
        this.ptb = i;
    }

    public int getNeedcapacity() {
        return this.needcapacity;
    }

    public void setNeedcapacity(int i) {
        this.needcapacity = i;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
