
package xbean;

public interface UniquePet extends mkdb.Bean {
	public UniquePet copy(); // 深拷贝
	public UniquePet toData(); // 一个 Data 实例
	public UniquePet toBean(); // 一个 Bean 实例
	public UniquePet toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public UniquePet toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 所属角色

	public void setRoleid(long _v_); // 所属角色
}
