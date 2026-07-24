
package xbean;

public interface RolesNotifyMap extends mkdb.Bean {
	public RolesNotifyMap copy(); // 深拷贝
	public RolesNotifyMap toData(); // 一个 Data 实例
	public RolesNotifyMap toBean(); // 一个 Bean 实例
	public RolesNotifyMap toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RolesNotifyMap toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, xbean.RoleFutureNotifyMap> getRolesfuturemap(); // 

}
