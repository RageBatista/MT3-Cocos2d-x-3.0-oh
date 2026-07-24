
package xbean;

public interface PetSellCount extends mkdb.Bean {
	public PetSellCount copy(); // 深拷贝
	public PetSellCount toData(); // 一个 Data 实例
	public PetSellCount toBean(); // 一个 Bean 实例
	public PetSellCount toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public PetSellCount toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getCount(); // 次数 *byte够了
	public long getResettime(); // 重置时间

	public void setCount(int _v_); // 次数 *byte够了
	public void setResettime(long _v_); // 重置时间
}
