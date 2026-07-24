//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.Petskill;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;

public class SRefreshPetSkill extends __SRefreshPetSkill__ {
    public static final int PROTOCOL_TYPE = 788454;
    public int petkey;
    public LinkedList<Petskill> skills;
    public HashMap<Integer, Long> expiredtimes;

    protected void process() {
    }

    public int getType() {
        return 788454;
    }

    public SRefreshPetSkill() {
        this.skills = new LinkedList<>();
        this.expiredtimes = new HashMap<>();
    }

    public SRefreshPetSkill(int _petkey_, LinkedList<Petskill> _skills_, HashMap<Integer, Long> _expiredtimes_) {
        this.petkey = _petkey_;
        this.skills = _skills_;
        this.expiredtimes = _expiredtimes_;
    }

    public final boolean _validator_() {
        if (this.petkey < 1) {
            return false;
        } else {
            for(Petskill _v_ : this.skills) {
                if (!_v_._validator_()) {
                    return false;
                }
            }

            return true;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey);
            _os_.compact_uint32(this.skills.size());

            for(Petskill _v_ : this.skills) {
                _os_.marshal(_v_);
            }

            _os_.compact_uint32(this.expiredtimes.size());

            for(Map.Entry<Integer, Long> _e_ : this.expiredtimes.entrySet()) {
                _os_.marshal((Integer)_e_.getKey());
                _os_.marshal((Long)_e_.getValue());
            }

            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            Petskill _v_ = new Petskill();
            _v_.unmarshal(_os_);
            this.skills.add(_v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            long _v_ = _os_.unmarshal_long();
            this.expiredtimes.put(_k_, _v_);
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
        } else if (_o1_ instanceof SRefreshPetSkill) {
            SRefreshPetSkill _o_ = (SRefreshPetSkill)_o1_;
            if (this.petkey != _o_.petkey) {
                return false;
            } else if (!this.skills.equals(_o_.skills)) {
                return false;
            } else {
                return this.expiredtimes.equals(_o_.expiredtimes);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey;
        _h_ += this.skills.hashCode();
        _h_ += this.expiredtimes.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey).append(",");
        _sb_.append(this.skills).append(",");
        _sb_.append(this.expiredtimes).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
