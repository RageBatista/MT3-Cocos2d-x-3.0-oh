//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.friends;

import com.locojoy.base.Octets;
import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.talk.DisplayInfo;
import java.util.ArrayList;

public class StrangerMessageBean implements Marshal {
    public InfoBean friendinfobean;
    public String content;
    public ArrayList<Octets> details;
    public ArrayList<DisplayInfo> displayinfo;

    public StrangerMessageBean() {
        this.friendinfobean = new InfoBean();
        this.content = "";
        this.details = new ArrayList<>();
        this.displayinfo = new ArrayList<>();
    }

    public StrangerMessageBean(InfoBean _friendinfobean_, String _content_, ArrayList<Octets> _details_, ArrayList<DisplayInfo> _displayinfo_) {
        this.friendinfobean = _friendinfobean_;
        this.content = _content_;
        this.details = _details_;
        this.displayinfo = _displayinfo_;
    }

    public final boolean _validator_() {
        if (!this.friendinfobean._validator_()) {
            return false;
        } else {
            for(DisplayInfo _v_ : this.displayinfo) {
                if (!_v_._validator_()) {
                    return false;
                }
            }

            return true;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.friendinfobean);
        _os_.marshal(this.content, "UTF-16LE");
        _os_.compact_uint32(this.details.size());

        for(Octets _v_ : this.details) {
            _os_.marshal(_v_);
        }

        _os_.compact_uint32(this.displayinfo.size());

        for(DisplayInfo _v_ : this.displayinfo) {
            _os_.marshal(_v_);
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.friendinfobean.unmarshal(_os_);
        this.content = _os_.unmarshal_String("UTF-16LE");

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            Octets _v_ = _os_.unmarshal_Octets();
            this.details.add(_v_);
        }

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            DisplayInfo _v_ = new DisplayInfo();
            _v_.unmarshal(_os_);
            this.displayinfo.add(_v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof StrangerMessageBean) {
            StrangerMessageBean _o_ = (StrangerMessageBean)_o1_;
            if (!this.friendinfobean.equals(_o_.friendinfobean)) {
                return false;
            } else if (!this.content.equals(_o_.content)) {
                return false;
            } else if (!this.details.equals(_o_.details)) {
                return false;
            } else {
                return this.displayinfo.equals(_o_.displayinfo);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.friendinfobean.hashCode();
        _h_ += this.content.hashCode();
        _h_ += this.details.hashCode();
        _h_ += this.displayinfo.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.friendinfobean).append(",");
        _sb_.append("T").append(this.content.length()).append(",");
        _sb_.append(this.details).append(",");
        _sb_.append(this.displayinfo).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
