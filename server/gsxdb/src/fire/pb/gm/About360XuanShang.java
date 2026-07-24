//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class About360XuanShang implements ConvMain.Checkable, Comparable<About360XuanShang> {
    public int id = 0;
    public int needRoleLv = 0;
    public boolean needFirstCharge = false;
    public int chargeDaysExceptFirst = 0;
    public int loginDays = 0;
    public long totalPlayedTime = 0L;
    public ArrayList<Integer> prizeId;
    public ArrayList<Integer> prizeNum;
    public String desc = null;

    public int compareTo(About360XuanShang o) {
        return this.id - o.id;
    }

    public About360XuanShang() {
    }

    public About360XuanShang(About360XuanShang arg) {
        this.id = arg.id;
        this.needRoleLv = arg.needRoleLv;
        this.needFirstCharge = arg.needFirstCharge;
        this.chargeDaysExceptFirst = arg.chargeDaysExceptFirst;
        this.loginDays = arg.loginDays;
        this.totalPlayedTime = arg.totalPlayedTime;
        this.prizeId = arg.prizeId;
        this.prizeNum = arg.prizeNum;
        this.desc = arg.desc;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getNeedRoleLv() {
        return this.needRoleLv;
    }

    public void setNeedRoleLv(int v) {
        this.needRoleLv = v;
    }

    public boolean getNeedFirstCharge() {
        return this.needFirstCharge;
    }

    public void setNeedFirstCharge(boolean v) {
        this.needFirstCharge = v;
    }

    public int getChargeDaysExceptFirst() {
        return this.chargeDaysExceptFirst;
    }

    public void setChargeDaysExceptFirst(int v) {
        this.chargeDaysExceptFirst = v;
    }

    public int getLoginDays() {
        return this.loginDays;
    }

    public void setLoginDays(int v) {
        this.loginDays = v;
    }

    public long getTotalPlayedTime() {
        return this.totalPlayedTime;
    }

    public void setTotalPlayedTime(long v) {
        this.totalPlayedTime = v;
    }

    public ArrayList<Integer> getPrizeId() {
        return this.prizeId;
    }

    public void setPrizeId(ArrayList<Integer> v) {
        this.prizeId = v;
    }

    public ArrayList<Integer> getPrizeNum() {
        return this.prizeNum;
    }

    public void setPrizeNum(ArrayList<Integer> v) {
        this.prizeNum = v;
    }

    public String getDesc() {
        return this.desc;
    }

    public void setDesc(String v) {
        this.desc = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
