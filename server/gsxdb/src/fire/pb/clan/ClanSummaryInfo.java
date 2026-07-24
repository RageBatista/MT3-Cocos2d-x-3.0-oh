//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ClanSummaryInfo implements Marshal {
    public long clanid;
    public int index;
    public String clanname;
    public int membernum;
    public int clanlevel;
    public String clanmastername;
    public long clanmasterid;
    public String oldclanname;
    public int hotellevel;

    public ClanSummaryInfo() {
        this.clanname = "";
        this.clanmastername = "";
        this.oldclanname = "";
    }

    public ClanSummaryInfo(long _clanid_, int _index_, String _clanname_, int _membernum_, int _clanlevel_, String _clanmastername_, long _clanmasterid_, String _oldclanname_, int _hotellevel_) {
        this.clanid = _clanid_;
        this.index = _index_;
        this.clanname = _clanname_;
        this.membernum = _membernum_;
        this.clanlevel = _clanlevel_;
        this.clanmastername = _clanmastername_;
        this.clanmasterid = _clanmasterid_;
        this.oldclanname = _oldclanname_;
        this.hotellevel = _hotellevel_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.clanid);
        _os_.marshal(this.index);
        _os_.marshal(this.clanname, "UTF-16LE");
        _os_.marshal(this.membernum);
        _os_.marshal(this.clanlevel);
        _os_.marshal(this.clanmastername, "UTF-16LE");
        _os_.marshal(this.clanmasterid);
        _os_.marshal(this.oldclanname, "UTF-16LE");
        _os_.marshal(this.hotellevel);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.clanid = _os_.unmarshal_long();
        this.index = _os_.unmarshal_int();
        this.clanname = _os_.unmarshal_String("UTF-16LE");
        this.membernum = _os_.unmarshal_int();
        this.clanlevel = _os_.unmarshal_int();
        this.clanmastername = _os_.unmarshal_String("UTF-16LE");
        this.clanmasterid = _os_.unmarshal_long();
        this.oldclanname = _os_.unmarshal_String("UTF-16LE");
        this.hotellevel = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ClanSummaryInfo) {
            ClanSummaryInfo _o_ = (ClanSummaryInfo)_o1_;
            if (this.clanid != _o_.clanid) {
                return false;
            } else if (this.index != _o_.index) {
                return false;
            } else if (!this.clanname.equals(_o_.clanname)) {
                return false;
            } else if (this.membernum != _o_.membernum) {
                return false;
            } else if (this.clanlevel != _o_.clanlevel) {
                return false;
            } else if (!this.clanmastername.equals(_o_.clanmastername)) {
                return false;
            } else if (this.clanmasterid != _o_.clanmasterid) {
                return false;
            } else if (!this.oldclanname.equals(_o_.oldclanname)) {
                return false;
            } else {
                return this.hotellevel == _o_.hotellevel;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.clanid;
        _h_ += this.index;
        _h_ += this.clanname.hashCode();
        _h_ += this.membernum;
        _h_ += this.clanlevel;
        _h_ += this.clanmastername.hashCode();
        _h_ += (int)this.clanmasterid;
        _h_ += this.oldclanname.hashCode();
        _h_ += this.hotellevel;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.clanid).append(",");
        _sb_.append(this.index).append(",");
        _sb_.append("T").append(this.clanname.length()).append(",");
        _sb_.append(this.membernum).append(",");
        _sb_.append(this.clanlevel).append(",");
        _sb_.append("T").append(this.clanmastername.length()).append(",");
        _sb_.append(this.clanmasterid).append(",");
        _sb_.append("T").append(this.oldclanname.length()).append(",");
        _sb_.append(this.hotellevel).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
