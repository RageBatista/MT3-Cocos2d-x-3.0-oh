
package xbean;

public interface ItemUse extends mkdb.Bean {
	public ItemUse copy(); // 深拷贝
	public ItemUse toData(); // 一个 Data 实例
	public ItemUse toBean(); // 一个 Bean 实例
	public ItemUse toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ItemUse toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.ItemUseCount> getIteminfo(); // 每个道具的使用次数
	public java.util.Map<Integer, xbean.ItemUseCount> getIteminfoAsData(); // 每个道具的使用次数

}
