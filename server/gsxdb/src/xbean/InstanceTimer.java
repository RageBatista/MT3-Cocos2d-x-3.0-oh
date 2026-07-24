
package xbean;

public interface InstanceTimer extends mkdb.Bean {
	public InstanceTimer copy(); // 深拷贝
	public InstanceTimer toData(); // 一个 Data 实例
	public InstanceTimer toBean(); // 一个 Bean 实例
	public InstanceTimer toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public InstanceTimer toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public final static int STATE_UNSTART = 0; // 
	public final static int STATE_START = 1; // 
	public final static int STATE_END = 2; // 

	public int getState(); // 状态 0=未开始；1=已开始；2=已结束
	public long getStarttime(); // 开始时间
	public long getEndtime(); // 结束时间
	public long getFuturekey(); // 在timerfutures中的key

	public void setState(int _v_); // 状态 0=未开始；1=已开始；2=已结束
	public void setStarttime(long _v_); // 开始时间
	public void setEndtime(long _v_); // 结束时间
	public void setFuturekey(long _v_); // 在timerfutures中的key
}
