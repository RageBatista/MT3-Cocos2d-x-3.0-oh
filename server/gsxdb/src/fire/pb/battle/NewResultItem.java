//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;

public class NewResultItem implements Marshal {
    public DemoExecute execute;
    public LinkedList<NewSubResultItem> subresultlist;
    public LinkedList<FighterInfo> newfighter;
    public HashMap<Integer, Float> rolechangedattrs;
    public HashMap<Integer, Float> petchangedattrs;

    public NewResultItem() {
        this.execute = new DemoExecute();
        this.subresultlist = new LinkedList<>();
        this.newfighter = new LinkedList<>();
        this.rolechangedattrs = new HashMap<>();
        this.petchangedattrs = new HashMap<>();
    }

    public NewResultItem(DemoExecute _execute_, LinkedList<NewSubResultItem> _subresultlist_, LinkedList<FighterInfo> _newfighter_, HashMap<Integer, Float> _rolechangedattrs_, HashMap<Integer, Float> _petchangedattrs_) {
        this.execute = _execute_;
        this.subresultlist = _subresultlist_;
        this.newfighter = _newfighter_;
        this.rolechangedattrs = _rolechangedattrs_;
        this.petchangedattrs = _petchangedattrs_;
    }

    public final boolean _validator_() {
        if (!this.execute._validator_()) {
            return false;
        } else {
            for(NewSubResultItem _v_ : this.subresultlist) {
                if (!_v_._validator_()) {
                    return false;
                }
            }

            for(FighterInfo _v_ : this.newfighter) {
                if (!_v_._validator_()) {
                    return false;
                }
            }

            return true;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.execute);
        _os_.compact_uint32(this.subresultlist.size());

        for(NewSubResultItem _v_ : this.subresultlist) {
            _os_.marshal(_v_);
        }

        _os_.compact_uint32(this.newfighter.size());

        for(FighterInfo _v_ : this.newfighter) {
            _os_.marshal(_v_);
        }

        _os_.compact_uint32(this.rolechangedattrs.size());

        for(Map.Entry<Integer, Float> _e_ : this.rolechangedattrs.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Float)_e_.getValue());
        }

        _os_.compact_uint32(this.petchangedattrs.size());

        for(Map.Entry<Integer, Float> _e_ : this.petchangedattrs.entrySet()) {
            _os_.marshal((Integer)_e_.getKey());
            _os_.marshal((Float)_e_.getValue());
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.execute.unmarshal(_os_);

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            NewSubResultItem _v_ = new NewSubResultItem();
            _v_.unmarshal(_os_);
            this.subresultlist.add(_v_);
        }

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            FighterInfo _v_ = new FighterInfo();
            _v_.unmarshal(_os_);
            this.newfighter.add(_v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            float _v_ = _os_.unmarshal_float();
            this.rolechangedattrs.put(_k_, _v_);
        }

        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            int _k_ = _os_.unmarshal_int();
            float _v_ = _os_.unmarshal_float();
            this.petchangedattrs.put(_k_, _v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof NewResultItem) {
            NewResultItem _o_ = (NewResultItem)_o1_;
            if (!this.execute.equals(_o_.execute)) {
                return false;
            } else if (!this.subresultlist.equals(_o_.subresultlist)) {
                return false;
            } else if (!this.newfighter.equals(_o_.newfighter)) {
                return false;
            } else if (!this.rolechangedattrs.equals(_o_.rolechangedattrs)) {
                return false;
            } else {
                return this.petchangedattrs.equals(_o_.petchangedattrs);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.execute.hashCode();
        _h_ += this.subresultlist.hashCode();
        _h_ += this.newfighter.hashCode();
        _h_ += this.rolechangedattrs.hashCode();
        _h_ += this.petchangedattrs.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.execute).append(",");
        _sb_.append(this.subresultlist).append(",");
        _sb_.append(this.newfighter).append(",");
        _sb_.append(this.rolechangedattrs).append(",");
        _sb_.append(this.petchangedattrs).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
