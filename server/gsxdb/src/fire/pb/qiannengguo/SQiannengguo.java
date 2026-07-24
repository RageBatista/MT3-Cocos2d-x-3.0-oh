//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.qiannengguo;

import java.util.Map;
import mytools.ConvMain;

public class SQiannengguo implements ConvMain.Checkable, Comparable<SQiannengguo> {
    public int id = 0;
    public int rate = 0;
    public int proptype = 0;
    public int propvalue = 0;
    public String image = null;

    public int compareTo(SQiannengguo o) {
        return this.id - o.id;
    }

    public SQiannengguo() {
    }

    public SQiannengguo(SQiannengguo arg) {
        this.id = arg.id;
        this.proptype = arg.proptype;
        this.propvalue = arg.propvalue;
        this.image = arg.image;
        this.rate = arg.rate;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getRate() {
        return this.rate;
    }

    public void setRate(int rate) {
        this.rate = rate;
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getProptype() {
        return this.proptype;
    }

    public void setProptype(int v) {
        this.proptype = v;
    }

    public int getPropvalue() {
        return this.propvalue;
    }

    public void setPropvalue(int v) {
        this.propvalue = v;
    }

    public String getImage() {
        return this.image;
    }

    public void setImage(String v) {
        this.image = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
