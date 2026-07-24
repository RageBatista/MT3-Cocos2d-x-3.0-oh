
package xbean;

public interface RegRec extends mkdb.Bean {
	public RegRec copy(); // 深拷贝
	public RegRec toData(); // 一个 Data 实例
	public RegRec toBean(); // 一个 Bean 实例
	public RegRec toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RegRec toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.RegMonth> getMonthmap(); // 月Map
	public java.util.Map<Integer, xbean.RegMonth> getMonthmapAsData(); // 月Map
	public long getLastregtime(); // 上次签到时间

	public void setLastregtime(long _v_); // 上次签到时间
}
