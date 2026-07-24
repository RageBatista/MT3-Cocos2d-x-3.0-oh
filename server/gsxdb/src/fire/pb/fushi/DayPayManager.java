//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.msp.role.GSetNoPayDayState;
import fire.pb.GsClient;
import fire.pb.fushi.payday.SConsumeDayPay;
import fire.pb.fushi.payday.SHaveDayPay;
import fire.pb.fushi.payday.SQueryConsumeDayPay;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import fire.pb.team.PQuitTeamProc;
import fire.pb.team.TeamManager;
import fire.pb.util.DateValidate;
import java.util.Calendar;
import java.util.List;
import mkdb.Procedure;
import mkdb.Transaction;
import org.apache.log4j.Logger;
import xbean.Properties;
import xbean.User;
import xbean.subscription;
import xtable.Subscriptions;

public class DayPayManager {
    public static final Logger logger = Logger.getLogger("DayPay");
    private static DayPayManager instance = new DayPayManager();
    public static int daypayLevel = 0;
    public static int promptLevel = 30;
    public static long adddaypatime = 1200000L;

    public static DayPayManager getInstance() {
        return instance;
    }

    public void ProcessDayPay(int userId, final long roleid) {
        Procedure proc = new Procedure() {
            protected boolean process() throws Exception {
                Properties prop = xtable.Properties.select(roleid);
                if (prop != null && prop.getLevel() >= DayPayManager.daypayLevel) {
                    boolean ok = DayPayManager.getInstance().CheckDayPay(roleid, 0L);
                    if (!ok) {
                        boolean suc = DayPayManager.getInstance().CostDayPay(prop.getUserid(), roleid);
                        if (suc) {
                            MonthCardManager.getInstance().ModifyDayPayMonthCard(prop.getUserid(), roleid);
                        }
                    }
                }

                return true;
            }
        };
        if (Transaction.current() != null) {
            Procedure.pexecuteWhileCommit(proc);
        } else {
            proc.submit();
        }

    }

    public boolean CheckDayPay(long roleid, long delay) {
        long cur = System.currentTimeMillis();
        subscription sub = Subscriptions.select(roleid);
        if (sub != null && sub.getExpiretime() > 0L && cur < sub.getExpiretime()) {
            return true;
        } else {
            if (sub != null && sub.getExpiretime() > 0L && cur >= sub.getExpiretime()) {
                if (DateValidate.inTheSameDay(sub.getExpiretime(), cur)) {
                    return true;
                }

                if (delay != 0L) {
                    Calendar cal = Calendar.getInstance();
                    cal.setTimeInMillis(sub.getExpiretime());
                    cal.set(11, 23);
                    cal.set(12, 59);
                    cal.set(13, 59);
                    cal.set(14, 999);
                    long time = cal.getTimeInMillis();
                    if (cur < time + delay) {
                        return true;
                    }
                }
            }

            Properties prop = xtable.Properties.select(roleid);
            if (prop == null) {
                return false;
            } else {
                return cur <= prop.getExpiretime() + delay;
            }
        }
    }

    public boolean CheckDayPayWithLevel(long roleid) {
        Properties prop = xtable.Properties.select(roleid);
        if (prop != null) {
            return prop.getLevel() >= daypayLevel ? this.CheckDayPay(roleid, adddaypatime) : true;
        } else {
            return false;
        }
    }

    public boolean CheckFree(int level) {
        return level < daypayLevel;
    }

    public boolean CheckTrade(long roleid, int level) {
        boolean free = this.CheckFree(level);
        return free ? false : this.CheckDayPayWithLevel(roleid);
    }

    public boolean CostDayPay(int userid, long roleid) {
        User user = xtable.User.get(userid);
        if (user == null) {
            return false;
        } else {
            Properties prop = xtable.Properties.get(roleid);
            if (prop == null) {
                return false;
            } else {
                long cur = System.currentTimeMillis();
                subscription sub = Subscriptions.get(roleid);
                if (sub != null && sub.getExpiretime() > 0L && cur < sub.getExpiretime()) {
                    FushiManager.logger.info("CostDayPay[" + roleid + "]已经订阅游戏,到期时间:[" + sub.getExpiretime() + "].");
                    return false;
                } else if (sub != null && sub.getExpiretime() > 0L && cur >= sub.getExpiretime() && DateValidate.inTheSameDay(sub.getExpiretime(), cur)) {
                    FushiManager.logger.info("CostDayPay[" + roleid + "]订阅游戏今天已经到期,但今天不扣符石.");
                    return false;
                } else if (cur <= prop.getExpiretime()) {
                    return false;
                } else {
                    SCommonDayPay c = (SCommonDayPay)ConfigManager.getInstance().getConf(SCommonDayPay.class).get(1);
                    boolean ok = false;
                    boolean first = false;
                    if (prop.getFirstprompt() == 0) {
                        SQueryConsumeDayPay msg1 = new SQueryConsumeDayPay();
                        Procedure.psendWhileCommit(roleid, msg1);
                        prop.setFirstprompt(1);
                        ok = false;
                        first = true;
                    } else if (!ConfigManager.FUSHI_2_DAYPAY) {
                        FushiManager.logger.info("CostDayPay[" + roleid + "],本服务器关闭了符石买点卡.");
                    } else {
                        ok = FushiManager.subFushiFromUser(userid, roleid, c.serverdata, 0, 0, 2003, YYLoggerTuJingEnum.tujing_Value_daypa, true);
                    }

                    SHaveDayPay msg = new SHaveDayPay();
                    if (ok) {
                        Calendar cal = Calendar.getInstance();
                        cal.set(11, 23);
                        cal.set(12, 59);
                        cal.set(13, 59);
                        cal.set(14, 999);
                        prop.setExpiretime(cal.getTimeInMillis());
                        msg.daypay = 1;
                        GsClient.pSendWhileCommit(new GSetNoPayDayState(roleid, (byte)0));
                    } else {
                        msg.daypay = 0;
                        GsClient.pSendWhileCommit(new GSetNoPayDayState(roleid, (byte)1));
                        Procedure.pexecuteWhileCommit(new PQuitTeamProc(roleid));
                        TeamManager.getInstance().delTeamMatchAsyn(roleid);
                    }

                    if (!first) {
                        Procedure.psendWhileCommit(roleid, msg);
                    }

                    if (ok) {
                        SConsumeDayPay msg1 = new SConsumeDayPay();
                        Procedure.psendWhileCommit(roleid, msg1);
                        FushiManager.logger.info("CostDayPay[" + roleid + "]: 扣除点卡成功:[" + c.serverdata + "]");
                    } else {
                        FushiManager.logger.info("CostDayPay[" + roleid + "]: 扣除点卡失败:[" + c.serverdata + "]");
                    }

                    return ok;
                }
            }
        }
    }

    public boolean haveSubscribeAndNoExpire(long roleid) {
        subscription sub = Subscriptions.select(roleid);
        if (sub != null) {
            long cur = System.currentTimeMillis();
            if (cur < sub.getExpiretime()) {
                return true;
            }

            if (DateValidate.inTheSameDay(sub.getExpiretime(), cur)) {
                return true;
            }
        }

        return false;
    }

    public void Prompt(final long roleid) {
        Procedure proc = new Procedure() {
            protected boolean process() throws Exception {
                Properties prop = xtable.Properties.select(roleid);
                if (prop != null && prop.getLevel() >= DayPayManager.promptLevel && prop.getLevel() < DayPayManager.daypayLevel) {
                    MessageMgr.sendMsgNotify(roleid, 162172, (List)null);
                }

                return true;
            }
        };
        if (Transaction.current() != null) {
            Procedure.pexecuteWhileCommit(proc);
        } else {
            proc.submit();
        }

    }

    public void CostDayPayPrompt(final long roleid) {
        Procedure proc = new Procedure() {
            protected boolean process() throws Exception {
                Properties prop = xtable.Properties.get(roleid);
                if (prop != null && prop.getLevel() == DayPayManager.promptLevel && prop.getFirstprompt() == 0) {
                    SQueryConsumeDayPay msg1 = new SQueryConsumeDayPay();
                    Procedure.psendWhileCommit(roleid, msg1);
                    prop.setFirstprompt(1);
                }

                return true;
            }
        };
        if (Transaction.current() != null) {
            Procedure.pexecuteWhileCommit(proc);
        } else {
            proc.submit();
        }

    }
}
