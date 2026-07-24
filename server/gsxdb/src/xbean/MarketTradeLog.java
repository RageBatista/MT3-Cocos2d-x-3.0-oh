
package xbean;

public interface MarketTradeLog extends mkdb.Bean {
	public MarketTradeLog copy(); // 深拷贝
	public MarketTradeLog toData(); // 一个 Data 实例
	public MarketTradeLog toBean(); // 一个 Bean 实例
	public MarketTradeLog toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public MarketTradeLog toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.LogBean> getBuylog(); // 买记录
	public java.util.List<xbean.LogBean> getBuylogAsData(); // 买记录
	public java.util.List<xbean.LogBean> getSalelog(); // 卖记录
	public java.util.List<xbean.LogBean> getSalelogAsData(); // 卖记录

}
