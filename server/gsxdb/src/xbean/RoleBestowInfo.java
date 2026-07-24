
package xbean;

public interface RoleBestowInfo extends mkdb.Bean {
	public RoleBestowInfo copy(); // 深拷贝
	public RoleBestowInfo toData(); // 一个 Data 实例
	public RoleBestowInfo toBean(); // 一个 Bean 实例
	public RoleBestowInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleBestowInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, xbean.RoleBestowCount> getRolebestowinfo(); // 每个宝箱的开启次数
	public java.util.Map<Long, xbean.RoleBestowCount> getRolebestowinfoAsData(); // 每个宝箱的开启次数

}
