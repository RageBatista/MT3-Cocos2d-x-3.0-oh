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

public class RoleZongheRankRecord implements Marshal {
    public long roleid;
    public String nickname;
    public int level;
    public int school;
    public int rank;
    public int shape;
    public int color1;
    public int color2;
    public Map<Character, Integer> components;

    public RoleZongheRankRecord() {
        this.nickname = "";
        this.components = new HashMap();
    }

    public RoleZongheRankRecord(long _roleid_, String _nickname_, int _level_, int _school_, int _rank_, int _shape_, int _color1_, int _color2_, Map<Character, Integer> _components_) {
        this.roleid = _roleid_;
        this.nickname = _nickname_;
        this.level = _level_;
        this.school = _school_;
        this.rank = _rank_;
        this.shape = _shape_;
        this.color1 = _color1_;
        this.color2 = _color2_;
        this.components = _components_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.nickname, "UTF-16LE");
        _os_.marshal(this.level);
        _os_.marshal(this.school);
        _os_.marshal(this.rank);
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
        this.roleid = _os_.unmarshal_long();
        this.nickname = _os_.unmarshal_String("UTF-16LE");
        this.level = _os_.unmarshal_int();
        this.school = _os_.unmarshal_int();
        this.rank = _os_.unmarshal_int();
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
        } else if (_o1_ instanceof RoleZongheRankRecord) {
            RoleZongheRankRecord _o_ = (RoleZongheRankRecord)_o1_;
            return this.roleid == _o_.roleid && this.nickname.equals(_o_.nickname) && this.level == _o_.level && this.school == _o_.school && this.rank == _o_.rank && this.shape == _o_.shape && this.color1 == _o_.color1 && this.color2 == _o_.color2 && this.components.equals(_o_.components);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.nickname.hashCode();
        _h_ += this.level;
        _h_ += this.school;
        _h_ += this.rank;
        _h_ += this.shape;
        _h_ += this.color1;
        _h_ += this.color2;
        _h_ += this.components.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append("T").append(this.nickname.length()).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.school).append(",");
        _sb_.append(this.rank).append(",");
        _sb_.append(this.shape).append(",");
        _sb_.append(this.color1).append(",");
        _sb_.append(this.color2).append(",");
        _sb_.append(this.components.toString()).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
