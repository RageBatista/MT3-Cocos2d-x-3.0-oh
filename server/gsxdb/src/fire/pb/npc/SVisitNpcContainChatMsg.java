//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Octets;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.ArrayList;

public class SVisitNpcContainChatMsg extends __SVisitNpcContainChatMsg__ {
    public static final int PROTOCOL_TYPE = 795526;
    public long npckey;
    public ArrayList<Integer> services;
    public ArrayList<Integer> scenarioquests;
    public int msgid;
    public ArrayList<Octets> parameters;

    protected void process() {
    }

    public int getType() {
        return 795526;
    }

    public SVisitNpcContainChatMsg() {
        this.services = new ArrayList();
        this.scenarioquests = new ArrayList();
        this.parameters = new ArrayList();
    }

    public SVisitNpcContainChatMsg(long _npckey_, ArrayList<Integer> _services_, ArrayList<Integer> _scenarioquests_, int _msgid_, ArrayList<Octets> _parameters_) {
        this.npckey = _npckey_;
        this.services = _services_;
        this.scenarioquests = _scenarioquests_;
        this.msgid = _msgid_;
        this.parameters = _parameters_;
    }

    public final boolean _validator_() {
        return this.npckey >= 0L;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.npckey);
            _os_.compact_uint32(this.services.size());

            for(Integer _v_ : this.services) {
                _os_.marshal(_v_);
            }

            _os_.compact_uint32(this.scenarioquests.size());

            for(Integer _v_ : this.scenarioquests) {
                _os_.marshal(_v_);
            }

            _os_.marshal(this.msgid);
            _os_.compact_uint32(this.parameters.size());

            for(Octets _v_ : this.parameters) {
                _os_.marshal(_v_);
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.npckey = _os_.unmarshal_long();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            int _v_ = _os_.unmarshal_int();
            this.services.add(_v_);
        }

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            int _v_ = _os_.unmarshal_int();
            this.scenarioquests.add(_v_);
        }

        this.msgid = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            Octets _v_ = _os_.unmarshal_Octets();
            this.parameters.add(_v_);
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
        } else if (_o1_ instanceof SVisitNpcContainChatMsg) {
            SVisitNpcContainChatMsg _o_ = (SVisitNpcContainChatMsg)_o1_;
            if (this.npckey != _o_.npckey) {
                return false;
            } else if (!this.services.equals(_o_.services)) {
                return false;
            } else if (!this.scenarioquests.equals(_o_.scenarioquests)) {
                return false;
            } else if (this.msgid != _o_.msgid) {
                return false;
            } else {
                return this.parameters.equals(_o_.parameters);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.npckey;
        _h_ += this.services.hashCode();
        _h_ += this.scenarioquests.hashCode();
        _h_ += this.msgid;
        _h_ += this.parameters.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.npckey).append(",");
        _sb_.append(this.services).append(",");
        _sb_.append(this.scenarioquests).append(",");
        _sb_.append(this.msgid).append(",");
        _sb_.append(this.parameters).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
