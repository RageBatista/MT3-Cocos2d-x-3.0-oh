//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class Bag implements Marshal {
    public HashMap<Byte, Long> currency;
    public int capacity;
    public ArrayList<Item> items;

    public Bag() {
        this.currency = new HashMap<>();
        this.items = new ArrayList<>();
    }

    public Bag(HashMap<Byte, Long> _currency_, int _capacity_, ArrayList<Item> _items_) {
        this.currency = _currency_;
        this.capacity = _capacity_;
        this.items = _items_;
    }

    public final boolean _validator_() {
        if (this.capacity < 0) {
            return false;
        } else {
            for(Item _v_ : this.items) {
                if (!_v_._validator_()) {
                    return false;
                }
            }

            return true;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.compact_uint32(this.currency.size());

        for(Map.Entry<Byte, Long> _e_ : this.currency.entrySet()) {
            _os_.marshal((Byte)_e_.getKey());
            _os_.marshal((Long)_e_.getValue());
        }

        _os_.marshal(this.capacity);
        _os_.compact_uint32(this.items.size());

        for(Item _v_ : this.items) {
            _os_.marshal(_v_);
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        for(int size = _os_.uncompact_uint32(); size > 0; --size) {
            byte _k_ = _os_.unmarshal_byte();
            long _v_ = _os_.unmarshal_long();
            this.currency.put(_k_, _v_);
        }

        this.capacity = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            Item _v_ = new Item();
            _v_.unmarshal(_os_);
            this.items.add(_v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof Bag) {
            Bag _o_ = (Bag)_o1_;
            if (!this.currency.equals(_o_.currency)) {
                return false;
            } else if (this.capacity != _o_.capacity) {
                return false;
            } else {
                return this.items.equals(_o_.items);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.currency.hashCode();
        _h_ += this.capacity;
        _h_ += this.items.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.currency).append(",");
        _sb_.append(this.capacity).append(",");
        _sb_.append(this.items).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}
