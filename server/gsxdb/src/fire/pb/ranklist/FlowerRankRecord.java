//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.ranklist;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.Map;

public class FlowerRankRecord implements Marshal {
    public int rank;
    public long roleid;
    public String rolename;
    public int school;
    public long num;
    public int shape;
    public int color1;
    public int color2;
    public Map<Character, Integer> components;

    public FlowerRankRecord() {
        this.rolename = "";
        this.components = new HashMap();
    }

    public FlowerRankRecord(int _rank_, long _roleid_, String _rolename_, int _school_, long _num_, int _shape_, int _color1_, int _color2_, Map<Character, Integer> _components_) {
        this.rank = _rank_;
        this.roleid = _roleid_;
        this.rolename = _rolename_;
        this.school = _school_;
        this.num = _num_;
        this.shape = _shape_;
        this.color1 = _color1_;
        this.color2 = _color2_;
        this.components = _components_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.rank);
        _os_.marshal(this.roleid);
        _os_.marshal(this.rolename, "UTF-16LE");
        _os_.marshal(this.school);
        _os_.marshal(this.num);
        _os_.marshal(this.shape);
        _os_.marshal(this.color1);
        _os_.marshal(this.color2);
        _os_.compact_uint32(this.components.size());

        for(Map.Entry<Character, Integer> entry : this.components.entrySet()) {
            _os_.marshal((Character)entry.getKey());
            _os_.marshal((Integer)entry.getValue());
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.rank = _os_.unmarshal_int();
        this.roleid = _os_.unmarshal_long();
        this.rolename = _os_.unmarshal_String("UTF-16LE");
        this.school = _os_.unmarshal_int();
        this.num = _os_.unmarshal_long();
        this.shape = _os_.unmarshal_int();
        this.color1 = _os_.unmarshal_int();
        this.color2 = _os_.unmarshal_int();
        int componentsSize = _os_.uncompact_uint32();
        this.components = new HashMap(componentsSize);

        for(int i = 0; i < componentsSize; ++i) {
            char key = _os_.unmarshal_char();
            int value = _os_.unmarshal_int();
            this.components.put(key, value);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof FlowerRankRecord) {
            FlowerRankRecord _o_ = (FlowerRankRecord)_o1_;
            return this.rank == _o_.rank && this.roleid == _o_.roleid && this.rolename.equals(_o_.rolename) && this.school == _o_.school && this.num == _o_.num && this.shape == _o_.shape && this.color1 == _o_.color1 && this.color2 == _o_.color2 && this.components.equals(_o_.components);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.rank;
        _h_ += (int)this.roleid;
        _h_ += this.rolename.hashCode();
        _h_ += this.school;
        _h_ += (int)this.num;
        _h_ += this.shape;
        _h_ += this.color1;
        _h_ += this.color2;
        _h_ += this.components.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.rank).append(",");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.rolename.length()).append(",");
        _sb_.append(this.school).append(",");
        _sb_.append(this.num).append(",");
        _sb_.append(this.shape).append(",");
        _sb_.append(this.color1).append(",");
        _sb_.append(this.color2).append(",");
        _sb_.append(this.components.toString()).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
