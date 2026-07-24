
package xbean;

public interface BeginnerTip extends mkdb.Bean {
	public BeginnerTip copy(); // 深拷贝
	public BeginnerTip toData(); // 一个 Data 实例
	public BeginnerTip toBean(); // 一个 Bean 实例
	public BeginnerTip toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BeginnerTip toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Integer> getTips(); // 
	public java.util.Map<Integer, Integer> getTipsAsData(); // 

}
