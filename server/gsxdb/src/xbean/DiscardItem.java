
package xbean;

public interface DiscardItem extends mkdb.Bean {
	public DiscardItem copy(); // 深拷贝
	public DiscardItem toData(); // 一个 Data 实例
	public DiscardItem toBean(); // 一个 Bean 实例
	public DiscardItem toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public DiscardItem toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public xbean.Item getItem(); // 物品固有属性
	public long getDeletedate(); // 删除日期

	public void setDeletedate(long _v_); // 删除日期
}
