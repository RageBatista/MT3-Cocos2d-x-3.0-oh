//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.ranklist;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class FactionRaidRankRecord implements Marshal {
    public int rank;
    public long factionid;
    public String factionname;
    public long progressstime;
    public int progresss;
    public String factionmonstername;
    public String factioncopyname;
    public float bosshp;

    public FactionRaidRankRecord() {
        this.factionname = "";
        this.factionmonstername = "";
        this.factioncopyname = "";
    }

    public FactionRaidRankRecord(int _rank_, long _factionid_, String _factionname_, long _progressstime_, int _progresss_, String _factionmonstername_, String _factioncopyname_, float _bosshp_) {
        this.rank = _rank_;
        this.factionid = _factionid_;
        this.factionname = _factionname_;
        this.progressstime = _progressstime_;
        this.progresss = _progresss_;
        this.factionmonstername = _factionmonstername_;
        this.factioncopyname = _factioncopyname_;
        this.bosshp = _bosshp_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.rank);
        _os_.marshal(this.factionid);
        _os_.marshal(this.factionname, "UTF-16LE");
        _os_.marshal(this.progressstime);
        _os_.marshal(this.progresss);
        _os_.marshal(this.factionmonstername, "UTF-16LE");
        _os_.marshal(this.factioncopyname, "UTF-16LE");
        _os_.marshal(this.bosshp);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.rank = _os_.unmarshal_int();
        this.factionid = _os_.unmarshal_long();
        this.factionname = _os_.unmarshal_String("UTF-16LE");
        this.progressstime = _os_.unmarshal_long();
        this.progresss = _os_.unmarshal_int();
        this.factionmonstername = _os_.unmarshal_String("UTF-16LE");
        this.factioncopyname = _os_.unmarshal_String("UTF-16LE");
        this.bosshp = _os_.unmarshal_float();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof FactionRaidRankRecord) {
            FactionRaidRankRecord _o_ = (FactionRaidRankRecord)_o1_;
            if (this.rank != _o_.rank) {
                return false;
            } else if (this.factionid != _o_.factionid) {
                return false;
            } else if (!this.factionname.equals(_o_.factionname)) {
                return false;
            } else if (this.progressstime != _o_.progressstime) {
                return false;
            } else if (this.progresss != _o_.progresss) {
                return false;
            } else if (!this.factionmonstername.equals(_o_.factionmonstername)) {
                return false;
            } else if (!this.factioncopyname.equals(_o_.factioncopyname)) {
                return false;
            } else {
                return this.bosshp == _o_.bosshp;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.rank;
        _h_ += (int)this.factionid;
        _h_ += this.factionname.hashCode();
        _h_ += (int)this.progressstime;
        _h_ += this.progresss;
        _h_ += this.factionmonstername.hashCode();
        _h_ += this.factioncopyname.hashCode();
        _h_ += Float.floatToIntBits(this.bosshp);
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.rank).append(",");
        _sb_.append(this.factionid).append(",");
        _sb_.append("T").append(this.factionname.length()).append(",");
        _sb_.append(this.progressstime).append(",");
        _sb_.append(this.progresss).append(",");
        _sb_.append("T").append(this.factionmonstername.length()).append(",");
        _sb_.append("T").append(this.factioncopyname.length()).append(",");
        _sb_.append(this.bosshp).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
