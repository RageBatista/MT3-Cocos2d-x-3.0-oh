//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import fire.log.Logger;
import fire.pb.activity.award.RewardMgr;
import fire.pb.game.SFortuneWheel;
import fire.pb.main.ConfigManager;
import fire.pb.map.SActivityAwardItems;
import fire.pb.util.Misc;
import java.util.ArrayList;
import java.util.List;
import java.util.NavigableMap;
import java.util.Properties;
import mkdb.Procedure;
import xbean.Pod;
import xbean.WheelInfo;
import xbean.WheelInfos;
import xbean.WheelItem;
import xbean.WheelItemLimit;
import xtable.Wheelitemlimit;
import xtable.Wheelprogress;

public class PReqFortuneWheel extends Procedure {
    public static final int JIANGQUAN_SERVICEID = 1057;
    private final long roleid;
    private final long npckey;
    private final int npcid;
    private int baseMoney;
    private int baseSMoney;
    private int baseExp;
    private boolean sendP;
    private final int serviceid;
    private Integer awardIndex;
    private int msgid;
    private List<String> paras;
    private static Logger logger = Logger.getLogger("MAPMAIN");
    private static NavigableMap<Integer, SFortuneWheel> FortuneMap = ConfigManager.getInstance().getConf(SFortuneWheel.class);
    static Properties prop = ConfigManager.getInstance().getPropConf("game");
    private int flag;

    public PReqFortuneWheel(long roleid, long npckey, int npcid, boolean sendP, int serviceid) {
        this.sendP = true;
        this.flag = 0;
        this.roleid = roleid;
        this.npcid = npcid;
        this.serviceid = serviceid;
        this.sendP = sendP;
        this.npckey = npckey;
    }

    public PReqFortuneWheel(long roleid, long npckey, int npcid, int baseMoney, int baseExp, int baseSMoney, int awardIndex, int msgid, List<String> paras, boolean sendProtocol, int serviceid, int flag) {
        this(roleid, npckey, npcid, sendProtocol, serviceid);
        this.baseMoney = baseMoney;
        this.baseSMoney = baseSMoney;
        this.baseExp = baseExp;
        this.awardIndex = awardIndex;
        this.msgid = msgid;
        this.paras = paras;
        this.flag = flag;
    }

    public PReqFortuneWheel(long roleid, long npckey, int npcid, int baseMoney, int baseExp, int baseSMoney, int awardIndex, int msgid, List<String> paras, boolean sendProtocol, int serviceid) {
        this(roleid, npckey, npcid, sendProtocol, serviceid);
        this.baseMoney = baseMoney;
        this.baseSMoney = baseSMoney;
        this.baseExp = baseExp;
        this.awardIndex = awardIndex;
        this.msgid = msgid;
        this.paras = paras;
    }

    private int getItemId(int nIndex) {
        SActivityAwardItems items = (SActivityAwardItems)RewardMgr.getInstance().getAward2Map().get(nIndex);
        if (items == null) {
            return -1;
        } else {
            List<Integer> itemList = items.getItems();
            int index = Misc.getRandomBetween(0, itemList.size() - 1);
            return (Integer)itemList.get(index);
        }
    }

    protected boolean process() throws Exception {
        WheelItemLimit itemLimit = null;
        if (this.awardIndex != null) {
            itemLimit = Wheelitemlimit.get(this.awardIndex);
            if (itemLimit == null) {
                itemLimit = Pod.newWheelItemLimit();
                Wheelitemlimit.insert(this.awardIndex, itemLimit);
            }
        }

        WheelInfos wts = Wheelprogress.get(this.roleid);
        if (wts == null) {
            wts = Pod.newWheelInfos();
            Wheelprogress.insert(this.roleid, wts);
        }

        WheelInfo wt = findWheelType(wts, this.npcid, this.serviceid);
        if (this.serviceid == 1057 && wt != null) {
            wts.getWheellist().remove(wt);
            wt = null;
        }

        if (wt == null && this.awardIndex != null) {
            wt = Pod.newWheelInfo();
            wts.getWheellist().add(wt);
            wt.setNpcbaseid(this.npcid);
            wt.setServiceid(this.serviceid);
            wt.setTime(System.currentTimeMillis());
            wt.setBaseexp(this.baseExp);
            wt.setBasemoney(this.baseMoney);
            wt.setBasesmoney(this.baseSMoney);
            wt.setMsgid(this.msgid);
            if (this.paras != null) {
                wt.getMsgparas().addAll(this.paras);
            }

            wt.setFinish(false);
            SFortuneWheel sfw = (SFortuneWheel)FortuneMap.get(this.awardIndex);
            Integer[] objArr = new Integer[sfw.cards.size()];
            List<Integer> fixeditemIndexs = new ArrayList();
            List<Integer> allIndexs = new ArrayList();

            for(int i = 0; i < objArr.length; ++i) {
                objArr[i] = i;
                String[] strs = ((String)sfw.cards.get(i)).split(";");
                int type = Integer.parseInt(strs[0]);
                if ((type == 1 || type == 5) && strs.length == 9) {
                    if (Integer.parseInt(strs[8]) == 1) {
                        fixeditemIndexs.add(i);
                    }
                } else if (Integer.parseInt(strs[5]) == 1) {
                    fixeditemIndexs.add(i);
                }

                allIndexs.add(i);
            }

            if (!fixeditemIndexs.isEmpty()) {
                allIndexs.removeAll(fixeditemIndexs);
            }

            int count = 0;
            Integer[] objs = null;
            List<Integer> probs = new ArrayList();
            if (this.serviceid == 1057) {
                count = this.npcid;
                objs = objArr;
            } else {
                count = 8;
                count -= fixeditemIndexs.size();
                int[] allIndexArray = new int[allIndexs.size()];

                for(int i = 0; i < allIndexs.size(); ++i) {
                    allIndexArray[i] = (Integer)allIndexs.get(i);
                }

                int[] tmparray = Misc.getRandomArray(allIndexArray, count);
                List<Integer> randomIndexes = new ArrayList();

                for(int i = 0; i < tmparray.length; ++i) {
                    randomIndexes.add(tmparray[i]);
                }

                randomIndexes.addAll(fixeditemIndexs);
                objs = new Integer[randomIndexes.size()];
                objs = (Integer[])randomIndexes.toArray(objs);
            }

            int sum = 0;

            for(int i = 0; i < objs.length; ++i) {
                String[] strs = ((String)sfw.cards.get(objs[i])).split(";");
                int type = Integer.parseInt(strs[0]);
                int num = Integer.parseInt(strs[1]);
                int itemid = Integer.parseInt(strs[2]);
                int times = Integer.parseInt(strs[3]);
                WheelItem item = Pod.newWheelItem();
                item.setItemtype(type);
                item.setItemid(itemid);
                item.setNum(num);
                item.setTimes(times);
                wt.getWheelitems().add(item);
                int prob = Integer.parseInt(strs[4]);
                if (type == 1 && strs.length == 9) {
                    item.setBind(Integer.parseInt(strs[5]));
                    item.setMsgid(Integer.parseInt(strs[7]));
                    int maxNum = Integer.parseInt(strs[6]);
                    if (maxNum > 0) {
                        item.setLimit(maxNum);
                        Integer curNum = (Integer)itemLimit.getLimitmap().get(itemid);
                        if (curNum != null && curNum + num > maxNum) {
                            probs.add(0);
                        } else {
                            probs.add(prob);
                        }
                    } else {
                        probs.add(prob);
                    }
                } else if (type == 5) {
                    int true_itemid = this.getItemId(itemid);
                    if (true_itemid > 0) {
                        item.setItemtype(1);
                        item.setItemid(true_itemid);
                        probs.add(prob);
                    } else {
                        item.setItemtype(1);
                        probs.add(0);
                    }
                } else {
                    probs.add(prob);
                }

                sum += prob;
            }

            int index = Misc.getProbability(probs, sum);
            wt.setIndex(index);
            WheelItem item = (WheelItem)wt.getWheelitems().get(index);
            if (item.getLimit() > 0) {
                Integer curNum = (Integer)itemLimit.getLimitmap().get(item.getItemid());
                if (curNum == null) {
                    itemLimit.getLimitmap().put(item.getItemid(), item.getNum());
                } else {
                    itemLimit.getLimitmap().put(item.getItemid(), curNum + item.getNum());
                }
            }
        }

        if (wt == null) {
            logger.error("no fortune wheel data:npcid:" + this.npcid + "taskid:" + this.serviceid + "roleid:" + this.roleid);
        }

        if (this.sendP && wt != null) {
            SReqFortuneWheel srfw = this.genFortuneWheelProtocal(wt);
            srfw.flag = (byte)this.flag;
            psendWhileCommit(this.roleid, srfw);
        }

        return true;
    }

    private SReqFortuneWheel genFortuneWheelProtocal(WheelInfo wt) {
        SReqFortuneWheel srfw = new SReqFortuneWheel();
        srfw.npckey = this.npckey;
        srfw.serviceid = wt.getServiceid();
        srfw.index = wt.getIndex();

        for(WheelItem item : wt.getWheelitems()) {
            int type = item.getItemtype();
            int itemid = item.getItemid();
            int num = item.getNum();
            int times = item.getTimes();
            srfw.itemids.add(new ForturneWheelType(type, itemid, (long)num, times));
        }

        return srfw;
    }

    public static WheelInfo findWheelType(WheelInfos wts, int npcbaseid, int serviceid) {
        if (wts != null && wts.getWheellist().size() != 0) {
            for(WheelInfo wtype : wts.getWheellist()) {
                if (wtype.getServiceid() == serviceid) {
                    if (wtype.getNpcbaseid() == npcbaseid) {
                        return wtype;
                    }

                    if (serviceid == 1057) {
                        return wtype;
                    }
                }
            }

            return null;
        } else {
            return null;
        }
    }

    public static boolean reload() {
        FortuneMap = ConfigManager.getInstance().getConf(SFortuneWheel.class);
        return true;
    }
}
