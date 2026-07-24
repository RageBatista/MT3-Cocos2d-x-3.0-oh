//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.cross;

import com.locojoy.base.Octets;
import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class TableData implements Marshal {
    public String tablename;
    public Octets valuedata;
    public Octets keydata;

    public TableData() {
        this.tablename = "";
        this.valuedata = new Octets();
        this.keydata = new Octets();
    }

    public TableData(String _tablename_, Octets _valuedata_, Octets _keydata_) {
        this.tablename = _tablename_;
        this.valuedata = _valuedata_;
        this.keydata = _keydata_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.tablename, "UTF-16LE");
        _os_.marshal(this.valuedata);
        _os_.marshal(this.keydata);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.tablename = _os_.unmarshal_String("UTF-16LE");
        this.valuedata = _os_.unmarshal_Octets();
        this.keydata = _os_.unmarshal_Octets();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof TableData) {
            TableData _o_ = (TableData)_o1_;
            if (!this.tablename.equals(_o_.tablename)) {
                return false;
            } else if (!this.valuedata.equals(_o_.valuedata)) {
                return false;
            } else {
                return this.keydata.equals(_o_.keydata);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.tablename.hashCode();
        _h_ += this.valuedata.hashCode();
        _h_ += this.keydata.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append("T").append(this.tablename.length()).append(",");
        _sb_.append("B").append(this.valuedata.size()).append(",");
        _sb_.append("B").append(this.keydata.size()).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
