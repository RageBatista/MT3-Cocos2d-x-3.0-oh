
package xbean;

public interface FunOpenClose extends mkdb.Bean {
	public FunOpenClose copy(); // 深拷贝
	public FunOpenClose toData(); // 一个 Data 实例
	public FunOpenClose toBean(); // 一个 Bean 实例
	public FunOpenClose toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public FunOpenClose toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Integer> getFunmap(); // 
	public java.util.Map<Integer, Integer> getFunmapAsData(); // 

}
