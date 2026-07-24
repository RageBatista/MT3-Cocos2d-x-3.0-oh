
package xbean;

public interface RegMonth extends mkdb.Bean {
	public RegMonth copy(); // 深拷贝
	public RegMonth toData(); // 一个 Data 实例
	public RegMonth toBean(); // 一个 Bean 实例
	public RegMonth toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RegMonth toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.RegDay> getDaymap(); // 
	public java.util.Map<Integer, xbean.RegDay> getDaymapAsData(); // 
	public int getSuppregnum(); // 补签次数

	public void setSuppregnum(int _v_); // 补签次数
}
