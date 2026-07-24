
package xbean;

public interface SchoolWheel extends mkdb.Bean {
	public SchoolWheel copy(); // 深拷贝
	public SchoolWheel toData(); // 一个 Data 实例
	public SchoolWheel toBean(); // 一个 Bean 实例
	public SchoolWheel toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public SchoolWheel toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getAwardid(); // 奖励id
	public int getItemindex(); // 物品列的索引

	public void setAwardid(int _v_); // 奖励id
	public void setItemindex(int _v_); // 物品列的索引
}
