//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class BagConfig implements ConvMain.Checkable, Comparable<BagConfig> {
    public int id = 0;
    public int sizesize = 0;
    public int canpile = 0;
    public int loginsend = 0;
    public int moveable = 0;
    public long maxmoney = 0L;
    public String tablename = null;

    public int compareTo(BagConfig o) {
        return this.id - o.id;
    }

    public BagConfig() {
    }

    public BagConfig(BagConfig arg) {
        this.id = arg.id;
        this.sizesize = arg.sizesize;
        this.canpile = arg.canpile;
        this.loginsend = arg.loginsend;
        this.moveable = arg.moveable;
        this.maxmoney = arg.maxmoney;
        this.tablename = arg.tablename;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        int tmprefvalue = this.sizesize;
        if (tmprefvalue < 0) {
            throw new RuntimeException("BagConfig.sizesize=" + tmprefvalue + ",所以不满足条件 BagConfig.sizesize < 0");
        } else {
            tmprefvalue = this.canpile;
            if (tmprefvalue < 0) {
                throw new RuntimeException("BagConfig.canpile=" + tmprefvalue + ",所以不满足条件 BagConfig.canpile < 0");
            } else if (tmprefvalue > 1) {
                throw new RuntimeException("BagConfig.canpile=" + tmprefvalue + ",所以不满足条件 BagConfig.canpile > 1");
            } else {
                tmprefvalue = this.loginsend;
                if (tmprefvalue < 0) {
                    throw new RuntimeException("BagConfig.loginsend=" + tmprefvalue + ",所以不满足条件 BagConfig.loginsend < 0");
                } else if (tmprefvalue > 1) {
                    throw new RuntimeException("BagConfig.loginsend=" + tmprefvalue + ",所以不满足条件 BagConfig.loginsend > 1");
                } else {
                    tmprefvalue = this.moveable;
                    if (tmprefvalue < 0) {
                        throw new RuntimeException("BagConfig.moveable=" + tmprefvalue + ",所以不满足条件 BagConfig.moveable < 0");
                    } else if (tmprefvalue > 1) {
                        throw new RuntimeException("BagConfig.moveable=" + tmprefvalue + ",所以不满足条件 BagConfig.moveable > 1");
                    } else {
                        long tmprefvalueL = this.maxmoney;
                        if (tmprefvalueL < 0L) {
                            throw new RuntimeException("BagConfig.maxmoney=" + tmprefvalueL + ",所以不满足条件 BagConfig.maxmoney < 0L");
                        }
                    }
                }
            }
        }
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getSizesize() {
        return this.sizesize;
    }

    public void setSizesize(int v) {
        this.sizesize = v;
    }

    public int getCanpile() {
        return this.canpile;
    }

    public void setCanpile(int v) {
        this.canpile = v;
    }

    public int getLoginsend() {
        return this.loginsend;
    }

    public void setLoginsend(int v) {
        this.loginsend = v;
    }

    public int getMoveable() {
        return this.moveable;
    }

    public void setMoveable(int v) {
        this.moveable = v;
    }

    public long getMaxmoney() {
        return this.maxmoney;
    }

    public void setMaxmoney(long v) {
        this.maxmoney = v;
    }

    public String getTablename() {
        return this.tablename;
    }

    public void setTablename(String v) {
        this.tablename = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
