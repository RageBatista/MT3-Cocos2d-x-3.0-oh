
package xbean;

public interface AnYeLegendFuture extends mkdb.Bean {
	public AnYeLegendFuture copy(); // 深拷贝
	public AnYeLegendFuture toData(); // 一个 Data 实例
	public AnYeLegendFuture toBean(); // 一个 Bean 实例
	public AnYeLegendFuture toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public AnYeLegendFuture toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.concurrent.ScheduledFuture<?> getLegendfuture(); // 

	public void setLegendfuture(java.util.concurrent.ScheduledFuture<?> _v_); // 
}
