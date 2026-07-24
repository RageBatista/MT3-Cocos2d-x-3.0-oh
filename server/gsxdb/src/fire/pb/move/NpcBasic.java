//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.move;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class NpcBasic implements Marshal {
    public long npckey;
    public int id;
    public String name;
    public Pos pos;
    public byte posz;
    public Pos destpos;
    public int speed;
    public int dir;
    public int shape;
    public int scenestate;
    public HashMap<Byte, Integer> components;

    public NpcBasic() {
        this.name = "";
        this.pos = new Pos();
        this.destpos = new Pos();
        this.components = new HashMap();
    }

    public NpcBasic(long _npckey_, int _id_, String _name_, Pos _pos_, byte _posz_, Pos _destpos_, int _speed_, int _dir_, int _shape_, int _scenestate_, HashMap<Byte, Integer> _components_) {
        this.npckey = _npckey_;
        this.id = _id_;
        this.name = _name_;
        this.pos = _pos_;
        this.posz = _posz_;
        this.destpos = _destpos_;
        this.speed = _speed_;
        this.dir = _dir_;
        this.shape = _shape_;
        this.scenestate = _scenestate_;
        this.components = _components_;
    }

    public final boolean _validator_() {
        if (!this.pos._validator_()) {
            return false;
        } else {
            return this.destpos._validator_();
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.npckey);
        _os_.marshal(this.id);
        _os_.marshal(this.name, "UTF-16LE");
        _os_.marshal(this.pos);
        _os_.marshal(this.posz);
        _os_.marshal(this.destpos);
        _os_.marshal(this.speed);
        _os_.marshal(this.dir);
        _os_.marshal(this.shape);
        _os_.marshal(this.scenestate);
        _os_.compact_uint32(this.components.size());

        for(Map.Entry<Byte, Integer> _e_ : this.components.entrySet()) {
            _os_.marshal((Byte)_e_.getKey());
            _os_.marshal((Integer)_e_.getValue());
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.npckey = _os_.unmarshal_long();
        this.id = _os_.unmarshal_int();
        this.name = _os_.unmarshal_String("UTF-16LE");
        this.pos.unmarshal(_os_);
        this.posz = _os_.unmarshal_byte();
        this.destpos.unmarshal(_os_);
        this.speed = _os_.unmarshal_int();
        this.dir = _os_.unmarshal_int();
        this.shape = _os_.unmarshal_int();
        this.scenestate = _os_.unmarshal_int();

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            byte _k_ = _os_.unmarshal_byte();
            int _v_ = _os_.unmarshal_int();
            this.components.put(_k_, _v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof NpcBasic) {
            NpcBasic _o_ = (NpcBasic)_o1_;
            if (this.npckey != _o_.npckey) {
                return false;
            } else if (this.id != _o_.id) {
                return false;
            } else if (!this.name.equals(_o_.name)) {
                return false;
            } else if (!this.pos.equals(_o_.pos)) {
                return false;
            } else if (this.posz != _o_.posz) {
                return false;
            } else if (!this.destpos.equals(_o_.destpos)) {
                return false;
            } else if (this.speed != _o_.speed) {
                return false;
            } else if (this.dir != _o_.dir) {
                return false;
            } else if (this.shape != _o_.shape) {
                return false;
            } else if (this.scenestate != _o_.scenestate) {
                return false;
            } else {
                return this.components.equals(_o_.components);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.npckey;
        _h_ += this.id;
        _h_ += this.name.hashCode();
        _h_ += this.pos.hashCode();
        _h_ += this.posz;
        _h_ += this.destpos.hashCode();
        _h_ += this.speed;
        _h_ += this.dir;
        _h_ += this.shape;
        _h_ += this.scenestate;
        _h_ += this.components.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.npckey).append(",");
        _sb_.append(this.id).append(",");
        _sb_.append("T").append(this.name.length()).append(",");
        _sb_.append(this.pos).append(",");
        _sb_.append(this.posz).append(",");
        _sb_.append(this.destpos).append(",");
        _sb_.append(this.speed).append(",");
        _sb_.append(this.dir).append(",");
        _sb_.append(this.shape).append(",");
        _sb_.append(this.scenestate).append(",");
        _sb_.append(this.components).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
