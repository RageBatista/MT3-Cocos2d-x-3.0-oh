//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class SOutRecharge extends __SOutRecharge__ {
    public static final int PROTOCOL_TYPE = 817968;
    public long pay;
    public long total;
    public HashMap<Integer, Long> dayrewardmap;
    public HashMap<Integer, Long> totalrewardmap;

    protected void process() {
    }

    public int getType() {
        return 817968;
    }

    public SOutRecharge() {
        this.dayrewardmap = new HashMap<>();
        this.totalrewardmap = new HashMap<>();
    }

    public SOutRecharge(long _pay_, HashMap<Integer, Long> _dayrewardmap_, long _total_, HashMap<Integer, Long> _totalrewardmap_) {
        this.pay = _pay_;
        this.dayrewardmap = _dayrewardmap_;
        this.total = _total_;
        this.totalrewardmap = _totalrewardmap_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.pay);
            _os_.compact_uint32(this.dayrewardmap.size());

            for(Map.Entry<Integer, Long> _e_ : this.dayrewardmap.entrySet()) {
                _os_.marshal((Integer)_e_.getKey());
                _os_.marshal((Long)_e_.getValue());
            }

            _os_.marshal(this.total);
            _os_.compact_uint32(this.totalrewardmap.size());

            for(Map.Entry<Integer, Long> _e_ : this.totalrewardmap.entrySet()) {
                _os_.marshal((Integer)_e_.getKey());
                _os_.marshal((Long)_e_.getValue());
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.pay = _os_.unmarshal_long();

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            long _v_ = _os_.unmarshal_long();
            this.dayrewardmap.put(_k_, _v_);
        }

        this.total = _os_.unmarshal_long();

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            long _v_ = _os_.unmarshal_long();
            this.totalrewardmap.put(_k_, _v_);
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
        } else if (_o1_ instanceof SOutRecharge) {
            SOutRecharge _o_ = (SOutRecharge)_o1_;
            if (this.pay != _o_.pay) {
                return false;
            } else if (!this.dayrewardmap.equals(_o_.dayrewardmap)) {
                return false;
            } else if (this.total != _o_.total) {
                return false;
            } else {
                return this.totalrewardmap.equals(_o_.totalrewardmap);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.pay;
        _h_ += this.dayrewardmap.hashCode();
        _h_ += (int)this.total;
        _h_ += this.totalrewardmap.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.pay).append(",");
        _sb_.append(this.dayrewardmap).append(",");
        _sb_.append(this.total).append(",");
        _sb_.append(this.totalrewardmap).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
