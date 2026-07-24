//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team.teammelon;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.LinkedList;

public class STeamRollMelon extends __STeamRollMelon__ {
    public static final int PROTOCOL_TYPE = 794522;
    public LinkedList<RollMelon> melonlist;
    public int watcher;

    protected void process() {
    }

    public int getType() {
        return 794522;
    }

    public STeamRollMelon() {
        this.melonlist = new LinkedList();
    }

    public STeamRollMelon(LinkedList<RollMelon> _melonlist_, int _watcher_) {
        this.melonlist = _melonlist_;
        this.watcher = _watcher_;
    }

    public final boolean _validator_() {
        for(RollMelon _v_ : this.melonlist) {
            if (!_v_._validator_()) {
                return false;
            }
        }

        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.compact_uint32(this.melonlist.size());

            for(RollMelon _v_ : this.melonlist) {
                _os_.marshal(_v_);
            }

            _os_.marshal(this.watcher);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            RollMelon _v_ = new RollMelon();
            _v_.unmarshal(_os_);
            this.melonlist.add(_v_);
        }

        this.watcher = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof STeamRollMelon) {
            STeamRollMelon _o_ = (STeamRollMelon)_o1_;
            if (!this.melonlist.equals(_o_.melonlist)) {
                return false;
            } else {
                return this.watcher == _o_.watcher;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.melonlist.hashCode();
        _h_ += this.watcher;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.melonlist).append(",");
        _sb_.append(this.watcher).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
