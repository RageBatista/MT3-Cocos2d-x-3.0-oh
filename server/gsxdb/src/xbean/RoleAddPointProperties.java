
package xbean;

public interface RoleAddPointProperties extends mkdb.Bean {
	public RoleAddPointProperties copy(); // 深拷贝
	public RoleAddPointProperties toData(); // 一个 Data 实例
	public RoleAddPointProperties toBean(); // 一个 Bean 实例
	public RoleAddPointProperties toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleAddPointProperties toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Integer> getCons_save(); // 已分配体质
	public java.util.Map<Integer, Integer> getCons_saveAsData(); // 已分配体质
	public java.util.Map<Integer, Integer> getIq_save(); // 已分配智力
	public java.util.Map<Integer, Integer> getIq_saveAsData(); // 已分配智力
	public java.util.Map<Integer, Integer> getStr_save(); // 已分配力量
	public java.util.Map<Integer, Integer> getStr_saveAsData(); // 已分配力量
	public java.util.Map<Integer, Integer> getEndu_save(); // 已分配耐力
	public java.util.Map<Integer, Integer> getEndu_saveAsData(); // 已分配耐力
	public java.util.Map<Integer, Integer> getAgi_save(); // 已分配敏捷
	public java.util.Map<Integer, Integer> getAgi_saveAsData(); // 已分配敏捷

}
