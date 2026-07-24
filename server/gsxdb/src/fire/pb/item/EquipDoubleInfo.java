//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.HashMap;

public class EquipDoubleInfo {
    public static String dir = "equipdoubleinfo";

    public static HashMap<Long, NewShuangJiaInfo> getEquipAllInfo(long roleid) {
        try {
            File file = new File(dir + File.separator + roleid);
            if (!file.exists()) {
                return null;
            } else {
                ObjectInputStream is = new ObjectInputStream(new FileInputStream(file));
                new HashMap();
                HashMap<Long, NewShuangJiaInfo> map = (HashMap)is.readObject();
                is.close();
                return map;
            }
        } catch (Exception exception) {
            exception.printStackTrace();
            return null;
        }
    }

    public static void MoveShuangJia(long sell, long buy, long uniqueid) {
        NewShuangJiaInfo info = getEquipDoubleInfoAndRemove(sell, uniqueid);
        HashMap<Long, NewShuangJiaInfo> map = getEquipAllInfo(buy);
        if (map == null) {
            map = new HashMap();
        }

        map.put(uniqueid, info);
        UpdateEquipInfo(buy, map);
    }

    public static NewShuangJiaInfo getEquipDoubleInfoAndRemove(long roleid, long uniqueid) {
        HashMap<Long, NewShuangJiaInfo> info = getEquipAllInfo(roleid);
        if (info != null && info.containsKey(uniqueid)) {
            NewShuangJiaInfo newshuangjia = (NewShuangJiaInfo)info.get(uniqueid);
            info.remove(uniqueid);
            UpdateEquipInfo(roleid, info);
            return newshuangjia;
        } else {
            return null;
        }
    }

    public static NewShuangJiaInfo getEquipDoubleInfo(long roleid, long uniqueid) {
        HashMap<Long, NewShuangJiaInfo> info = getEquipAllInfo(roleid);
        return info != null && info.containsKey(uniqueid) ? (NewShuangJiaInfo)info.get(uniqueid) : null;
    }

    public static void UpdateEquipInfo(long roleid, HashMap<Long, NewShuangJiaInfo> map) {
        try {
            File file1 = new File(dir);
            if (!file1.exists()) {
                file1.mkdir();
            }

            File file2 = new File(dir + File.separator + roleid);
            ObjectOutputStream os = new ObjectOutputStream(new FileOutputStream(file2));
            os.writeObject(map);
            os.close();
        } catch (Exception exception) {
            exception.printStackTrace();
        }

    }
}
