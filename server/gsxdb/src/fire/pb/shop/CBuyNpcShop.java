//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.PropRole;
import fire.pb.npc.NpcManager;
import fire.pb.shop.srv.BuyShopFactory;
import fire.pb.shop.utils.ShopParameters;
import gnet.link.Onlines;
import gnet.link.Role;
import mkdb.Trace;

public class CBuyNpcShop extends __CBuyNpcShop__ {
    public static final int PROTOCOL_TYPE = 810633;
    public int shopid;
    public int goodsid;
    public int num;
    public int buytype;

    protected void process() {
        Role role = Onlines.getInstance().find(this);
        if (role != null) {
            SGoods goods = (SGoods)Module.sGoodsMap.get(this.goodsid);
            if (null == goods) {
                Trace.info("没有该商品[" + this.goodsid + "]");
            } else {
                if (this.buytype == 1) {
                    SNpcSale ns = NpcManager.getInstance().getNpcSale(this.shopid);
                    if (ns == null || !ns.getGoodsids().contains(this.goodsid)) {
                        Trace.info("NPC并不出售该物品.shopid:" + this.shopid + "goodsid:" + this.goodsid);
                        return;
                    }
                }

                ShopParameters params = new ShopParameters();
                params.role = new PropRole(role.getRoleid(), true);
                params.goods = goods;
                params.num = this.num;
                params.shopId = this.shopid;
                (new BuyShopFactory(params, this.buytype)).submit();
            }
        }
    }

    public int getType() {
        return 810633;
    }

    public CBuyNpcShop() {
    }

    public CBuyNpcShop(int _shopid_, int _goodsid_, int _num_, int _buytype_) {
        this.shopid = _shopid_;
        this.goodsid = _goodsid_;
        this.num = _num_;
        this.buytype = _buytype_;
    }

    public final boolean _validator_() {
        if (this.shopid < 1) {
            return false;
        } else if (this.goodsid < 0) {
            return false;
        } else if (this.num < 1) {
            return false;
        } else {
            return this.buytype >= 0 && this.buytype <= 11;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.shopid);
            _os_.marshal(this.goodsid);
            _os_.marshal(this.num);
            _os_.marshal(this.buytype);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.shopid = _os_.unmarshal_int();
        this.goodsid = _os_.unmarshal_int();
        this.num = _os_.unmarshal_int();
        this.buytype = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CBuyNpcShop) {
            CBuyNpcShop _o_ = (CBuyNpcShop)_o1_;
            if (this.shopid != _o_.shopid) {
                return false;
            } else if (this.goodsid != _o_.goodsid) {
                return false;
            } else if (this.num != _o_.num) {
                return false;
            } else {
                return this.buytype == _o_.buytype;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.shopid;
        _h_ += this.goodsid;
        _h_ += this.num;
        _h_ += this.buytype;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.shopid).append(",");
        _sb_.append(this.goodsid).append(",");
        _sb_.append(this.num).append(",");
        _sb_.append(this.buytype).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CBuyNpcShop _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.shopid - _o_.shopid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.goodsid - _o_.goodsid;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.num - _o_.num;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.buytype - _o_.buytype;
                        return 0 != _c_ ? _c_ : _c_;
                    }
                }
            }
        }
    }
}
