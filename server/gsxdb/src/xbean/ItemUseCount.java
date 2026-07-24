
package xbean;

public interface ItemUseCount extends mkdb.Bean {
	public ItemUseCount copy(); // 深拷贝
	public ItemUseCount toData(); // 一个 Data 实例
	public ItemUseCount toBean(); // 一个 Bean 实例
	public ItemUseCount toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ItemUseCount toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getItemid(); // 工具编号
	public int getUsetimes(); // 使用次数
	public long getLastusetime(); // 上次使用时间

	public void setItemid(int _v_); // 工具编号
	public void setUsetimes(int _v_); // 使用次数
	public void setLastusetime(long _v_); // 上次使用时间
}
