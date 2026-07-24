//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.ranklist.jianglifasong;

import fire.pb.PropRole;
import fire.pb.RoleConfigManager;
import fire.pb.compensation.CreateSingleCompensation;
import fire.pb.game.Srankawardrewardcw;
import fire.pb.game.Srankawardrewardrw;
import fire.pb.game.Srankawardreward;
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
import xbean.SingleCompensationAward;
import xtable.Petscorelist;
import xtable.Rolerankdatalist;
import xtable.Rolezonghelist;

public class ZhouRewardManager {
    static Calendar calendar = Calendar.getInstance();
    static final int weekOfMonth;
    static final int Weeklyzhou;

    static {
        weekOfMonth = calendar.get(4);
        Weeklyzhou = Integer.parseInt(RoleConfigManager.getRoleWeeklyrewards(11001).getValue());
    }

    public static void WeeklyReward() {
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
            Srankawardreward Srankawardreward = (Srankawardreward)conf.get(i + 1);
            RoleZongheRankRecord roleZongheRankRecord = (RoleZongheRankRecord)records.get(i);
            if (Srankawardreward == null || roleZongheRankRecord == null) {
                return;
            }

            int money = 0;
            int updatedMoney = 0;
            String dayimg = Srankawardreward.getdayimg();
            String zhufu = Srankawardreward.getzhufu();
            String ganxie = Srankawardreward.getganxie();
            Srankawardreward.getItem1id();
            Srankawardreward.getItem2id();
            Srankawardreward.getItem3id();
            Srankawardreward.getItem4id();
            System.out.println("getItem4id :" + Srankawardreward.getItem4id());
            Srankawardreward.getItem5id();
            System.out.println("getItem5id :" + Srankawardreward.getItem5id());
            Srankawardreward.getItem6id();
            System.out.println("getItem6id :" + Srankawardreward.getItem6id());
            Srankawardreward.getItem1num();
            Srankawardreward.getItem2num();
            Srankawardreward.getItem3num();
            Srankawardreward.getItem4num();
            Srankawardreward.getItem5num();
            Srankawardreward.getItem6num();
            int i2 = i + 1;
            System.out.println("dayimg: " + dayimg);
            newSingleCompensationAwardData.setType(0);
            newSingleCompensationAwardData.setId((long)Srankawardreward.getItem1id());
            newSingleCompensationAwardData.setNum((long)Srankawardreward.getItem1num());
            newSingleCompensationAwardData.setFlag(1L);
            linkedList.add(newSingleCompensationAwardData);
            newSingleCompensationAwardData2.setType(0);
            newSingleCompensationAwardData2.setId((long)Srankawardreward.getItem2id());
            newSingleCompensationAwardData2.setNum((long)Srankawardreward.getItem2num());
            newSingleCompensationAwardData2.setFlag(1L);
            linkedList.add(newSingleCompensationAwardData2);
            newSingleCompensationAwardData3.setType(0);
            newSingleCompensationAwardData3.setId((long)Srankawardreward.getItem3id());
            newSingleCompensationAwardData3.setNum((long)Srankawardreward.getItem3num());
            newSingleCompensationAwardData3.setFlag(1L);
            linkedList.add(newSingleCompensationAwardData3);
            newSingleCompensationAwardData4.setType(0);
            newSingleCompensationAwardData4.setId((long)Srankawardreward.getItem4id());
            newSingleCompensationAwardData4.setNum((long)Srankawardreward.getItem4num());
            newSingleCompensationAwardData4.setFlag(1L);
            linkedList.add(newSingleCompensationAwardData4);
            newSingleCompensationAwardData5.setType(0);
            newSingleCompensationAwardData5.setId((long)Srankawardreward.getItem5id());
            newSingleCompensationAwardData5.setNum((long)Srankawardreward.getItem5num());
            newSingleCompensationAwardData5.setFlag(1L);
            linkedList.add(newSingleCompensationAwardData5);
            newSingleCompensationAwardData6.setType(0);
            newSingleCompensationAwardData6.setId((long)Srankawardreward.getItem6id());
            newSingleCompensationAwardData6.setNum((long)Srankawardreward.getItem6num());
            newSingleCompensationAwardData6.setFlag(1L);
            linkedList.add(newSingleCompensationAwardData6);
            newSingleCompensationAwardData7.setType(0);
            newSingleCompensationAwardData7.setId((long)Srankawardreward.getItem6id());
            newSingleCompensationAwardData7.setNum((long)Srankawardreward.getItem6num());
            newSingleCompensationAwardData7.setFlag(1L);
            PropRole pRole1 = new PropRole(roleZongheRankRecord.getRoleid(), true);

            try {
                CreateSingleCompensation.createFromYunYing(roleZongheRankRecord.getRoleid(), linkedList, dayimg, "<T t='' c='ff875832'/><B></B><T t='亲爱的[' c='ff875832'/><T t='" + pRole1.getName() + "' c='ff6ddcf6'/><T t=']玩家:' c='ff875832'/><B></B><T t='    恭喜您在循环榜-综合战力排行榜' c='FF00BF00'/><T t='活动中展露头角获得第' c='ff875832'/><T t=' [" + i2 + "名] ' c='FF00BF00'/><T t='的好成绩。' c='ff875832'/><E e='200' /><E e='200' /><B></B><T t='感谢:' c='ff875832'/><T t='" + ganxie + "！' c='FFFF1B00'/><B></B><T t='祝您:' c='ff875832'/><T t='" + zhufu + "' c='FFFF1B00'/><E e='157' /><E e='159' /><E e='217' /><E e='243' /><E e='246' /><B></B><T t='' c='ff875832'/><B></B>", 0L, "冲榜奖励2", "冲榜奖励3").submit().get(2L, TimeUnit.SECONDS);
            } catch (Exception e) {
                e.printStackTrace();
                return;
            }

            List<String> paras1 = new ArrayList();
            paras1.add(pRole1.getName());
            paras1.add(String.valueOf(dayimg));
            paras1.add(String.valueOf(Weeklyzhou));
            int ts = Integer.parseInt(RoleConfigManager.getRoleStsommonConfig(7).getValue());
            STransChatMessageNotify2Client ssmn12 = MessageMgr.getMsgNotify(ts, 0, paras1);
            SceneManager.sendAll(ssmn12);
            System.out.println("发送周" + Weeklyzhou + "-综合战力榜第：" + i2 + "名,(" + roleZongheRankRecord.getRoleid() + ")获得" + Srankawardreward.getdayimg() + ")");
            WeeklyzonghewriteTxt((new SimpleDateFormat("yyyy-MM-dd HH:mm:ss")).format(new Date(Long.parseLong(String.valueOf(System.currentTimeMillis())))) + "综合战力榜发放记录：角色ID【" + roleZongheRankRecord.getRoleid() + "】【" + pRole1.getName() + "】 ，获得名称: [" + i2 + "] 名，获得的物品: 【" + linkedList + "】\n");
        }

    }

    private static void WeeklyzonghewriteTxt(String s) {
        try {
            File file = new File("循环榜-综合榜发放记录.txt");
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
            Srankawardrewardrw Srankawardrewardrw = (Srankawardrewardrw)conf.get(i + 1);
            RoleRankRecord current = (RoleRankRecord)records.get(i);
            if (Srankawardrewardrw == null || current == null) {
                return;
            }

            int money = 0;
            int updatedMoney = 0;
            String dayimg = Srankawardrewardrw.getdayimg();
            String zhufu = Srankawardrewardrw.getzhufu();
            String ganxie = Srankawardrewardrw.getganxie();
            Srankawardrewardrw.getItem1id();
            Srankawardrewardrw.getItem2id();
            Srankawardrewardrw.getItem3id();
            Srankawardrewardrw.getItem4id();
            Srankawardrewardrw.getItem5id();
            Srankawardrewardrw.getItem6id();
            Srankawardrewardrw.getItem1num();
            Srankawardrewardrw.getItem2num();
            Srankawardrewardrw.getItem3num();
            Srankawardrewardrw.getItem4num();
            Srankawardrewardrw.getItem5num();
            Srankawardrewardrw.getItem6num();
            int ptb = Srankawardrewardrw.getptb();
            int i2 = i + 1;
            System.out.println("dayimg: " + dayimg);
            newSingleCompensationAwardData.setType(0);
            newSingleCompensationAwardData.setId((long)Srankawardrewardrw.getItem1id());
            newSingleCompensationAwardData.setNum((long)Srankawardrewardrw.getItem1num());
            newSingleCompensationAwardData.setFlag(1L);
            linkedList.add(newSingleCompensationAwardData);
            newSingleCompensationAwardData2.setType(0);
            newSingleCompensationAwardData2.setId((long)Srankawardrewardrw.getItem2id());
            newSingleCompensationAwardData2.setNum((long)Srankawardrewardrw.getItem2num());
            newSingleCompensationAwardData2.setFlag(1L);
            linkedList.add(newSingleCompensationAwardData2);
            newSingleCompensationAwardData3.setType(0);
            newSingleCompensationAwardData3.setId((long)Srankawardrewardrw.getItem3id());
            newSingleCompensationAwardData3.setNum((long)Srankawardrewardrw.getItem3num());
            newSingleCompensationAwardData3.setFlag(1L);
            linkedList.add(newSingleCompensationAwardData3);
            newSingleCompensationAwardData4.setType(0);
            newSingleCompensationAwardData4.setId((long)Srankawardrewardrw.getItem4id());
            newSingleCompensationAwardData4.setNum((long)Srankawardrewardrw.getItem4num());
            newSingleCompensationAwardData4.setFlag(1L);
            linkedList.add(newSingleCompensationAwardData4);
            newSingleCompensationAwardData5.setType(0);
            newSingleCompensationAwardData5.setId((long)Srankawardrewardrw.getItem5id());
            newSingleCompensationAwardData5.setNum((long)Srankawardrewardrw.getItem5num());
            newSingleCompensationAwardData5.setFlag(1L);
            linkedList.add(newSingleCompensationAwardData5);
            newSingleCompensationAwardData6.setType(0);
            newSingleCompensationAwardData6.setId((long)Srankawardrewardrw.getItem6id());
            newSingleCompensationAwardData6.setNum((long)Srankawardrewardrw.getItem6num());
            newSingleCompensationAwardData6.setFlag(1L);
            linkedList.add(newSingleCompensationAwardData6);
            PropRole pRole1 = new PropRole(current.getRoleid(), true);

            try {
                CreateSingleCompensation.createFromYunYing(current.getRoleid(), linkedList, dayimg, "<T t='' c='ff875832'/><B></B><T t='亲爱的[' c='ff875832'/><T t='" + pRole1.getName() + "' c='ff6ddcf6'/><T t=']玩家:' c='ff875832'/><B></B><T t='    恭喜您在循环榜-人物战力排行榜' c='FF00BF00'/><T t='活动中展露头角获得第' c='ff875832'/><T t=' [" + i2 + "名] ' c='FF00BF00'/><T t='的好成绩。' c='ff875832'/><E e='200' /><E e='200' /><B></B><T t='感谢:' c='ff875832'/><T t='" + ganxie + "！' c='FFFF1B00'/><B></B><T t='祝您:' c='ff875832'/><T t='" + zhufu + "' c='FFFF1B00'/><E e='157' /><E e='159' /><E e='217' /><E e='243' /><E e='246' /><B></B><T t='' c='ff875832'/><B></B><T t='获得平台币' c='ff20822D'/><T t='[' c='ff875832'/><T t='" + ptb + "' c='FFFF1B00'/><T t=']' c='ff875832'/><T t='个,已发送至后台注意查收！' c='FF20822D'/>", 0L, "冲榜奖励2", "冲榜奖励3").submit().get(2L, TimeUnit.SECONDS);
            } catch (Exception e) {
                e.printStackTrace();
                return;
            }

            List<String> paras1 = new ArrayList();
            paras1.add(pRole1.getName());
            paras1.add(String.valueOf(dayimg));
            paras1.add(String.valueOf(Weeklyzhou));
            int ts = Integer.parseInt(RoleConfigManager.getRoleStsommonConfig(7).getValue());
            STransChatMessageNotify2Client ssmn12 = MessageMgr.getMsgNotify(ts, 0, paras1);
            SceneManager.sendAll(ssmn12);
            System.out.println("发送周" + Weeklyzhou + "-人物战力榜第：" + i2 + "名,(" + current.getRoleid() + ")获得" + Srankawardrewardrw.getdayimg() + ")");
            WeeklyrenwuwriteTxt((new SimpleDateFormat("yyyy-MM-dd HH:mm:ss")).format(new Date(Long.parseLong(String.valueOf(System.currentTimeMillis())))) + "人物力榜发放记录：角色ID【" + current.getRoleid() + "】【" + pRole1.getName() + "】 ，获得名称: [" + i2 + "] 名，获得的物品: 【" + linkedList + "】\n");
        }

    }

    private static void WeeklyrenwuwriteTxt(String s) {
        try {
            File file = new File("循环榜-人物战力榜发放记录.txt");
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
        Map<Integer, Srankawardrewardcw> conf = ConfigManager.getInstance().getConf(Srankawardrewardcw.class);
        List<PetScoreListRecord> records = Petscorelist.select(1).getRecords();
        SingleCompensationAward newSingleCompensationAwardData = Pod.newSingleCompensationAwardData();
        SingleCompensationAward newSingleCompensationAwardData2 = Pod.newSingleCompensationAwardData();
        SingleCompensationAward newSingleCompensationAwardData3 = Pod.newSingleCompensationAwardData();
        SingleCompensationAward newSingleCompensationAwardData4 = Pod.newSingleCompensationAwardData();
        SingleCompensationAward newSingleCompensationAwardData5 = Pod.newSingleCompensationAwardData();
        SingleCompensationAward newSingleCompensationAwardData6 = Pod.newSingleCompensationAwardData();

        for(int i = 0; i < records.size(); ++i) {
            LinkedList<SingleCompensationAward> linkedList = new LinkedList();
            Srankawardrewardcw Srankawardrewardcw = (Srankawardrewardcw)conf.get(i + 1);
            PetScoreListRecord ptScoreListRecord = (PetScoreListRecord)records.get(i);
            if (Srankawardrewardcw == null || ptScoreListRecord == null) {
                return;
            }

            int money = 0;
            int updatedMoney = 0;
            String dayimg = Srankawardrewardcw.getdayimg();
            String zhufu = Srankawardrewardcw.getzhufu();
            String ganxie = Srankawardrewardcw.getganxie();
            Srankawardrewardcw.getItem1id();
            Srankawardrewardcw.getItem2id();
            Srankawardrewardcw.getItem3id();
            Srankawardrewardcw.getItem4id();
            Srankawardrewardcw.getItem5id();
            Srankawardrewardcw.getItem6id();
            Srankawardrewardcw.getItem1num();
            Srankawardrewardcw.getItem2num();
            Srankawardrewardcw.getItem3num();
            Srankawardrewardcw.getItem4num();
            Srankawardrewardcw.getItem5num();
            Srankawardrewardcw.getItem6num();
            int i2 = i + 1;
            System.out.println("dayimg: " + dayimg);
            newSingleCompensationAwardData.setType(0);
            newSingleCompensationAwardData.setId((long)Srankawardrewardcw.getItem1id());
            newSingleCompensationAwardData.setNum((long)Srankawardrewardcw.getItem1num());
            newSingleCompensationAwardData.setFlag(1L);
            linkedList.add(newSingleCompensationAwardData);
            newSingleCompensationAwardData2.setType(0);
            newSingleCompensationAwardData2.setId((long)Srankawardrewardcw.getItem2id());
            newSingleCompensationAwardData2.setNum((long)Srankawardrewardcw.getItem2num());
            newSingleCompensationAwardData2.setFlag(1L);
            linkedList.add(newSingleCompensationAwardData2);
            newSingleCompensationAwardData3.setType(0);
            newSingleCompensationAwardData3.setId((long)Srankawardrewardcw.getItem3id());
            newSingleCompensationAwardData3.setNum((long)Srankawardrewardcw.getItem3num());
            newSingleCompensationAwardData3.setFlag(1L);
            linkedList.add(newSingleCompensationAwardData3);
            newSingleCompensationAwardData4.setType(0);
            newSingleCompensationAwardData4.setId((long)Srankawardrewardcw.getItem4id());
            newSingleCompensationAwardData4.setNum((long)Srankawardrewardcw.getItem4num());
            newSingleCompensationAwardData4.setFlag(1L);
            linkedList.add(newSingleCompensationAwardData4);
            newSingleCompensationAwardData5.setType(0);
            newSingleCompensationAwardData5.setId((long)Srankawardrewardcw.getItem5id());
            newSingleCompensationAwardData5.setNum((long)Srankawardrewardcw.getItem5num());
            newSingleCompensationAwardData5.setFlag(1L);
            linkedList.add(newSingleCompensationAwardData5);
            newSingleCompensationAwardData6.setType(0);
            newSingleCompensationAwardData6.setId((long)Srankawardrewardcw.getItem6id());
            newSingleCompensationAwardData6.setNum((long)Srankawardrewardcw.getItem6num());
            newSingleCompensationAwardData6.setFlag(1L);
            linkedList.add(newSingleCompensationAwardData6);
            PropRole pRole1 = new PropRole(ptScoreListRecord.getMarshaldata().getRoleid(), true);

            try {
                CreateSingleCompensation.createFromYunYing(ptScoreListRecord.getMarshaldata().getRoleid(), linkedList, dayimg, "<T t='' c='ff875832'/><B></B><T t='亲爱的[' c='ff875832'/><T t='" + pRole1.getName() + "' c='ff6ddcf6'/><T t=']玩家:' c='ff875832'/><B></B><T t='    恭喜您在循环榜-宠物战力排行榜' c='FF00BF00'/><T t='活动中展露头角获得第' c='ff875832'/><T t=' [" + i2 + "名] ' c='FF00BF00'/><T t='的好成绩。' c='ff875832'/><E e='200' /><E e='200' /><B></B><T t='感谢:' c='ff875832'/><T t='" + ganxie + "！' c='FFFF1B00'/><B></B><T t='祝您:' c='ff875832'/><T t='" + zhufu + "' c='FFFF1B00'/><E e='157' /><E e='159' /><E e='217' /><E e='243' /><E e='246' /><B></B>", 0L, "冲榜奖励2", "冲榜奖励3").submit().get(2L, TimeUnit.SECONDS);
            } catch (Exception e) {
                e.printStackTrace();
                return;
            }

            List<String> paras1 = new ArrayList();
            int ts = Integer.parseInt(RoleConfigManager.getRoleStsommonConfig(7).getValue());
            STransChatMessageNotify2Client ssmn12 = MessageMgr.getMsgNotify(ts, 0, paras1);
            SceneManager.sendAll(ssmn12);
            System.out.println("发送周" + Weeklyzhou + "-宠物榜第：" + i2 + "名,(" + ptScoreListRecord.getMarshaldata().getRoleid() + ")获得" + Srankawardrewardcw.getdayimg() + ")");
            WeeklychongwuwriteTxt((new SimpleDateFormat("yyyy-MM-dd HH:mm:ss")).format(new Date(Long.parseLong(String.valueOf(System.currentTimeMillis())))) + "宠物榜发放记录：角色ID【" + ptScoreListRecord.getMarshaldata().getRoleid() + "】【" + pRole1.getName() + "】 ，获得名称: [" + i2 + "] 名，获得的物品: 【" + linkedList + "】\n");
        }

    }

    private static void WeeklychongwuwriteTxt(String s) {
        try {
            File file = new File("循环榜-宠物榜发放记录.txt");
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
}
