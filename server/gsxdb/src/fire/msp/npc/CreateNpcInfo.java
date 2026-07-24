//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.msp.npc;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class CreateNpcInfo implements Marshal {
    public long npckey;
    public int npcbaseid;
    public String name;
    public int dir;
    public long sceneid;
    public long ownerid;
    public long time;

    public CreateNpcInfo() {
        this.name = "";
    }

    public CreateNpcInfo(long _npckey_, int _npcbaseid_, String _name_, int _dir_, long _sceneid_, long _ownerid_, long _time_) {
        this.npckey = _npckey_;
        this.npcbaseid = _npcbaseid_;
        this.name = _name_;
        this.dir = _dir_;
        this.sceneid = _sceneid_;
        this.ownerid = _ownerid_;
        this.time = _time_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.npckey);
        _os_.marshal(this.npcbaseid);
        _os_.marshal(this.name, "UTF-16LE");
        _os_.marshal(this.dir);
        _os_.marshal(this.sceneid);
        _os_.marshal(this.ownerid);
        _os_.marshal(this.time);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.npckey = _os_.unmarshal_long();
        this.npcbaseid = _os_.unmarshal_int();
        this.name = _os_.unmarshal_String("UTF-16LE");
        this.dir = _os_.unmarshal_int();
        this.sceneid = _os_.unmarshal_long();
        this.ownerid = _os_.unmarshal_long();
        this.time = _os_.unmarshal_long();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CreateNpcInfo) {
            CreateNpcInfo _o_ = (CreateNpcInfo)_o1_;
            if (this.npckey != _o_.npckey) {
                return false;
            } else if (this.npcbaseid != _o_.npcbaseid) {
                return false;
            } else if (!this.name.equals(_o_.name)) {
                return false;
            } else if (this.dir != _o_.dir) {
                return false;
            } else if (this.sceneid != _o_.sceneid) {
                return false;
            } else if (this.ownerid != _o_.ownerid) {
                return false;
            } else {
                return this.time == _o_.time;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.npckey;
        _h_ += this.npcbaseid;
        _h_ += this.name.hashCode();
        _h_ += this.dir;
        _h_ += (int)this.sceneid;
        _h_ += (int)this.ownerid;
        _h_ += (int)this.time;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.npckey).append(",");
        _sb_.append(this.npcbaseid).append(",");
        _sb_.append("T").append(this.name.length()).append(",");
        _sb_.append(this.dir).append(",");
        _sb_.append(this.sceneid).append(",");
        _sb_.append(this.ownerid).append(",");
        _sb_.append(this.time).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
