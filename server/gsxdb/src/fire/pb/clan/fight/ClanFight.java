//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan.fight;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ClanFight implements Marshal {
    public long clanid1;
    public String clanname1;
    public long clanid2;
    public String clanname2;
    public int winner;

    public ClanFight() {
        this.clanname1 = "";
        this.clanname2 = "";
    }

    public ClanFight(long _clanid1_, String _clanname1_, long _clanid2_, String _clanname2_, int _winner_) {
        this.clanid1 = _clanid1_;
        this.clanname1 = _clanname1_;
        this.clanid2 = _clanid2_;
        this.clanname2 = _clanname2_;
        this.winner = _winner_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.clanid1);
        _os_.marshal(this.clanname1, "UTF-16LE");
        _os_.marshal(this.clanid2);
        _os_.marshal(this.clanname2, "UTF-16LE");
        _os_.marshal(this.winner);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.clanid1 = _os_.unmarshal_long();
        this.clanname1 = _os_.unmarshal_String("UTF-16LE");
        this.clanid2 = _os_.unmarshal_long();
        this.clanname2 = _os_.unmarshal_String("UTF-16LE");
        this.winner = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ClanFight) {
            ClanFight _o_ = (ClanFight)_o1_;
            if (this.clanid1 != _o_.clanid1) {
                return false;
            } else if (!this.clanname1.equals(_o_.clanname1)) {
                return false;
            } else if (this.clanid2 != _o_.clanid2) {
                return false;
            } else if (!this.clanname2.equals(_o_.clanname2)) {
                return false;
            } else {
                return this.winner == _o_.winner;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.clanid1;
        _h_ += this.clanname1.hashCode();
        _h_ += (int)this.clanid2;
        _h_ += this.clanname2.hashCode();
        _h_ += this.winner;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.clanid1).append(",");
        _sb_.append("T").append(this.clanname1.length()).append(",");
        _sb_.append(this.clanid2).append(",");
        _sb_.append("T").append(this.clanname2.length()).append(",");
        _sb_.append(this.winner).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
