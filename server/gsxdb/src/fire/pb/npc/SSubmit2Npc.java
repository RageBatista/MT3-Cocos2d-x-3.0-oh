//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.ArrayList;

public class SSubmit2Npc extends __SSubmit2Npc__ {
    public static final int PROTOCOL_TYPE = 795455;
    public int questid;
    public long npckey;
    public int submittype;
    public ArrayList<Integer> availableids;
    public int availablepos;

    protected void process() {
    }

    public int getType() {
        return 795455;
    }

    public SSubmit2Npc() {
        this.availableids = new ArrayList();
    }

    public SSubmit2Npc(int _questid_, long _npckey_, int _submittype_, ArrayList<Integer> _availableids_, int _availablepos_) {
        this.questid = _questid_;
        this.npckey = _npckey_;
        this.submittype = _submittype_;
        this.availableids = _availableids_;
        this.availablepos = _availablepos_;
    }

    public final boolean _validator_() {
        if (this.questid < 0) {
            return false;
        } else if (this.npckey <= 0L) {
            return false;
        } else if (this.submittype < 0) {
            return false;
        } else {
            for(Integer _v_ : this.availableids) {
                if (_v_ < 0) {
                    return false;
                }
            }

            if (this.availablepos >= 0 && this.availablepos <= 5) {
                return true;
            } else {
                return false;
            }
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.questid);
            _os_.marshal(this.npckey);
            _os_.marshal(this.submittype);
            _os_.compact_uint32(this.availableids.size());

            for(Integer _v_ : this.availableids) {
                _os_.marshal(_v_);
            }

            _os_.marshal(this.availablepos);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.questid = _os_.unmarshal_int();
        this.npckey = _os_.unmarshal_long();
        this.submittype = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            int _v_ = _os_.unmarshal_int();
            this.availableids.add(_v_);
        }

        this.availablepos = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SSubmit2Npc) {
            SSubmit2Npc _o_ = (SSubmit2Npc)_o1_;
            if (this.questid != _o_.questid) {
                return false;
            } else if (this.npckey != _o_.npckey) {
                return false;
            } else if (this.submittype != _o_.submittype) {
                return false;
            } else if (!this.availableids.equals(_o_.availableids)) {
                return false;
            } else {
                return this.availablepos == _o_.availablepos;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.questid;
        _h_ += (int)this.npckey;
        _h_ += this.submittype;
        _h_ += this.availableids.hashCode();
        _h_ += this.availablepos;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.questid).append(",");
        _sb_.append(this.npckey).append(",");
        _sb_.append(this.submittype).append(",");
        _sb_.append(this.availableids).append(",");
        _sb_.append(this.availablepos).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
