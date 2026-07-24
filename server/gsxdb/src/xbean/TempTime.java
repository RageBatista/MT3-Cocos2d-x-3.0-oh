
package xbean;

public interface TempTime extends mkdb.Bean {
	public TempTime copy(); // 深拷贝
	public TempTime toData(); // 一个 Data 实例
	public TempTime toBean(); // 一个 Bean 实例
	public TempTime toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TempTime toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Long> getItems(); // 
	public java.util.Map<Integer, Long> getItemsAsData(); // 

}
