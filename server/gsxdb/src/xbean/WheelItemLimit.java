
package xbean;

public interface WheelItemLimit extends mkdb.Bean {
	public WheelItemLimit copy(); // 深拷贝
	public WheelItemLimit toData(); // 一个 Data 实例
	public WheelItemLimit toBean(); // 一个 Bean 实例
	public WheelItemLimit toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public WheelItemLimit toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Integer> getLimitmap(); // 
	public java.util.Map<Integer, Integer> getLimitmapAsData(); // 

}
