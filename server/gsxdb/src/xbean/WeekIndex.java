
package xbean;

public interface WeekIndex extends mkdb.Bean {
	public WeekIndex copy(); // 深拷贝
	public WeekIndex toData(); // 一个 Data 实例
	public WeekIndex toBean(); // 一个 Bean 实例
	public WeekIndex toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public WeekIndex toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getIndex(); // 伙伴免费轮换索引
	public int getInstanceindex(); // 副本轮换索引

	public void setIndex(int _v_); // 伙伴免费轮换索引
	public void setInstanceindex(int _v_); // 副本轮换索引
}
