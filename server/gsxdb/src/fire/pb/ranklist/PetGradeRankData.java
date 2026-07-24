//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.ranklist;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class PetGradeRankData implements Marshal {
    public long roleid;
    public long uniquepetid;
    public String nickname;
    public String petname;
    public int petgrade;
    public int rank;
    public int colour;

    public PetGradeRankData() {
        this.nickname = "";
        this.petname = "";
    }

    public PetGradeRankData(long _roleid_, long _uniquepetid_, String _nickname_, String _petname_, int _petgrade_, int _rank_, int _colour_) {
        this.roleid = _roleid_;
        this.uniquepetid = _uniquepetid_;
        this.nickname = _nickname_;
        this.petname = _petname_;
        this.petgrade = _petgrade_;
        this.rank = _rank_;
        this.colour = _colour_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.uniquepetid);
        _os_.marshal(this.nickname, "UTF-16LE");
        _os_.marshal(this.petname, "UTF-16LE");
        _os_.marshal(this.petgrade);
        _os_.marshal(this.rank);
        _os_.marshal(this.colour);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.uniquepetid = _os_.unmarshal_long();
        this.nickname = _os_.unmarshal_String("UTF-16LE");
        this.petname = _os_.unmarshal_String("UTF-16LE");
        this.petgrade = _os_.unmarshal_int();
        this.rank = _os_.unmarshal_int();
        this.colour = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof PetGradeRankData) {
            PetGradeRankData _o_ = (PetGradeRankData)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (this.uniquepetid != _o_.uniquepetid) {
                return false;
            } else if (!this.nickname.equals(_o_.nickname)) {
                return false;
            } else if (!this.petname.equals(_o_.petname)) {
                return false;
            } else if (this.petgrade != _o_.petgrade) {
                return false;
            } else if (this.rank != _o_.rank) {
                return false;
            } else {
                return this.colour == _o_.colour;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += (int)this.uniquepetid;
        _h_ += this.nickname.hashCode();
        _h_ += this.petname.hashCode();
        _h_ += this.petgrade;
        _h_ += this.rank;
        _h_ += this.colour;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append(this.uniquepetid).append(",");
        _sb_.append("T").append(this.nickname.length()).append(",");
        _sb_.append("T").append(this.petname.length()).append(",");
        _sb_.append(this.petgrade).append(",");
        _sb_.append(this.rank).append(",");
        _sb_.append(this.colour).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
