
package xbean;

public interface RoleBlackMarket extends mkdb.Bean {
	public RoleBlackMarket copy(); // 深拷贝
	public RoleBlackMarket toData(); // 一个 Data 实例
	public RoleBlackMarket toBean(); // 一个 Bean 实例
	public RoleBlackMarket toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleBlackMarket toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, xbean.GoldOrder> getGoldordersale(); // 出售列表
	public java.util.Map<Long, xbean.GoldOrder> getGoldordersaleAsData(); // 出售列表
	public java.util.Map<Long, xbean.GoldOrder> getGoldorderbuy(); // 购买列表
	public java.util.Map<Long, xbean.GoldOrder> getGoldorderbuyAsData(); // 购买列表

}
