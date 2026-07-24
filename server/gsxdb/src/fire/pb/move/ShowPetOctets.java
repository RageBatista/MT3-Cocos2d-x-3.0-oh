//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.move;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ShowPetOctets implements Marshal {
    public int showpetid;
    public String showpetname;
    public short petcoloursndsize;
    public byte showskilleffect;
    public byte evolvelevel;

    public ShowPetOctets() {
        this.showpetname = "";
    }

    public ShowPetOctets(int _showpetid_, String _showpetname_, short _petcoloursndsize_, byte _showskilleffect_, byte _evolvelevel_) {
        this.showpetid = _showpetid_;
        this.showpetname = _showpetname_;
        this.petcoloursndsize = _petcoloursndsize_;
        this.showskilleffect = _showskilleffect_;
        this.evolvelevel = _evolvelevel_;
    }

    public final boolean _validator_() {
        return this.showpetid >= -1;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.showpetid);
        _os_.marshal(this.showpetname, "UTF-16LE");
        _os_.marshal(this.petcoloursndsize);
        _os_.marshal(this.showskilleffect);
        _os_.marshal(this.evolvelevel);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.showpetid = _os_.unmarshal_int();
        this.showpetname = _os_.unmarshal_String("UTF-16LE");
        this.petcoloursndsize = _os_.unmarshal_short();
        this.showskilleffect = _os_.unmarshal_byte();
        this.evolvelevel = _os_.unmarshal_byte();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ShowPetOctets) {
            ShowPetOctets _o_ = (ShowPetOctets)_o1_;
            if (this.showpetid != _o_.showpetid) {
                return false;
            } else if (!this.showpetname.equals(_o_.showpetname)) {
                return false;
            } else if (this.petcoloursndsize != _o_.petcoloursndsize) {
                return false;
            } else if (this.showskilleffect != _o_.showskilleffect) {
                return false;
            } else {
                return this.evolvelevel == _o_.evolvelevel;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.showpetid;
        _h_ += this.showpetname.hashCode();
        _h_ += this.petcoloursndsize;
        _h_ += this.showskilleffect;
        _h_ += this.evolvelevel;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.showpetid).append(",");
        _sb_.append("T").append(this.showpetname.length()).append(",");
        _sb_.append(this.petcoloursndsize).append(",");
        _sb_.append(this.showskilleffect).append(",");
        _sb_.append(this.evolvelevel).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
