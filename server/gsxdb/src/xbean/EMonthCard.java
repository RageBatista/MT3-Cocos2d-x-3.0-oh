
package xbean;

public interface EMonthCard extends mkdb.Bean {
	public EMonthCard copy(); // 深拷贝
	public EMonthCard toData(); // 一个 Data 实例
	public EMonthCard toBean(); // 一个 Bean 实例
	public EMonthCard toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public EMonthCard toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getEndtime(); // 结束时间戳，作者 changhao
	public long getGrabtime(); // 领取时间戳，作者 changhao
	public long getFirstprompttime(); // 少于3天提示，作者 changhao

	public void setEndtime(long _v_); // 结束时间戳，作者 changhao
	public void setGrabtime(long _v_); // 领取时间戳，作者 changhao
	public void setFirstprompttime(long _v_); // 少于3天提示，作者 changhao
}
