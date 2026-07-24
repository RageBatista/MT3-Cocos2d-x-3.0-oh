
package xbean;

public interface OffLineHook extends mkdb.Bean {
	public OffLineHook copy(); // 深拷贝
	public OffLineHook toData(); // 一个 Data 实例
	public OffLineHook toBean(); // 一个 Bean 实例
	public OffLineHook toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public OffLineHook toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getHooktime(); // 开始挂机时间
	public long getRemainfivebeitime(); // 点击使用5倍的时候封存5倍时间
	public long getFivebeitimestart(); // 开始使用五倍时间的时间
	public long getFivebeitotalusetime(); // 最后一次点击前总的使用时间
	public int getFlag(); // 0=无挂机或者已经领取了挂机经验 1=单倍挂机 2=5倍挂机

	public void setHooktime(long _v_); // 开始挂机时间
	public void setRemainfivebeitime(long _v_); // 点击使用5倍的时候封存5倍时间
	public void setFivebeitimestart(long _v_); // 开始使用五倍时间的时间
	public void setFivebeitotalusetime(long _v_); // 最后一次点击前总的使用时间
	public void setFlag(int _v_); // 0=无挂机或者已经领取了挂机经验 1=单倍挂机 2=5倍挂机
}
