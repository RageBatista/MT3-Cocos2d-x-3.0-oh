//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.ranklist;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class RoleProfessionRankRecord implements Marshal {
    public int rank;
    public long roleid;
    public String rolename;
    public int school;
    public int score;
    public String faction;
    public int rolelevel;

    public RoleProfessionRankRecord() {
        this.rolename = "";
        this.faction = "";
    }

    public RoleProfessionRankRecord(int _rank_, long _roleid_, String _rolename_, int _school_, int _score_, String _faction_, int _rolelevel_) {
        this.rank = _rank_;
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.school = _school_;
        this.score = _score_;
        this.faction = _faction_;
        this.rolelevel = _rolelevel_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.rank);
        _os_.marshal(this.roleid);
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.school);
        _os_.marshal(this.score);
        _os_.marshal(this.faction, "UTF-16LE");
        _os_.marshal(this.rolelevel);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.rank = _os_.unmarshal_int();
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.school = _os_.unmarshal_int();
        this.score = _os_.unmarshal_int();
        this.faction = _os_.unmarshal_String("UTF-16LE");
        this.rolelevel = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RoleProfessionRankRecord) {
            RoleProfessionRankRecord _o_ = (RoleProfessionRankRecord)_o1_;
            return this.rank == _o_.rank && this.roleid == _o_.roleid && this.rolename.equals(_o_.rolename) && this.school == _o_.school && this.score == _o_.score && this.faction.equals(_o_.faction) && this.rolelevel == _o_.rolelevel;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0 + this.rank;
        return _h_ + (int)this.roleid + this.rolename.hashCode() + this.school + this.score + this.faction.hashCode() + this.rolelevel;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.rank).append(",");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.school).append(",");
        _sb_.append(this.score).append(",");
        _sb_.append("T").append(this.faction.length()).append(",");
        _sb_.append(this.rolelevel).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
