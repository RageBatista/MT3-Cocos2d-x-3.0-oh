
package xbean;

public interface RolePingBiRolesInfo extends mkdb.Bean {
	public RolePingBiRolesInfo copy(); // 深拷贝
	public RolePingBiRolesInfo toData(); // 一个 Data 实例
	public RolePingBiRolesInfo toBean(); // 一个 Bean 实例
	public RolePingBiRolesInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RolePingBiRolesInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, Long> getPingbiroles(); // //存储黑名单角色id
	public java.util.Map<Long, Long> getPingbirolesAsData(); // //存储黑名单角色id

}
