package fire.pb.timer;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ScheduledFuture;

/**
 * 
 * 建一个集合，存放TimerFuture
 * @作者没人
 *
 */
public class ScheduledFutureMap
{
	private final static ScheduledFutureMap _instance = new ScheduledFutureMap();
	public synchronized static ScheduledFutureMap getInstance(){return _instance;};
	private ScheduledFutureMap(){}


	private final Map<Long,ScheduledFuture<?>> futures = new HashMap<Long, ScheduledFuture<?>>();
	private long autokey = 0;

	// 角色挂机任务映射
	private static final Map<Long, ScheduledFuture<?>> roleFutures = new HashMap<Long, ScheduledFuture<?>>();

	public synchronized  long insert(ScheduledFuture<?> future)
	{
		autokey++;
		futures.put(autokey, future);
		return autokey;
	}
	public synchronized  ScheduledFuture<?> get(long futurekey)
	{
		return futures.get(futurekey);
	}
	public synchronized  ScheduledFuture<?> remove(long futurekey)
	{
		return futures.remove(futurekey);
	}

	// 角色挂机任务相关的静态方法
	public static synchronized ScheduledFuture<?> getRoleFuture(long roleId) {
		return roleFutures.get(roleId);
	}

	public static synchronized void setRoleFuture(long roleId, ScheduledFuture<?> future) {
		roleFutures.put(roleId, future);
	}

	public static synchronized ScheduledFuture<?> removeRoleFuture(long roleId) {
		return roleFutures.remove(roleId);
	}
}
