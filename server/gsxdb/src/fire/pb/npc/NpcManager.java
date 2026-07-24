//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import fire.pb.game.ImperialExamProvinceRepo;
import fire.pb.game.ImperialExamStateRepo;
import fire.pb.game.ImperialExamVillageRepo;
import fire.pb.game.SImperialExamProvinceRepo;
import fire.pb.game.SImperialExamStateRepo;
import fire.pb.game.SImperialExamVillageRepo;
import fire.pb.game.SPointCardImperialExamProvinceRepo;
import fire.pb.game.SPointCardImperialExamStateRepo;
import fire.pb.game.SPointCardImperialExamVillageRepo;
import fire.pb.main.ConfigManager;
import fire.pb.school.shouxi.ProfessionLeaderManager;
import fire.pb.school.shouxi.RefreshProfessionLeaderTask;
import fire.pb.school.shouxi.RefreshShouxiTask;
import fire.pb.shop.Module;
import fire.pb.shop.SNpcSale;
import fire.pb.util.Misc;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NavigableMap;
import java.util.TreeMap;
import java.util.concurrent.TimeUnit;
import mkdb.Mkdb;

public class NpcManager {
    private static NpcManager _instance = new NpcManager();
    private NavigableMap<Integer, ImperialExamVillageRepo> keju1RepoMap = new TreeMap();
    private NavigableMap<Integer, ImperialExamProvinceRepo> keju2RepoMap = new TreeMap();
    private NavigableMap<Integer, ImperialExamStateRepo> keju3RepoMap = new TreeMap();
    private NavigableMap<Integer, SNpcSale> npcSaleMap = new TreeMap();
    private NavigableMap<Integer, SNpcShare> npcShareMap = new TreeMap();
    private Map<Integer, List<NpcNameTable>> npcNameTableMap = new HashMap();
    private Map<Integer, List<NpcPreNameTable>> npcPreNameTableMap = new HashMap();

    private NpcManager() {
    }

    public static NpcManager getInstance() {
        return _instance;
    }

    void init() throws Exception {
        ConfigManager cm = ConfigManager.getInstance();
        this.npcSaleMap = (TreeMap)Module.sNpcSaleMap;
        fire.pb.npc.Module.logger.info("NPC买卖物品表加载完毕。一共加载NPC" + this.npcSaleMap.size() + "个");
        int nGroup = -1;
        Map<Integer, SNpcNameRandom> npcnameTable = cm.getConf(SNpcNameRandom.class);

        for(SNpcNameRandom npc : npcnameTable.values()) {
            NpcNameTable npcname = new NpcNameTable(npc);
            if (nGroup != npc.group) {
                nGroup = npc.group;
                List<NpcNameTable> nameList = new ArrayList();
                nameList.add(npcname);
                this.npcNameTableMap.put(nGroup, nameList);
            } else {
                List<NpcNameTable> nameList = (List)this.npcNameTableMap.get(nGroup);
                nameList.add(npcname);
            }
        }

        nGroup = -1;
        Map<Integer, SNpcPreNameRandom> npcpreNameTable = cm.getConf(SNpcPreNameRandom.class);

        for(SNpcPreNameRandom npc : npcpreNameTable.values()) {
            NpcPreNameTable npcPreName = new NpcPreNameTable(npc);
            if (nGroup != npc.group) {
                nGroup = npc.group;
                List<NpcPreNameTable> nameList = new ArrayList();
                nameList.add(npcPreName);
                this.npcPreNameTableMap.put(nGroup, nameList);
            } else {
                List<NpcPreNameTable> nameList = (List)this.npcPreNameTableMap.get(nGroup);
                nameList.add(npcPreName);
            }
        }

        if (fire.pb.fushi.Module.GetPayServiceType() == 0) {
            this.keju1RepoMap.putAll(cm.getConf(SImperialExamVillageRepo.class));
            this.keju2RepoMap.putAll(cm.getConf(SImperialExamProvinceRepo.class));
            this.keju3RepoMap.putAll(cm.getConf(SImperialExamStateRepo.class));
        } else {
            this.keju1RepoMap.putAll(cm.getConf(SPointCardImperialExamVillageRepo.class));
            this.keju2RepoMap.putAll(cm.getConf(SPointCardImperialExamProvinceRepo.class));
            this.keju3RepoMap.putAll(cm.getConf(SPointCardImperialExamStateRepo.class));
        }

        this.npcShareMap = cm.getConf(SNpcShare.class);
        ProfessionLeaderManager.getInstance().setVoteTime();
        ProfessionLeaderManager.getInstance().setChallengeTime();
        long delta = ProfessionLeaderManager.getInstance().getVoteEndTime() - System.currentTimeMillis() + 1000L;
        Mkdb.executor().scheduleAtFixedRate(new RefreshShouxiTask(), delta, 604800000L, TimeUnit.MILLISECONDS);
        long delta1 = ProfessionLeaderManager.getInstance().getChallengeEndTime() - System.currentTimeMillis() + 1000L;
        if (delta1 < 0L) {
            long v = ProfessionLeaderManager.getInstance().getVoteEndTime() + 345600000L;
            Mkdb.executor().scheduleAtFixedRate(new RefreshProfessionLeaderTask(), v, 604800000L, TimeUnit.MILLISECONDS);
        } else {
            Mkdb.executor().scheduleAtFixedRate(new RefreshProfessionLeaderTask(), delta1, 604800000L, TimeUnit.MILLISECONDS);
        }

    }

    void reload() {
        this.npcSaleMap = (TreeMap)Module.sNpcSaleMap;
        this.npcShareMap = ConfigManager.getInstance().getConf(SNpcShare.class);
    }

    public int getRoleChangeShape(short shape, int num) {
        return shape > 10 ? 0 : 0;
    }

    public NavigableMap<Integer, ImperialExamVillageRepo> getKeju1RepositoryMap() {
        return this.keju1RepoMap;
    }

    public NavigableMap<Integer, ImperialExamProvinceRepo> getKeju2RepositoryMap() {
        return this.keju2RepoMap;
    }

    public NavigableMap<Integer, ImperialExamStateRepo> getKeju3RepositoryMap() {
        return this.keju3RepoMap;
    }

    public final SNpcSale getNpcSale(int npcid) {
        return (SNpcSale)this.npcSaleMap.get(npcid);
    }

    public final boolean isShareNpc(int npckey) {
        SNpcShare result = (SNpcShare)this.npcShareMap.get(npckey);
        if (result == null) {
            return false;
        } else {
            return result.getShare() == 1;
        }
    }

    public SNpcShare getNpcShareByID(int npcId) {
        return (SNpcShare)this.npcShareMap.get(npcId);
    }

    public String getNpcNameByID(int npcid) {
        SNpcShare result = (SNpcShare)this.npcShareMap.get(npcid);
        return result == null ? "" : result.getName();
    }

    public int getShape(int npcid) {
        SNpcShare result = (SNpcShare)this.npcShareMap.get(npcid);
        return result == null ? 0 : result.shape;
    }

    public int getNpcZaxueID(int npcid) {
        SNpcShare result = (SNpcShare)this.npcShareMap.get(npcid);
        return result == null ? -1 : result.get杂学id();
    }

    public NavigableMap<Integer, SNpcSale> getNpcSaleMap() {
        return this.npcSaleMap;
    }

    public String getNpcName(SNpcShare npcShare) {
        if (npcShare == null) {
            return "";
        } else {
            StringBuilder strBuilder = new StringBuilder();
            if (npcShare.namepre1 != 0 && this.npcPreNameTableMap.containsKey(npcShare.namepre1)) {
                List<NpcPreNameTable> nameList = (List)this.npcPreNameTableMap.get(npcShare.namepre1);
                int nIndex = Misc.getRandomBetween(0, nameList.size() - 1);
                if (nIndex < nameList.size()) {
                    NpcPreNameTable npc = (NpcPreNameTable)nameList.get(nIndex);
                    strBuilder.append(npc.preName);
                }
            }

            if (npcShare.namepre2 != 0 && this.npcPreNameTableMap.containsKey(npcShare.namepre2)) {
                List<NpcPreNameTable> nameList = (List)this.npcPreNameTableMap.get(npcShare.namepre2);
                int nIndex = Misc.getRandomBetween(0, nameList.size() - 1);
                if (nIndex < nameList.size()) {
                    NpcPreNameTable npc = (NpcPreNameTable)nameList.get(nIndex);
                    strBuilder.append(npc.preName);
                }
            }

            if (npcShare.nametable != 0) {
                if (this.npcNameTableMap.containsKey(npcShare.nametable)) {
                    List<NpcNameTable> nameList = (List)this.npcNameTableMap.get(npcShare.nametable);
                    int nIndex = Misc.getRandomBetween(0, nameList.size() - 1);
                    if (nIndex < nameList.size()) {
                        NpcNameTable npc = (NpcNameTable)nameList.get(nIndex);
                        strBuilder.append(npc.firstName);
                    }

                    nIndex = Misc.getRandomBetween(0, nameList.size() - 1);
                    if (nIndex < nameList.size()) {
                        NpcNameTable npc = (NpcNameTable)nameList.get(nIndex);
                        strBuilder.append(npc.secondName);
                    }
                }
            } else {
                strBuilder.append(npcShare.getName());
            }

            String name = strBuilder.toString();
            return !name.equals("") ? name : "";
        }
    }
}
