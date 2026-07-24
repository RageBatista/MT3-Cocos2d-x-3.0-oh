
package xbean;

public interface Bag extends mkdb.Bean {
	public Bag copy(); // 深拷贝
	public Bag toData(); // 一个 Data 实例
	public Bag toBean(); // 一个 Bean 实例
	public Bag toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public Bag toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Long> getCurrency(); // 货币, key 为枚举值, value为货币值
	public java.util.Map<Integer, Long> getCurrencyAsData(); // 货币, key 为枚举值, value为货币值
	public int getCapacity(); // 
	public int getNextid(); // 
	public java.util.Map<Integer, xbean.Item> getItems(); // 
	public java.util.Map<Integer, xbean.Item> getItemsAsData(); // 
	public int getLocked(); // 0 没有锁。1 有锁

	public void setCapacity(int _v_); // 
	public void setNextid(int _v_); // 
	public void setLocked(int _v_); // 0 没有锁。1 有锁
}
