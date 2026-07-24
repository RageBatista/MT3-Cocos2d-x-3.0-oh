//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.role;

import fire.pb.util.DateValidate;
import xbean.DayCount;
import xbean.DayCounter;
import xbean.Pod;
import xtable.Daycounter;

public class RoleDayCounter {
    private static RoleDayCounter _instance = null;

    public static RoleDayCounter getInstance() {
        if (_instance == null) {
            _instance = new RoleDayCounter();
        }

        return _instance;
    }

    public int getDayCounter(long roleId, int id) {
        DayCounter dayCounter = Daycounter.select(roleId);
        if (dayCounter == null) {
            return 0;
        } else if (dayCounter.getCountermap().containsKey(id)) {
            DayCount count = (DayCount)dayCounter.getCountermap().get(id);
            long time = System.currentTimeMillis();
            long lastonline = count.getTime();
            boolean isSameDay = DateValidate.inTheSameDay(lastonline, time);
            return isSameDay ? count.getCount() : 0;
        } else {
            return 0;
        }
    }

    public void setDayCounter(long roleId, int id) {
        DayCounter dayCounter = Daycounter.get(roleId);
        if (dayCounter == null) {
            dayCounter = Pod.newDayCounter();
            Daycounter.insert(roleId, dayCounter);
        }

        if (dayCounter.getCountermap().containsKey(id)) {
            DayCount count = (DayCount)dayCounter.getCountermap().get(id);
            long time = System.currentTimeMillis();
            long lastonline = count.getTime();
            boolean isSameDay = DateValidate.inTheSameDay(lastonline, time);
            if (isSameDay) {
                count.setCount(count.getCount() + 1);
                count.setTime(System.currentTimeMillis());
            } else {
                DayCount cnt = Pod.newDayCount();
                cnt.setTime(System.currentTimeMillis());
                cnt.setCount(1);
                dayCounter.getCountermap().put(id, cnt);
            }
        } else {
            DayCount cnt = Pod.newDayCount();
            cnt.setTime(System.currentTimeMillis());
            cnt.setCount(1);
            dayCounter.getCountermap().put(id, cnt);
        }

    }
}
