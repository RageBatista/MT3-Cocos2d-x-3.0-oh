
package xbean;

public interface InstanceFutureInfo extends mkdb.Bean {
	public InstanceFutureInfo copy(); // 深拷贝
	public InstanceFutureInfo toData(); // 一个 Data 实例
	public InstanceFutureInfo toBean(); // 一个 Bean 实例
	public InstanceFutureInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public InstanceFutureInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.concurrent.ScheduledFuture<?> getTimeoutfuture(); // 

	public void setTimeoutfuture(java.util.concurrent.ScheduledFuture<?> _v_); // 
}
