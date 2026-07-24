
package xbean;

public interface TimerFuture extends mkdb.Bean {
	public TimerFuture copy(); // 深拷贝
	public TimerFuture toData(); // 一个 Data 实例
	public TimerFuture toBean(); // 一个 Bean 实例
	public TimerFuture toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TimerFuture toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.concurrent.ScheduledFuture<?> getFuture(); // 

	public void setFuture(java.util.concurrent.ScheduledFuture<?> _v_); // 
}
