
package xbean;

public interface TreasureMapInfo extends mkdb.Bean {
	public TreasureMapInfo copy(); // 深拷贝
	public TreasureMapInfo toData(); // 一个 Data 实例
	public TreasureMapInfo toBean(); // 一个 Bean 实例
	public TreasureMapInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TreasureMapInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getAwardid(); // 奖励id
	public int getTableindex(); // 奖励表里的唯一id
	public int getItemid(); // 使用的物品id
	public int getItemkey(); // 物品的key

	public void setAwardid(int _v_); // 奖励id
	public void setTableindex(int _v_); // 奖励表里的唯一id
	public void setItemid(int _v_); // 使用的物品id
	public void setItemkey(int _v_); // 物品的key
}
