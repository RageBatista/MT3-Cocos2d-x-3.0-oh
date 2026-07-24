
package xbean;

public interface PvP5QueueRole extends mkdb.Bean {
	public PvP5QueueRole copy(); // 深拷贝
	public PvP5QueueRole toData(); // 一个 Data 实例
	public PvP5QueueRole toBean(); // 一个 Bean 实例
	public PvP5QueueRole toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public PvP5QueueRole toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 
	public long getEnterqueuetime(); // 进入队列的时间

	public void setRoleid(long _v_); // 
	public void setEnterqueuetime(long _v_); // 进入队列的时间
}
