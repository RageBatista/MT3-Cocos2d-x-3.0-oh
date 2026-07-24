// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）

package fire.pb.battle;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;

public class FighterInfo implements Marshal {
    public int fightertype;
    public long dataid;
    public String fightername;
    public String title;
    public int titleid;
    public int awakestate;
    public int index;
    public byte bgm;
    public int maxhp;
    public int uplimithp;
    public int hp;
    public int ep;
    public int shape;
    public int subtype;
    public java.util.HashMap<Byte, Integer> components;
    public java.util.HashMap<Integer, Integer> buffs;
    public int footlogoid;
    public LinkedList<Integer> petkeys;

    public FighterInfo() {
        this.fightername = "";
        this.title = "";
        this.components = new java.util.HashMap<Byte, Integer>();
        this.buffs = new HashMap<Integer, Integer>();
        this.petkeys = new LinkedList<Integer>();
    }

    public FighterInfo(int _fightertype_, long _dataid_, String _fightername_, String _title_, int _titleid_, int _awakestate_, int _index_, byte _bgm_, int _maxhp_, int _uplimithp_, int _hp_, int _ep_, int _shape_, int _subtype_, java.util.HashMap<Byte, Integer> _components_, java.util.HashMap<Integer, Integer> _buffs_, int _footlogoid_, LinkedList<Integer> _petkeys_) {
        this.fightertype = _fightertype_;
        this.dataid = _dataid_;
        this.fightername = _fightername_;
        this.title = _title_;
        this.titleid = _titleid_;
        this.awakestate = _awakestate_;
        this.index = _index_;
        this.bgm = _bgm_;
        this.maxhp = _maxhp_;
        this.uplimithp = _uplimithp_;
        this.hp = _hp_;
        this.ep = _ep_;
        this.shape = _shape_;
        this.subtype = _subtype_;
        this.components = _components_;
        this.buffs = _buffs_;
        this.footlogoid = _footlogoid_;
        this.petkeys = _petkeys_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.fightertype);
        _os_.marshal(this.dataid);
        _os_.marshal(this.fightername, "UTF-16LE");
        _os_.marshal(this.title, "UTF-16LE");
        _os_.marshal(this.titleid);
        _os_.marshal(this.awakestate);
        _os_.marshal(this.index);
        _os_.marshal(this.bgm);
        _os_.marshal(this.maxhp);
        _os_.marshal(this.uplimithp);
        _os_.marshal(this.hp);
        _os_.marshal(this.ep);
        _os_.marshal(this.shape);
        _os_.marshal(this.subtype);
        _os_.compact_uint32(this.components.size());

        for(java.util.Map.Entry<Byte, Integer> _e_ : this.components.entrySet()) {
            _os_.marshal(_e_.getKey());
            _os_.marshal(_e_.getValue());
        }

        _os_.compact_uint32(this.buffs.size());

        for(Map.Entry<Integer, Integer> _e_ : this.buffs.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        _os_.marshal(this.footlogoid);
        _os_.compact_uint32(this.petkeys.size());

        for(Integer _v_ : this.petkeys) {
            _os_.marshal(_v_);
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.fightertype = _os_.unmarshal_int();
        this.dataid = _os_.unmarshal_long();
        this.fightername = _os_.unmarshal_String("UTF-16LE");
        this.title = _os_.unmarshal_String("UTF-16LE");
        this.titleid = _os_.unmarshal_int();
        this.awakestate = _os_.unmarshal_int();
        this.index = _os_.unmarshal_int();
        this.bgm = _os_.unmarshal_byte();
        this.maxhp = _os_.unmarshal_int();
        this.uplimithp = _os_.unmarshal_int();
        this.hp = _os_.unmarshal_int();
        this.ep = _os_.unmarshal_int();
        this.shape = _os_.unmarshal_int();
        this.subtype = _os_.unmarshal_int();

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            byte _k_ = _os_.unmarshal_byte();
            int _v_ = _os_.unmarshal_int();
            this.components.put(_k_, _v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            int _v_ = _os_.unmarshal_int();
            this.buffs.put(_k_, _v_);
        }

        this.footlogoid = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            int _v_ = _os_.unmarshal_int();
            this.petkeys.add(_v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof FighterInfo) {
            FighterInfo _o_ = (FighterInfo)_o1_;
            if (this.fightertype != _o_.fightertype) {
                return false;
            } else if (this.dataid != _o_.dataid) {
                return false;
            } else if (!this.fightername.equals(_o_.fightername)) {
                return false;
            } else if (!this.title.equals(_o_.title)) {
                return false;
            } else if (this.titleid != _o_.titleid) {
                return false;
            } else if (this.awakestate != _o_.awakestate) {
                return false;
            } else if (this.index != _o_.index) {
                return false;
            } else if (this.bgm != _o_.bgm) {
                return false;
            } else if (this.maxhp != _o_.maxhp) {
                return false;
            } else if (this.uplimithp != _o_.uplimithp) {
                return false;
            } else if (this.hp != _o_.hp) {
                return false;
            } else if (this.ep != _o_.ep) {
                return false;
            } else if (this.shape != _o_.shape) {
                return false;
            } else if (this.subtype != _o_.subtype) {
                return false;
            } else if (!this.components.equals(_o_.components)) {
                return false;
            } else if (!this.buffs.equals(_o_.buffs)) {
                return false;
            } else if (this.footlogoid != _o_.footlogoid) {
                return false;
            } else {
                return this.petkeys.equals(_o_.petkeys);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.fightertype;
        _h_ += (int)this.dataid;
        _h_ += this.fightername.hashCode();
        _h_ += this.title.hashCode();
        _h_ += this.titleid;
        _h_ += this.awakestate;
        _h_ += this.index;
        _h_ += this.bgm;
        _h_ += this.maxhp;
        _h_ += this.uplimithp;
        _h_ += this.hp;
        _h_ += this.ep;
        _h_ += this.shape;
        _h_ += this.subtype;
        _h_ += this.components.hashCode();
        _h_ += this.buffs.hashCode();
        _h_ += this.footlogoid;
        _h_ += this.petkeys.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.fightertype).append(",");
        _sb_.append(this.dataid).append(",");
        _sb_.append("T").append(this.fightername.length()).append(",");
        _sb_.append("T").append(this.title.length()).append(",");
        _sb_.append(this.titleid).append(",");
        _sb_.append(this.awakestate).append(",");
        _sb_.append(this.index).append(",");
        _sb_.append(this.bgm).append(",");
        _sb_.append(this.maxhp).append(",");
        _sb_.append(this.uplimithp).append(",");
        _sb_.append(this.hp).append(",");
        _sb_.append(this.ep).append(",");
        _sb_.append(this.shape).append(",");
        _sb_.append(this.subtype).append(",");
        _sb_.append(this.components).append(",");
        _sb_.append(this.buffs).append(",");
        _sb_.append(this.footlogoid).append(",");
        _sb_.append(this.petkeys).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
