
package xbean;

public interface BuffRole extends mkdb.Bean {
	public BuffRole copy(); // 深拷贝
	public BuffRole toData(); // 一个 Data 实例
	public BuffRole toBean(); // 一个 Bean 实例
	public BuffRole toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BuffRole toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 
	public xbean.BuffAgent getBuffagent(); // 

	public void setRoleid(long _v_); // 
}
