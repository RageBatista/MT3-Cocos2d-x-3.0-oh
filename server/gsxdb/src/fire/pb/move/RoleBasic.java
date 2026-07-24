//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.move;

import com.locojoy.base.Octets;
import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.LinkedList;

public class RoleBasic implements Marshal {
    public Octets rolebasicoctets;
    public Pos pos;
    public byte posz;
    public LinkedList<Pos> poses;

    public RoleBasic() {
        this.rolebasicoctets = new Octets();
        this.pos = new Pos();
        this.poses = new LinkedList<>();
    }

    public RoleBasic(Octets _rolebasicoctets_, Pos _pos_, byte _posz_, LinkedList<Pos> _poses_) {
        this.rolebasicoctets = _rolebasicoctets_;
        this.pos = _pos_;
        this.posz = _posz_;
        this.poses = _poses_;
    }

    public final boolean _validator_() {
        if (!this.pos._validator_()) {
            return false;
        } else {
            for(Pos _v_ : this.poses) {
                if (!_v_._validator_()) {
                    return false;
                }
            }

            return true;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.rolebasicoctets);
        _os_.marshal(this.pos);
        _os_.marshal(this.posz);
        _os_.compact_uint32(this.poses.size());

        for(Pos _v_ : this.poses) {
            _os_.marshal(_v_);
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.rolebasicoctets = _os_.unmarshal_Octets();
        this.pos.unmarshal(_os_);
        this.posz = _os_.unmarshal_byte();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            Pos _v_ = new Pos();
            _v_.unmarshal(_os_);
            this.poses.add(_v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RoleBasic) {
            RoleBasic _o_ = (RoleBasic)_o1_;
            if (!this.rolebasicoctets.equals(_o_.rolebasicoctets)) {
                return false;
            } else if (!this.pos.equals(_o_.pos)) {
                return false;
            } else if (this.posz != _o_.posz) {
                return false;
            } else {
                return this.poses.equals(_o_.poses);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.rolebasicoctets.hashCode();
        _h_ += this.pos.hashCode();
        _h_ += this.posz;
        _h_ += this.poses.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append("B").append(this.rolebasicoctets.size()).append(",");
        _sb_.append(this.pos).append(",");
        _sb_.append(this.posz).append(",");
        _sb_.append(this.poses).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
