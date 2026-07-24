//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package gnet;

import com.locojoy.base.Octets;
import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class GRoleInventory implements Marshal {
    public int id;
    public int pos;
    public int count;
    public int max_count;
    public byte container_id;
    public Octets data;
    public int guid1;
    public int guid2;
    public int mask;
    public int proctype;
    public int reserved;

    public GRoleInventory() {
        this.id = 0;
        this.pos = -1;
        this.count = 0;
        this.max_count = 0;
        this.container_id = 0;
        this.data = new Octets();
        this.guid1 = 0;
        this.guid2 = 0;
        this.mask = 0;
        this.proctype = 0;
        this.reserved = 0;
    }

    public GRoleInventory(int _id_, int _pos_, int _count_, int _max_count_, byte _container_id_, Octets _data_, int _guid1_, int _guid2_, int _mask_, int _proctype_, int _reserved_) {
        this.id = _id_;
        this.pos = _pos_;
        this.count = _count_;
        this.max_count = _max_count_;
        this.container_id = _container_id_;
        this.data = _data_;
        this.guid1 = _guid1_;
        this.guid2 = _guid2_;
        this.mask = _mask_;
        this.proctype = _proctype_;
        this.reserved = _reserved_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.id);
        _os_.marshal(this.pos);
        _os_.marshal(this.count);
        _os_.marshal(this.max_count);
        _os_.marshal(this.container_id);
        _os_.marshal(this.data);
        _os_.marshal(this.guid1);
        _os_.marshal(this.guid2);
        _os_.marshal(this.mask);
        _os_.marshal(this.proctype);
        _os_.marshal(this.reserved);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.id = _os_.unmarshal_int();
        this.pos = _os_.unmarshal_int();
        this.count = _os_.unmarshal_int();
        this.max_count = _os_.unmarshal_int();
        this.container_id = _os_.unmarshal_byte();
        this.data = _os_.unmarshal_Octets();
        this.guid1 = _os_.unmarshal_int();
        this.guid2 = _os_.unmarshal_int();
        this.mask = _os_.unmarshal_int();
        this.proctype = _os_.unmarshal_int();
        this.reserved = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof GRoleInventory) {
            GRoleInventory _o_ = (GRoleInventory)_o1_;
            if (this.id != _o_.id) {
                return false;
            } else if (this.pos != _o_.pos) {
                return false;
            } else if (this.count != _o_.count) {
                return false;
            } else if (this.max_count != _o_.max_count) {
                return false;
            } else if (this.container_id != _o_.container_id) {
                return false;
            } else if (!this.data.equals(_o_.data)) {
                return false;
            } else if (this.guid1 != _o_.guid1) {
                return false;
            } else if (this.guid2 != _o_.guid2) {
                return false;
            } else if (this.mask != _o_.mask) {
                return false;
            } else if (this.proctype != _o_.proctype) {
                return false;
            } else {
                return this.reserved == _o_.reserved;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.id;
        _h_ += this.pos;
        _h_ += this.count;
        _h_ += this.max_count;
        _h_ += this.container_id;
        _h_ += this.data.hashCode();
        _h_ += this.guid1;
        _h_ += this.guid2;
        _h_ += this.mask;
        _h_ += this.proctype;
        _h_ += this.reserved;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.id).append(",");
        _sb_.append(this.pos).append(",");
        _sb_.append(this.count).append(",");
        _sb_.append(this.max_count).append(",");
        _sb_.append(this.container_id).append(",");
        _sb_.append("B").append(this.data.size()).append(",");
        _sb_.append(this.guid1).append(",");
        _sb_.append(this.guid2).append(",");
        _sb_.append(this.mask).append(",");
        _sb_.append(this.proctype).append(",");
        _sb_.append(this.reserved).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
