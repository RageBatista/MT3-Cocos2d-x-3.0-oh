
package xbean;

public interface InstanceSave extends mkdb.Bean {
	public InstanceSave copy(); // 深拷贝
	public InstanceSave toData(); // 一个 Data 实例
	public InstanceSave toBean(); // 一个 Bean 实例
	public InstanceSave toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public InstanceSave toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getSaveid(); // 
	public int getState(); // 
	public java.util.Map<Integer, Integer> getSubsaves(); // 子进度状态，value是子进度计数
	public java.util.Map<Integer, Integer> getSubsavesAsData(); // 子进度状态，value是子进度计数
	public java.util.Map<Long, xbean.InstanceNpcSave> getNpcsaves(); // npc的状态存储, key 是npckey
	public java.util.Map<Long, xbean.InstanceNpcSave> getNpcsavesAsData(); // npc的状态存储, key 是npckey

	public void setSaveid(int _v_); // 
	public void setState(int _v_); // 
}
