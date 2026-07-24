
package xbean;

public interface RoleFutureNotifyMap extends mkdb.Bean {
	public RoleFutureNotifyMap copy(); // 深拷贝
	public RoleFutureNotifyMap toData(); // 一个 Data 实例
	public RoleFutureNotifyMap toBean(); // 一个 Bean 实例
	public RoleFutureNotifyMap toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleFutureNotifyMap toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, java.util.concurrent.ScheduledFuture<?>> getNotifymap(); // 

}
