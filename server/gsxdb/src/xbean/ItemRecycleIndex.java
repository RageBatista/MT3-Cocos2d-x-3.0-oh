
package xbean;

public interface ItemRecycleIndex extends mkdb.Bean {
	public ItemRecycleIndex copy(); // 深拷贝
	public ItemRecycleIndex toData(); // 一个 Data 实例
	public ItemRecycleIndex toBean(); // 一个 Bean 实例
	public ItemRecycleIndex toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ItemRecycleIndex toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Set<Long> getDayrecycle(); // 
	public java.util.Set<Long> getDayrecycleAsData(); // 

}
