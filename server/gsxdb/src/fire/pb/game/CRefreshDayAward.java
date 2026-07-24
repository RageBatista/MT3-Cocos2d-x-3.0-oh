//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.fushi.FushiManager;
import fire.pb.main.ConfigManager;
import gnet.link.Dispatch;
import gnet.link.Onlines;
import java.util.Map;
import mkdb.Procedure;
import xbean.DailyInfo;
import xbean.TotalInfo;
import xtable.Dailyrecharge;
import xtable.Totalrecharge;

public class CRefreshDayAward extends __CRefreshDayAward__ {
    public static final int PROTOCOL_TYPE = 817971;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid > 0L) {
            final int userid = ((Dispatch)this.getContext()).userid;
            final Map<Integer, SDayReaward> SDayReawardConf = ConfigManager.getInstance().getConf(SDayReaward.class);
            final Map<Integer, STotalReaward> STotalReawardConf = ConfigManager.getInstance().getConf(STotalReaward.class);
            (new Procedure() {
                public boolean process() {
                    boolean res = FushiManager.subFushiFromUser(userid, roleid, 500000, 0, 0, 1999, YYLoggerTuJingEnum.GM, false);
                    if (!res) {
                        return true;
                    } else {
                        SOutRecharge sOutRecharge = new SOutRecharge();
                        long now = System.currentTimeMillis();
                        DailyInfo dailyInfo = Dailyrecharge.get(roleid);
                        if (dailyInfo != null) {
                            dailyInfo.setPaynum(0L);
                            dailyInfo.getDayrewardmap().clear();
                            dailyInfo.setTime(now);

                            for(SDayReaward value : SDayReawardConf.values()) {
                                if ((long)value.id < dailyInfo.getPaynum() && !dailyInfo.getDayrewardmap().containsKey(value.id)) {
                                    dailyInfo.getDayrewardmap().put(value.id, 0L);
                                }
                            }

                            sOutRecharge.pay = dailyInfo.getPaynum();
                            sOutRecharge.dayrewardmap.putAll(dailyInfo.getDayrewardmap());
                        }

                        TotalInfo totalInfo = Totalrecharge.get(roleid);
                        if (totalInfo != null) {
                            for(STotalReaward value : STotalReawardConf.values()) {
                                if ((long)value.id < totalInfo.getTotal() && !totalInfo.getTotalrewardmap().containsKey(value.id)) {
                                    totalInfo.getTotalrewardmap().put(value.id, 0L);
                                }
                            }

                            sOutRecharge.total = totalInfo.getTotal();
                            sOutRecharge.totalrewardmap.putAll(totalInfo.getTotalrewardmap());
                        }

                        Procedure.psendWhileCommit(roleid, sOutRecharge);
                        return true;
                    }
                }
            }).submit();
        }
    }

    public int getType() {
        return 817971;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream octetsStream) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return octetsStream;
        }
    }

    public OctetsStream unmarshal(OctetsStream octetsStream) throws MarshalException {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return octetsStream;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CRefreshDayAward) {
            CRefreshDayAward _o_ = (CRefreshDayAward)_o1_;
            return true;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        return _h_;
    }
}
