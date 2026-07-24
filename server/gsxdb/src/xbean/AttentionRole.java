
package xbean;

public interface AttentionRole extends mkdb.Bean {
	public AttentionRole copy(); // 深拷贝
	public AttentionRole toData(); // 一个 Data 实例
	public AttentionRole toBean(); // 一个 Bean 实例
	public AttentionRole toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public AttentionRole toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Set<Long> getRoleids(); // 角色id
	public java.util.Set<Long> getRoleidsAsData(); // 角色id

}
