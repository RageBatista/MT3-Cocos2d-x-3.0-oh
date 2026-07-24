//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill.particleskill;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class ParticleSkill implements Marshal {
    public int id;
    public int level;
    public int maxlevel;
    public int exp;
    public HashMap<Integer, Float> effects;
    public HashMap<Integer, Float> nexteffect;

    public ParticleSkill() {
        this.effects = new HashMap();
        this.nexteffect = new HashMap();
    }

    public ParticleSkill(int _id_, int _level_, int _maxlevel_, int _exp_, HashMap<Integer, Float> _effects_, HashMap<Integer, Float> _nexteffect_) {
        this.id = _id_;
        this.level = _level_;
        this.maxlevel = _maxlevel_;
        this.exp = _exp_;
        this.effects = _effects_;
        this.nexteffect = _nexteffect_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.id);
        _os_.marshal(this.level);
        _os_.marshal(this.maxlevel);
        _os_.marshal(this.exp);
        _os_.compact_uint32(this.effects.size());

        for(Map.Entry<Integer, Float> _e_ : this.effects.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Float)_e_.getValue());
        }

        _os_.compact_uint32(this.nexteffect.size());

        for(Map.Entry<Integer, Float> _e_ : this.nexteffect.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Float)_e_.getValue());
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.id = _os_.unmarshal_int();
        this.level = _os_.unmarshal_int();
        this.maxlevel = _os_.unmarshal_int();
        this.exp = _os_.unmarshal_int();

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            float _v_ = _os_.unmarshal_float();
            this.effects.put(_k_, _v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            float _v_ = _os_.unmarshal_float();
            this.nexteffect.put(_k_, _v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ParticleSkill) {
            ParticleSkill _o_ = (ParticleSkill)_o1_;
            if (this.id != _o_.id) {
                return false;
            } else if (this.level != _o_.level) {
                return false;
            } else if (this.maxlevel != _o_.maxlevel) {
                return false;
            } else if (this.exp != _o_.exp) {
                return false;
            } else if (!this.effects.equals(_o_.effects)) {
                return false;
            } else {
                return this.nexteffect.equals(_o_.nexteffect);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.id;
        _h_ += this.level;
        _h_ += this.maxlevel;
        _h_ += this.exp;
        _h_ += this.effects.hashCode();
        _h_ += this.nexteffect.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.id).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.maxlevel).append(",");
        _sb_.append(this.exp).append(",");
        _sb_.append(this.effects).append(",");
        _sb_.append(this.nexteffect).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
