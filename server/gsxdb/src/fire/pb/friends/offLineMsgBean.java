//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.friends;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class offLineMsgBean implements Marshal {
    public StrangerMessageBean strangermessage;
    public String time;

    public offLineMsgBean() {
        this.strangermessage = new StrangerMessageBean();
        this.time = "";
    }

    public offLineMsgBean(StrangerMessageBean _strangermessage_, String _time_) {
        this.strangermessage = _strangermessage_;
        this.time = _time_;
    }

    public final boolean _validator_() {
        return this.strangermessage._validator_();
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.strangermessage);
        _os_.marshal(this.time, "UTF-16LE");
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.strangermessage.unmarshal(_os_);
        this.time = _os_.unmarshal_String("UTF-16LE");
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof offLineMsgBean) {
            offLineMsgBean _o_ = (offLineMsgBean)_o1_;
            if (!this.strangermessage.equals(_o_.strangermessage)) {
                return false;
            } else {
                return this.time.equals(_o_.time);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.strangermessage.hashCode();
        _h_ += this.time.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.strangermessage).append(",");
        _sb_.append("T").append(this.time.length()).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
