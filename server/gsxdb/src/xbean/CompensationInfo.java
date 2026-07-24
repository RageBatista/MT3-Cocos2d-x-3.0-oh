
package xbean;

public interface CompensationInfo extends mkdb.Bean {
	public CompensationInfo copy(); // 深拷贝
	public CompensationInfo toData(); // 一个 Data 实例
	public CompensationInfo toBean(); // 一个 Bean 实例
	public CompensationInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public CompensationInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getReceiveawardtime(); // 领取奖励的时间
	public int getReadflag(); // 是否已读 0=未读 1=已读

	public void setReceiveawardtime(long _v_); // 领取奖励的时间
	public void setReadflag(int _v_); // 是否已读 0=未读 1=已读
}
