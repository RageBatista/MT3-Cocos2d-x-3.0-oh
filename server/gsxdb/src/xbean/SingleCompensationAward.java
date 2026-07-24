
package xbean;

public interface SingleCompensationAward extends mkdb.Bean {
	public SingleCompensationAward copy(); // 深拷贝
	public SingleCompensationAward toData(); // 一个 Data 实例
	public SingleCompensationAward toBean(); // 一个 Bean 实例
	public SingleCompensationAward toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public SingleCompensationAward toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getType(); // 奖励类型
	public long getId(); // 奖励id,类型是物品时为物品id
	public long getNum(); // 奖励数量
	public long getFlag(); // 奖励标记,类型是物品时有绑定标记

	public void setType(int _v_); // 奖励类型
	public void setId(long _v_); // 奖励id,类型是物品时为物品id
	public void setNum(long _v_); // 奖励数量
	public void setFlag(long _v_); // 奖励标记,类型是物品时有绑定标记
}
