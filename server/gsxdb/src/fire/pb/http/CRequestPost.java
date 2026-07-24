//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.http;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.shop.utils.HttpPackage;
import gnet.link.Onlines;
import java.util.HashMap;
import java.util.Map;
import mkdb.Procedure;

public class CRequestPost extends __CRequestPost__ {
    public static final int PROTOCOL_TYPE = 800300;
    public String url;
    public int dataid;
    public String postdata;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            (new Procedure() {
                public boolean process() {
                    Map<String, String> headers = new HashMap();
                    String ret = HttpPackage.postMethod(CRequestPost.this.url, headers, CRequestPost.this.postdata);
                    SResponsePost responsePost = new SResponsePost();
                    responsePost.dataid = CRequestPost.this.dataid;
                    responsePost.retvalue = ret;
                    Onlines.getInstance().send(roleid, responsePost);
                    return true;
                }
            }).submit();
        }

    }

    public int getType() {
        return 800300;
    }

    public CRequestPost() {
        this.url = "";
        this.postdata = "";
        this.dataid = 0;
    }

    public CRequestPost(String _url_, String _data_, int dataid) {
        this.url = _url_;
        this.postdata = _data_;
        this.dataid = dataid;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.url, "UTF-16LE");
            _os_.marshal(this.postdata, "UTF-16LE");
            _os_.marshal(this.dataid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.url = _os_.unmarshal_String("UTF-16LE");
        this.postdata = _os_.unmarshal_String("UTF-16LE");
        this.dataid = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CRequestPost) {
            CRequestPost _o_ = (CRequestPost)_o1_;
            if (!this.url.equals(_o_.url)) {
                return false;
            } else if (this.postdata != _o_.postdata) {
                return false;
            } else {
                return this.dataid == _o_.dataid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.url.hashCode();
        _h_ += this.postdata.hashCode();
        _h_ += this.dataid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append("T").append(this.url.length()).append(",");
        _sb_.append(this.postdata.length()).append(",");
        _sb_.append(this.dataid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
