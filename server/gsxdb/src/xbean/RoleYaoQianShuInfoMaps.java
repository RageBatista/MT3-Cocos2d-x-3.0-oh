
package xbean;

public interface RoleYaoQianShuInfoMaps extends mkdb.Bean {
	public RoleYaoQianShuInfoMaps copy(); // 深拷贝
	public RoleYaoQianShuInfoMaps toData(); // 一个 Data 实例
	public RoleYaoQianShuInfoMaps toBean(); // 一个 Bean 实例
	public RoleYaoQianShuInfoMaps toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleYaoQianShuInfoMaps toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, xbean.RoleYaoQianShuInfo> getYaoqianshumaps(); // key 为npckey
	public java.util.Map<Long, xbean.RoleYaoQianShuInfo> getYaoqianshumapsAsData(); // key 为npckey

}
