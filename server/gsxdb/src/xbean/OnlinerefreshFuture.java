
package xbean;

public interface OnlinerefreshFuture extends mkdb.Bean {
	public OnlinerefreshFuture copy(); // 深拷贝
	public OnlinerefreshFuture toData(); // 一个 Data 实例
	public OnlinerefreshFuture toBean(); // 一个 Bean 实例
	public OnlinerefreshFuture toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public OnlinerefreshFuture toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.concurrent.ScheduledFuture<?> getFurvec(); // 

	public void setFurvec(java.util.concurrent.ScheduledFuture<?> _v_); // 
}
