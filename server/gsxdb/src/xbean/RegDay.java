
package xbean;

public interface RegDay extends mkdb.Bean {
	public RegDay copy(); // 深拷贝
	public RegDay toData(); // 一个 Data 实例
	public RegDay toBean(); // 一个 Bean 实例
	public RegDay toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RegDay toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getRewardflag(); // 奖励标志(1-过期 2-已领取 3-未领取)
	public int getDay(); // 第几天
	public int getSuppregflag(); // 补签标志(0-正常签到 1-补签)

	public void setRewardflag(int _v_); // 奖励标志(1-过期 2-已领取 3-未领取)
	public void setDay(int _v_); // 第几天
	public void setSuppregflag(int _v_); // 补签标志(0-正常签到 1-补签)
}
