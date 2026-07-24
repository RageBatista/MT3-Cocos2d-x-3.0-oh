//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.ranklist;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class LevelRankData implements Marshal {
    public long roleid;
    public String nickname;
    public int level;
    public int school;
    public int rank;

    public LevelRankData() {
        this.nickname = "";
    }

    public LevelRankData(long _roleid_, String _nickname_, int _level_, int _school_, int _rank_) {
        this.roleid = _roleid_;
        this.nickname = _nickname_;
        this.level = _level_;
        this.school = _school_;
        this.rank = _rank_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.nickname, "UTF-16LE");
        _os_.marshal(this.level);
        _os_.marshal(this.school);
        _os_.marshal(this.rank);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.nickname = _os_.unmarshal_String("UTF-16LE");
        this.level = _os_.unmarshal_int();
        this.school = _os_.unmarshal_int();
        this.rank = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof LevelRankData) {
            LevelRankData _o_ = (LevelRankData)_o1_;
            return this.roleid == _o_.roleid && this.nickname.equals(_o_.nickname) && this.level == _o_.level && this.school == _o_.school && this.rank == _o_.rank;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.nickname.hashCode();
        _h_ += this.level;
        _h_ += this.school;
        _h_ += this.rank;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.nickname.length()).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.school).append(",");
        _sb_.append(this.rank).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
