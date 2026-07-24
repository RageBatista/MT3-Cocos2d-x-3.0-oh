package fire.pb.pet;

import fire.pb.main.ConfigManager;
import fire.pb.skill.SPetSkillitem;
import fire.pb.skill.SPetSkillupgrade;
import fire.pb.skill.SSkillConfig;
import java.util.ArrayList;
import java.util.Map;
import java.util.Map.Entry;
import java.util.NavigableMap;
import java.util.TreeMap;

/**
 * 宠物配置管理器。
 */
public class PetManager {
    private NavigableMap<Integer, PetAttr> petAttrConfigMap = new TreeMap<Integer, PetAttr>();
    private NavigableMap<Integer, ArrayList<SShenShouInc>> shenshouIncConfigMap =
            new TreeMap<Integer, ArrayList<SShenShouInc>>();
    private ArrayList<PetAttr> shenshouAttrConfigList = new ArrayList<PetAttr>();

    static class SingletonHolder {
        static PetManager singleton = new PetManager();
    }

    public static PetManager getInstance() {
        return SingletonHolder.singleton;
    }

    private PetManager() {
        this.reload();
    }

    public void reload() {
        this.petAttrConfigMap = ConfigManager.getInstance().getConf(PetAttr.class);
        Map<Integer, SShenShouInc> shenShouIncConfigs =
                ConfigManager.getInstance().getConf(SShenShouInc.class);

        for (Entry<Integer, SShenShouInc> entry : shenShouIncConfigs.entrySet()) {
            int petId = entry.getValue().getPetid();
            if (!this.shenshouIncConfigMap.containsKey(petId)) {
                this.shenshouIncConfigMap.put(petId, new ArrayList<SShenShouInc>());
            }

            ArrayList<SShenShouInc> petIncConfigs = this.shenshouIncConfigMap.get(petId);
            petIncConfigs.add(entry.getValue());
        }

        for (PetAttr petAttr : this.petAttrConfigMap.values()) {
            if (petAttr.getKind() == PetTypeEnum.SACREDANIMAL) {
                this.shenshouAttrConfigList.add(petAttr);
            }
        }

        if (Module.logger.isInfoEnabled()) {
            Module.logger.info("PetAttr load size=" + this.petAttrConfigMap.size());
        }
    }

    public PetAttr getAttr(int petId) {
        return this.petAttrConfigMap.get(petId);
    }

    public SPetSkillupgrade getSkillUpGrade(int skillId) {
        Map<Integer, SPetSkillupgrade> map = ConfigManager.getInstance().getConf(SPetSkillupgrade.class);
        if (map != null) {
            return map.get(skillId);
        }
        return null;
    }

    public int getSkillScore(int skillId) {
        SPetSkillitem skillItem = ConfigManager.getInstance().getConf(SPetSkillitem.class).get(skillId);
        return skillItem != null ? skillItem.getScore() : 0;
    }

    public boolean isActiveSkill(int skillId) {
        SSkillConfig config = ConfigManager.getInstance().getConf(SSkillConfig.class).get(skillId);
        if (config == null) {
            return false;
        }
        return config.isActive;
    }

    public PetAttr randGetOneShenShou() {
        final int randIndex = (int)(Math.random() * this.shenshouAttrConfigList.size());
        return this.shenshouAttrConfigList.get(randIndex);
    }

    public final SShenShouInc getShenShouIncConfig(int petId, int hasIncCount) {
        ArrayList<SShenShouInc> incConfigs = this.shenshouIncConfigMap.get(petId);
        if (incConfigs == null) {
            return null;
        }

        for (SShenShouInc sShenShouInc : incConfigs) {
            if (sShenShouInc.getInccount() == hasIncCount + 1) {
                return sShenShouInc;
            }
        }

        return null;
    }

    /**
     * 是否宠物参战的寿命是永久的。
     */
    public boolean isPetLifeForever(int petId) {
        PetAttr petAttr = this.getAttr(petId);
        return petAttr != null && petAttr.getLife() == -1;
    }
}
