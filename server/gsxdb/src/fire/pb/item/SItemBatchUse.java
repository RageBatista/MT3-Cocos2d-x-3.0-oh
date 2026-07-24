//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SItemBatchUse extends __SItemBatchUse__ {
    public static final int PROTOCOL_TYPE = 787456;
    public int itemid;
    public int maxbatchcount;
    public int batchtype;
    public String description;

    public SItemBatchUse() {
    }

    public SItemBatchUse(int _itemid_, int _maxbatchcount_, int _batchtype_, String _description_) {
        this.itemid = _itemid_;
        this.maxbatchcount = _maxbatchcount_;
        this.batchtype = _batchtype_;
        this.description = _description_;
    }

    public int getItemid() {
        return this.itemid;
    }

    public void setItemid(int itemid) {
        this.itemid = itemid;
    }

    public int getMaxbatchcount() {
        return this.maxbatchcount;
    }

    public void setMaxbatchcount(int maxbatchcount) {
        this.maxbatchcount = maxbatchcount;
    }

    public int getBatchtype() {
        return this.batchtype;
    }

    public void setBatchtype(int batchtype) {
        this.batchtype = batchtype;
    }

    public String getDescription() {
        return this.description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public final boolean _validator_() {
        if (this.itemid <= 0) {
            return false;
        } else if (this.maxbatchcount <= 0) {
            return false;
        } else {
            return this.batchtype >= 0;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.itemid);
            _os_.marshal(this.maxbatchcount);
            _os_.marshal(this.batchtype);
            _os_.marshal(this.description);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.itemid = _os_.unmarshal_int();
        this.maxbatchcount = _os_.unmarshal_int();
        this.batchtype = _os_.unmarshal_int();
        this.description = _os_.unmarshal_String();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SItemBatchUse) {
            SItemBatchUse _o_ = (SItemBatchUse)_o1_;
            if (this.itemid != _o_.itemid) {
                return false;
            } else if (this.maxbatchcount != _o_.maxbatchcount) {
                return false;
            } else {
                return this.batchtype != _o_.batchtype ? false : this.description.equals(_o_.description);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.itemid;
        _h_ += this.maxbatchcount;
        _h_ += this.batchtype;
        _h_ += this.description.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.itemid).append(",");
        _sb_.append(this.maxbatchcount).append(",");
        _sb_.append(this.batchtype).append(",");
        _sb_.append(this.description).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int getType() {
        return 787456;
    }
}
