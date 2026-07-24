//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi;

import com.locojoy.base.Marshal.OctetsStream;
import fire.log.YYLogger;
import fire.log.beans.ItemBean;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.fushi.spotcheck.SpotCheckManage;
import fire.pb.item.Pack;
import fire.pb.main.ConfigManager;
import fire.pb.main.Gs;
import fire.pb.statistics.StatisticUtil;
import fire.pb.talk.MessageMgr;
import fire.pb.util.DateValidate;
import fire.pb.util.FireProp;
import gnet.MerchantDiscount;
import gnet.link.Onlines;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.NavigableMap;
import java.util.TreeMap;
import java.util.concurrent.TimeUnit;
import mkdb.Executor;
import mkdb.Procedure;
import mkdb.TTable;
import mkdb.Transaction;
import org.apache.http.client.methods.HttpGet;
import org.apache.log4j.Logger;
import xbean.AUUserInfo;
import xbean.ChargeOrder;
import xbean.PlatformInfo;
import xbean.Pod;
import xbean.RoleDoubleChareInfo;
import xbean.YbNum;
import xbean.YbNums;
import xbean.YingYongBao;
import xbean.YybFushiNum;
import xbean.YybFushiNums;
import xtable.Auuserinfo;
import xtable.Chargeorder;
import xtable.Fushinum;
import xtable.Payplatform;
import xtable.Yingyongbaoinfos;
import xtable.Yybfushi;

public class FushiManager {
    public static final int MAX_NUM = 1999999999;
    public static long FIRST_CHARGE_START_TIME = 0L;
    public static long MULTICHARGE_CHARGE_START_TIME = 0L;
    public static long FIRST_CHARGE_CLEAR_PRESENT_START_TIME = 0L;
    public static String YYBAddress = "";
    public static String YYBGet = "";
    public static String YYBAdd = "";
    public static String YYBSub = "";
    public static Integer YYBOp = 0;
    public static final Logger logger = Logger.getLogger("RECHARGE");
    public static final Logger warnlogger = Logger.getLogger("FUSHIWARN");
    private static FushiManager instance = new FushiManager();
    public Map<String, Map<Integer, LinkedList<GoodInfo>>> goodListMap = new HashMap();
    private static Map<Integer, Integer> yybGenBalance = new TreeMap(new Comparator<Integer>() {
        public int compare(Integer key1, Integer key2) {
            return key2 - key1;
        }
    });
    public static Map<Integer, Integer> shouchongMap = new HashMap();
    public static float returnRatio = 1.2F;
    public static int returnZoneId = 0;

    public static FushiManager getInstance() {
        return instance;
    }

    public void init() throws Exception {
        final boolean isdirect = ConfigManager.getChargeDirect();
        (new Procedure() {
            protected boolean process() throws Exception {
                if (isdirect) {
                    FushiManager.logger.info("乐动TCP方式直接回调!");
                } else {
                    final List<Long> keys = new ArrayList();
                    Chargeorder.getTable().walk(new TTable.IWalk<Long, ChargeOrder>() {
                        public boolean onRecord(Long k, ChargeOrder v) {
                            keys.add(k);
                            return true;
                        }
                    });

                    for(Long gameSn : keys) {
                        Executor.getInstance().schedule(new CheckCharge(gameSn), 2L, TimeUnit.MINUTES);
                    }
                }

                return true;
            }
        }).submit();
        this.initChargeGoodList();
        Module.initCreditPoint();
        DayPayManager.daypayLevel = ((SCommonDayPay)ConfigManager.getInstance().getConf(SCommonDayPay.class).get(3)).serverdata;
        SCommonDayPay c = (SCommonDayPay)ConfigManager.getInstance().getConf(SCommonDayPay.class).get(9);
        if (c != null) {
            DayPayManager.promptLevel = c.serverdata;
        }

    }

    public void initChargeGoodList() throws Exception {
        YYBAddress = ConfigManager.getInstance().getPropConf("sys").getProperty("sys.plat.yybAddress");
        YYBGet = ConfigManager.getInstance().getPropConf("sys").getProperty("sys.plat.yybGet");
        YYBAdd = ConfigManager.getInstance().getPropConf("sys").getProperty("sys.plat.yybAdd");
        YYBSub = ConfigManager.getInstance().getPropConf("sys").getProperty("sys.plat.yybSub");
        YYBOp = FireProp.getIntValue(ConfigManager.getInstance().getPropConf("sys"), "sys.plat.yybOp");
        String str = ConfigManager.getInstance().getPropConf("sys").getProperty("sys.firstcharge.starttime");
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd-HH-mm-ss");
        FIRST_CHARGE_START_TIME = sdf.parse(str).getTime();
        str = ConfigManager.getInstance().getPropConf("sys").getProperty("sys.firstcharge.clearpresent.starttime");
        FIRST_CHARGE_CLEAR_PRESENT_START_TIME = sdf.parse(str).getTime();
        String multiStr = ConfigManager.getInstance().getPropConf("sys").getProperty("sys.multicharge.starttime");
        MULTICHARGE_CHARGE_START_TIME = sdf.parse(multiStr).getTime();
        this.goodListMap.clear();
        if (Module.GetPayServiceType() == 0) {
            Map<Integer, SAddCash> rawData = ConfigManager.getInstance().getConf(SAddCash.class);

            for(Map.Entry<Integer, SAddCash> entry : rawData.entrySet()) {
                SAddCash sAddCash = (SAddCash)entry.getValue();
                Map<Integer, LinkedList<GoodInfo>> platGoodInfos = (Map)this.goodListMap.get(sAddCash.roofid);
                if (platGoodInfos == null) {
                    platGoodInfos = new HashMap();
                    this.goodListMap.put(sAddCash.roofid, platGoodInfos);
                }

                LinkedList<GoodInfo> serverGoodInfos = (LinkedList)platGoodInfos.get(sAddCash.serverid);
                if (serverGoodInfos == null) {
                    serverGoodInfos = new LinkedList();
                    platGoodInfos.put(sAddCash.serverid, serverGoodInfos);
                }

                serverGoodInfos.add(new GoodInfo(sAddCash.id, sAddCash.sellpricenum, sAddCash.sellnum, sAddCash.sellnummore, 0));
                if ((Integer)entry.getKey() == 101 || (Integer)entry.getKey() == 102 || (Integer)entry.getKey() == 103 || (Integer)entry.getKey() == 104 || (Integer)entry.getKey() == 105 || (Integer)entry.getKey() == 106 || (Integer)entry.getKey() == 107 || (Integer)entry.getKey() == 108) {
                    yybGenBalance.put(sAddCash.getSellnum(), sAddCash.getSellnummore());
                }
            }
        } else {
            Map<Integer, SAddCashPCard> rawDataPCard = ConfigManager.getInstance().getConf(SAddCashPCard.class);

            for(Map.Entry<Integer, SAddCashPCard> entry : rawDataPCard.entrySet()) {
                SAddCashPCard sAddCashPCard = (SAddCashPCard)entry.getValue();
                Map<Integer, LinkedList<GoodInfo>> platGoodInfos = (Map)this.goodListMap.get(sAddCashPCard.roofid);
                if (platGoodInfos == null) {
                    platGoodInfos = new HashMap();
                    this.goodListMap.put(sAddCashPCard.roofid, platGoodInfos);
                }

                LinkedList<GoodInfo> serverGoodInfos = (LinkedList)platGoodInfos.get(sAddCashPCard.serverid);
                if (serverGoodInfos == null) {
                    serverGoodInfos = new LinkedList();
                    platGoodInfos.put(sAddCashPCard.serverid, serverGoodInfos);
                }

                serverGoodInfos.add(new GoodInfo(sAddCashPCard.id, sAddCashPCard.sellpricenum, sAddCashPCard.sellnum, sAddCashPCard.sellnummore, 0));
                if ((Integer)entry.getKey() == 101 || (Integer)entry.getKey() == 102 || (Integer)entry.getKey() == 103 || (Integer)entry.getKey() == 104 || (Integer)entry.getKey() == 105 || (Integer)entry.getKey() == 106 || (Integer)entry.getKey() == 107 || (Integer)entry.getKey() == 108) {
                    yybGenBalance.put(sAddCashPCard.getSellnum(), sAddCashPCard.getSellnummore());
                }
            }
        }

    }

    public static HttpGet makeYybGetCurrencyRequest(int userId, long roleId) throws Exception {
        YingYongBao yyb = Yingyongbaoinfos.select(userId);
        if (yyb == null) {
            logger.error("FushiManager.makeYybGetCurrencyRequest:YingYongBao数据为null!");
            return null;
        } else {
            String openid = yyb.getOpenid();
            String openkey = yyb.getOpenkey();
            String pf = yyb.getPf();
            String pfkey = yyb.getPfkey();
            String zoneid = yyb.getZoneid();
            String platform_name = URLEncoder.encode(yyb.getPlatformname(), "utf-8");
            String httpurl = String.format("http://%1$s%2$s?openid=%3$s&openkey=%4$s&pf=%5$s&pfkey=%6$s&zoneid=%7$s&platform_name=%8$s", YYBAddress, YYBGet, openid, openkey, pf, pfkey, zoneid, platform_name);
            logger.info("FushiManager.makeYybGetCurrencyRequest:" + httpurl);
            HttpGet request = new HttpGet(httpurl);
            return request;
        }
    }

    public static HttpGet makeYybAddCurrencyRequest(int userId, long roleId, int presenttimes, long billno) throws Exception {
        YingYongBao yyb = Yingyongbaoinfos.select(userId);
        if (yyb == null) {
            logger.error("FushiManager.makeYybAddCurrencyRequest:YingYongBao数据为null!");
            return null;
        } else {
            String openid = yyb.getOpenid();
            String openkey = yyb.getOpenkey();
            String pf = yyb.getPf();
            String pfkey = yyb.getPfkey();
            String zoneid = yyb.getZoneid();
            String presenttimesStr = String.valueOf(presenttimes);
            String platform_name = URLEncoder.encode(yyb.getPlatformname(), "utf-8");
            String httpurl = String.format("http://%1$s%2$s?openid=%3$s&openkey=%4$s&pf=%5$s&pfkey=%6$s&billno=%7$s&zoneid=%8$s&presenttimes=%9$s&platform_name=%10$s", YYBAddress, YYBAdd, openid, openkey, pf, pfkey, String.valueOf(billno), zoneid, presenttimesStr, platform_name);
            logger.info("FushiManager.makeYybAddCurrencyRequest:" + httpurl);
            HttpGet request = new HttpGet(httpurl);
            return request;
        }
    }

    public static HttpGet makeYybSubCurrencyRequest(int userId, long roleId, int amt, long billno) throws Exception {
        YingYongBao yyb = Yingyongbaoinfos.select(userId);
        if (yyb == null) {
            logger.error("FushiManager.makeYybSubCurrencyRequest:YingYongBao数据为null!");
            return null;
        } else {
            String openid = yyb.getOpenid();
            String openkey = yyb.getOpenkey();
            String pf = yyb.getPf();
            String pfkey = yyb.getPfkey();
            String amtStr = String.valueOf(amt);
            String zoneid = yyb.getZoneid();
            String platform_name = URLEncoder.encode(yyb.getPlatformname(), "utf-8");
            String httpurl = String.format("http://%1$s%2$s?openid=%3$s&openkey=%4$s&pf=%5$s&pfkey=%6$s&billno=%7$s&amt=%8$s&zoneid=%9$s&platform_name=%10$s", YYBAddress, YYBSub, openid, openkey, pf, pfkey, String.valueOf(billno), amtStr, zoneid, platform_name);
            logger.info("FushiManager.makeYybSubCurrencyRequest:" + httpurl);
            HttpGet request = new HttpGet(httpurl);
            return request;
        }
    }

    public static int getFenduan(int value) {
        if (value <= 0) {
            logger.error("yuan bao chongzhi value must be more than 0:" + value);
            return -1;
        } else if (value > FushiConst.FEN_DUAN_9) {
            return 10;
        } else if (value > FushiConst.FEN_DUAN_8) {
            return 9;
        } else if (value > FushiConst.FEN_DUAN_7) {
            return 8;
        } else if (value > FushiConst.FEN_DUAN_6) {
            return 7;
        } else if (value > FushiConst.FEN_DUAN_5) {
            return 6;
        } else if (value > FushiConst.FEN_DUAN_4) {
            return 5;
        } else if (value > FushiConst.FEN_DUAN_3) {
            return 4;
        } else if (value > FushiConst.FEN_DUAN_2) {
            return 3;
        } else if (value > FushiConst.FEN_DUAN_1) {
            return 2;
        } else {
            return value > 0 ? 1 : -1;
        }
    }

    public static boolean addFushiToUser(int userid, long roleid, int fushiNum, int fushitype, YYLoggerTuJingEnum way) {
        if (Module.getIsYYBUser(userid)) {
            if (userid > 0 && roleid > 0L) {
                if (fushiNum < 0) {
                    logger.error("FushiManager.addFushiToUser:fushiNum=" + fushiNum + "<=0,错误！roleid=" + roleid);
                    return false;
                } else {
                    YybFushiNums yybFs = Yybfushi.get(userid);
                    if (yybFs == null) {
                        logger.error("FushiManager.addFushiToUser:fushiNum=" + fushiNum + "没有符石数据1,roleid=" + roleid + ",userid=" + userid);
                        return false;
                    } else {
                        YybFushiNum yybFushiNum = (YybFushiNum)yybFs.getRolefushi().get(roleid);
                        if (yybFushiNum == null) {
                            logger.error("FushiManager.addFushiToUser:fushiNum=" + fushiNum + "没有符石数据2,roleid=" + roleid + ",userid=" + userid);
                            return false;
                        } else {
                            yybFushiNum.setBalance(yybFushiNum.getBalance() + fushiNum);
                            yybFushiNum.setGenbalance(yybFushiNum.getGenbalance() + fushiNum);
                            long oldall = yybFushiNum.getFushiall();
                            yybFushiNum.setFushiall(yybFushiNum.getFushiall() + (long)fushiNum);
                            int balance = yybFushiNum.getBalance();
                            int genBalance = yybFushiNum.getGenbalance();
                            logger.info((new StringBuilder()).append("FushiManager.addYYBFushiToUser:User[").append(userid).append("]Role[").append(roleid).append("]增加").append(fushitype).append("类型符石数:").append(fushiNum).append(",现有总量:").append(yybFushiNum.getBalance()));
                            refreshRoleFushi(roleid, balance, balance - genBalance);
                            SpotCheckManage.refreshTradingOpenState(roleid, oldall, yybFushiNum.getFushiall());
                            YYLogger.OpTokenGetLog(roleid, way, 3, (long)fushiNum, (long)yybFushiNum.getBalance(), new ItemBean());
                            return true;
                        }
                    }
                }
            } else {
                logger.error("FushiManager.addFushiToUser:userid=" + userid + ",roleid=" + roleid + ",错误！");
                return false;
            }
        } else if (userid > 0 && roleid > 0L) {
            if (fushiNum < 0) {
                logger.error("FushiManager.addFushiToUser:fushiNum=" + fushiNum + "<=0,错误！roleid=" + roleid);
                return false;
            } else {
                YbNums ybNums = Fushinum.get(userid);
                if (ybNums == null) {
                    ybNums = Pod.newYbNums();
                    Fushinum.insert(userid, ybNums);
                }

                YbNum ybNum = (YbNum)ybNums.getRoleyb().get(roleid);
                if (ybNum == null) {
                    ybNum = Pod.newYbNum();
                    ybNums.getRoleyb().put(roleid, ybNum);
                }

                int cashYbChange = 0;
                int sysYbChange = 0;
                if (fushitype == 1) {
                    int sysNum = ybNum.getSysnum();
                    int newNum = sysNum + fushiNum;
                    if (newNum < 0 || newNum > 1999999999) {
                        logger.error("FushiManager.addFushiToUser:User[" + userid + "]Role[" + roleid + "]系统符石newNum=" + newNum + ",超范围！");
                        return false;
                    }

                    ybNum.setSysnum(newNum);
                    sysYbChange = fushiNum;
                } else if (fushitype == 0) {
                    int cashNum = ybNum.getNum();
                    int newNum = cashNum + fushiNum;
                    if (newNum < 0 || newNum > 1999999999) {
                        logger.error("FushiManager.addFushiToUser:User[" + userid + "]Role[" + roleid + "]现金符石newNum=" + newNum + ",超范围！");
                        return false;
                    }

                    ybNum.setNum(newNum);
                    cashYbChange = fushiNum;
                }

                long oldall = ybNum.getFushiall();
                ybNum.setFushiall(ybNum.getFushiall() + (long)fushiNum);
                logger.info("FushiManager.addFushiToUser:User[" + userid + "]Role[" + roleid + "]增加" + fushitype + "类型符石数:" + fushiNum + ",现有总量:" + (ybNum.getNum() + ybNum.getSysnum()));
                refreshRoleFushi(roleid, ybNum, true);
                SpotCheckManage.refreshTradingOpenState(roleid, oldall, ybNum.getFushiall());
                logCashChange(roleid, ybNum, cashYbChange, 0, sysYbChange, 1303);
                YYLogger.OpTokenGetLog(roleid, way, 3, (long)fushiNum, (long)ybNum.getNum(), new ItemBean());
                return true;
            }
        } else {
            logger.error("FushiManager.addFushiToUser:userid=" + userid + ",roleid=" + roleid + ",错误！");
            return false;
        }
    }

    public static boolean subFushiFromUser(int userid, long roleid, int fushiNum, int itemid, int itemNum, int consumetype, YYLoggerTuJingEnum way, boolean showmsg) {
        if (Module.getIsYYBUser(userid)) {
            if (userid > 0 && roleid > 0L) {
                if (fushiNum < 0) {
                    logger.error("FushiManager.addFushiToUser:fushiNum=" + fushiNum + "<=0,错误！roleid=" + roleid);
                    return false;
                } else {
                    YybFushiNums yybFs = Yybfushi.get(userid);
                    if (yybFs == null) {
                        logger.error("FushiManager.addFushiToUser:fushiNum=" + fushiNum + "没有符石数据1,roleid=" + roleid + ",userid=" + userid);
                        return false;
                    } else {
                        YybFushiNum yybFushiNum = (YybFushiNum)yybFs.getRolefushi().get(roleid);
                        if (yybFushiNum == null) {
                            logger.error("FushiManager.addFushiToUser:fushiNum=" + fushiNum + "没有符石数据2,roleid=" + roleid + ",userid=" + userid);
                            return false;
                        } else {
                            int balance = yybFushiNum.getBalance();
                            int genBalance = yybFushiNum.getGenbalance();
                            if (balance < fushiNum) {
                                logger.error("FushiManager.subFushiToUser:fushiNum=" + fushiNum + "<=0,符石不足,roleid=" + roleid);
                                return false;
                            } else {
                                if (genBalance > fushiNum) {
                                    yybFushiNum.setBalance(balance - fushiNum);
                                    yybFushiNum.setGenbalance(genBalance - fushiNum);
                                } else {
                                    yybFushiNum.setGenbalance(0);
                                    yybFushiNum.setBalance(balance - fushiNum);
                                }

                                balance = yybFushiNum.getBalance();
                                genBalance = yybFushiNum.getGenbalance();
                                if (consumetype == 2003) {
                                    Pack bag = new Pack(roleid, false);
                                    bag.addSysCurrency((long)((float)fushiNum * Module.getCreditPointValue(15)), 13, "点卡服每日扣点卡\t", way, 0);
                                }

                                logger.info((new StringBuilder()).append("FushiManager.subYYBFushiToUser:User[").append(userid).append("]Role[").append(roleid).append("]扣除").append(consumetype).append("类型符石数:").append(fushiNum).append(",现有总量:").append(yybFushiNum.getBalance()));
                                refreshRoleFushi(roleid, balance, balance - genBalance);
                                logCashChange(roleid, balance, genBalance);
                                if (fushiNum > 0) {
                                    StatisticUtil.updateFushiConsumeStats(roleid, System.currentTimeMillis(), fushiNum, fushiNum);
                                }

                                YYLogger.OpTokenUseLog(roleid, way, 3, (long)fushiNum, (long)yybFushiNum.getBalance(), new ItemBean());
                                return true;
                            }
                        }
                    }
                }
            } else {
                logger.error("FushiManager.addFushiToUser:userid=" + userid + ",roleid=" + roleid + ",错误！");
                return false;
            }
        } else if (userid > 0 && roleid > 0L) {
            if (fushiNum < 0) {
                logger.error("FushiManager.subFushiFromUser:fushiNum=" + fushiNum + "<=0,错误！roleid=" + roleid);
                return false;
            } else {
                YbNums ybNums = Fushinum.get(userid);
                if (ybNums == null) {
                    ybNums = Pod.newYbNums();
                    Fushinum.insert(userid, ybNums);
                }

                YbNum ybNum = (YbNum)ybNums.getRoleyb().get(roleid);
                if (ybNum == null) {
                    ybNum = Pod.newYbNum();
                    ybNums.getRoleyb().put(roleid, ybNum);
                }

                int sysYbUsed = 0;
                int cashYbUsed = 0;
                int num = ybNum.getNum();
                int sysNum = ybNum.getSysnum();
                if (num + sysNum < fushiNum) {
                    logger.error("FushiManager.subFushiFromUser:userid=" + userid + ",roleid=" + roleid + ",符石数:" + (num + sysNum) + "不够:" + fushiNum);
                    if (showmsg) {
                        MessageMgr.psendMsgNotify(roleid, 142686, (List)null);
                    }

                    return false;
                } else {
                    if (fushiNum <= sysNum) {
                        sysYbUsed = fushiNum;
                        ybNum.setSysnum(ybNum.getSysnum() - fushiNum);
                    } else {
                        sysYbUsed = ybNum.getSysnum();
                        ybNum.setSysnum(0);
                        cashYbUsed = fushiNum - sysYbUsed;
                        ybNum.setNum(ybNum.getNum() - cashYbUsed);
                    }

                    if (ybNum.getNum() >= 0 && ybNum.getSysnum() >= 0) {
                        if (consumetype == 2003) {
                            Pack bag = new Pack(roleid, false);
                            bag.addSysCurrency((long)((float)fushiNum * Module.getCreditPointValue(15)), 13, "点卡服每日扣点卡\t", way, 0);
                        }

                        logger.info("FushiManager.subFushiFromUser:User[" + userid + "]Role[" + roleid + "]减少符石数:" + fushiNum + ",现有总量:" + (ybNum.getNum() + ybNum.getSysnum()));
                        refreshRoleFushi(roleid, ybNum, true);
                        logCashChange(roleid, ybNum, -cashYbUsed, 0, -sysYbUsed, consumetype);
                        if (cashYbUsed + sysYbUsed > 0) {
                            StatisticUtil.updateFushiConsumeStats(roleid, System.currentTimeMillis(), cashYbUsed + sysYbUsed, cashYbUsed);
                        }

                        YYLogger.OpTokenUseLog(roleid, way, 3, (long)fushiNum, (long)ybNum.getNum(), new ItemBean());
                        return true;
                    } else {
                        logger.error("FushiManager.subFushiFromUser:userid=" + userid + ",roleid=" + roleid + ",符石数扣除后小于0!");
                        return false;
                    }
                }
            }
        } else {
            logger.error("FushiManager.subFushiFromUser:userid=" + userid + ",roleid=" + roleid + ",错误！");
            return false;
        }
    }

    public static void logCashChange(long roleid, YbNum ybNum, int cashYbChange, int bindYbChange, int sysYbChange, int reasonid) {
        try {
            if (roleid == 100L) {
                return;
            }

            if (roleid != 100L) {
                StatisticUtil.updateFushiNumStats(roleid, ybNum);
            }
        } catch (Exception e) {
            logger.info("cash change log error", e);
        }

    }

    public static void logCashChange(long roleid, int balance, int genbalance) {
        try {
            if (roleid == 100L) {
                return;
            }

            StatisticUtil.updateFushiNumStats(roleid, balance, genbalance);
        } catch (Exception e) {
            logger.info("cash change log error", e);
        }

    }

    public static void refreshRoleFushi(long roleid, int num, int totalnum) {
        SReqFushiNum srybn = new SReqFushiNum();
        srybn.num = num;
        srybn.totalnum = totalnum;
        if (Transaction.current() != null) {
            Procedure.psendWhileCommit(roleid, srybn);
        } else {
            Onlines.getInstance().send(roleid, srybn);
        }

    }

    public static void refreshRoleFushi(long roleid, YbNum ybNum, boolean inProcedure) {
        SReqFushiNum srybn = new SReqFushiNum();
        if (ybNum == null) {
            srybn.num = 0;
            srybn.bindnum = 0;
            srybn.totalnum = 0;
        } else {
            srybn.num = ybNum.getNum() + ybNum.getSysnum();
            srybn.totalnum = ybNum.getNopresentnum();
        }

        if (inProcedure) {
            Procedure.psendWhileCommit(roleid, srybn);
        } else {
            Onlines.getInstance().send(roleid, srybn);
        }

    }

    public static boolean checkFushiDayLimit(YbNum ybNum, int num) {
        long curTime = System.currentTimeMillis();
        if (!DateValidate.inTheSameDay(ybNum.getBindorsysnumtodaytime(), curTime)) {
            ybNum.setBindorsysnumtoday(0);
        }

        if (ybNum.getBindorsysnumtoday() + num > 400000) {
            return false;
        } else {
            ybNum.setBindorsysnumtodaytime(curTime);
            ybNum.setBindorsysnumtoday(ybNum.getBindorsysnumtoday() + num);
            return true;
        }
    }

    public static void updateMerchantDiscount(final List<MerchantDiscount> discountList) {
        logger.info("服务器收到AU-DiscountAnnounce消息开始更新商家折扣信息……");

        try {
            clearOldMerchantDiscount();
        } catch (Exception e1) {
            logger.error("删除旧的商家信息错误： ", e1);
        }

        (new Procedure() {
            public boolean process() {
                for(MerchantDiscount discount : discountList) {
                    OctetsStream os = new OctetsStream(discount.name);
                    String name = null;

                    try {
                        name = os.getString("UTF-16LE");
                    } catch (Exception e) {
                        FushiManager.logger.error("gs解析商家折扣信息unmarshal名字出错： ", e);
                        continue;
                    }

                    PlatformInfo info = Pod.newPlatformInfo();
                    info.setDiscount(1);
                    info.setId(discount.id);
                    info.setName(name);
                    FushiManager.logger.info("商家： " + discount.id + "商家名：  " + name + "折扣： " + discount.discount);
                    Payplatform.add(discount.id, info);
                }

                return true;
            }
        }).submit();
    }

    private static void clearOldMerchantDiscount() throws Exception {
        final List<Integer> idList = new ArrayList();
        Payplatform.getTable().browse(new TTable.IWalk<Integer, PlatformInfo>() {
            public boolean onRecord(Integer id, PlatformInfo info) {
                idList.add(id);
                return true;
            }
        });
        (new Procedure() {
            public boolean process() {
                for(Integer id : idList) {
                    Payplatform.remove(id);
                }

                return true;
            }
        }).submit().get();
    }

    public void initReturnFuShi() {
        shouchongMap.clear();
        returnZoneId = FireProp.getIntValue(ConfigManager.getInstance().getPropConf("sys"), "sys.return.fushi.zoneid");
        returnRatio = FireProp.getFloatValue(ConfigManager.getInstance().getPropConf("sys"), "sys.return.fushi.ratio");
        logger.debug("zoneId=" + returnZoneId + "  ratio=" + returnRatio);
        int serverId = ConfigManager.getGsZoneId();
        if (returnZoneId == serverId) {
            String filePath = ConfigManager.PROPERTY_PATH + "/returnFuShi.txt";
            File file = new File(filePath);
            if (!file.exists()) {
                logger.error("文件路径： " + filePath + "找不到相关文件");
            } else {
                FileReader fileReader = null;
                BufferedReader bufferedReader = null;

                try {
                    fileReader = new FileReader(file);
                    bufferedReader = new BufferedReader(fileReader);
                    String line = null;

                    while((line = bufferedReader.readLine()) != null) {
                        if (!line.trim().equals("")) {
                            line = line.replace("，", ",");
                            String[] temp = line.split(",");
                            if (temp.length != 2) {
                                logger.info("符石返还 配置有错误" + line);
                            } else {
                                int userId = Integer.parseInt(temp[0]);
                                int shouchong = Integer.parseInt(temp[1]);
                                Integer fushi = (Integer)shouchongMap.get(userId);
                                if (fushi == null) {
                                    shouchongMap.put(userId, shouchong);
                                } else {
                                    shouchongMap.put(userId, shouchong + fushi);
                                }
                            }
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (fileReader != null && bufferedReader != null) {
                            fileReader.close();
                            bufferedReader.close();
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }

                }

            }
        }
    }

    public int getFuShiFanHuan(int userId) {
        Integer fushi = (Integer)shouchongMap.get(userId);
        return fushi == null ? 0 : (int)((float)(fushi / 10) * returnRatio);
    }

    public static ChargeConfig getChargeConfigByMoney(int money) {
        ChargeConfig ret = null;
        if (Module.GetPayServiceType() == 0) {
            NavigableMap<Integer, SAddCash> chargeConf = ConfigManager.getInstance().getConf(SAddCash.class);
            if (chargeConf == null) {
                return null;
            }

            for(SAddCash conf : chargeConf.values()) {
                if (conf.sellpricenum == money) {
                    ret = conf;
                    break;
                }
            }
        } else {
            NavigableMap<Integer, SAddCashPCard> chargeConf = ConfigManager.getInstance().getConf(SAddCashPCard.class);
            if (chargeConf == null) {
                return null;
            }

            for(SAddCashPCard conf : chargeConf.values()) {
                if (conf.sellpricenum == money) {
                    ret = conf;
                    break;
                }
            }
        }

        return ret;
    }

    public static ChargeConfig getChargeConfigByProductID(String product) {
        ChargeConfig ret = null;
        if (Module.GetPayServiceType() == 0) {
            NavigableMap<Integer, SAddCash> chargeConf = ConfigManager.getInstance().getConf(SAddCash.class);
            if (chargeConf == null) {
                return null;
            }

            for(SAddCash conf : chargeConf.values()) {
                if (conf.productid.equals(product)) {
                    ret = conf;
                    break;
                }
            }
        } else {
            NavigableMap<Integer, SAddCashPCard> chargeConf = ConfigManager.getInstance().getConf(SAddCashPCard.class);
            if (chargeConf == null) {
                return null;
            }

            for(SAddCashPCard conf : chargeConf.values()) {
                if (conf.productid.equals(product)) {
                    ret = conf;
                    break;
                }
            }
        }

        return ret;
    }

    public List<GoodInfo> getGoodsList(String platString) {
        List<GoodInfo> list = new ArrayList();
        Map<Integer, LinkedList<GoodInfo>> platGoods = (Map)getInstance().goodListMap.get(platString);
        if (platGoods == null) {
            platGoods = (Map)getInstance().goodListMap.get("ljpl");
        }

        LinkedList<GoodInfo> commonGoods = (LinkedList)platGoods.get(0);
        if (commonGoods != null) {
            for(GoodInfo goodInfo : commonGoods) {
                if (Module.GetPayServiceType() == 0) {
                    if (((SAddCash)ConfigManager.getInstance().getConf(SAddCash.class).get(goodInfo.goodid)).gameshow == 1) {
                        list.add(new GoodInfo(goodInfo.goodid, goodInfo.price, goodInfo.fushi, goodInfo.present, goodInfo.beishu));
                    }
                } else if (((SAddCashPCard)ConfigManager.getInstance().getConf(SAddCashPCard.class).get(goodInfo.goodid)).gameshow == 1) {
                    list.add(new GoodInfo(goodInfo.goodid, goodInfo.price, goodInfo.fushi, goodInfo.present, goodInfo.beishu));
                }
            }
        }

        LinkedList<GoodInfo> serveridGoods = (LinkedList)platGoods.get(Gs.serverid);
        if (serveridGoods != null && ConfigManager.getGsZoneId() > 0) {
            for(GoodInfo goodInfo : serveridGoods) {
                if (Module.GetPayServiceType() == 0) {
                    if (((SAddCash)ConfigManager.getInstance().getConf(SAddCash.class).get(goodInfo.goodid)).gameshow == 1) {
                        list.add(new GoodInfo(goodInfo.goodid, goodInfo.price, goodInfo.fushi, goodInfo.present, 0));
                    }
                } else if (((SAddCashPCard)ConfigManager.getInstance().getConf(SAddCashPCard.class).get(goodInfo.goodid)).gameshow == 1) {
                    list.add(new GoodInfo(goodInfo.goodid, goodInfo.price, goodInfo.fushi, goodInfo.present, 0));
                }
            }
        }

        return list;
    }

    public static int getDoubleChareState(RoleDoubleChareInfo multiCharge, int userid) {
        if (multiCharge != null && multiCharge.getActivetime() >= MULTICHARGE_CHARGE_START_TIME) {
            if (multiCharge.getActivetime() > MULTICHARGE_CHARGE_START_TIME) {
                return 0;
            } else {
                if (multiCharge.getFlag() == 1) {
                    for(Map.Entry<Integer, Integer> temp : multiCharge.getAchievement().entrySet()) {
                        if ((Integer)temp.getValue() == 0) {
                            return 1;
                        }
                    }
                } else {
                    AUUserInfo auUserInfo = Auuserinfo.select(userid);
                    if (auUserInfo == null) {
                        logger.error("Exception11:auuserinfo null.userid+" + userid);
                        return 0;
                    }

                    String platString = auUserInfo.getNickname().substring(0, 4);

                    for(GoodInfo info : getInstance().getGoodsList(platString)) {
                        if (info.beishu > 0) {
                            Integer value = (Integer)multiCharge.getAchievement().get(info.goodid);
                            if (value == null || value != 1) {
                                return 1;
                            }
                        }
                    }

                    logger.error("Exception111: auuserinfo null.userid+" + userid);
                }

                return 0;
            }
        } else {
            return 1;
        }
    }

    public void initRoleDoubleChareInfo(RoleDoubleChareInfo multiCharge, List<GoodInfo> list) {
        if (list.size() != 0) {
            if (multiCharge.getActivetime() <= MULTICHARGE_CHARGE_START_TIME) {
                if (multiCharge.getActivetime() == MULTICHARGE_CHARGE_START_TIME && multiCharge.getFlag() == 2) {
                    for(GoodInfo gd : list) {
                        if (multiCharge.getAchievement().get(gd.goodid) == null && gd.beishu > 0) {
                            multiCharge.getAchievement().put(gd.goodid, 0);
                        }
                    }
                }

                if (multiCharge.getActivetime() < MULTICHARGE_CHARGE_START_TIME) {
                    multiCharge.getAchievement().clear();

                    for(GoodInfo gd : list) {
                        if (gd.beishu > 0) {
                            multiCharge.getAchievement().put(gd.goodid, 0);
                        }
                    }
                }

                multiCharge.setActivetime(MULTICHARGE_CHARGE_START_TIME);
                multiCharge.setFlag(1);
            }
        }
    }

    public int getYybGenBalance(int midnum) {
        for(Map.Entry<Integer, Integer> genBalance : yybGenBalance.entrySet()) {
            if (midnum >= (Integer)genBalance.getKey()) {
                return (Integer)genBalance.getValue();
            }
        }

        return 0;
    }
}
