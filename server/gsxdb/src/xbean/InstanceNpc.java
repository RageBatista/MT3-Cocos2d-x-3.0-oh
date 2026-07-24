
package xbean;

public interface InstanceNpc extends mkdb.Bean {
	public InstanceNpc copy(); // 深拷贝
	public InstanceNpc toData(); // 一个 Data 实例
	public InstanceNpc toBean(); // 一个 Bean 实例
	public InstanceNpc toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public InstanceNpc toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getNpcbaseid(); // npc基本ID
	public int getState(); // 状态 1 显示 2 隐藏

	public void setNpcbaseid(int _v_); // npc基本ID
	public void setState(int _v_); // 状态 1 显示 2 隐藏
}
