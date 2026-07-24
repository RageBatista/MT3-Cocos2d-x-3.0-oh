//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.LinkedList;

public class SSendSingleCharacterList extends __SSendSingleCharacterList__ {
    public static final int PROTOCOL_TYPE = 794472;
    public LinkedList<SingleCharacterBasic> singlecharacterlist;

    protected void process() {
    }

    public int getType() {
        return 794472;
    }

    public SSendSingleCharacterList() {
        this.singlecharacterlist = new LinkedList();
    }

    public SSendSingleCharacterList(LinkedList<SingleCharacterBasic> _singlecharacterlist_) {
        this.singlecharacterlist = _singlecharacterlist_;
    }

    public final boolean _validator_() {
        for(SingleCharacterBasic _v_ : this.singlecharacterlist) {
            if (!_v_._validator_()) {
                return false;
            }
        }

        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.compact_uint32(this.singlecharacterlist.size());

            for(SingleCharacterBasic _v_ : this.singlecharacterlist) {
                _os_.marshal(_v_);
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            SingleCharacterBasic _v_ = new SingleCharacterBasic();
            _v_.unmarshal(_os_);
            this.singlecharacterlist.add(_v_);
        }

        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SSendSingleCharacterList) {
            SSendSingleCharacterList _o_ = (SSendSingleCharacterList)_o1_;
            return this.singlecharacterlist.equals(_o_.singlecharacterlist);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.singlecharacterlist.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.singlecharacterlist).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
