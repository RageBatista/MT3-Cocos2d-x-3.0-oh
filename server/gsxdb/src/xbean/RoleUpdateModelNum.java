
package xbean;

public interface RoleUpdateModelNum extends mkdb.Bean {
	public RoleUpdateModelNum copy(); // 深拷贝
	public RoleUpdateModelNum toData(); // 一个 Data 实例
	public RoleUpdateModelNum toBean(); // 一个 Bean 实例
	public RoleUpdateModelNum toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleUpdateModelNum toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getTradingbuyfushinum(); // 每日交易所购买符石数量

	public void setTradingbuyfushinum(int _v_); // 每日交易所购买符石数量
}
