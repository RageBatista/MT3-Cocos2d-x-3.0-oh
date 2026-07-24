
package xbean;

public interface YbNums extends mkdb.Bean {
	public YbNums copy(); // 深拷贝
	public YbNums toData(); // 一个 Data 实例
	public YbNums toBean(); // 一个 Bean 实例
	public YbNums toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public YbNums toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, xbean.YbNum> getRoleyb(); // 角色id -> 符石，作者 changhao
	public java.util.Map<Long, xbean.YbNum> getRoleybAsData(); // 角色id -> 符石，作者 changhao

}
