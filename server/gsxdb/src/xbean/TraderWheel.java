
package xbean;

public interface TraderWheel extends mkdb.Bean {
	public TraderWheel copy(); // 深拷贝
	public TraderWheel toData(); // 一个 Data 实例
	public TraderWheel toBean(); // 一个 Bean 实例
	public TraderWheel toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TraderWheel toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getBoxtype(); // 宝箱类型
	public int getItemindex(); // 物品列的索引

	public void setBoxtype(int _v_); // 宝箱类型
	public void setItemindex(int _v_); // 物品列的索引
}
