//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.qiannengguo;

import fire.pb.main.ConfigManager;
import java.util.Map;
import java.util.TreeMap;
import xbean.Properties;

public class PotentialMgr {
    public static SQiannengguoextra getExtra(Properties properties) {
        TreeMap<Integer, SQiannengguoextra> conf = ConfigManager.getInstance().getConf(SQiannengguoextra.class);
        int lastId = 0;
        int count = properties.getQlgmap().size();

        for(Map.Entry<Integer, SQiannengguoextra> entry : conf.entrySet()) {
            if (count >= ((SQiannengguoextra)entry.getValue()).needcount) {
                lastId = (Integer)entry.getKey();
            }
        }

        if (lastId == 0) {
            return null;
        } else {
            return (SQiannengguoextra)conf.get(lastId);
        }
    }
}
