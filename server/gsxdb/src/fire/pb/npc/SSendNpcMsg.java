//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.ArrayList;

public class SSendNpcMsg extends __SSendNpcMsg__ {
    public static final int PROTOCOL_TYPE = 795454;
    public long npckey;
    public int npcid;
    public int msgid;
    public ArrayList<Long> args;

    protected void process() {
    }

    public int getType() {
        return 795454;
    }

    public SSendNpcMsg() {
        this.args = new ArrayList();
    }

    public SSendNpcMsg(long _npckey_, int _npcid_, int _msgid_, ArrayList<Long> _args_) {
        this.npckey = _npckey_;
        this.npcid = _npcid_;
        this.msgid = _msgid_;
        this.args = _args_;
    }

    public final boolean _validator_() {
        if (this.npckey <= 0L) {
            return false;
        } else if (this.npcid <= 0) {
            return false;
        } else {
            return this.msgid > 0;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.npckey);
            _os_.marshal(this.npcid);
            _os_.marshal(this.msgid);
            _os_.compact_uint32(this.args.size());

            for(Long _v_ : this.args) {
                _os_.marshal(_v_);
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.npckey = _os_.unmarshal_long();
        this.npcid = _os_.unmarshal_int();
        this.msgid = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            long _v_ = _os_.unmarshal_long();
            this.args.add(_v_);
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
        } else if (_o1_ instanceof SSendNpcMsg) {
            SSendNpcMsg _o_ = (SSendNpcMsg)_o1_;
            if (this.npckey != _o_.npckey) {
                return false;
            } else if (this.npcid != _o_.npcid) {
                return false;
            } else if (this.msgid != _o_.msgid) {
                return false;
            } else {
                return this.args.equals(_o_.args);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.npckey;
        _h_ += this.npcid;
        _h_ += this.msgid;
        _h_ += this.args.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.npckey).append(",");
        _sb_.append(this.npcid).append(",");
        _sb_.append(this.msgid).append(",");
        _sb_.append(this.args).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
