
package xbean;

public interface Protectors extends mkdb.Bean {
	public Protectors copy(); // 深拷贝
	public Protectors toData(); // 一个 Data 实例
	public Protectors toBean(); // 一个 Bean 实例
	public Protectors toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public Protectors toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<Integer> getProtectorlist(); // 
	public java.util.List<Integer> getProtectorlistAsData(); // 

}
