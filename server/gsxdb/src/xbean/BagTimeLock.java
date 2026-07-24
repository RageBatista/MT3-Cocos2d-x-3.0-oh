
package xbean;

public interface BagTimeLock extends mkdb.Bean {
	public BagTimeLock copy(); // 深拷贝
	public BagTimeLock toData(); // 一个 Data 实例
	public BagTimeLock toBean(); // 一个 Bean 实例
	public BagTimeLock toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BagTimeLock toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getItemkey(); // 
	public int getNum(); // 
	public long getTimeout(); // 超时时间

	public void setItemkey(int _v_); // 
	public void setNum(int _v_); // 
	public void setTimeout(long _v_); // 超时时间
}
