
package xbean;

public interface LiveDieWeekNum extends mkdb.Bean {
	public LiveDieWeekNum copy(); // 深拷贝
	public LiveDieWeekNum toData(); // 一个 Data 实例
	public LiveDieWeekNum toBean(); // 一个 Bean 实例
	public LiveDieWeekNum toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public LiveDieWeekNum toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getWeeknum(); // 生死战清除录像记录

	public void setWeeknum(long _v_); // 生死战清除录像记录
}
