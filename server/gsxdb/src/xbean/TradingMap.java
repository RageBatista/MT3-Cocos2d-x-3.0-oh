
package xbean;

public interface TradingMap extends mkdb.Bean {
	public TradingMap copy(); // 深拷贝
	public TradingMap toData(); // 一个 Data 实例
	public TradingMap toBean(); // 一个 Bean 实例
	public TradingMap toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TradingMap toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.TradingPrice> getSelllist(); // 排序好的出售列表
	public java.util.List<xbean.TradingPrice> getSelllistAsData(); // 排序好的出售列表
	public java.util.List<xbean.TradingPrice> getBuylist(); // 排序好的购买列表
	public java.util.List<xbean.TradingPrice> getBuylistAsData(); // 排序好的购买列表

}
