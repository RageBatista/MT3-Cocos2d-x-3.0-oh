//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.fushi.FushiManager;
import fire.pb.fushi.Module;
import fire.pb.item.Pack;
import fire.pb.talk.MessageMgr;
import gnet.link.Dispatch;
import gnet.link.Onlines;
import java.util.Arrays;
import mkdb.Procedure;
import xbean.YbNum;
import xbean.YbNums;
import xtable.Fushinum;

public class CExchangeCurrency extends __CExchangeCurrency__ {
    public static final int PROTOCOL_TYPE = 810653;
    public int srcmoneytype;
    public int dstmoneytype;
    public int money;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            final int userid = ((Dispatch)this.getContext()).userid;
            (new Procedure() {
                protected boolean process() throws Exception {
                    Pack bag = new Pack(roleid, false);
                    long ret = 0L;
                    int newMoney = 0;
                    if (CExchangeCurrency.this.srcmoneytype == 3) {
                        if (Module.GetPayServiceType() == 1) {
                            return false;
                        }

                        if (CExchangeCurrency.this.dstmoneytype == 1 && this.dealHearthStone()) {
                            newMoney = CExchangeCurrency.this.money * 10000;
                            ret = bag.addSysMoney((long)newMoney, "1符石兑换10000银币", YYLoggerTuJingEnum.tujing_Value_huobiduihuan, 0);
                            if (ret != 0L) {
                                MessageMgr.psendMsgNotify(roleid, 160402,Arrays.<String>asList(Integer.toString(CExchangeCurrency.this.money), Integer.toString(newMoney)));
                            }
                        } else if (CExchangeCurrency.this.dstmoneytype == 2 && this.dealHearthStone()) {
                            newMoney = CExchangeCurrency.this.money * 0;
                            ret = bag.addSysGold((long)newMoney, "1符石兑换0金币", YYLoggerTuJingEnum.tujing_Value_huobiduihuan, 0);
                            if (ret != 0L) {
                                ret = bag.addSysCurrency((long)((float)newMoney * Module.getCreditPointValue(9)), 13, "1符石兑换0金币", YYLoggerTuJingEnum.tujing_Value_huobiduihuan, 0);
                                MessageMgr.psendMsgNotify(roleid, 160403,Arrays.<String>asList(Integer.toString(CExchangeCurrency.this.money), Integer.toString(newMoney)));
                            }
                        }
                    } else if (CExchangeCurrency.this.srcmoneytype == 2 && this.dealGold()) {
                        newMoney = CExchangeCurrency.this.money * 100;
                        ret = bag.addSysMoney((long)newMoney, "1金币兑换100银币", YYLoggerTuJingEnum.tujing_Value_huobiduihuan, 0);
                        if (ret != 0L) {
                            MessageMgr.psendMsgNotify(roleid, 160404,Arrays.<String>asList(Integer.toString(CExchangeCurrency.this.money), Integer.toString(newMoney)));
                        }
                    }

                    return ret != 0L;
                }

                public boolean dealHearthStone() {
                    if (Module.getIsYYBUser(userid)) {
                        return FushiManager.subFushiFromUser(userid, roleid, CExchangeCurrency.this.money, 0, 0, 2000, YYLoggerTuJingEnum.tujing_Value_huobiduihuancost, true);
                    } else {
                        YbNums ybNums = Fushinum.get(userid);
                        if (ybNums == null) {
                            return false;
                        } else {
                            YbNum ybNum = (YbNum)ybNums.getRoleyb().get(roleid);
                            if (ybNum == null) {
                                return false;
                            } else {
                                return ybNum.getNum() >= 0 && ybNum.getSysnum() >= 0 ? FushiManager.subFushiFromUser(userid, roleid, CExchangeCurrency.this.money, 0, 0, 2000, YYLoggerTuJingEnum.tujing_Value_huobiduihuancost, true) : false;
                            }
                        }
                    }
                }

                public boolean dealGold() {
                    Pack bag = new Pack(roleid, false);
                    long ret = bag.subGold((long)(-CExchangeCurrency.this.money), "货币兑换", YYLoggerTuJingEnum.tujing_Value_huobiduihuancost, 0);
                    return ret != 0L;
                }
            }).submit();
        }
    }

    public int getType() {
        return 810653;
    }

    public CExchangeCurrency() {
    }

    public CExchangeCurrency(int _srcmoneytype_, int _dstmoneytype_, int _money_) {
        this.srcmoneytype = _srcmoneytype_;
        this.dstmoneytype = _dstmoneytype_;
        this.money = _money_;
    }

    public final boolean _validator_() {
        if (this.srcmoneytype >= 1 && this.srcmoneytype <= 10) {
            if (this.dstmoneytype >= 1 && this.dstmoneytype <= 10) {
                return this.money >= 1;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.srcmoneytype);
            _os_.marshal(this.dstmoneytype);
            _os_.marshal(this.money);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.srcmoneytype = _os_.unmarshal_int();
        this.dstmoneytype = _os_.unmarshal_int();
        this.money = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CExchangeCurrency) {
            CExchangeCurrency _o_ = (CExchangeCurrency)_o1_;
            if (this.srcmoneytype != _o_.srcmoneytype) {
                return false;
            } else if (this.dstmoneytype != _o_.dstmoneytype) {
                return false;
            } else {
                return this.money == _o_.money;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.srcmoneytype;
        _h_ += this.dstmoneytype;
        _h_ += this.money;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.srcmoneytype).append(",");
        _sb_.append(this.dstmoneytype).append(",");
        _sb_.append(this.money).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CExchangeCurrency _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.srcmoneytype - _o_.srcmoneytype;
            if (_c_ != 0) {
                return _c_;
            } else {
                _c_ = this.dstmoneytype - _o_.dstmoneytype;
                if (_c_ != 0) {
                    return _c_;
                } else {
                    _c_ = this.money - _o_.money;
                    return _c_ != 0 ? _c_ : _c_;
                }
            }
        }
    }
}
