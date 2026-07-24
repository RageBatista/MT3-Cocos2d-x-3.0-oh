
package xbean;

public interface RewardData extends mkdb.Bean {
	public RewardData copy(); // 深拷贝
	public RewardData toData(); // 一个 Data 实例
	public RewardData toBean(); // 一个 Bean 实例
	public RewardData toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RewardData toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getRewardid(); // 领了多少个奖励,缺省是0
	public long getLastrewardtime(); // 上次领取奖励的时间
	public long getTimewait(); // 距离下次奖励领取等待时间

	public void setRewardid(int _v_); // 领了多少个奖励,缺省是0
	public void setLastrewardtime(long _v_); // 上次领取奖励的时间
	public void setTimewait(long _v_); // 距离下次奖励领取等待时间
}
