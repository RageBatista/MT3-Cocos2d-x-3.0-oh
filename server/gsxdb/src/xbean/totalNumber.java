
package xbean;

public interface totalNumber extends mkdb.Bean {
	public totalNumber copy(); // 深拷贝
	public totalNumber toData(); // 一个 Data 实例
	public totalNumber toBean(); // 一个 Bean 实例
	public totalNumber toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public totalNumber toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getTotalnumber(); // 

	public void setTotalnumber(long _v_); // 
}
