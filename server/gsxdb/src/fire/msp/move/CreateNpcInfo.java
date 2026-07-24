//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.msp.move;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class CreateNpcInfo implements Marshal {
    public int npcid;
    public String npcname;
    public int dir;
    public long sceneid;
    public int xpos;
    public int ypos;

    public CreateNpcInfo() {
        this.npcname = "";
    }

    public CreateNpcInfo(int _npcid_, String _npcname_, int _dir_, long _sceneid_, int _xpos_, int _ypos_) {
        this.npcid = _npcid_;
        this.npcname = _npcname_;
        this.dir = _dir_;
        this.sceneid = _sceneid_;
        this.xpos = _xpos_;
        this.ypos = _ypos_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.npcid);
        _os_.marshal(this.npcname, "UTF-16LE");
        _os_.marshal(this.dir);
        _os_.marshal(this.sceneid);
        _os_.marshal(this.xpos);
        _os_.marshal(this.ypos);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.npcid = _os_.unmarshal_int();
        this.npcname = _os_.unmarshal_String("UTF-16LE");
        this.dir = _os_.unmarshal_int();
        this.sceneid = _os_.unmarshal_long();
        this.xpos = _os_.unmarshal_int();
        this.ypos = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CreateNpcInfo) {
            CreateNpcInfo _o_ = (CreateNpcInfo)_o1_;
            if (this.npcid != _o_.npcid) {
                return false;
            } else if (!this.npcname.equals(_o_.npcname)) {
                return false;
            } else if (this.dir != _o_.dir) {
                return false;
            } else if (this.sceneid != _o_.sceneid) {
                return false;
            } else if (this.xpos != _o_.xpos) {
                return false;
            } else {
                return this.ypos == _o_.ypos;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.npcid;
        _h_ += this.npcname.hashCode();
        _h_ += this.dir;
        _h_ += (int)this.sceneid;
        _h_ += this.xpos;
        _h_ += this.ypos;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.npcid).append(",");
        _sb_.append("T").append(this.npcname.length()).append(",");
        _sb_.append(this.dir).append(",");
        _sb_.append(this.sceneid).append(",");
        _sb_.append(this.xpos).append(",");
        _sb_.append(this.ypos).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
