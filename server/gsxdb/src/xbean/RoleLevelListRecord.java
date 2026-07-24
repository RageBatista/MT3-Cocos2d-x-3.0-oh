
package xbean;

public interface RoleLevelListRecord extends mkdb.Bean {
	public RoleLevelListRecord copy(); // 深拷贝
	public RoleLevelListRecord toData(); // 一个 Data 实例
	public RoleLevelListRecord toBean(); // 一个 Bean 实例
	public RoleLevelListRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleLevelListRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getTime(); // 达到这个数量的时间
	public xbean.MarshalRoleLevelRecord getMarshaldata(); // 

	public void setTime(long _v_); // 达到这个数量的时间
}
