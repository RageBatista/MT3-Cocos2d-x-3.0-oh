
package xbean;

public interface DiscardPet extends mkdb.Bean {
	public DiscardPet copy(); // 深拷贝
	public DiscardPet toData(); // 一个 Data 实例
	public DiscardPet toBean(); // 一个 Bean 实例
	public DiscardPet toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public DiscardPet toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public xbean.PetInfo getPet(); // 宠物属性
	public long getRoleid(); // 宠物删除时的主人
	public long getDeletedate(); // 删除日期
	public int getReason(); // 删除原因

	public void setRoleid(long _v_); // 宠物删除时的主人
	public void setDeletedate(long _v_); // 删除日期
	public void setReason(int _v_); // 删除原因
}
