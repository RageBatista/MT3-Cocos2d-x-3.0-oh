
package xbean;

public interface YybFushiNums extends mkdb.Bean {
	public YybFushiNums copy(); // 深拷贝
	public YybFushiNums toData(); // 一个 Data 实例
	public YybFushiNums toBean(); // 一个 Bean 实例
	public YybFushiNums toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public YybFushiNums toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, xbean.YybFushiNum> getRolefushi(); // 
	public java.util.Map<Long, xbean.YybFushiNum> getRolefushiAsData(); // 

}
