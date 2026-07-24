//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.shop.srv.BuyMallShop;
import gnet.link.Dispatch;
import gnet.link.Onlines;
import mkdb.Procedure;

public class CBuyMallShop extends __CBuyMallShop__ {
    public static final int PROTOCOL_TYPE = 810632;
    public int shopid;
    public int taskid;
    public int goodsid;
    public int num;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            final int userid = ((Dispatch)this.getContext()).userid;
            (new Procedure() {
                protected boolean process() throws Exception {
                    return (new BuyMallShop(roleid, userid, CBuyMallShop.this.goodsid, CBuyMallShop.this.num, false)).exc();
                }
            }).submit();
        }
    }

    public int getType() {
        return 810632;
    }

    public CBuyMallShop() {
    }

    public CBuyMallShop(int _shopid_, int _taskid_, int _goodsid_, int _num_) {
        this.shopid = _shopid_;
        this.taskid = _taskid_;
        this.goodsid = _goodsid_;
        this.num = _num_;
    }

    public final boolean _validator_() {
        return this.num >= 0;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.shopid);
            _os_.marshal(this.taskid);
            _os_.marshal(this.goodsid);
            _os_.marshal(this.num);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.shopid = _os_.unmarshal_int();
        this.taskid = _os_.unmarshal_int();
        this.goodsid = _os_.unmarshal_int();
        this.num = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CBuyMallShop) {
            CBuyMallShop _o_ = (CBuyMallShop)_o1_;
            if (this.shopid != _o_.shopid) {
                return false;
            } else if (this.taskid != _o_.taskid) {
                return false;
            } else if (this.goodsid != _o_.goodsid) {
                return false;
            } else {
                return this.num == _o_.num;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.shopid;
        _h_ += this.taskid;
        _h_ += this.goodsid;
        _h_ += this.num;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.shopid).append(",");
        _sb_.append(this.taskid).append(",");
        _sb_.append(this.goodsid).append(",");
        _sb_.append(this.num).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CBuyMallShop _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.shopid - _o_.shopid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.taskid - _o_.taskid;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.goodsid - _o_.goodsid;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.num - _o_.num;
                        return 0 != _c_ ? _c_ : _c_;
                    }
                }
            }
        }
    }
}
