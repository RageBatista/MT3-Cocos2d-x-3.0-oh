//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.msp.npc;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class CreateNpcInfoUniverse implements Marshal {
    public int npcbaseid;
    public String name;
    public int shape;
    public long ownerid;
    public int mapid;
    public int posx;
    public int posy;
    public int num;
    public long npckey;
    public long time;

    public CreateNpcInfoUniverse() {
        this.name = "";
    }

    public CreateNpcInfoUniverse(int _npcbaseid_, String _name_, int _shape_, long _ownerid_, int _mapid_, int _posx_, int _posy_, int _num_, long _npckey_, long _time_) {
        this.npcbaseid = _npcbaseid_;
        this.name = _name_;
        this.shape = _shape_;
        this.ownerid = _ownerid_;
        this.mapid = _mapid_;
        this.posx = _posx_;
        this.posy = _posy_;
        this.num = _num_;
        this.npckey = _npckey_;
        this.time = _time_;
    }

    public final boolean _validator_() {
        if (this.npcbaseid <= 0) {
            return false;
        } else if (this.mapid <= 0) {
            return false;
        } else {
            return this.num > 0;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.npcbaseid);
        _os_.marshal(this.name, "UTF-16LE");
        _os_.marshal(this.shape);
        _os_.marshal(this.ownerid);
        _os_.marshal(this.mapid);
        _os_.marshal(this.posx);
        _os_.marshal(this.posy);
        _os_.marshal(this.num);
        _os_.marshal(this.npckey);
        _os_.marshal(this.time);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.npcbaseid = _os_.unmarshal_int();
        this.name = _os_.unmarshal_String("UTF-16LE");
        this.shape = _os_.unmarshal_int();
        this.ownerid = _os_.unmarshal_long();
        this.mapid = _os_.unmarshal_int();
        this.posx = _os_.unmarshal_int();
        this.posy = _os_.unmarshal_int();
        this.num = _os_.unmarshal_int();
        this.npckey = _os_.unmarshal_long();
        this.time = _os_.unmarshal_long();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CreateNpcInfoUniverse) {
            CreateNpcInfoUniverse _o_ = (CreateNpcInfoUniverse)_o1_;
            if (this.npcbaseid != _o_.npcbaseid) {
                return false;
            } else if (!this.name.equals(_o_.name)) {
                return false;
            } else if (this.shape != _o_.shape) {
                return false;
            } else if (this.ownerid != _o_.ownerid) {
                return false;
            } else if (this.mapid != _o_.mapid) {
                return false;
            } else if (this.posx != _o_.posx) {
                return false;
            } else if (this.posy != _o_.posy) {
                return false;
            } else if (this.num != _o_.num) {
                return false;
            } else if (this.npckey != _o_.npckey) {
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
        _h_ += this.npcbaseid;
        _h_ += this.name.hashCode();
        _h_ += this.shape;
        _h_ += (int)this.ownerid;
        _h_ += this.mapid;
        _h_ += this.posx;
        _h_ += this.posy;
        _h_ += this.num;
        _h_ += (int)this.npckey;
        _h_ += (int)this.time;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.npcbaseid).append(",");
        _sb_.append("T").append(this.name.length()).append(",");
        _sb_.append(this.shape).append(",");
        _sb_.append(this.ownerid).append(",");
        _sb_.append(this.mapid).append(",");
        _sb_.append(this.posx).append(",");
        _sb_.append(this.posy).append(",");
        _sb_.append(this.num).append(",");
        _sb_.append(this.npckey).append(",");
        _sb_.append(this.time).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
