//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.groceries;

import fire.pb.activity.timernpc.TimerNpcService;
import fire.pb.buff.Module;
import fire.pb.item.Commontext;
import fire.pb.item.GroceryItem;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemMgr;
import fire.pb.item.UseItemHandler;
import fire.pb.item.ZhaoHuanLingWithEvent;
import fire.pb.item.Commontext.UseResult;
import fire.pb.main.ConfigManager;
import fire.pb.map.SceneManager;
import fire.pb.mission.treasuremap.BaoTuMapManager;
import fire.pb.mission.treasuremap.EventTimerGroupData;
import fire.pb.mission.treasuremap.EventTimerNpcData;
import fire.pb.mission.treasuremap.GiftByEvent;
import fire.pb.talk.MessageMgr;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.TimeUnit;
import mkdb.Executor;
import xbean.Item;
import xbean.Properties;

public class ZhaoHuanLingItem extends GroceryItem {
    public ZhaoHuanLingItem(ItemMgr var1, int var2) {
        super(var1, var2);
    }

    public ZhaoHuanLingItem(ItemMgr var1, Item var2) {
        super(var1, var2);
    }

    protected UseItemHandler getUseItemHandler() {
        return new ZhaoHuanLingItemHandler();
    }

    private class ZhaoHuanLingItemHandler implements UseItemHandler {
        private ZhaoHuanLingItemHandler() {
        }

        public Commontext.UseResult onUse(long var1, ItemBase var3, int var4) {
            Properties var5 = xtable.Properties.get(var1);
            if (null != var5 && !Module.existState(var1, 507004)) {
                int var6 = ZhaoHuanLingItem.this.getItemId();
                ZhaoHuanLingWithEvent var7 = (ZhaoHuanLingWithEvent)ConfigManager.getInstance().getConf(ZhaoHuanLingWithEvent.class).get(var6);
                if (null == var7) {
                    System.out.println("z召唤令道具表配置错误,召唤令id:" + var6 + "没有关联对应事件!");
                    return UseResult.FAIL;
                } else {
                    EventTimerGroupData var8 = this.createEventMonster(var1, var7.getEventId());
                    if (null == var8) {
                        return UseResult.FAIL;
                    } else {
                        ArrayList var9 = new ArrayList(4);
                        var9.add(var5.getRolename());
                        StringBuilder var10 = new StringBuilder();
                        Iterator var11 = var8.sceneList.iterator();

                        while(var11.hasNext()) {
                            var10.append(SceneManager.getMapNameByMapID((Integer)var11.next()));
                            var10.append(" ");
                        }

                        var10.append("等地区");
                        var9.add(var10.toString());
                        var9.add(ZhaoHuanLingItem.this.getName());
                        SceneManager.sendAll(MessageMgr.getMsgNotify(191118, 0, var9));
                        return UseResult.SUCC;
                    }
                }
            } else {
                MessageMgr.psendMsgNotify(var1, 142383, (List)null);
                return UseResult.FAIL;
            }
        }

        private EventTimerGroupData createEventMonster(final long var1, int var3) {
            final GiftByEvent var4 = BaoTuMapManager.getInstance().getEventGift(var3);
            if (var4 == null) {
                System.out.println(var1 + ",触发事件id错误:" + var3);
                return null;
            } else {
                EventTimerNpcData var5 = BaoTuMapManager.getInstance().getEventTimerNpcData(var4.group);
                if (var5 == null) {
                    System.out.println("事件刷怪组数据读取错误," + var4.name);
                    return null;
                } else {
                    final EventTimerGroupData var6 = BaoTuMapManager.getInstance().getEventTimerGroupData(var5, var1);
                    if (var6 == null) {
                        System.out.println("事件刷怪组详细数据读取错误," + var4.name);
                        return null;
                    } else {
                        if (var6.delaysec > 0) {
                            Executor.getInstance().schedule(new Runnable() {
                                public void run() {
                                    TimerNpcService.getInstance().createTimerNpcByData(var6, var4.noticeId, var1);
                                }
                            }, (long)var6.delaysec, TimeUnit.SECONDS);
                            ArrayList var7 = new ArrayList(1);
                            var7.add(String.valueOf(var6.delaysec));
                            SceneManager.sendAll(MessageMgr.getMsgNotify(var6.delaynoticeid, 0, var7));
                        } else {
                            TimerNpcService.getInstance().createTimerNpcByData(var6, var4.noticeId, var1);
                        }

                        MessageMgr.psendMsgNotifyWhileCommit(var1, var4.messageId, (List)null);
                        return var6;
                    }
                }
            }
        }
    }
}
