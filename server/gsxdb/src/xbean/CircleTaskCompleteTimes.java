
package xbean;

public interface CircleTaskCompleteTimes extends mkdb.Bean {
	public CircleTaskCompleteTimes copy(); // 深拷贝
	public CircleTaskCompleteTimes toData(); // 一个 Data 实例
	public CircleTaskCompleteTimes toBean(); // 一个 Bean 实例
	public CircleTaskCompleteTimes toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public CircleTaskCompleteTimes toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Integer> getCircletaskcounts(); // key 为循环类型
	public java.util.Map<Integer, Integer> getCircletaskcountsAsData(); // key 为循环类型
	public long getLogtime(); // 

	public void setLogtime(long _v_); // 
}
