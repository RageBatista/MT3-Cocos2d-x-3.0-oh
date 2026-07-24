
package xbean;

public interface FuShiRecord extends mkdb.Bean {
	public FuShiRecord copy(); // 深拷贝
	public FuShiRecord toData(); // 一个 Data 实例
	public FuShiRecord toBean(); // 一个 Bean 实例
	public FuShiRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public FuShiRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getAddtime(); // 增加的时间
	public int getCurrentnum(); // 当前数量

	public void setAddtime(long _v_); // 增加的时间
	public void setCurrentnum(int _v_); // 当前数量
}
