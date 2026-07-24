//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.item.Pack;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import fire.pb.util.BagUtil;
import fire.pb.util.DateValidate;
import gnet.link.Onlines;
import java.util.Arrays;
import java.util.Map;
import mkdb.Procedure;
import xbean.DailyInfo;
import xbean.TotalInfo;
import xtable.Dailyrecharge;
import xtable.Totalrecharge;

public class CReceiveReward extends __CReceiveReward__ {
    public static final int PROTOCOL_TYPE = 817969;
    public int rewardid;
    public int reawardType;

    protected void process() {
        final long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId != -1L) {
            final int rewardId = this.rewardid;
            final int reawardType = this.reawardType;
            final Map<Integer, SDayReaward> SDayReawardConf = ConfigManager.getInstance().getConf(SDayReaward.class);
            final Map<Integer, STotalReaward> STotalReawardConf = ConfigManager.getInstance().getConf(STotalReaward.class);
            (new Procedure() {
                public boolean process() {
                    long now = System.currentTimeMillis();
                    SOutRecharge sOutRecharge = new SOutRecharge();
                    DailyInfo dailyInfo = Dailyrecharge.get(roleId);
                    TotalInfo totalInfo = Totalrecharge.get(roleId);
                    if (reawardType == 1) {
                        if (dailyInfo == null) {
                            return false;
                        }

                        if (!DateValidate.inTheSameDay(dailyInfo.getTime(), now)) {
                            dailyInfo.setPaynum(0L);
                            dailyInfo.setTime(now);
                            dailyInfo.getDayrewardmap().clear();
                            sOutRecharge.pay = dailyInfo.getPaynum();
                            sOutRecharge.dayrewardmap.putAll(dailyInfo.getDayrewardmap());
                        } else {
                            Map<Integer, Long> dayrewardmap = dailyInfo.getDayrewardmap();
                            if (dayrewardmap == null) {
                                System.out.println("非法操作，今日没有充值，领取失败");
                                return false;
                            }

                            if (!dayrewardmap.containsKey(rewardId)) {
                                System.out.println("非法操作，今日充值等级不足，领取失败");
                                return false;
                            }

                            if ((Long)dayrewardmap.get(rewardId) != 0L) {
                                System.out.println("当前等级已经领取过了");
                                return false;
                            }

                            SDayReaward sDayReaward = (SDayReaward)SDayReawardConf.get(rewardId);
                            if (sDayReaward == null) {
                                return false;
                            }

                            Pack itemBag = new Pack(roleId, false);
                            int emptyVolume = itemBag.getFreepos().size();
                            if (emptyVolume < sDayReaward.needcapacity) {
                                MessageMgr.sendMsgNotify(roleId, 141095,Arrays.<String>asList(String.valueOf(sDayReaward.needcapacity)));
                                System.out.println("空间不足");
                                return false;
                            }

                            int item1id = sDayReaward.item1id;
                            int item1num = sDayReaward.item1num;
                            int item2id = sDayReaward.item2id;
                            int item2num = sDayReaward.item2num;
                            int item3id = sDayReaward.item3id;
                            int item3num = sDayReaward.item3num;
                            if (BagUtil.addItem(roleId, item1id, item1num, "每日充值", YYLoggerTuJingEnum.tujing_Value_xitongzengsong, item1id) != item1num) {
                                return false;
                            }

                            if (BagUtil.addItem(roleId, item2id, item2num, "每日充值", YYLoggerTuJingEnum.tujing_Value_xitongzengsong, item2id) != item2num) {
                                return false;
                            }

                            if (BagUtil.addItem(roleId, item3id, item3num, "每日充值", YYLoggerTuJingEnum.tujing_Value_xitongzengsong, item3id) != item3num) {
                                return false;
                            }

                            dailyInfo.getDayrewardmap().put(rewardId, now);
                        }
                    }

                    if (reawardType == 3) {
                        if (totalInfo == null) {
                            return false;
                        }

                        Map<Integer, Long> totalrewardmap = totalInfo.getTotalrewardmap();
                        if (totalrewardmap == null) {
                            System.out.println("非法操作，今日没有充值，领取失败");
                            return false;
                        }

                        if (!totalrewardmap.containsKey(rewardId)) {
                            System.out.println("非法操作，今日充值等级不足，领取失败");
                            return false;
                        }

                        if ((Long)totalrewardmap.get(rewardId) != 0L) {
                            System.out.println("当前等级已经领取过了");
                            return false;
                        }

                        STotalReaward sTotalReaward = (STotalReaward)STotalReawardConf.get(rewardId);
                        if (sTotalReaward == null) {
                            return false;
                        }

                        Pack itemBag = new Pack(roleId, false);
                        int emptyVolume = itemBag.getFreepos().size();
                        if (emptyVolume < sTotalReaward.needcapacity) {
                            MessageMgr.sendMsgNotify(roleId, 141095,Arrays.<String>asList(String.valueOf(sTotalReaward.needcapacity)));
                            System.out.println("空间不足");
                            return false;
                        }

                        int item1id = sTotalReaward.item1id;
                        int item1num = sTotalReaward.item1num;
                        int item2id = sTotalReaward.item2id;
                        int item2num = sTotalReaward.item2num;
                        int item3id = sTotalReaward.item3id;
                        int item3num = sTotalReaward.item3num;
                        if (BagUtil.addItem(roleId, item1id, item1num, "每日充值", YYLoggerTuJingEnum.tujing_Value_xitongzengsong, item1id) != item1num) {
                            return false;
                        }

                        if (BagUtil.addItem(roleId, item2id, item2num, "每日充值", YYLoggerTuJingEnum.tujing_Value_xitongzengsong, item2id) != item2num) {
                            return false;
                        }

                        if (BagUtil.addItem(roleId, item3id, item3num, "每日充值", YYLoggerTuJingEnum.tujing_Value_xitongzengsong, item3id) != item3num) {
                            return false;
                        }

                        totalInfo.getTotalrewardmap().put(rewardId, now);
                    }

                    if (dailyInfo != null) {
                        sOutRecharge.pay = dailyInfo.getPaynum();
                        sOutRecharge.dayrewardmap.putAll(dailyInfo.getDayrewardmap());
                    }

                    if (totalInfo != null) {
                        sOutRecharge.total = totalInfo.getTotal();
                        sOutRecharge.totalrewardmap.putAll(totalInfo.getTotalrewardmap());
                    }

                    Procedure.psendWhileCommit(roleId, sOutRecharge);
                    return true;
                }
            }).submit();
        }
    }

    public int getType() {
        return 817969;
    }

    public CReceiveReward() {
    }

    public CReceiveReward(int _rewardid_, int _reawardType_) {
        this.rewardid = _rewardid_;
        this.reawardType = _reawardType_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.rewardid);
            _os_.marshal(this.reawardType);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.rewardid = _os_.unmarshal_int();
        this.reawardType = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CReceiveReward) {
            CReceiveReward _o_ = (CReceiveReward)_o1_;
            if (this.rewardid != _o_.rewardid) {
                return false;
            } else {
                return this.reawardType == _o_.reawardType;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.rewardid;
        _h_ += this.reawardType;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.rewardid).append(",");
        _sb_.append(this.reawardType).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CReceiveReward _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.rewardid - _o_.rewardid;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}
