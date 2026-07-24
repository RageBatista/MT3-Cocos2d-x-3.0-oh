package fire.pb.guaji;

import java.util.ArrayList;
import java.util.List;
import java.util.TimerTask;

public class MuTong_Guajitask extends TimerTask {
    private final Guajitask delegate;

    public MuTong_Guajitask(long roleId, int leixing, int mapid) {
        List<Integer> points = new ArrayList<>(1);
        points.add(leixing);
        this.delegate = new Guajitask(roleId, points, mapid);
    }

    @Override
    public void run() {
        this.delegate.run();
    }
}

