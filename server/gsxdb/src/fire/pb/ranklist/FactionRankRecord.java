//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.ranklist;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class FactionRankRecord implements Marshal {
    public int rank;
    public String factionname;
    public String mastername;
    public int level;
    public int camp;
    public long factionkey;

    public FactionRankRecord() {
        this.factionname = "";
        this.mastername = "";
    }

    public FactionRankRecord(int _rank_, String _factionname_, String _mastername_, int _level_, int _camp_, long _factionkey_) {
        this.rank = _rank_;
        this.factionname = _factionname_;
        this.mastername = _mastername_;
        this.level = _level_;
        this.camp = _camp_;
        this.factionkey = _factionkey_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.rank);
        _os_.marshal(this.factionname, "UTF-16LE");
        _os_.marshal(this.mastername, "UTF-16LE");
        _os_.marshal(this.level);
        _os_.marshal(this.camp);
        _os_.marshal(this.factionkey);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.rank = _os_.unmarshal_int();
        this.factionname = _os_.unmarshal_String("UTF-16LE");
        this.mastername = _os_.unmarshal_String("UTF-16LE");
        this.level = _os_.unmarshal_int();
        this.camp = _os_.unmarshal_int();
        this.factionkey = _os_.unmarshal_long();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof FactionRankRecord) {
            FactionRankRecord _o_ = (FactionRankRecord)_o1_;
            if (this.rank != _o_.rank) {
                return false;
            } else if (!this.factionname.equals(_o_.factionname)) {
                return false;
            } else if (!this.mastername.equals(_o_.mastername)) {
                return false;
            } else if (this.level != _o_.level) {
                return false;
            } else if (this.camp != _o_.camp) {
                return false;
            } else {
                return this.factionkey == _o_.factionkey;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.rank;
        _h_ += this.factionname.hashCode();
        _h_ += this.mastername.hashCode();
        _h_ += this.level;
        _h_ += this.camp;
        _h_ += (int)this.factionkey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.rank).append(",");
        _sb_.append("T").append(this.factionname.length()).append(",");
        _sb_.append("T").append(this.mastername.length()).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.camp).append(",");
        _sb_.append(this.factionkey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
