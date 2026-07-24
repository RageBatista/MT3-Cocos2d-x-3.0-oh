//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import fire.pb.util.BagUtil;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import mkdb.Procedure;
import xbean.Properties;

public class PBenefitCodeExchange extends Procedure {
    private long roleId;
    private String code;

    public PBenefitCodeExchange(long roleId, String code) {
        this.roleId = roleId;
        this.code = code;
    }

    protected boolean process() throws Exception {
        Properties properties = xtable.Properties.get(this.roleId);
        TreeMap<Integer, SBenefitCode> conf = ConfigManager.getInstance().getConf(SBenefitCode.class);
        int reawardId = 0;
        int reawardNum = 0;

        for(Map.Entry<Integer, SBenefitCode> CodeEntry : conf.entrySet()) {
            if (this.code.equals(((SBenefitCode)CodeEntry.getValue()).code)) {
                reawardId = ((SBenefitCode)CodeEntry.getValue()).itemid;
                reawardNum = ((SBenefitCode)CodeEntry.getValue()).itemnum;
            }
        }

        if (reawardId != 0 && reawardNum != 0) {
            List<String> benefitcode = properties.getBenefitcode();
            if (benefitcode.contains(this.code)) {
                MessageMgr.psendMsgNotify(this.roleId, 191257, (List)null);
                return false;
            } else {
                int res = BagUtil.addItem(this.roleId, reawardId, reawardNum, "福利码兑换", YYLoggerTuJingEnum.tujing_Value_libaoduihuan, reawardId);
                if (res != reawardNum) {
                    return false;
                } else {
                    benefitcode.add(this.code);
                    MessageMgr.psendMsgNotify(this.roleId, 191258, (List)null);
                    return true;
                }
            }
        } else {
            return false;
        }
    }
}
