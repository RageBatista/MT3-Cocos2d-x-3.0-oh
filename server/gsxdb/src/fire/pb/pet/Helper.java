//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.pb.buff.Module;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import xbean.PetInfo;
import xbean.PetSkill;
import xtable.Properties;

public class Helper {
    public static String toString(PetInfo petInfo) {
        List<Integer> skillIds = new ArrayList();
        List<Integer> skillTypes = new ArrayList();
        List<Integer> skillCertifys = new ArrayList();

        for(PetSkill skill : petInfo.getSkills()) {
            skillIds.add(skill.getSkillid());
            skillTypes.add(skill.getSkilltype());
            skillCertifys.add(skill.getCertification());
        }

        List<Integer> internalIds = new ArrayList();
        List<Integer> internalTypes = new ArrayList();
        List<Integer> internalCertifys = new ArrayList();

        for(PetSkill internal : petInfo.getInternals()) {
            internalIds.add(internal.getSkillid());
            internalTypes.add(internal.getSkilltype());
            internalCertifys.add(internal.getCertification());
        }

        return "{ key:" + petInfo.getKey() + " uniqId:" + petInfo.getUniqid() + " ownerId:" + petInfo.getOwnerid() + " id:" + petInfo.getId() + " name:" + petInfo.getName() + " kind:" + petInfo.getKind() + " isBind:" + petInfo.getIsbinded() + " lv:" + petInfo.getLevel() + " exp:" + petInfo.getExp() + " point:" + petInfo.getPoint() + " cons:" + petInfo.getBfp().getCons() + " iq:" + petInfo.getBfp().getIq() + " str:" + petInfo.getBfp().getStr() + " endu:" + petInfo.getBfp().getEndu() + " agi:" + petInfo.getBfp().getAgi() + " attackApt:" + petInfo.getBornattackapt() + " defendApt:" + petInfo.getBorndefendapt() + " magicApt:" + petInfo.getBornmagicapt() + " phyforceApt:" + petInfo.getBornphyforceapt() + " speedApt:" + petInfo.getBornspeedapt() + " aptAddCount:" + petInfo.getAptaddcount() + " growRate:" + petInfo.getGrowrate() + " growRateAddCount:" + petInfo.getGrowrateaddcount() + " washCount:" + petInfo.getWashcount() + " life:" + petInfo.getLife() + " skillIds:" + Arrays.toString(skillIds.toArray()) + " skillTypes:" + Arrays.toString(skillTypes.toArray()) + " skillCertifys:" + Arrays.toString(skillCertifys.toArray()) + " internalIds:" + Arrays.toString(internalIds.toArray()) + " internalTypes:" + Arrays.toString(internalTypes.toArray()) + " internalCertifys:" + Arrays.toString(internalCertifys.toArray()) + " }";
    }

    public static boolean isPetInBattle(long roleId, int petKey) {
        if (Module.existState(roleId, 507004)) {
            Integer key = Properties.selectFightpetkey(roleId);
            if (key != null && key == petKey) {
                return true;
            }
        }

        return false;
    }
}
