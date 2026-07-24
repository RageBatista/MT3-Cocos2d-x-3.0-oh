//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.ranklist;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class PvP5RankData implements Marshal {
    public int rank;
    public long roleid;
    public String rolename;
    public int score;
    public int school;

    public PvP5RankData() {
        this.rolename = "";
    }

    public PvP5RankData(int _rank_, long _roleid_, String _rolename_, int _score_, int _school_) {
        this.rank = _rank_;
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.score = _score_;
        this.school = _school_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.rank);
        _os_.marshal(this.roleid);
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.score);
        _os_.marshal(this.school);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.rank = _os_.unmarshal_int();
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.score = _os_.unmarshal_int();
        this.school = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof PvP5RankData) {
            PvP5RankData _o_ = (PvP5RankData)_o1_;
            if (this.rank != _o_.rank) {
                return false;
            } else if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else if (this.score != _o_.score) {
                return false;
            } else {
                return this.school == _o_.school;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.rank;
        _h_ += (int)this.roleid;
        _h_ += this.rolename.hashCode();
        _h_ += this.score;
        _h_ += this.school;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.rank).append(",");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.score).append(",");
        _sb_.append(this.school).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
