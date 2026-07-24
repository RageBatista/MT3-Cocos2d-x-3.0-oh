//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.ranklist;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ClanFightRaceRank implements Marshal {
    public int rank;
    public long clanid;
    public String clanname;
    public int clanlevel;
    public int fightcount;
    public int wincount;
    public int scroe;

    public ClanFightRaceRank() {
        this.clanname = "";
    }

    public ClanFightRaceRank(int _rank_, long _clanid_, String _clanname_, int _clanlevel_, int _fightcount_, int _wincount_, int _scroe_) {
        this.rank = _rank_;
        this.clanid = _clanid_;
        this.clanname = _clanname_;
        this.clanlevel = _clanlevel_;
        this.fightcount = _fightcount_;
        this.wincount = _wincount_;
        this.scroe = _scroe_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.rank);
        _os_.marshal(this.clanid);
        _os_.marshal(this.clanname, "UTF-16LE");
        _os_.marshal(this.clanlevel);
        _os_.marshal(this.fightcount);
        _os_.marshal(this.wincount);
        _os_.marshal(this.scroe);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.rank = _os_.unmarshal_int();
        this.clanid = _os_.unmarshal_long();
        this.clanname = _os_.unmarshal_String("UTF-16LE");
        this.clanlevel = _os_.unmarshal_int();
        this.fightcount = _os_.unmarshal_int();
        this.wincount = _os_.unmarshal_int();
        this.scroe = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ClanFightRaceRank) {
            ClanFightRaceRank _o_ = (ClanFightRaceRank)_o1_;
            if (this.rank != _o_.rank) {
                return false;
            } else if (this.clanid != _o_.clanid) {
                return false;
            } else if (!this.clanname.equals(_o_.clanname)) {
                return false;
            } else if (this.clanlevel != _o_.clanlevel) {
                return false;
            } else if (this.fightcount != _o_.fightcount) {
                return false;
            } else if (this.wincount != _o_.wincount) {
                return false;
            } else {
                return this.scroe == _o_.scroe;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.rank;
        _h_ += (int)this.clanid;
        _h_ += this.clanname.hashCode();
        _h_ += this.clanlevel;
        _h_ += this.fightcount;
        _h_ += this.wincount;
        _h_ += this.scroe;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.rank).append(",");
        _sb_.append(this.clanid).append(",");
        _sb_.append("T").append(this.clanname.length()).append(",");
        _sb_.append(this.clanlevel).append(",");
        _sb_.append(this.fightcount).append(",");
        _sb_.append(this.wincount).append(",");
        _sb_.append(this.scroe).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
