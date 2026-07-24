//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SEquipMakeInfo implements ConvMain.Checkable, Comparable<SEquipMakeInfo> {
    public int id = 0;
    public int type = 0;
    public int tuzhiid = 0;
    public int tuzhinum = 0;
    public int hantieid = 0;
    public int hantienum = 0;
    public int zhizaofuid = 0;
    public int zhizaofunum = 0;
    public int qianghuaid = 0;
    public int qianghuanum = 0;
    public int moneynum = 0;
    public int moneytype = 0;
    public int chanchuequipid = 0;
    public ArrayList<Integer> ptdazhaoid;
    public ArrayList<Integer> ptdazhaorate;
    public ArrayList<Integer> qhdazhaoid;
    public ArrayList<Integer> qhdazhaorate;
    public ArrayList<Integer> vcailiaotie;
    public ArrayList<Integer> vcailiaotienum;
    public ArrayList<Integer> vcailiaozhizaofu;
    public ArrayList<Integer> vcailiaozhizaofunum;

    public int compareTo(SEquipMakeInfo o) {
        return this.id - o.id;
    }

    public SEquipMakeInfo() {
    }

    public SEquipMakeInfo(SEquipMakeInfo arg) {
        this.id = arg.id;
        this.type = arg.type;
        this.tuzhiid = arg.tuzhiid;
        this.tuzhinum = arg.tuzhinum;
        this.hantieid = arg.hantieid;
        this.hantienum = arg.hantienum;
        this.zhizaofuid = arg.zhizaofuid;
        this.zhizaofunum = arg.zhizaofunum;
        this.qianghuaid = arg.qianghuaid;
        this.qianghuanum = arg.qianghuanum;
        this.moneynum = arg.moneynum;
        this.moneytype = arg.moneytype;
        this.chanchuequipid = arg.chanchuequipid;
        this.ptdazhaoid = arg.ptdazhaoid;
        this.ptdazhaorate = arg.ptdazhaorate;
        this.qhdazhaoid = arg.qhdazhaoid;
        this.qhdazhaorate = arg.qhdazhaorate;
        this.vcailiaotie = arg.vcailiaotie;
        this.vcailiaotienum = arg.vcailiaotienum;
        this.vcailiaozhizaofu = arg.vcailiaozhizaofu;
        this.vcailiaozhizaofunum = arg.vcailiaozhizaofunum;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getType() {
        return this.type;
    }

    public void setType(int v) {
        this.type = v;
    }

    public int getTuzhiid() {
        return this.tuzhiid;
    }

    public void setTuzhiid(int v) {
        this.tuzhiid = v;
    }

    public int getTuzhinum() {
        return this.tuzhinum;
    }

    public void setTuzhinum(int v) {
        this.tuzhinum = v;
    }

    public int getHantieid() {
        return this.hantieid;
    }

    public void setHantieid(int v) {
        this.hantieid = v;
    }

    public int getHantienum() {
        return this.hantienum;
    }

    public void setHantienum(int v) {
        this.hantienum = v;
    }

    public int getZhizaofuid() {
        return this.zhizaofuid;
    }

    public void setZhizaofuid(int v) {
        this.zhizaofuid = v;
    }

    public int getZhizaofunum() {
        return this.zhizaofunum;
    }

    public void setZhizaofunum(int v) {
        this.zhizaofunum = v;
    }

    public int getQianghuaid() {
        return this.qianghuaid;
    }

    public void setQianghuaid(int v) {
        this.qianghuaid = v;
    }

    public int getQianghuanum() {
        return this.qianghuanum;
    }

    public void setQianghuanum(int v) {
        this.qianghuanum = v;
    }

    public int getMoneynum() {
        return this.moneynum;
    }

    public void setMoneynum(int v) {
        this.moneynum = v;
    }

    public int getMoneytype() {
        return this.moneytype;
    }

    public void setMoneytype(int v) {
        this.moneytype = v;
    }

    public int getChanchuequipid() {
        return this.chanchuequipid;
    }

    public void setChanchuequipid(int v) {
        this.chanchuequipid = v;
    }

    public ArrayList<Integer> getPtdazhaoid() {
        return this.ptdazhaoid;
    }

    public void setPtdazhaoid(ArrayList<Integer> v) {
        this.ptdazhaoid = v;
    }

    public ArrayList<Integer> getPtdazhaorate() {
        return this.ptdazhaorate;
    }

    public void setPtdazhaorate(ArrayList<Integer> v) {
        this.ptdazhaorate = v;
    }

    public ArrayList<Integer> getQhdazhaoid() {
        return this.qhdazhaoid;
    }

    public void setQhdazhaoid(ArrayList<Integer> v) {
        this.qhdazhaoid = v;
    }

    public ArrayList<Integer> getQhdazhaorate() {
        return this.qhdazhaorate;
    }

    public void setQhdazhaorate(ArrayList<Integer> v) {
        this.qhdazhaorate = v;
    }

    public ArrayList<Integer> getVcailiaotie() {
        return this.vcailiaotie;
    }

    public void setVcailiaotie(ArrayList<Integer> v) {
        this.vcailiaotie = v;
    }

    public ArrayList<Integer> getVcailiaotienum() {
        return this.vcailiaotienum;
    }

    public void setVcailiaotienum(ArrayList<Integer> v) {
        this.vcailiaotienum = v;
    }

    public ArrayList<Integer> getVcailiaozhizaofu() {
        return this.vcailiaozhizaofu;
    }

    public void setVcailiaozhizaofu(ArrayList<Integer> v) {
        this.vcailiaozhizaofu = v;
    }

    public ArrayList<Integer> getVcailiaozhizaofunum() {
        return this.vcailiaozhizaofunum;
    }

    public void setVcailiaozhizaofunum(ArrayList<Integer> v) {
        this.vcailiaozhizaofunum = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
