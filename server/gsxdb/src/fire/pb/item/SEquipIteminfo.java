//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SEquipIteminfo implements ConvMain.Checkable, Comparable<SEquipIteminfo> {
    public int id = 0;
    public String shuxing1name = null;
    public ArrayList<Integer> shuxing1bodongduanmin;
    public ArrayList<Integer> shuxing1bodongduanmax;
    public ArrayList<Integer> shuxing1bodongquanzhong;
    public String shuxing2name = null;
    public ArrayList<Integer> shuxing2bodongduanmin;
    public ArrayList<Integer> shuxing2bodongduanmax;
    public ArrayList<Integer> shuxing2bodongquanzhong;
    public String shuxing3name = null;
    public ArrayList<Integer> shuxing3bodongduanmin;
    public ArrayList<Integer> shuxing3bodongduanmax;
    public ArrayList<Integer> shuxing3bodongquanzhong;

    public int compareTo(SEquipIteminfo o) {
        return this.id - o.id;
    }

    public SEquipIteminfo() {
    }

    public SEquipIteminfo(SEquipIteminfo arg) {
        this.id = arg.id;
        this.shuxing1name = arg.shuxing1name;
        this.shuxing1bodongduanmin = arg.shuxing1bodongduanmin;
        this.shuxing1bodongduanmax = arg.shuxing1bodongduanmax;
        this.shuxing1bodongquanzhong = arg.shuxing1bodongquanzhong;
        this.shuxing2name = arg.shuxing2name;
        this.shuxing2bodongduanmin = arg.shuxing2bodongduanmin;
        this.shuxing2bodongduanmax = arg.shuxing2bodongduanmax;
        this.shuxing2bodongquanzhong = arg.shuxing2bodongquanzhong;
        this.shuxing3name = arg.shuxing3name;
        this.shuxing3bodongduanmin = arg.shuxing3bodongduanmin;
        this.shuxing3bodongduanmax = arg.shuxing3bodongduanmax;
        this.shuxing3bodongquanzhong = arg.shuxing3bodongquanzhong;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getShuxing1name() {
        return this.shuxing1name;
    }

    public void setShuxing1name(String v) {
        this.shuxing1name = v;
    }

    public ArrayList<Integer> getShuxing1bodongduanmin() {
        return this.shuxing1bodongduanmin;
    }

    public void setShuxing1bodongduanmin(ArrayList<Integer> v) {
        this.shuxing1bodongduanmin = v;
    }

    public ArrayList<Integer> getShuxing1bodongduanmax() {
        return this.shuxing1bodongduanmax;
    }

    public void setShuxing1bodongduanmax(ArrayList<Integer> v) {
        this.shuxing1bodongduanmax = v;
    }

    public ArrayList<Integer> getShuxing1bodongquanzhong() {
        return this.shuxing1bodongquanzhong;
    }

    public void setShuxing1bodongquanzhong(ArrayList<Integer> v) {
        this.shuxing1bodongquanzhong = v;
    }

    public String getShuxing2name() {
        return this.shuxing2name;
    }

    public void setShuxing2name(String v) {
        this.shuxing2name = v;
    }

    public ArrayList<Integer> getShuxing2bodongduanmin() {
        return this.shuxing2bodongduanmin;
    }

    public void setShuxing2bodongduanmin(ArrayList<Integer> v) {
        this.shuxing2bodongduanmin = v;
    }

    public ArrayList<Integer> getShuxing2bodongduanmax() {
        return this.shuxing2bodongduanmax;
    }

    public void setShuxing2bodongduanmax(ArrayList<Integer> v) {
        this.shuxing2bodongduanmax = v;
    }

    public ArrayList<Integer> getShuxing2bodongquanzhong() {
        return this.shuxing2bodongquanzhong;
    }

    public void setShuxing2bodongquanzhong(ArrayList<Integer> v) {
        this.shuxing2bodongquanzhong = v;
    }

    public String getShuxing3name() {
        return this.shuxing3name;
    }

    public void setShuxing3name(String v) {
        this.shuxing3name = v;
    }

    public ArrayList<Integer> getShuxing3bodongduanmin() {
        return this.shuxing3bodongduanmin;
    }

    public void setShuxing3bodongduanmin(ArrayList<Integer> v) {
        this.shuxing3bodongduanmin = v;
    }

    public ArrayList<Integer> getShuxing3bodongduanmax() {
        return this.shuxing3bodongduanmax;
    }

    public void setShuxing3bodongduanmax(ArrayList<Integer> v) {
        this.shuxing3bodongduanmax = v;
    }

    public ArrayList<Integer> getShuxing3bodongquanzhong() {
        return this.shuxing3bodongquanzhong;
    }

    public void setShuxing3bodongquanzhong(ArrayList<Integer> v) {
        this.shuxing3bodongquanzhong = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
