//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi;

import java.util.Map;
import mytools.ConvMain;

public class ChargeConfig implements ConvMain.Checkable {
    public int id = 0;
    public int serverid = 0;
    public String roofid = null;
    public int sellpricenum = 0;
    public int sellnum = 0;
    public int sellnummore = 0;
    public int kind = 0;
    public String name = null;
    public int gameshow = 0;
    public String productid = null;
    public String productstr = null;
    public int chargecount = 0;

    public ChargeConfig() {
    }

    public ChargeConfig(ChargeConfig arg) {
        this.id = arg.id;
        this.serverid = arg.serverid;
        this.roofid = arg.roofid;
        this.sellpricenum = arg.sellpricenum;
        this.sellnum = arg.sellnum;
        this.sellnummore = arg.sellnummore;
        this.kind = arg.kind;
        this.name = arg.name;
        this.gameshow = arg.gameshow;
        this.productid = arg.productid;
        this.productstr = arg.productstr;
        this.chargecount = arg.chargecount;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getServerid() {
        return this.serverid;
    }

    public void setServerid(int v) {
        this.serverid = v;
    }

    public String getRoofid() {
        return this.roofid;
    }

    public void setRoofid(String v) {
        this.roofid = v;
    }

    public int getSellpricenum() {
        return this.sellpricenum;
    }

    public void setSellpricenum(int v) {
        this.sellpricenum = v;
    }

    public int getSellnum() {
        return this.sellnum;
    }

    public void setSellnum(int v) {
        this.sellnum = v;
    }

    public int getSellnummore() {
        return this.sellnummore;
    }

    public void setSellnummore(int v) {
        this.sellnummore = v;
    }

    public int getKind() {
        return this.kind;
    }

    public void setKind(int v) {
        this.kind = v;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String v) {
        this.name = v;
    }

    public int getGameshow() {
        return this.gameshow;
    }

    public void setGameshow(int v) {
        this.gameshow = v;
    }

    public String getProductid() {
        return this.productid;
    }

    public void setProductid(String v) {
        this.productid = v;
    }

    public String getProductstr() {
        return this.productstr;
    }

    public void setProductstr(String v) {
        this.productstr = v;
    }

    public int getChargecount() {
        return this.chargecount;
    }

    public void setChargecount(int v) {
        this.chargecount = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
