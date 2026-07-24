
package xbean;

public interface Course extends mkdb.Bean {
	public Course copy(); // 深拷贝
	public Course toData(); // 一个 Data 实例
	public Course toBean(); // 一个 Bean 实例
	public Course toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public Course toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getId(); // ID
	public int getCount(); // 完成次数, 有的历程需要多次完成一个操作
	public int getState(); // 状态 0 未完成, 1 已经完成, 2 已经领奖

	public void setId(int _v_); // ID
	public void setCount(int _v_); // 完成次数, 有的历程需要多次完成一个操作
	public void setState(int _v_); // 状态 0 未完成, 1 已经完成, 2 已经领奖
}
