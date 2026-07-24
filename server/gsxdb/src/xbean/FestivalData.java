
package xbean;

public interface FestivalData extends mkdb.Bean {
	public FestivalData copy(); // 深拷贝
	public FestivalData toData(); // 一个 Data 实例
	public FestivalData toBean(); // 一个 Bean 实例
	public FestivalData toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public FestivalData toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Long> getRewardmap(); // 已经领取的节日奖励(key-奖励ID, value-领取时间)
	public java.util.Map<Integer, Long> getRewardmapAsData(); // 已经领取的节日奖励(key-奖励ID, value-领取时间)

}
