package fire.pb.gm;

import fire.pb.timer.AbstractScheduledActivity;
import fire.pb.timer.ActivityManager;

public class GM_stopact extends GMCommand {

	@Override
	boolean exec(String[] args) {
		if (args.length < 2) {
			sendToGM(usage());
			return false;
		}
		int actId = Integer.parseInt(args[0]);
		int endAct = Integer.parseInt(args[1]);
		boolean cancelFuture = false;
		if (args.length >= 3)
			cancelFuture = args[2].equals("1") ? true : false;
		AbstractScheduledActivity act = ActivityManager.getActivitymap().get(
				actId);
		if (act == null)
			return false;
		try {
			if (endAct == 1)
				act.end(cancelFuture);
			else
				act.stop(cancelFuture);
			ActivityManager.getActivitymap().remove(actId);
			act = null;
		} catch (Exception e) {
			logger.error("Stop activity by GM Command failed.id:" + actId, e);

		}
		return true;
	}

	@Override
	String usage() {

		return "//stopact activityid endact cancelweekrepeat - 第一个参数指定活动唯一id, 第二个参数为1时结束活动, 为0时暂停活动(之后还可恢复), 第三个参数为1表示周期循环的活动也停止";
	}

}
