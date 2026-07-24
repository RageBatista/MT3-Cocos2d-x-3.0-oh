
package xbean;

public interface DayCounter extends mkdb.Bean {
	public DayCounter copy(); // 深拷贝
	public DayCounter toData(); // 一个 Data 实例
	public DayCounter toBean(); // 一个 Bean 实例
	public DayCounter toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public DayCounter toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.DayCount> getCountermap(); // 使用表
	public java.util.Map<Integer, xbean.DayCount> getCountermapAsData(); // 使用表

}
