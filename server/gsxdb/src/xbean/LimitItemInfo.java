
package xbean;

public interface LimitItemInfo extends mkdb.Bean {
	public LimitItemInfo copy(); // 深拷贝
	public LimitItemInfo toData(); // 一个 Data 实例
	public LimitItemInfo toBean(); // 一个 Bean 实例
	public LimitItemInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public LimitItemInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getMaxnum(); // 
	public int getNum(); // 

	public void setMaxnum(int _v_); // 
	public void setNum(int _v_); // 
}
