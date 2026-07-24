//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.ranklist.jianglifasong;

import fire.pb.PropRole;
import fire.pb.RoleConfigManager;
import fire.pb.compensation.CreateSingleCompensation;
import fire.pb.game.Srankawardrewarcw;
import fire.pb.game.Srankawardreward;
import fire.pb.game.Srankawardrewardrw;
import fire.pb.main.ConfigManager;
import fire.pb.map.SceneManager;
import fire.pb.talk.MessageMgr;
import fire.pb.talk.STransChatMessageNotify2Client;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import xbean.PetScoreListRecord;
import xbean.Pod;
import xbean.RoleRankRecord;
import xbean.RoleZongheRankRecord;
import xbean.ServiceInfo;
import xbean.SingleCompensationAward;
import xtable.Petscorelist;
import xtable.Rolerankdatalist;
import xtable.Rolezonghelist;
import xtable.Serviceinfos;

public class WeeklyRewardManager {
    static Calendar calendar = Calendar.getInstance();
    static final int weekOfMonth;

    public static void WeeklyReward() {
        int tianshu = Integer.parseInt(RoleConfigManager.getRoleRFrankingConfig(11001).getValue());
        ServiceInfo serviceInfo = Serviceinfos.select(1);
        if (serviceInfo.getDays() == tianshu) {
            Map<Integer, Srankawardreward> conf = ConfigManager.getInstance().getConf(Srankawardreward.class);
            List<RoleZongheRankRecord> records = Rolezonghelist.select(1).getRecords();
            SingleCompensationAward newSingleCompensationAwardData = Pod.newSingleCompensationAwardData();
            SingleCompensationAward newSingleCompensationAwardData2 = Pod.newSingleCompensationAwardData();
            SingleCompensationAward newSingleCompensationAwardData3 = Pod.newSingleCompensationAwardData();
            SingleCompensationAward newSingleCompensationAwardData4 = Pod.newSingleCompensationAwardData();
            SingleCompensationAward newSingleCompensationAwardData5 = Pod.newSingleCompensationAwardData();
            SingleCompensationAward newSingleCompensationAwardData6 = Pod.newSingleCompensationAwardData();
            SingleCompensationAward newSingleCompensationAwardData7 = Pod.newSingleCompensationAwardData();

            for(int i = 0; i < records.size(); ++i) {
                LinkedList<SingleCompensationAward> linkedList = new LinkedList();
                Srankawardreward SWeeklyrewardszh = (Srankawardreward)conf.get(i + 1);
                RoleZongheRankRecord roleZongheRankRecord = (RoleZongheRankRecord)records.get(i);
                if (SWeeklyrewardszh == null || roleZongheRankRecord == null) {
                    return;
                }

                int money = 0;
                int updatedMoney = 0;
                String dayimg = SWeeklyrewardszh.getdayimg();
                String zhufu = SWeeklyrewardszh.getzhufu();
                String ganxie = SWeeklyrewardszh.getganxie();
                SWeeklyrewardszh.getItem1id();
                SWeeklyrewardszh.getItem2id();
                SWeeklyrewardszh.getItem3id();
                SWeeklyrewardszh.getItem4id();
                System.out.println("getItem4id :" + SWeeklyrewardszh.getItem4id());
                SWeeklyrewardszh.getItem5id();
                System.out.println("getItem5id :" + SWeeklyrewardszh.getItem5id());
                SWeeklyrewardszh.getItem6id();
                System.out.println("getItem6id :" + SWeeklyrewardszh.getItem6id());
                SWeeklyrewardszh.getItem1num();
                SWeeklyrewardszh.getItem2num();
                SWeeklyrewardszh.getItem3num();
                SWeeklyrewardszh.getItem4num();
                SWeeklyrewardszh.getItem5num();
                SWeeklyrewardszh.getItem6num();
                int i2 = i + 1;
                System.out.println("dayimg: " + dayimg);
                newSingleCompensationAwardData.setType(0);
                newSingleCompensationAwardData.setId((long)SWeeklyrewardszh.getItem1id());
                newSingleCompensationAwardData.setNum((long)SWeeklyrewardszh.getItem1num());
                newSingleCompensationAwardData.setFlag(1L);
                linkedList.add(newSingleCompensationAwardData);
                newSingleCompensationAwardData2.setType(0);
                newSingleCompensationAwardData2.setId((long)SWeeklyrewardszh.getItem2id());
                newSingleCompensationAwardData2.setNum((long)SWeeklyrewardszh.getItem2num());
                newSingleCompensationAwardData2.setFlag(1L);
                linkedList.add(newSingleCompensationAwardData2);
                newSingleCompensationAwardData3.setType(0);
                newSingleCompensationAwardData3.setId((long)SWeeklyrewardszh.getItem3id());
                newSingleCompensationAwardData3.setNum((long)SWeeklyrewardszh.getItem3num());
                newSingleCompensationAwardData3.setFlag(1L);
                linkedList.add(newSingleCompensationAwardData3);
                newSingleCompensationAwardData4.setType(0);
                newSingleCompensationAwardData4.setId((long)SWeeklyrewardszh.getItem4id());
                newSingleCompensationAwardData4.setNum((long)SWeeklyrewardszh.getItem4num());
                newSingleCompensationAwardData4.setFlag(1L);
                linkedList.add(newSingleCompensationAwardData4);
                newSingleCompensationAwardData5.setType(0);
                newSingleCompensationAwardData5.setId((long)SWeeklyrewardszh.getItem5id());
                newSingleCompensationAwardData5.setNum((long)SWeeklyrewardszh.getItem5num());
                newSingleCompensationAwardData5.setFlag(1L);
                linkedList.add(newSingleCompensationAwardData5);
                newSingleCompensationAwardData6.setType(0);
                newSingleCompensationAwardData6.setId((long)SWeeklyrewardszh.getItem6id());
                newSingleCompensationAwardData6.setNum((long)SWeeklyrewardszh.getItem6num());
                newSingleCompensationAwardData6.setFlag(1L);
                linkedList.add(newSingleCompensationAwardData6);
                newSingleCompensationAwardData7.setType(0);
                newSingleCompensationAwardData7.setId((long)SWeeklyrewardszh.getItem6id());
                newSingleCompensationAwardData7.setNum((long)SWeeklyrewardszh.getItem6num());
                newSingleCompensationAwardData7.setFlag(1L);
                PropRole pRole1 = new PropRole(roleZongheRankRecord.getRoleid(), true);

                try {
                    CreateSingleCompensation.createFromYunYing(roleZongheRankRecord.getRoleid(), linkedList, dayimg, "<T t='' c='ff875832'/><B></B><T t='亲爱的[' c='ff875832'/><T t='" + pRole1.getName() + "' c='ff6ddcf6'/><T t=']玩家:' c='ff875832'/><B></B><T t='    恭喜您在综合战力排行榜' c='FF00BF00'/><T t='活动中展露头角获得第' c='ff875832'/><T t=' [" + i2 + "名] ' c='FF00BF00'/><T t='的好成绩。' c='ff875832'/><E e='200' /><E e='200' /><B></B><T t='感谢:' c='ff875832'/><T t='" + ganxie + "！' c='FFFF1B00'/><B></B><T t='祝您:' c='ff875832'/><T t='" + zhufu + "' c='FFFF1B00'/><E e='157' /><E e='159' /><E e='217' /><E e='243' /><E e='246' /><B></B><T t='' c='ff875832'/><B></B>", 0L, "冲榜奖励2", "冲榜奖励3").submit().get(2L, TimeUnit.SECONDS);
                } catch (Exception e) {
                    e.printStackTrace();
                    return;
                }

                List<String> paras1 = new ArrayList();
                paras1.add(pRole1.getName());
                paras1.add(String.valueOf(dayimg));
                paras1.add(String.valueOf(tianshu));
                int ts = Integer.parseInt(RoleConfigManager.getRoleStsommonConfig(8).getValue());
                STransChatMessageNotify2Client ssmn12 = MessageMgr.getMsgNotify(ts, 0, paras1);
                SceneManager.sendAll(ssmn12);
                System.out.println("发送" + tianshu + "日综合战力榜第：" + i2 + "名,(" + roleZongheRankRecord.getRoleid() + ")获得" + SWeeklyrewardszh.getdayimg() + ")");
                zonghewriteTxt((new SimpleDateFormat("yyyy-MM-dd HH:mm:ss")).format(new Date(Long.parseLong(String.valueOf(System.currentTimeMillis())))) + "综合战力榜发放记录：角色ID【" + roleZongheRankRecord.getRoleid() + "】【" + pRole1.getName() + "】 ，获得名称: [" + i2 + "] 名，获得的物品: 【" + linkedList + "】\n");
            }
        }

    }

    private static void zonghewriteTxt(String s) {
        try {
            File file = new File("综合榜发放记录.txt");
            if (!file.exists()) {
                file.createNewFile();
            }

            FileWriter fileWriter = new FileWriter(file.getName(), true);
            fileWriter.write(s);
            fileWriter.close();
        } catch (IOException ex) {
            ex.printStackTrace();
        }

    }

    public static void WeeklyrenwuReward() {
        int tianshu = Integer.parseInt(RoleConfigManager.getRoleRFrankingConfig(11001).getValue());
        ServiceInfo serviceInfo = Serviceinfos.select(1);
        if (serviceInfo.getDays() == tianshu) {
            Map<Integer, Srankawardrewardrw> conf = ConfigManager.getInstance().getConf(Srankawardrewardrw.class);
            List<RoleRankRecord> records = Rolerankdatalist.select(1).getRecords();
            SingleCompensationAward newSingleCompensationAwardData = Pod.newSingleCompensationAwardData();
            SingleCompensationAward newSingleCompensationAwardData2 = Pod.newSingleCompensationAwardData();
            SingleCompensationAward newSingleCompensationAwardData3 = Pod.newSingleCompensationAwardData();
            SingleCompensationAward newSingleCompensationAwardData4 = Pod.newSingleCompensationAwardData();
            SingleCompensationAward newSingleCompensationAwardData5 = Pod.newSingleCompensationAwardData();
            SingleCompensationAward newSingleCompensationAwardData6 = Pod.newSingleCompensationAwardData();

            for(int i = 0; i < records.size(); ++i) {
                LinkedList<SingleCompensationAward> linkedList = new LinkedList();
                Srankawardrewardrw SWeeklyrewardsrw = (Srankawardrewardrw)conf.get(i + 1);
                RoleRankRecord current = (RoleRankRecord)records.get(i);
                if (SWeeklyrewardsrw == null || current == null) {
                    return;
                }

                int money = 0;
                int updatedMoney = 0;
                String dayimg = SWeeklyrewardsrw.getdayimg();
                String zhufu = SWeeklyrewardsrw.getzhufu();
                String ganxie = SWeeklyrewardsrw.getganxie();
                SWeeklyrewardsrw.getItem1id();
                SWeeklyrewardsrw.getItem2id();
                SWeeklyrewardsrw.getItem3id();
                SWeeklyrewardsrw.getItem4id();
                SWeeklyrewardsrw.getItem5id();
                SWeeklyrewardsrw.getItem6id();
                SWeeklyrewardsrw.getItem1num();
                SWeeklyrewardsrw.getItem2num();
                SWeeklyrewardsrw.getItem3num();
                SWeeklyrewardsrw.getItem4num();
                SWeeklyrewardsrw.getItem5num();
                SWeeklyrewardsrw.getItem6num();
                int i2 = i + 1;
                System.out.println("dayimg: " + dayimg);
                newSingleCompensationAwardData.setType(0);
                newSingleCompensationAwardData.setId((long)SWeeklyrewardsrw.getItem1id());
                newSingleCompensationAwardData.setNum((long)SWeeklyrewardsrw.getItem1num());
                newSingleCompensationAwardData.setFlag(1L);
                linkedList.add(newSingleCompensationAwardData);
                newSingleCompensationAwardData2.setType(0);
                newSingleCompensationAwardData2.setId((long)SWeeklyrewardsrw.getItem2id());
                newSingleCompensationAwardData2.setNum((long)SWeeklyrewardsrw.getItem2num());
                newSingleCompensationAwardData2.setFlag(1L);
                linkedList.add(newSingleCompensationAwardData2);
                newSingleCompensationAwardData3.setType(0);
                newSingleCompensationAwardData3.setId((long)SWeeklyrewardsrw.getItem3id());
                newSingleCompensationAwardData3.setNum((long)SWeeklyrewardsrw.getItem3num());
                newSingleCompensationAwardData3.setFlag(1L);
                linkedList.add(newSingleCompensationAwardData3);
                newSingleCompensationAwardData4.setType(0);
                newSingleCompensationAwardData4.setId((long)SWeeklyrewardsrw.getItem4id());
                newSingleCompensationAwardData4.setNum((long)SWeeklyrewardsrw.getItem4num());
                newSingleCompensationAwardData4.setFlag(1L);
                linkedList.add(newSingleCompensationAwardData4);
                newSingleCompensationAwardData5.setType(0);
                newSingleCompensationAwardData5.setId((long)SWeeklyrewardsrw.getItem5id());
                newSingleCompensationAwardData5.setNum((long)SWeeklyrewardsrw.getItem5num());
                newSingleCompensationAwardData5.setFlag(1L);
                linkedList.add(newSingleCompensationAwardData5);
                newSingleCompensationAwardData6.setType(0);
                newSingleCompensationAwardData6.setId((long)SWeeklyrewardsrw.getItem6id());
                newSingleCompensationAwardData6.setNum((long)SWeeklyrewardsrw.getItem6num());
                newSingleCompensationAwardData6.setFlag(1L);
                linkedList.add(newSingleCompensationAwardData6);
                PropRole pRole1 = new PropRole(current.getRoleid(), true);

                try {
                    CreateSingleCompensation.createFromYunYing(current.getRoleid(), linkedList, dayimg, "<T t='' c='ff875832'/><B></B><T t='亲爱的[' c='ff875832'/><T t='" + pRole1.getName() + "' c='ff6ddcf6'/><T t=']玩家:' c='ff875832'/><B></B><T t='    恭喜您在人物战力排行榜' c='FF00BF00'/><T t='活动中展露头角获得第' c='ff875832'/><T t=' [" + i2 + "名] ' c='FF00BF00'/><T t='的好成绩。' c='ff875832'/><E e='200' /><E e='200' /><B></B><T t='感谢:' c='ff875832'/><T t='" + ganxie + "！' c='FFFF1B00'/><B></B><T t='祝您:' c='ff875832'/><T t='" + zhufu + "' c='FFFF1B00'/><E e='157' /><E e='159' /><E e='217' /><E e='243' /><E e='246' /><B></B><T t='' c='ff875832'/><B></B>", 0L, "冲榜奖励2", "冲榜奖励3").submit().get(2L, TimeUnit.SECONDS);
                } catch (Exception e) {
                    e.printStackTrace();
                    return;
                }

                List<String> paras1 = new ArrayList();
                paras1.add(pRole1.getName());
                paras1.add(String.valueOf(dayimg));
                paras1.add(String.valueOf(tianshu));
                int ts = Integer.parseInt(RoleConfigManager.getRoleStsommonConfig(8).getValue());
                STransChatMessageNotify2Client ssmn12 = MessageMgr.getMsgNotify(ts, 0, paras1);
                SceneManager.sendAll(ssmn12);
                System.out.println("发送" + tianshu + "日人物战力榜第：" + i2 + "名,(" + current.getRoleid() + ")获得" + SWeeklyrewardsrw.getdayimg() + ")");
                renwuwriteTxt((new SimpleDateFormat("yyyy-MM-dd HH:mm:ss")).format(new Date(Long.parseLong(String.valueOf(System.currentTimeMillis())))) + "人物力榜发放记录：角色ID【" + current.getRoleid() + "】【" + pRole1.getName() + "】 ，获得名称: [" + i2 + "] 名，获得的物品: 【" + linkedList + "】\n");
            }
        }

    }

    private static void renwuwriteTxt(String s) {
        try {
            File file = new File("人物战力榜发放记录.txt");
            if (!file.exists()) {
                file.createNewFile();
            }

            FileWriter fileWriter = new FileWriter(file.getName(), true);
            fileWriter.write(s);
            fileWriter.close();
        } catch (IOException ex) {
            ex.printStackTrace();
        }

    }

    public static void WeeklychongwuReward() {
        int tianshu = Integer.parseInt(RoleConfigManager.getRoleRFrankingConfig(11001).getValue());
        ServiceInfo serviceInfo = Serviceinfos.select(1);
        if (serviceInfo.getDays() == tianshu) {
            Map<Integer, Srankawardrewarcw> conf = ConfigManager.getInstance().getConf(Srankawardrewarcw.class);
            List<PetScoreListRecord> records = Petscorelist.select(1).getRecords();
            SingleCompensationAward newSingleCompensationAwardData = Pod.newSingleCompensationAwardData();
            SingleCompensationAward newSingleCompensationAwardData2 = Pod.newSingleCompensationAwardData();
            SingleCompensationAward newSingleCompensationAwardData3 = Pod.newSingleCompensationAwardData();
            SingleCompensationAward newSingleCompensationAwardData4 = Pod.newSingleCompensationAwardData();
            SingleCompensationAward newSingleCompensationAwardData5 = Pod.newSingleCompensationAwardData();
            SingleCompensationAward newSingleCompensationAwardData6 = Pod.newSingleCompensationAwardData();

            for(int i = 0; i < records.size(); ++i) {
                LinkedList<SingleCompensationAward> linkedList = new LinkedList();
                Srankawardrewarcw SWeeklyrewardscw = (Srankawardrewarcw)conf.get(i + 1);
                PetScoreListRecord ptScoreListRecord = (PetScoreListRecord)records.get(i);
                if (SWeeklyrewardscw == null || ptScoreListRecord == null) {
                    return;
                }

                int money = 0;
                int updatedMoney = 0;
                String dayimg = SWeeklyrewardscw.getdayimg();
                String zhufu = SWeeklyrewardscw.getzhufu();
                String ganxie = SWeeklyrewardscw.getganxie();
                SWeeklyrewardscw.getItem1id();
                SWeeklyrewardscw.getItem2id();
                SWeeklyrewardscw.getItem3id();
                SWeeklyrewardscw.getItem4id();
                SWeeklyrewardscw.getItem5id();
                SWeeklyrewardscw.getItem6id();
                SWeeklyrewardscw.getItem1num();
                SWeeklyrewardscw.getItem2num();
                SWeeklyrewardscw.getItem3num();
                SWeeklyrewardscw.getItem4num();
                SWeeklyrewardscw.getItem5num();
                SWeeklyrewardscw.getItem6num();
                int i2 = i + 1;
                System.out.println("dayimg: " + dayimg);
                newSingleCompensationAwardData.setType(0);
                newSingleCompensationAwardData.setId((long)SWeeklyrewardscw.getItem1id());
                newSingleCompensationAwardData.setNum((long)SWeeklyrewardscw.getItem1num());
                newSingleCompensationAwardData.setFlag(1L);
                linkedList.add(newSingleCompensationAwardData);
                newSingleCompensationAwardData2.setType(0);
                newSingleCompensationAwardData2.setId((long)SWeeklyrewardscw.getItem2id());
                newSingleCompensationAwardData2.setNum((long)SWeeklyrewardscw.getItem2num());
                newSingleCompensationAwardData2.setFlag(1L);
                linkedList.add(newSingleCompensationAwardData2);
                newSingleCompensationAwardData3.setType(0);
                newSingleCompensationAwardData3.setId((long)SWeeklyrewardscw.getItem3id());
                newSingleCompensationAwardData3.setNum((long)SWeeklyrewardscw.getItem3num());
                newSingleCompensationAwardData3.setFlag(1L);
                linkedList.add(newSingleCompensationAwardData3);
                newSingleCompensationAwardData4.setType(0);
                newSingleCompensationAwardData4.setId((long)SWeeklyrewardscw.getItem4id());
                newSingleCompensationAwardData4.setNum((long)SWeeklyrewardscw.getItem4num());
                newSingleCompensationAwardData4.setFlag(1L);
                linkedList.add(newSingleCompensationAwardData4);
                newSingleCompensationAwardData5.setType(0);
                newSingleCompensationAwardData5.setId((long)SWeeklyrewardscw.getItem5id());
                newSingleCompensationAwardData5.setNum((long)SWeeklyrewardscw.getItem5num());
                newSingleCompensationAwardData5.setFlag(1L);
                linkedList.add(newSingleCompensationAwardData5);
                newSingleCompensationAwardData6.setType(0);
                newSingleCompensationAwardData6.setId((long)SWeeklyrewardscw.getItem6id());
                newSingleCompensationAwardData6.setNum((long)SWeeklyrewardscw.getItem6num());
                newSingleCompensationAwardData6.setFlag(1L);
                linkedList.add(newSingleCompensationAwardData6);
                PropRole pRole1 = new PropRole(ptScoreListRecord.getMarshaldata().getRoleid(), true);

                try {
                    CreateSingleCompensation.createFromYunYing(ptScoreListRecord.getMarshaldata().getRoleid(), linkedList, dayimg, "<T t='' c='ff875832'/><B></B><T t='亲爱的[' c='ff875832'/><T t='" + pRole1.getName() + "' c='ff6ddcf6'/><T t=']玩家:' c='ff875832'/><B></B><T t='    恭喜您在宠物战力排行榜' c='FF00BF00'/><T t='活动中展露头角获得第' c='ff875832'/><T t=' [" + i2 + "名] ' c='FF00BF00'/><T t='的好成绩。' c='ff875832'/><E e='200' /><E e='200' /><B></B><T t='感谢:' c='ff875832'/><T t='" + ganxie + "！' c='FFFF1B00'/><B></B><T t='祝您:' c='ff875832'/><T t='" + zhufu + "' c='FFFF1B00'/><E e='157' /><E e='159' /><E e='217' /><E e='243' /><E e='246' /><B></B>", 0L, "冲榜奖励2", "冲榜奖励3").submit().get(2L, TimeUnit.SECONDS);
                } catch (Exception e) {
                    e.printStackTrace();
                    return;
                }

                List<String> paras1 = new ArrayList();
                paras1.add(pRole1.getName());
                paras1.add(String.valueOf(dayimg));
                paras1.add(String.valueOf(tianshu));
                int ts = Integer.parseInt(RoleConfigManager.getRoleStsommonConfig(8).getValue());
                STransChatMessageNotify2Client ssmn12 = MessageMgr.getMsgNotify(ts, 0, paras1);
                SceneManager.sendAll(ssmn12);
                System.out.println("发送" + tianshu + "日宠物榜第：" + i2 + "名,(" + ptScoreListRecord.getMarshaldata().getRoleid() + ")获得" + SWeeklyrewardscw.getdayimg() + ")");
                chongwuwriteTxt((new SimpleDateFormat("yyyy-MM-dd HH:mm:ss")).format(new Date(Long.parseLong(String.valueOf(System.currentTimeMillis())))) + "宠物榜发放记录：角色ID【" + ptScoreListRecord.getMarshaldata().getRoleid() + "】【" + pRole1.getName() + "】 ，获得名称: [" + i2 + "] 名，获得的物品: 【" + linkedList + "】\n");
            }
        }

    }

    private static void chongwuwriteTxt(String s) {
        try {
            File file = new File("宠物榜发放记录.txt");
            if (!file.exists()) {
                file.createNewFile();
            }

            FileWriter fileWriter = new FileWriter(file.getName(), true);
            fileWriter.write(s);
            fileWriter.close();
        } catch (IOException ex) {
            ex.printStackTrace();
        }

    }

    static {
        weekOfMonth = calendar.get(4);
    }
}
