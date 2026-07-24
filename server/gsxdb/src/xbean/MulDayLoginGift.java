
package xbean;

public interface MulDayLoginGift extends mkdb.Bean {
	public MulDayLoginGift copy(); // 深拷贝
	public MulDayLoginGift toData(); // 一个 Data 实例
	public MulDayLoginGift toBean(); // 一个 Bean 实例
	public MulDayLoginGift toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public MulDayLoginGift toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getLogindays(); // 累计登录天数
	public long getLogintime(); // 更新时间
	public java.util.Map<Integer, Long> getRewardmap(); // 七日登录奖励(key-奖励ID，val-领取时间(0表示未领取))
	public java.util.Map<Integer, Long> getRewardmapAsData(); // 七日登录奖励(key-奖励ID，val-领取时间(0表示未领取))

	public void setLogindays(int _v_); // 累计登录天数
	public void setLogintime(long _v_); // 更新时间
}
