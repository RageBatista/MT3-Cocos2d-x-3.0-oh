
package xbean;

public interface FestivalGift extends mkdb.Bean {
	public FestivalGift copy(); // 深拷贝
	public FestivalGift toData(); // 一个 Data 实例
	public FestivalGift toBean(); // 一个 Bean 实例
	public FestivalGift toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public FestivalGift toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getTime(); // 上次领取节日礼物的时间
	public long getOnlinetotal(); // 距上次领取礼物累计时间

	public void setTime(long _v_); // 上次领取节日礼物的时间
	public void setOnlinetotal(long _v_); // 距上次领取礼物累计时间
}
