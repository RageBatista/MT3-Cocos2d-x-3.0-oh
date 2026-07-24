
package xbean;

public interface RandomNameInfo extends mkdb.Bean {
	public RandomNameInfo copy(); // 深拷贝
	public RandomNameInfo toData(); // 一个 Data 实例
	public RandomNameInfo toBean(); // 一个 Bean 实例
	public RandomNameInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RandomNameInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRandomtime(); // 

	public void setRandomtime(long _v_); // 
}
