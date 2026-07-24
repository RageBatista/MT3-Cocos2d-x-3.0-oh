//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import fire.log.YYLogger;
import fire.log.beans.ItemBean;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.WorldTime;
import fire.pb.attr.SRefreshRoleCurrency;
import fire.pb.course.CourseManager;
import fire.pb.talk.MessageMgr;
import fire.pb.util.DateValidate;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;
import mkdb.Mkdb;
import mkdb.Procedure;
import mkdb.TField;
import mkdb.TTable;
import mkdb.Transaction;
import xbean.Bag;
import xbean.Item;
import xbean.Pod;
import xbean.Properties;

public abstract class ItemMaps implements Iterable<ItemBase> {
    protected static final int MSG_FULL = 140397;
    protected static final int MSG_NOTENOUGH = 120059;
    protected final Bag pack;
    protected final BagConfig conf;
    protected final boolean readonly;
    protected final long roleId;

    public static boolean isStack(Item item) {
        if (item == null) {
            return false;
        } else {
            return item.getMarkettime() == 0L && item.getExtid() == 0L;
        }
    }

    public static boolean isStack(Item srcItem, Item dstItem, int dntcare) {
        if (dstItem != null && srcItem != null) {
            if (srcItem.getId() == dstItem.getId() && srcItem.getTimeout() == dstItem.getTimeout() && srcItem.getExtid() == 0L && dstItem.getExtid() == 0L) {
                if (dntcare == 0) {
                    boolean pile = (srcItem.getFlags() & 1) == (dstItem.getFlags() & 1);
                    if (pile) {
                        if (dstItem.getMarkettime() == 0L && srcItem.getMarkettime() == 0L) {
                            return true;
                        } else {
                            long srcitemfreezeTime = srcItem.getMarkettime();
                            long dstitemfreezeTime = dstItem.getMarkettime();
                            long now = System.currentTimeMillis();
                            if (now >= srcitemfreezeTime && now >= dstitemfreezeTime) {
                                return true;
                            } else if (DateValidate.inTheSameDay(srcitemfreezeTime, dstitemfreezeTime)) {
                                dstItem.setMarkettime(Math.max(srcitemfreezeTime, dstitemfreezeTime));
                                return true;
                            } else {
                                return false;
                            }
                        }
                    } else {
                        return false;
                    }
                } else {
                    return (srcItem.getFlags() | dntcare) == (dstItem.getFlags() | dntcare);
                }
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    static void doStack(Item srcItem, Item dstItem, int num) {
        Map<Integer, Integer> heapnum;
        if (num != -1) {
            assert getItemNum(srcItem) >= num;

            heapnum = doCut(srcItem, num);
        } else {
            heapnum = new HashMap();
            heapnum.putAll(srcItem.getNumbermap());
            if (srcItem.getNumber() != 0) {
                heapnum.put(0, srcItem.getNumber());
                srcItem.setNumber(0);
            }

            srcItem.getNumbermap().clear();
        }

        stackNumber(heapnum, dstItem);
    }

    public static Map<Integer, Integer> doCut(Item xItem, int num) {
        Map<Integer, Integer> ret = new HashMap();
        int leftnum = num;

        for(int curflag = 2; curflag > 0 && leftnum > 0; --curflag) {
            Integer n = (Integer)xItem.getNumbermap().get(curflag);
            if (n != null) {
                if (leftnum >= n) {
                    xItem.getNumbermap().remove(curflag);
                    ret.put(curflag, n);
                    leftnum -= n;
                } else {
                    ret.put(curflag, leftnum);
                    xItem.getNumbermap().put(curflag, n - leftnum);
                    leftnum = 0;
                }
            }
        }

        if (leftnum > 0) {
            xItem.setNumber(xItem.getNumber() - leftnum);
            ret.put(0, leftnum);
        }

        return ret;
    }

    public static String getPackname(int bagtype) {
        switch (bagtype) {
            case 0:
                return "Null背包";
            case 1:
                return "仓库";
            case 2:
                return "仓库";
            case 3:
                return "装备背包";
            case 4:
                return "临时背包";
            case 5:
                return "任务背包";
            case 6:
                return "宠物背包";
            case 7:
                return "摊位背包";
            default:
                return "异常背包";
        }
    }

    public static String getItemLogs(List<ItemBase> items) {
        StringBuilder sb = new StringBuilder();

        for(ItemBase item : items) {
            if (item != null) {
                sb.append(item.getItemLog());
            }
        }

        return sb.toString();
    }

    public static final int getItemHasNum(long roleId, int itemId) {
        int num = 0;

        for(ItemBase bi : new Pack(roleId, true)) {
            if (bi.getItemId() == itemId) {
                num += bi.getNumber();
            }
        }

        for(ItemBase bi : new Depot(roleId, true)) {
            if (bi.getItemId() == itemId) {
                num += bi.getNumber();
            }
        }

        for(ItemBase bi : new Temp(roleId, true)) {
            if (bi.getItemId() == itemId) {
                num += bi.getNumber();
            }
        }

        return num;
    }

    public static int getItemNum(Item item) {
        int itemnum = item.getNumber();

        for(int num : item.getNumbermap().values()) {
            itemnum += num;
        }

        return itemnum;
    }

    public static void stackNumber(Map<Integer, Integer> stackNum, Item xItem) {
        for(Map.Entry<Integer, Integer> e : stackNum.entrySet()) {
            if ((Integer)e.getKey() == 0) {
                xItem.setNumber(xItem.getNumber() + (Integer)e.getValue());
            } else {
                Integer n = (Integer)xItem.getNumbermap().get(e.getKey());
                if (n == null) {
                    xItem.getNumbermap().put(e.getKey(), e.getValue());
                } else {
                    xItem.getNumbermap().put(e.getKey(), n + (Integer)e.getValue());
                }
            }
        }

    }

    protected static fire.pb.Item xItem2Item(Item dstItem, int key, int isNew) {
        fire.pb.Item ki = new fire.pb.Item();
        ki.flags = dstItem.getFlags();
        ki.id = dstItem.getId();
        ki.number = getItemNum(dstItem);
        ki.position = dstItem.getPosition();
        ki.key = key;
        ki.timeout = dstItem.getTimeout();
        if ((dstItem.getFlags() & 64) != 0) {
            if (ItemBase.isTimeout(dstItem)) {
                ki.loseeffecttime = -1L;
            } else {
                ki.loseeffecttime = dstItem.getLoseeffecttime() - WorldTime.getInstance().getTimeInMillis();
            }
        } else {
            ki.loseeffecttime = -1L;
        }

        ki.isnew = isNew;
        ki.markettime = dstItem.getMarkettime();
        return ki;
    }

    protected static fire.pb.Item xItem2Item(Item dstItem, int key, int isNew, int num) {
        fire.pb.Item ki = new fire.pb.Item();
        ki.flags = dstItem.getFlags();
        ki.id = dstItem.getId();
        ki.number = num;
        ki.position = dstItem.getPosition();
        ki.key = key;
        ki.timeout = dstItem.getTimeout();
        if ((dstItem.getFlags() & 64) != 0) {
            if (ItemBase.isTimeout(dstItem)) {
                ki.loseeffecttime = -1L;
            } else {
                ki.loseeffecttime = dstItem.getLoseeffecttime() - WorldTime.getInstance().getTimeInMillis();
            }
        } else {
            ki.loseeffecttime = -1L;
        }

        ki.isnew = isNew;
        ki.markettime = dstItem.getMarkettime();
        return ki;
    }

    public ItemMaps(long roleId, boolean readonly) {
        this.readonly = readonly;
        this.roleId = roleId;
        this.conf = Module.getInstance().getItemManager().getPackCfg(this.getPackid());
        TTable<Long, Bag> table = (TTable)Mkdb.getInstance().getTables().getTable(this.conf.tablename);
        if (table == null) {
            throw new RuntimeException("未找到table=" + this.conf.tablename);
        } else {
            Bag myPack;
            if (readonly) {
                myPack = (Bag)table.select(roleId, new TField<Bag, Bag>() {
                    public Bag get(Bag v) {
                        return v.toData();
                    }
                });
            } else {
                myPack = (Bag)table.get(roleId);
            }

            if (myPack == null) {
                if (readonly) {
                    this.pack = Pod.newBagData();
                } else {
                    this.pack = Pod.newBag();
                }

                this.pack.setCapacity(this.conf.sizesize);
                if (!readonly) {
                    table.insert(roleId, this.pack);
                }
            } else {
                this.pack = myPack;
            }

        }
    }

    public int addCapacity(int size) {
        if (!this.readonly) {
            this.pack.setCapacity(this.pack.getCapacity() + size);
        }

        return this.pack.getCapacity();
    }

    protected long addContribution(long money, String reason, YYLoggerTuJingEnum way) {
        if (this.readonly) {
            return 0L;
        } else {
            long res = Long.MAX_VALUE - this.getContribution() <= money ? Long.MAX_VALUE : money + this.getContribution();
            if (res < 0L) {
                Module.logger.error("配置不存在");
                return 0L;
            } else if (res > this.conf.maxmoney) {
                return 0L;
            } else {
                long oldvalue = this.getCurrency(4);
                this.pack.getCurrency().put(4, res);
                this.notifyMoney(4);
                long realadd = res - oldvalue;
                YYLogger.OpTokenGetLog(this.roleId, way, 4, money, res, new ItemBean());
                return realadd;
            }
        }
    }

    protected long addCurrency(long money, int moneyType, String reason, YYLoggerTuJingEnum way) {
        if (this.readonly) {
            return 0L;
        } else {
            long res = Long.MAX_VALUE - this.getCurrency(moneyType) <= money ? Long.MAX_VALUE : money + this.getCurrency(moneyType);
            if (res < 0L) {
                Module.logger.error("金钱不足:" + this.roleId);
                return 0L;
            } else if (res > this.conf.maxmoney) {
                long oldvalue = this.getCurrency(moneyType);
                this.pack.getCurrency().put(moneyType, this.conf.maxmoney);
                this.notifyMoney(moneyType);
                long realadd = res - oldvalue;
                MessageMgr.psendMsgNotify(this.roleId, 160162, (List)null);
                return realadd;
            } else {
                if (res > 99999900000L) {
                    MessageMgr.psendMsgNotify(this.roleId, 160113, (List)null);
                }

                SRefreshRoleCurrency send = new SRefreshRoleCurrency();
                switch (moneyType) {
                    case 4:
                        send.datas.put(9, res);
                        break;
                    case 5:
                        send.datas.put(5, res);
                        break;
                    case 6:
                        send.datas.put(2, res);
                        break;
                    case 7:
                        send.datas.put(6, res);
                        if (money > 0L) {
                            CourseManager.achieveUpdate(this.roleId, 48, 0, 0, (int)money);
                        }
                        break;
                    case 9:
                        send.datas.put(3, res);
                        break;
                    case 11:
                        send.datas.put(4, res);
                        break;
                    case 13:
                        send.datas.put(10, res);
                        break;
                    case 100:
                        send.datas.put(11, res);
                    case 101:
                        send.datas.put(12, res);
                    case 102:
                        send.datas.put(13, res);
                    case 103:
                        send.datas.put(14, res);
                }

                if (send.datas.size() > 0) {
                    Procedure.psend(this.roleId, send);
                }

                long oldvalue = this.getCurrency(moneyType);
                this.pack.getCurrency().put(moneyType, res);
                this.notifyMoney(moneyType);
                long realadd = res - oldvalue;
                if (moneyType == 4) {
                    Properties prop = xtable.Properties.get(this.roleId);
                    if (prop != null) {
                        long cur = this.getCurrency(moneyType);
                        if (cur > prop.getHistorymaxprofessioncontribute()) {
                            prop.setHistorymaxprofessioncontribute(cur);
                        }
                    }
                }

                if (money > 0L) {
                    YYLogger.OpTokenGetLog(this.roleId, way, moneyType, money, res, new ItemBean());
                } else if (money != 0L) {
                    YYLogger.OpTokenUseLog(this.roleId, way, moneyType, money, res, new ItemBean());
                }

                Module.logger.info((new StringBuffer()).append(this.roleId).append(" 添加货币:").append(money).append(" 角色:").append(moneyType).append(" 来源: ").append(reason));
                return realadd;
            }
        }
    }

    public boolean addFlag(int key, int flag, int packid) {
        if (this.readonly) {
            return false;
        } else {
            Item xi = (Item)this.pack.getItems().get(key);
            if (xi == null) {
                return true;
            } else {
                xi.setFlags(xi.getFlags() | flag);
                SItemSign ref = new SItemSign(key, xi.getFlags(), packid);
                Procedure.psendWhileCommit(this.roleId, ref);
                return false;
            }
        }
    }

    protected long addGold(long money, String reason, YYLoggerTuJingEnum way) {
        if (this.readonly) {
            return 0L;
        } else {
            long current = this.getGold();

            if (money > 0 && current > Long.MAX_VALUE - money) {
                Module.logger.error("Gold overflow: current=" + current + ", add=" + money);
                return current;
            }

            long res = current + money;
            if (res < 0L) {
                Module.logger.error("金币溢出");
                return 0L;
            } else if (res > this.conf.maxmoney) {
                return 0L;
            } else {
                long oldvalue = this.getCurrency(2);
                this.pack.getCurrency().put(2, res);
                this.notifyMoney(2);
                long realadd = res - oldvalue;
                YYLogger.OpTokenGetLog(this.roleId, way, 2, realadd, res, new ItemBean());
                return realadd;
            }
        }
    }

    public int doAddItem(int itemId, int num, int numType, int initFlag, String reason, YYLoggerTuJingEnum counterType, int xiangGuanId) {
        if (!this.readonly && num > 0) {
            ItemShuXing attr = Module.getInstance().getItemManager().getAttr(itemId);
            if (attr == null) {
                return 0;
            } else {
                int canOwn = Module.getInstance().getMaxOwn(this.roleId, itemId);
                int canAdd = Integer.MAX_VALUE;
                if (canOwn != 0) {
                    canAdd = canOwn - getItemHasNum(this.roleId, itemId);
                }

                int stacked = this.doDoStack(itemId, num, numType, initFlag, canAdd, counterType);
                int leftNum = num - stacked;

                int addNum;
                for(int var15 = canAdd - stacked; leftNum > 0; var15 -= addNum) {
                    if (var15 <= 0) {
                        List<String> parameters = new ArrayList();
                        parameters.add(attr.name);
                        MessageMgr.psendMsgNotify(this.roleId, 142752, parameters);
                        return num - leftNum;
                    }

                    int getNum = Math.min(attr.maxstack, leftNum);
                    addNum = Math.min(getNum, var15);
                    ItemBase itemBase = Module.getInstance().getItemManager().genItemBase(itemId, addNum, numType);
                    if (itemBase == null) {
                        break;
                    }

                    if (initFlag != 0) {
                        itemBase.setFlag(itemBase.getFlags() | initFlag);
                    }

                    if (!this.processDoAddItem(itemBase, -1, counterType)) {
                        break;
                    }

                    leftNum -= addNum;
                }

                addNum = getItemHasNum(this.roleId, itemId);
                ItemBean itemBean = new ItemBean(itemId, num, addNum);
                YYLogger.OpItemGetLog(this.roleId, itemBean, counterType);
                Module.logger.info((new StringBuffer()).append("roleId:").append(this.roleId).append(" 添加物品:").append(itemId).append(" 角色:").append(num).append(" 添加后数量:").append(addNum).append(" 角色:").append(counterType).append(" 角色:").append(reason));
                return num - leftNum;
            }
        } else {
            return 0;
        }
    }

    public final int doAddItem(int itemId, int num, int numType, String reason, YYLoggerTuJingEnum counterType, int xiangGuanId) {
        return this.doAddItem(itemId, num, numType, 0, reason, counterType, xiangGuanId);
    }

    public final int doAddItem(int itemId, int num, String reason, YYLoggerTuJingEnum counterType, int xiangGuanId) {
        return this.doAddItem(itemId, num, 0, 0, reason, counterType, xiangGuanId);
    }

    public AddItemResult doAddItem(ItemBase item, int pos, String reason, YYLoggerTuJingEnum counterType, int xiangGuanId) {
        int num = item.getNumber();
        int hasnum = getItemHasNum(this.roleId, item.getItemId());
        int maxown = Module.getInstance().getMaxOwn(this.roleId, item.getItemId());
        if (maxown != 0 && hasnum + item.getNumber() > maxown) {
            List<String> parameters = new ArrayList();
            parameters.add(item.getItemAttr().name);
            MessageMgr.psendMsgNotify(this.roleId, 142752, parameters);
            return AddItemResult.MAX_OWN_NUM;
        } else {
            if (item.getOwnerid() != 0L && item.getOwnerid() != this.roleId) {
                if (item.isBind()) {
                    return AddItemResult.BIND_ITEM;
                }

                if (item.isTimeout()) {
                    return AddItemResult.TIMEOUT_CANNOT_TRADE;
                }
            }

            if (!this.processDoAddItem(item, pos, counterType)) {
                return AddItemResult.FULL;
            } else {
                int addnum = getItemHasNum(this.roleId, item.getItemId());
                ItemBean itemBean = new ItemBean(item.getItemId(), num, addnum);
                YYLogger.OpItemGetLog(this.roleId, itemBean, counterType);
                Module.logger.info((new StringBuffer()).append("roleId:").append(this.roleId).append(" 添加物品:").append(item.getItemId()).append(" 角色:").append(num).append(" 添加后数量:").append(addnum).append(" 角色:").append(counterType).append(" 角色:").append(reason));
                return AddItemResult.SUCC;
            }
        }
    }

    private boolean doAddItem2AutoPos(ItemBase ib, boolean sendMsg, YYLoggerTuJingEnum logtype) {
        if (this.conf.canpile == 1) {
            this.doDoStack(ib, 0, this.getCapacity() - 1, logtype);
        }

        if (ib.getNumber() > 0) {
            List<Integer> freeposes = this.getFreepos();
            if (freeposes.isEmpty()) {
                return false;
            }

            if (!this.doAddItem2Pos(ib, (Integer)freeposes.get(0), sendMsg, logtype)) {
                return false;
            }
        }

        return true;
    }

    private boolean doAddItem2Pos(ItemBase ib, int pos, boolean sendMsg, YYLoggerTuJingEnum logtype) {
        if (pos >= 0 && pos < this.getCapacity()) {
            ib.getDataItem().setPosition(pos);
            int key = this.doPushItem(ib.getDataItem());
            if (key == 0) {
                return false;
            } else {
                long oldowner = ib.getOwnerid();
                ib.setKey(key);
                ib.setOwnerid(this.roleId);
                ib.setPackId(this.getPackid());
                if (oldowner == 0L) {
                    ib.onInsert();
                }

                if (sendMsg) {
                    SAddItem send = new SAddItem();
                    send.packid = this.getPackid();
                    send.data.add(xItem2Item(ib.itemData, key, this.roleId == oldowner ? 0 : 1));
                    Transaction.tsendWhileCommit(this.roleId, send);
                }

                return true;
            }
        } else {
            return false;
        }
    }

    private boolean doAddItem2Pos(ItemBase bi, int pos, YYLoggerTuJingEnum logtype, boolean sendProcotol) {
        return this.doAddItem2Pos(bi, pos, sendProcotol, logtype);
    }

    protected long addMoney(long money, String reason, YYLoggerTuJingEnum way) {
        if (this.readonly) {
            return 0L;
        } else {
            long res = Long.MAX_VALUE - this.getMoney() <= money ? Long.MAX_VALUE : money + this.getMoney();
            if (res < 0L) {
                Module.logger.error("金钱不足:" + this.roleId);
                return 0L;
            } else if (res > this.conf.maxmoney) {
                return 0L;
            } else {
                long oldvalue = this.getCurrency(1);
                this.pack.getCurrency().put(1, res);
                this.notifyMoney(1);
                long realadd = res - oldvalue;
                return realadd;
            }
        }
    }

    protected boolean doList() {
        if (this.readonly) {
            return false;
        } else {
            Map<Integer, Integer> backup = this.collectItemInfo();
            Set<Integer> toRemove = new TreeSet();
            Set<Integer> toIngore = new TreeSet();

            for(Map.Entry<Integer, Item> item : this.pack.getItems().entrySet()) {
                if (!toIngore.contains(item.getKey()) && !toRemove.contains(item.getKey())) {
                    ItemShuXing attr = Module.getInstance().getItemManager().getAttr(((Item)item.getValue()).getId());
                    if (getItemNum((Item)item.getValue()) >= attr.maxstack) {
                        toIngore.add(item.getKey());
                    } else {
                        for(Map.Entry<Integer, Item> item2 : this.pack.getItems().entrySet()) {
                            if (!toIngore.contains(item2.getKey()) && !toRemove.contains(item2.getKey()) && item2.getKey() != item.getKey() && isStack((Item)item2.getValue(), (Item)item.getValue(), 0)) {
                                int pilednumber = Math.min(attr.maxstack - getItemNum((Item)item.getValue()), getItemNum((Item)item2.getValue()));
                                if (pilednumber > 0) {
                                    doStack((Item)item2.getValue(), (Item)item.getValue(), pilednumber);
                                }

                                if (getItemNum((Item)item2.getValue()) == 0) {
                                    toRemove.add(item2.getKey());
                                }

                                if (getItemNum((Item)item.getValue()) == attr.maxstack) {
                                    toIngore.add(item.getKey());
                                    break;
                                }
                            }
                        }
                    }
                }
            }

            for(Integer key : toRemove) {
                Item xitem = (Item)this.pack.getItems().get(key);
                if (xitem != null) {
                    this.doDelete(key, true);
                }
            }

            this.sort();
            Map<Integer, Integer> after = this.collectItemInfo();
            if (after.size() != backup.size()) {
                Module.logger.error("背包空间不足");
                return false;
            } else {
                for(Map.Entry<Integer, Integer> item : after.entrySet()) {
                    Integer num = (Integer)backup.get(item.getKey());
                    if (num == null || num != (Integer)item.getValue()) {
                        Module.logger.error("背包空间不足");
                        return false;
                    }
                }

                SGetPackInfo res = new SGetPackInfo();
                res.packid = this.getPackid();
                res.baginfo = this.getPackInfo();
                Procedure.psendWhileCommit(this.roleId, res);
                return true;
            }
        }
    }

    protected boolean doListquest() {
        if (this.readonly) {
            return false;
        } else {
            Map<Integer, Integer> backup = this.collectItemInfo();
            Set<Integer> toRemove = new TreeSet();
            Set<Integer> toIngore = new TreeSet();

            for(Map.Entry<Integer, Item> item : this.pack.getItems().entrySet()) {
                if (!toIngore.contains(item.getKey()) && !toRemove.contains(item.getKey())) {
                    ItemShuXing attr = Module.getInstance().getItemManager().getAttr(((Item)item.getValue()).getId());
                    if (getItemNum((Item)item.getValue()) >= attr.maxstack) {
                        toIngore.add(item.getKey());
                    } else {
                        for(Map.Entry<Integer, Item> item2 : this.pack.getItems().entrySet()) {
                            if (!toIngore.contains(item2.getKey()) && !toRemove.contains(item2.getKey()) && item2.getKey() != item.getKey() && isStack((Item)item2.getValue(), (Item)item.getValue(), 0)) {
                                int pilednumber = Math.min(attr.maxstack - getItemNum((Item)item.getValue()), getItemNum((Item)item2.getValue()));
                                if (pilednumber > 0) {
                                    doStack((Item)item2.getValue(), (Item)item.getValue(), pilednumber);
                                }

                                if (getItemNum((Item)item2.getValue()) == 0) {
                                    toRemove.add(item2.getKey());
                                }

                                if (getItemNum((Item)item.getValue()) == attr.maxstack) {
                                    toIngore.add(item.getKey());
                                    break;
                                }
                            }
                        }
                    }
                }
            }

            for(Integer key : toRemove) {
                Item xitem = (Item)this.pack.getItems().get(key);
                if (xitem != null) {
                    this.doDelete(key, true);
                }
            }

            this.sortquest();
            Map<Integer, Integer> after = this.collectItemInfo();
            if (after.size() != backup.size()) {
                Module.logger.error("背包空间不足");
                return false;
            } else {
                for(Map.Entry<Integer, Integer> item : after.entrySet()) {
                    Integer num = (Integer)backup.get(item.getKey());
                    if (num == null || num != (Integer)item.getValue()) {
                        Module.logger.error("背包空间不足");
                        return false;
                    }
                }

                SGetPackInfo res = new SGetPackInfo();
                res.packid = this.getPackid();
                res.baginfo = this.getPackInfo();
                Procedure.psendWhileCommit(this.roleId, res);
                return true;
            }
        }
    }

    public void clear() {
        List<Integer> keys = new ArrayList();

        for(ItemBase bi : this) {
            keys.add(bi.getKey());
            bi.onDelete(YYLoggerTuJingEnum.CLEAR);
        }

        for(int key : keys) {
            this.doDelete(key, true);
        }

    }

    private Map<Integer, Integer> collectItemInfo() {
        Map<Integer, Integer> iteminfo = new HashMap();

        for(Item item : this.pack.getItems().values()) {
            Integer num = (Integer)iteminfo.get(item.getId());
            if (num == null) {
                iteminfo.put(item.getId(), getItemNum(item));
            } else {
                iteminfo.put(item.getId(), getItemNum(item) + num);
            }
        }

        return iteminfo;
    }

    public int getItemNum(int itemid, int flag) {
        int count = 0;
        Map<Integer, Item> items = this.pack.getItems();
        if (null == items) {
            return -1;
        } else {
            for(Item e : items.values()) {
                if (itemid == e.getId() && (e.getFlags() & flag) == 0) {
                    count += getItemNum(e);
                }
            }

            return count;
        }
    }

    public int getItemNumExpStall(int itemid) {
        int count = 0;
        if (this.getPackid() != 1) {
            count = this.getItemNum(itemid, 0);
        } else {
            Map<Integer, Item> items = this.pack.getItems();
            if (null == items) {
                count = -1;
            } else {
                for(int keyinpack : items.keySet()) {
                    ItemBase basicitem = this.getItem(keyinpack);
                    Item e = (Item)items.get(keyinpack);
                    if (itemid == basicitem.getItemId() && (basicitem.getFlags() & 4) == 0) {
                        count += getItemNum(e);
                    }
                }
            }
        }

        return count;
    }

    public List<Integer> getItemNumExpStall(int itemid, int bind, List<Integer> keys) {
        if (this.getPackid() != 1) {
            Map<Integer, Item> items = this.pack.getItems();
            if (null == items) {
                return keys;
            }

            for(Map.Entry<Integer, Item> e : items.entrySet()) {
                if (itemid == ((Item)e.getValue()).getId() && (((Item)e.getValue()).getFlags() & 1) == bind) {
                    keys.add(e.getKey());
                }
            }
        } else {
            Map<Integer, Item> items = this.pack.getItems();
            if (null == items) {
                return keys;
            }

            for(Map.Entry<Integer, Item> entry : items.entrySet()) {
                int keyinpack = (Integer)entry.getKey();
                ItemBase basicitem = this.getItem(keyinpack);
                if (itemid == basicitem.getItemId() && (basicitem.getFlags() & 4) == 0 && (((Item)entry.getValue()).getFlags() & 1) == bind) {
                    keys.add(entry.getKey());
                }
            }
        }

        return keys;
    }

    protected int doPushItem(Item xi) {
        int nextid;
        do {
            nextid = this.incNextId();
            if (nextid == 0) {
                nextid = this.incNextId();
            }
        } while(null != this.pack.getItems().get(nextid));

        if (xi.getTimeout() > 0L) {
        }

        this.pack.getItems().put(nextid, xi);
        if (xi.getUniqueid() == 0L) {
            long uniqueid = Module.getInstance().getItemUniqueIdFactory().getUniqueId();
            xi.setUniqueid(uniqueid);
        }

        return nextid;
    }

    protected Item doDelete(int key, boolean removeuid) {
        return (Item)this.pack.getItems().remove(key);
    }

    public SRefreshNaiJiu getBagEndureInfo() {
        SRefreshNaiJiu ret = new SRefreshNaiJiu();
        ret.packid = this.getPackid();

        for(ItemBase bi : this) {
            if (bi != null && bi.getPackId() == this.getPackid() && bi instanceof EquipItem) {
                EquipItem ei = (EquipItem)bi;
                EquipNaiJiu ee = new EquipNaiJiu();
                ee.keyinpack = ei.getKey();
                ee.endure = ei.getEndure();
                ret.data.add(ee);
            }
        }

        return ret;
    }

    protected abstract int getPackid();

    public fire.pb.Bag getPackInfo() {
        fire.pb.Bag ret = new fire.pb.Bag();
        SRefreshNaiJiu send = new SRefreshNaiJiu();
        send.packid = this.getPackid();

        for(ItemBase bi : this) {
            if (bi != null && bi.getPackId() == this.getPackid()) {
                ret.items.add(xItem2Item(bi.getDataItem(), bi.getKey(), 0));
                if (bi instanceof EquipItem) {
                    EquipItem ei = (EquipItem)bi;
                    if (ei.getEndure() <= 5) {
                        EquipNaiJiu ee = new EquipNaiJiu();
                        ee.keyinpack = ei.getKey();
                        ee.endure = ei.getEndure();
                        send.data.add(ee);
                    }
                } else if (bi instanceof TimeOutItem) {
                    bi.onTimeout();
                }
            }
        }

        ret.capacity = this.getCapacity();

        for(Map.Entry<Integer, Long> currency : this.pack.getCurrency().entrySet()) {
            ret.currency.put(((Integer)currency.getKey()).byteValue(), currency.getValue());
        }

        if (!send.data.isEmpty()) {
            if (Transaction.current() != null) {
                Procedure.psendWhileCommit(this.roleId, send);
            } else {
                Onlines.getInstance().send(this.roleId, send);
            }
        }

        return ret;
    }

    public int getCapacity() {
        return this.pack.getCapacity();
    }

    public long getContribution() {
        return !this.pack.getCurrency().containsKey(4) ? 0L : (Long)this.pack.getCurrency().get(4);
    }

    public long getCreditPoint() {
        return !this.pack.getCurrency().containsKey(13) ? 0L : (Long)this.pack.getCurrency().get(13);
    }

    public long getCurrency(int currencyType) {
        return !this.pack.getCurrency().containsKey(currencyType) ? 0L : (Long)this.pack.getCurrency().get(currencyType);
    }

    private int getFirstFreePos(int page) {
        if (this.isFull()) {
            return -1;
        } else {
            int startpos = (page - 1) * 25;
            int endpos = page * 25 - 1;
            int fpos = Integer.MAX_VALUE;

            for(int pos : this.getFreepos()) {
                if (pos >= startpos && pos <= endpos && fpos > pos) {
                    fpos = pos;
                }
            }

            if (fpos == Integer.MAX_VALUE) {
                return -1;
            } else {
                return fpos;
            }
        }
    }

    public ArrayList<Integer> getFreepos() {
        ArrayList<Integer> frees = new ArrayList();

        for(int i = 0; i < this.getCapacity(); ++i) {
            frees.add(i);
        }

        for(Item xi : this.pack.getItems().values()) {
            frees.remove(Integer.valueOf(xi.getPosition()));
        }

        Collections.sort(frees);
        return frees;
    }

    protected int fixInvalidPositions() {
        if (this.readonly) {
            return 0;
        } else {
            int capacity = this.getCapacity();
            if (capacity <= 0) {
                return 0;
            } else {
                boolean[] used = new boolean[capacity];
                ArrayList<Item> needFix = new ArrayList();
                ArrayList<Integer> keys = new ArrayList(this.pack.getItems().keySet());
                Collections.sort(keys);

                for(int key : keys) {
                    Item xi = (Item)this.pack.getItems().get(key);
                    if (xi != null) {
                        int pos = xi.getPosition();
                        if (pos >= 0 && pos < capacity && !used[pos]) {
                            used[pos] = true;
                        } else {
                            needFix.add(xi);
                        }
                    }
                }

                if (needFix.isEmpty()) {
                    return 0;
                } else {
                    ArrayList<Integer> freepos = new ArrayList();

                    for(int i = 0; i < capacity; ++i) {
                        if (!used[i]) {
                            freepos.add(i);
                        }
                    }

                    int fixed = 0;

                    for(Item xi : needFix) {
                        if (freepos.isEmpty()) {
                            break;
                        }

                        int newPos = (Integer)freepos.remove(0);
                        if (xi.getPosition() != newPos) {
                            xi.setPosition(newPos);
                            ++fixed;
                        }
                    }

                    return fixed;
                }
            }
        }
    }

    public long getGold() {
        return !this.pack.getCurrency().containsKey(2) ? 0L : (Long)this.pack.getCurrency().get(2);
    }

    public ItemBase getItem(int key) {
        Item item = (Item)this.pack.getItems().get(key);
        return item == null ? null : this.toBasicItem(item, key);
    }

    public ItemBase getItemByPos(int pos) {
        Map.Entry<Integer, Item> item = this.getXitemByPos(pos);
        return item == null ? null : this.toBasicItem((Item)item.getValue(), (Integer)item.getKey());
    }

    public String getItemLogsByKeys(List<Integer> keyinpacks) {
        StringBuilder sb = new StringBuilder();

        for(int keyinpack : keyinpacks) {
            ItemBase item = this.getItem(keyinpack);
            if (item != null) {
                sb.append(item.getItemLog());
            }
        }

        return sb.toString();
    }

    public long getMaxMoney() {
        return this.conf.maxmoney;
    }

    public long getMoney() {
        return !this.pack.getCurrency().containsKey(1) ? 0L : (Long)this.pack.getCurrency().get(1);
    }

    public int getRemainSize() {
        return this.getCapacity() - this.size();
    }

    private Map.Entry<Integer, Item> getXitemByPos(int pos) {
        if (pos < 0) {
            return null;
        } else {
            for(Map.Entry<Integer, Item> item : this.pack.getItems().entrySet()) {
                if (((Item)item.getValue()).getPosition() == pos) {
                    return item;
                }
            }

            return null;
        }
    }

    protected int incNextId() {
        int id = this.pack.getNextid() + 1;
        if (id < 0) {
            throw new RuntimeException("背包key不存在");
        } else {
            this.pack.setNextid(id);
            return id;
        }
    }

    protected boolean isBind(Item xi) {
        return (xi.getFlags() & 1) == 1;
    }

    public boolean isEmpty() {
        return this.pack.getItems().size() == 0;
    }

    public boolean isFull() {
        return this.size() >= this.getCapacity();
    }

    public boolean isPosFree(int pos) {
        if (pos >= 0 && pos <= this.getCapacity()) {
            for(Item item : this.pack.getItems().values()) {
                if (item.getPosition() == pos) {
                    return false;
                }
            }

            return true;
        } else {
            return false;
        }
    }

    public Iterator<ItemBase> iterator() {
        return new PackIterator();
    }

    public final boolean TransIn(ItemBase ib, int pos) {
        return this.TransIn(ib, pos, (ItemBase)null);
    }

    protected boolean TransIn(ItemBase ib, int pos, ItemBase dstitem) {
        if (pos == -1) {
            return this.doAddItem2AutoPos(ib, true, YYLoggerTuJingEnum.GENERAL);
        } else if (dstitem != null && dstitem.getPosition() == pos) {
            this.stackItem(dstitem, ib.itemData.getNumber(), ib.itemData.getNumbermap(), YYLoggerTuJingEnum.GENERAL);
            return true;
        } else {
            return this.doAddItem2Pos(ib, pos, YYLoggerTuJingEnum.GENERAL, true);
        }
    }

    protected boolean TranItemToPage(ItemBase item, int page) {
        if (this.conf.canpile == 1) {
            int startpos = (page - 1) * 25;
            int endpos = page * 25 - 1;
            this.doDoStack(item, startpos, endpos);
        }

        if (item.getNumber() > 0) {
            int xpos = this.getFirstFreePos(page);
            if (xpos == -1) {
                return false;
            }

            if (!this.doAddItem2Pos(item, xpos, YYLoggerTuJingEnum.GENERAL, true)) {
                return false;
            }
        }

        return true;
    }

    public ItemBase TransOut(int key, int number, String reason) {
        Item xi = (Item)this.pack.getItems().get(key);
        if (xi == null) {
            return null;
        } else {
            int itemnum = getItemNum(xi);
            if (number > itemnum) {
                return null;
            } else {
                Item removed;
                if (number != -1 && number != itemnum) {
                    removed = xi.copy();
                    Map<Integer, Integer> splitnum = doCut(xi, number);
                    if (getItemNum(xi) <= 0) {
                        throw new RuntimeException("物品数据有错误");
                    }

                    SItemNumChange send = new SItemNumChange();
                    send.packid = this.getPackid();
                    send.curnum = getItemNum(xi);
                    send.keyinpack = key;
                    Transaction.tsendWhileCommit(this.roleId, send);
                    removed.setNumber(0);
                    removed.getNumbermap().clear();
                    stackNumber(splitnum, removed);
                    removed.setUniqueid(0L);
                } else {
                    removed = this.doDelete(key, false);
                    SDelItem send = new SDelItem();
                    send.packid = this.getPackid();
                    send.itemkey = key;
                    Transaction.tsendWhileCommit(this.roleId, send);
                }

                ItemBase item = Module.getInstance().getItemManager().toItemBase(removed, this.roleId, this.getPackid(), key);
                return item;
            }
        }
    }

    protected void notifyMoney(int type) {
        SRefreshCurrency refmoney = new SRefreshCurrency();
        refmoney.packid = this.getPackid();
        refmoney.currency.put((byte)type, this.getCurrency(type));
        Procedure.psendWhileCommit(this.roleId, refmoney);
    }

    private int doDoStack(int itemid, int num, int numbertype, int initflag, int maxadd, YYLoggerTuJingEnum logtype) {
        int added = 0;

        for(ItemBase bi : this) {
            if (added >= maxadd) {
                return added;
            }

            int flag = initflag == -1 ? bi.getIniFlag() : initflag;
            if (bi.getItemId() == itemid && bi.getFlags() == flag && isStack(bi.getDataItem())) {
                int maxpile = bi.getItemAttr().maxstack - bi.getNumber();
                if (maxpile > 0) {
                    maxpile = Math.min(maxpile, num - added);
                    int pilenum = Math.min(maxadd - added, maxpile);
                    if (numbertype == 0) {
                        this.stackItem(bi, pilenum, (Map)null, logtype);
                    } else {
                        Map<Integer, Integer> numbermap = new HashMap();
                        numbermap.put(numbertype, pilenum);
                        this.stackItem(bi, 0, numbermap, logtype);
                    }

                    added += pilenum;
                }
            }
        }

        return added;
    }

    private void doDoStack(ItemBase bi, int minpos, int maxpos) {
        this.doDoStack(bi, minpos, maxpos, YYLoggerTuJingEnum.GENERAL);
    }

    private void doDoStack(ItemBase bi, int minpos, int maxpos, YYLoggerTuJingEnum countertype) {
        int maxheap = bi.getItemAttr().maxstack;
        if (maxheap > 1) {
            for(Map.Entry<Integer, Item> xitem : this.pack.getItems().entrySet()) {
                if (((Item)xitem.getValue()).getPosition() >= minpos && ((Item)xitem.getValue()).getPosition() <= maxpos && isStack(bi.getDataItem(), (Item)xitem.getValue(), 0)) {
                    int heapnum = Math.min(bi.getNumber(), maxheap - getItemNum((Item)xitem.getValue()));
                    if (heapnum > 0) {
                        doStack(bi.getDataItem(), (Item)xitem.getValue(), heapnum);
                        SItemNumChange send = new SItemNumChange();
                        send.packid = this.getPackid();
                        send.curnum = getItemNum((Item)xitem.getValue());
                        send.keyinpack = (Integer)xitem.getKey();
                        Transaction.tsendWhileCommit(this.roleId, send);
                        if (bi.getDataItem().getMarkettime() > 0L) {
                            long oldowner = bi.getOwnerid();
                            SAddItem addItem = new SAddItem();
                            addItem.packid = this.getPackid();
                            addItem.data.add(xItem2Item((Item)xitem.getValue(), (Integer)xitem.getKey(), this.roleId == oldowner ? 0 : 1, getItemNum((Item)xitem.getValue())));
                            Procedure.psendWhileCommit(this.roleId, addItem);
                        }

                        if (bi.getNumber() <= 0) {
                            break;
                        }
                    }
                }
            }

            if (bi.getNumber() <= 0 && bi.getPackId() == this.getPackid() && bi.getOwnerid() == this.roleId) {
                this.doDelete(bi.getKey(), true);
                SDelItem send = new SDelItem();
                send.packid = bi.getPackId();
                send.itemkey = bi.getKey();
                Procedure.psendWhileCommit(this.roleId, send);
            }

        }
    }

    protected void stackItem(ItemBase ib, int num, Map<Integer, Integer> nummap, YYLoggerTuJingEnum countertype) {
        assert ib.getPackId() == this.getPackid();

        assert ib.getOwnerid() == this.roleId;

        ib.itemData.setNumber(ib.itemData.getNumber() + num);
        int addnum = num;
        if (nummap != null) {
            for(Map.Entry<Integer, Integer> e : nummap.entrySet()) {
                Integer oldnum = (Integer)ib.itemData.getNumbermap().get(e.getKey());
                if (oldnum == null) {
                    ib.itemData.getNumbermap().put(e.getKey(), e.getValue());
                } else {
                    ib.itemData.getNumbermap().put(e.getKey(), (Integer)e.getValue() + oldnum);
                }

                addnum += (Integer)e.getValue();
            }
        }

        if (addnum != 0) {
            SItemNumChange modnum = new SItemNumChange();
            modnum.packid = this.getPackid();
            modnum.curnum = ib.getNumber();
            modnum.keyinpack = ib.getKey();
            Procedure.psendWhileCommit(this.roleId, modnum);
        }

    }

    private boolean processDoAddItem(ItemBase ib, int p, YYLoggerTuJingEnum logtype) {
        if (p == -1) {
            return this.doAddItem2AutoPos(ib, true, logtype);
        } else {
            ItemBase dstitem = this.getItemByPos(p);
            if (dstitem == null) {
                if (!this.doAddItem2Pos(ib, p, logtype, true)) {
                    return false;
                }
            } else {
                if (!isStack(ib.itemData, dstitem.itemData, 0)) {
                    return false;
                }

                int maxpilenum = dstitem.getItemAttr().maxstack - dstitem.getNumber();
                if (maxpilenum < ib.getNumber()) {
                    return false;
                }

                this.stackItem(dstitem, ib.getDataItem().getNumber(), ib.getDataItem().getNumbermap(), logtype);
            }

            return true;
        }
    }

    protected void psendMsgNotify(int msgId, List<String> parameters) {
        MessageMgr.psendMsgNotify(this.roleId, msgId, parameters);
    }

    public boolean cleanAllItemFlag(int flag) {
        if (this.readonly) {
            return false;
        } else {
            Iterator<Integer> iter = this.pack.getItems().keySet().iterator();

            while(iter.hasNext()) {
                Item xi = (Item)this.pack.getItems().get(iter.next());
                if (xi == null) {
                    return false;
                }

                xi.setFlags(xi.getFlags() & ~flag);
            }

            return true;
        }
    }

    public int cleanBindingItemById(int itemid, int num, YYLoggerTuJingEnum countertype, int xiangguanid, String reason) {
        if (this.readonly) {
            return 0;
        } else if (num <= 0) {
            return 0;
        } else {
            int leftnum = num;
            Map<Integer, Integer> removekeys = new HashMap();

            for(ItemBase item : this) {
                if (leftnum <= 0) {
                    break;
                }

                if (item != null && item.getItemId() == itemid && this.isBind(item.getDataItem())) {
                    int movenum = Math.min(leftnum, item.getNumber());
                    leftnum -= movenum;
                    removekeys.put(item.getKey(), movenum);
                }
            }

            for(Map.Entry<Integer, Integer> removekey : removekeys.entrySet()) {
                this.removeItemWithKey((Integer)removekey.getKey(), (Integer)removekey.getValue(), countertype, xiangguanid, reason);
            }

            return num - leftnum;
        }
    }

    public boolean cleanFlag(int key, int flag, int packid) {
        if (this.readonly) {
            return false;
        } else {
            Item xi = (Item)this.pack.getItems().get(key);
            if (xi == null) {
                return true;
            } else {
                xi.setFlags(xi.getFlags() & ~flag);
                SItemSign ref = new SItemSign(key, xi.getFlags(), packid);
                Procedure.psendWhileCommit(this.roleId, ref);
                return true;
            }
        }
    }

    public int removeItemById(int itemid, int num, YYLoggerTuJingEnum countertype, int xiangguanid, String reason) {
        return this.removeItemById(itemid, num, countertype, xiangguanid, reason, false, 0);
    }

    public int removeItemById(int itemid, int num, YYLoggerTuJingEnum countertype, int xiangguanid, String reason, boolean isLock) {
        return this.removeItemById(itemid, num, countertype, xiangguanid, reason, isLock, 0);
    }

    public int removeItemById(int itemid, int num, YYLoggerTuJingEnum countertype, int xiangguanid, String reason, boolean isLock, int isBind) {
        if (this.readonly) {
            return 0;
        } else if (num <= 0) {
            return 0;
        } else {
            int leftnum = num;
            Map<Integer, Integer> removekeys = new HashMap();
            boolean b = false;
            if (isBind == 1) {
                b = true;
            }

            for(ItemBase item : this) {
                if (leftnum <= 0) {
                    break;
                }

                if (item != null && item.getItemId() == itemid && (isBind == 0 || !b || !this.isBind(item.getDataItem()))) {
                    int movenum = Math.min(leftnum, item.getNumber());
                    leftnum -= movenum;
                    removekeys.put(item.getKey(), movenum);
                }
            }

            for(Map.Entry<Integer, Integer> removekey : removekeys.entrySet()) {
                this.removeItemWithKey((Integer)removekey.getKey(), (Integer)removekey.getValue(), countertype, xiangguanid, reason);
            }

            if (num - leftnum > 0) {
                Module.logger.info((new StringBuffer()).append("roleId:").append(this.roleId).append(" 删除物品id:").append(itemid).append(" 角色:").append(num).append(" 角色:").append(countertype).append(" 角色:").append(reason));
            }

            return num - leftnum;
        }
    }

    public int removeItemWithKey(int key, int num, YYLoggerTuJingEnum countertype, int xiangguanid, String reason) {
        ItemBase bi = this.TransOut(key, num, reason);
        if (bi == null) {
            return 0;
        } else {
            List<Number> itemStrs = new ArrayList();
            itemStrs.add(bi.getItemId());
            itemStrs.add(bi.getNumber());
            itemStrs.add(bi.itemData.getUniqueid());
            bi.onDelete(countertype);
            int hasnum = getItemHasNum(this.roleId, bi.getItemId());
            ItemBean itemBean = new ItemBean(bi.getItemId(), num, hasnum);
            YYLogger.OpItemUseLog(this.roleId, itemBean, countertype);
            Module.logger.info((new StringBuffer()).append("roleId:").append(this.roleId).append(" 删除物品id:").append(bi.getItemId()).append(" 角色:").append(num).append(" 角色:").append(countertype).append(" 角色:").append(reason));
            return bi.getNumber();
        }
    }

    public int removeItemByPos(int pos, int num, YYLoggerTuJingEnum countertype, int xiangguanid, String reason) {
        if (this.readonly) {
            return 0;
        } else {
            for(ItemBase item : this) {
                if (item.itemData.getPosition() == pos) {
                    return this.removeItemWithKey(item.getKey(), num, countertype, xiangguanid, reason);
                }
            }

            return 0;
        }
    }

    public int size() {
        return this.pack.getItems().size();
    }

    protected int sort() {
        if (this.readonly) {
            return 0;
        } else {
            int count = 0;
            SortedSet<ItemBase> allItems = new TreeSet(new ItemComparator());

            for(ItemBase item : this) {
                if (item.getPackId() != 5) {
                    allItems.add(item);
                }
            }

            int pos = 0;

            for(ItemBase i : allItems) {
                if (i.getPosition() != pos) {
                    i.getDataItem().setPosition(pos);
                    ++count;
                }

                ++pos;
            }

            return count;
        }
    }

    protected int sortquest() {
        if (this.readonly) {
            return 0;
        } else {
            int count = 0;
            SortedSet<ItemBase> allItems = new TreeSet(new ItemComparator());

            for(ItemBase item : this) {
                if (item.getPackId() == 5) {
                    allItems.add(item);
                }
            }

            int pos = 0;

            for(ItemBase i : allItems) {
                if (i.getPosition() != pos) {
                    i.getDataItem().setPosition(pos);
                    ++count;
                }

                ++pos;
            }

            return count;
        }
    }

    private ItemBase toBasicItem(Item item, int key) {
        return Module.getInstance().getItemManager().toItemBase(item, this.roleId, this.getPackid(), key);
    }

    public static final fire.pb.Item transItemData2SendData(Item dstItem, int key, int isNew) {
        return xItem2Item(dstItem, key, isNew);
    }

    private class PackIterator implements Iterator<ItemBase> {
        private final Iterator<Integer> iter;

        public PackIterator() {
            this.iter = ItemMaps.this.pack.getItems().keySet().iterator();
        }

        public boolean hasNext() {
            return this.iter.hasNext();
        }

        public ItemBase next() {
            int key = (Integer)this.iter.next();
            Item item = (Item)ItemMaps.this.pack.getItems().get(key);
            return item == null ? null : Module.getInstance().getItemManager().toItemBase(item, ItemMaps.this.roleId, ItemMaps.this.getPackid(), key);
        }

        public void remove() {
            throw new RuntimeException("临时不支持删除");
        }
    }
}
