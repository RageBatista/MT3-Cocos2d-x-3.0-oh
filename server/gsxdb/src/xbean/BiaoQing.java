
package xbean;

public interface BiaoQing extends mkdb.Bean {
	public BiaoQing copy(); // 深拷贝
	public BiaoQing toData(); // 一个 Data 实例
	public BiaoQing toBean(); // 一个 Bean 实例
	public BiaoQing toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BiaoQing toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Long> getBiaoqinginfos(); // 
	public java.util.Map<Integer, Long> getBiaoqinginfosAsData(); // 

}
