
package xbean;

public interface RoleTradingInfoList extends mkdb.Bean {
	public RoleTradingInfoList copy(); // 深拷贝
	public RoleTradingInfoList toData(); // 一个 Data 实例
	public RoleTradingInfoList toBean(); // 一个 Bean 实例
	public RoleTradingInfoList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleTradingInfoList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<String, String> getTradinglist(); // 
	public java.util.Map<String, String> getTradinglistAsData(); // 

}
