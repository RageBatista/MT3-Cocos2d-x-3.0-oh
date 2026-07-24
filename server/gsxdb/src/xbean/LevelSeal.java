
package xbean;

public interface LevelSeal extends mkdb.Bean {
	public LevelSeal copy(); // 深拷贝
	public LevelSeal toData(); // 一个 Data 实例
	public LevelSeal toBean(); // 一个 Bean 实例
	public LevelSeal toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public LevelSeal toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getLevel(); // 到达等级
	public int getRolenum(); // 已经到达这个等级的人数

	public void setLevel(int _v_); // 到达等级
	public void setRolenum(int _v_); // 已经到达这个等级的人数
}
