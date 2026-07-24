//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SSendNpcService extends __SSendNpcService__ {
    public static final int PROTOCOL_TYPE = 795689;
    public long npckey;
    public int service;
    public String title;

    protected void process() {
    }

    public int getType() {
        return 795689;
    }

    public SSendNpcService() {
        this.title = "";
    }

    public SSendNpcService(long _npckey_, int _service_, String _title_) {
        this.npckey = _npckey_;
        this.service = _service_;
        this.title = _title_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.npckey);
            _os_.marshal(this.service);
            _os_.marshal(this.title, "UTF-16LE");
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.npckey = _os_.unmarshal_long();
        this.service = _os_.unmarshal_int();
        this.title = _os_.unmarshal_String("UTF-16LE");
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SSendNpcService) {
            SSendNpcService _o_ = (SSendNpcService)_o1_;
            if (this.npckey != _o_.npckey) {
                return false;
            } else if (this.service != _o_.service) {
                return false;
            } else {
                return this.title.equals(_o_.title);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.npckey;
        _h_ += this.service;
        _h_ += this.title.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.npckey).append(",");
        _sb_.append(this.service).append(",");
        _sb_.append("T").append(this.title.length()).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
