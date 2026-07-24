//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;
import java.util.LinkedList;

public class CUseFormBook extends __CUseFormBook__ {
    public static final int PROTOCOL_TYPE = 794553;
    public int formationid;
    public LinkedList<UseFormBook> listbook;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            for(UseFormBook book : this.listbook) {
                (new PUseFormationItem(roleid, this.formationid, book.bookid, book.num)).submit();
            }

        }
    }

    public int getType() {
        return 794553;
    }

    public CUseFormBook() {
        this.listbook = new LinkedList();
    }

    public CUseFormBook(int _formationid_, LinkedList<UseFormBook> _listbook_) {
        this.formationid = _formationid_;
        this.listbook = _listbook_;
    }

    public final boolean _validator_() {
        for(UseFormBook _v_ : this.listbook) {
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
            _os_.marshal(this.formationid);
            _os_.compact_uint32(this.listbook.size());

            for(UseFormBook _v_ : this.listbook) {
                _os_.marshal(_v_);
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.formationid = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            UseFormBook _v_ = new UseFormBook();
            _v_.unmarshal(_os_);
            this.listbook.add(_v_);
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
        } else if (_o1_ instanceof CUseFormBook) {
            CUseFormBook _o_ = (CUseFormBook)_o1_;
            if (this.formationid != _o_.formationid) {
                return false;
            } else {
                return this.listbook.equals(_o_.listbook);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.formationid;
        _h_ += this.listbook.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.formationid).append(",");
        _sb_.append(this.listbook).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
