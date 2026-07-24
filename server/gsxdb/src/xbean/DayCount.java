
package xbean;

public interface DayCount extends mkdb.Bean {
	public DayCount copy(); // 深拷贝
	public DayCount toData(); // 一个 Data 实例
	public DayCount toBean(); // 一个 Bean 实例
	public DayCount toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public DayCount toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getTime(); // 使用时间
	public int getCount(); // 使用次数

	public void setTime(long _v_); // 使用时间
	public void setCount(int _v_); // 使用次数
}
