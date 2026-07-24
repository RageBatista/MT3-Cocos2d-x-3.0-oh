
package xbean;

public interface lichengxinxi extends mkdb.Bean {
	public lichengxinxi copy(); // 深拷贝
	public lichengxinxi toData(); // 一个 Data 实例
	public lichengxinxi toBean(); // 一个 Bean 实例
	public lichengxinxi toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public lichengxinxi toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.Course> getLicheng(); // 
	public java.util.Map<Integer, xbean.Course> getLichengAsData(); // 

}
