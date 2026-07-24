//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.ranklist;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class BingFengRankData implements Marshal {
    public int shool;
    public int rank;
    public long roleid;
    public String rolename;
    public int stage;
    public int times;

    public BingFengRankData() {
        this.rolename = "";
    }

    public BingFengRankData(int _shool_, int _rank_, long _roleid_, String _rolename_, int _stage_, int _times_) {
        this.shool = _shool_;
        this.rank = _rank_;
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.stage = _stage_;
        this.times = _times_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.shool);
        _os_.marshal(this.rank);
        _os_.marshal(this.roleid);
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.stage);
        _os_.marshal(this.times);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.shool = _os_.unmarshal_int();
        this.rank = _os_.unmarshal_int();
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.stage = _os_.unmarshal_int();
        this.times = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof BingFengRankData) {
            BingFengRankData _o_ = (BingFengRankData)_o1_;
            if (this.shool != _o_.shool) {
                return false;
            } else if (this.rank != _o_.rank) {
                return false;
            } else if (this.roleid != _o_.roleid) {
                return false;
            } else if (!this.rolename.equals(_o_.rolename)) {
                return false;
            } else if (this.stage != _o_.stage) {
                return false;
            } else {
                return this.times == _o_.times;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.shool;
        _h_ += this.rank;
        _h_ += (int)this.roleid;
        _h_ += this.rolename.hashCode();
        _h_ += this.stage;
        _h_ += this.times;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.shool).append(",");
        _sb_.append(this.rank).append(",");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.stage).append(",");
        _sb_.append(this.times).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
