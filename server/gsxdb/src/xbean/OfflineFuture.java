
package xbean;

public interface OfflineFuture extends mkdb.Bean {
	public OfflineFuture copy(); // 深拷贝
	public OfflineFuture toData(); // 一个 Data 实例
	public OfflineFuture toBean(); // 一个 Bean 实例
	public OfflineFuture toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public OfflineFuture toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.concurrent.ScheduledFuture<?> getTimefuture(); // 人物下线后的计时任务

	public void setTimefuture(java.util.concurrent.ScheduledFuture<?> _v_); // 人物下线后的计时任务
}
