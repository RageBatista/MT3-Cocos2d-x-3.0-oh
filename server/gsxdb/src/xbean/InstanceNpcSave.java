
package xbean;

public interface InstanceNpcSave extends mkdb.Bean {
	public InstanceNpcSave copy(); // 深拷贝
	public InstanceNpcSave toData(); // 一个 Data 实例
	public InstanceNpcSave toBean(); // 一个 Bean 实例
	public InstanceNpcSave toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public InstanceNpcSave toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getNpckey(); // NPC钥匙
	public long getRoleid(); // 有值表示被该角色占用,没有值表示空闲
	public int getFinishcount(); // 已经完成的数量
	public int getCount(); // 需要完成的数量

	public void setNpckey(long _v_); // NPC钥匙
	public void setRoleid(long _v_); // 有值表示被该角色占用,没有值表示空闲
	public void setFinishcount(int _v_); // 已经完成的数量
	public void setCount(int _v_); // 需要完成的数量
}
