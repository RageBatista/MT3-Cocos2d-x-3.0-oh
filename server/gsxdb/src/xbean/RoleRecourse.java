
package xbean;

public interface RoleRecourse extends mkdb.Bean {
	public RoleRecourse copy(); // 深拷贝
	public RoleRecourse toData(); // 一个 Data 实例
	public RoleRecourse toBean(); // 一个 Bean 实例
	public RoleRecourse toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleRecourse toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.TaskRecourse> getRecoursetask(); // 
	public java.util.Map<Integer, xbean.TaskRecourse> getRecoursetaskAsData(); // 

}
