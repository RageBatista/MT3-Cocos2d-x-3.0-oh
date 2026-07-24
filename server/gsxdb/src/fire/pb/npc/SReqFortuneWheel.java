//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.ArrayList;

public class SReqFortuneWheel extends __SReqFortuneWheel__ {
    public static final int PROTOCOL_TYPE = 795445;
    public long npckey;
    public int serviceid;
    public ArrayList<ForturneWheelType> itemids;
    public int index;
    public byte flag;

    protected void process() {
    }

    public int getType() {
        return 795445;
    }

    public SReqFortuneWheel() {
        this.itemids = new ArrayList();
    }

    public SReqFortuneWheel(long _npckey_, int _serviceid_, ArrayList<ForturneWheelType> _itemids_, int _index_, byte _flag_) {
        this.npckey = _npckey_;
        this.serviceid = _serviceid_;
        this.itemids = _itemids_;
        this.index = _index_;
        this.flag = _flag_;
    }

    public final boolean _validator_() {
        if (this.npckey < 0L) {
            return false;
        } else {
            for(ForturneWheelType _v_ : this.itemids) {
                if (!_v_._validator_()) {
                    return false;
                }
            }

            if (this.index < 0) {
                return false;
            } else {
                return true;
            }
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.npckey);
            _os_.marshal(this.serviceid);
            _os_.compact_uint32(this.itemids.size());

            for(ForturneWheelType _v_ : this.itemids) {
                _os_.marshal(_v_);
            }

            _os_.marshal(this.index);
            _os_.marshal(this.flag);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.npckey = _os_.unmarshal_long();
        this.serviceid = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            ForturneWheelType _v_ = new ForturneWheelType();
            _v_.unmarshal(_os_);
            this.itemids.add(_v_);
        }

        this.index = _os_.unmarshal_int();
        this.flag = _os_.unmarshal_byte();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SReqFortuneWheel) {
            SReqFortuneWheel _o_ = (SReqFortuneWheel)_o1_;
            if (this.npckey != _o_.npckey) {
                return false;
            } else if (this.serviceid != _o_.serviceid) {
                return false;
            } else if (!this.itemids.equals(_o_.itemids)) {
                return false;
            } else if (this.index != _o_.index) {
                return false;
            } else {
                return this.flag == _o_.flag;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.npckey;
        _h_ += this.serviceid;
        _h_ += this.itemids.hashCode();
        _h_ += this.index;
        _h_ += this.flag;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.npckey).append(",");
        _sb_.append(this.serviceid).append(",");
        _sb_.append(this.itemids).append(",");
        _sb_.append(this.index).append(",");
        _sb_.append(this.flag).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
