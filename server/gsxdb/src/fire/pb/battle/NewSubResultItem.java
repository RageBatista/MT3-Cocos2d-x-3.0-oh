//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.LinkedList;

public class NewSubResultItem implements Marshal {
    public int subskillid;
    public int subskillstarttime;
    public LinkedList<NewDemoResult> resultlist;

    public NewSubResultItem() {
        this.resultlist = new LinkedList();
    }

    public NewSubResultItem(int _subskillid_, int _subskillstarttime_, LinkedList<NewDemoResult> _resultlist_) {
        this.subskillid = _subskillid_;
        this.subskillstarttime = _subskillstarttime_;
        this.resultlist = _resultlist_;
    }

    public final boolean _validator_() {
        for(NewDemoResult _v_ : this.resultlist) {
            if (!_v_._validator_()) {
                return false;
            }
        }

        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.subskillid);
        _os_.marshal(this.subskillstarttime);
        _os_.compact_uint32(this.resultlist.size());

        for(NewDemoResult _v_ : this.resultlist) {
            _os_.marshal(_v_);
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.subskillid = _os_.unmarshal_int();
        this.subskillstarttime = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            NewDemoResult _v_ = new NewDemoResult();
            _v_.unmarshal(_os_);
            this.resultlist.add(_v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof NewSubResultItem) {
            NewSubResultItem _o_ = (NewSubResultItem)_o1_;
            if (this.subskillid != _o_.subskillid) {
                return false;
            } else if (this.subskillstarttime != _o_.subskillstarttime) {
                return false;
            } else {
                return this.resultlist.equals(_o_.resultlist);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.subskillid;
        _h_ += this.subskillstarttime;
        _h_ += this.resultlist.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.subskillid).append(",");
        _sb_.append(this.subskillstarttime).append(",");
        _sb_.append(this.resultlist).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
