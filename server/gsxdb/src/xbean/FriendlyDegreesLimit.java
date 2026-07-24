
package xbean;

public interface FriendlyDegreesLimit extends mkdb.Bean {
	public FriendlyDegreesLimit copy(); // 深拷贝
	public FriendlyDegreesLimit toData(); // 一个 Data 实例
	public FriendlyDegreesLimit toBean(); // 一个 Bean 实例
	public FriendlyDegreesLimit toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public FriendlyDegreesLimit toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, Integer> getTodayfriendlydegreesmap(); // key=roleid value=今日增加的好友度
	public java.util.Map<Long, Integer> getTodayfriendlydegreesmapAsData(); // key=roleid value=今日增加的好友度
	public long getResettime(); // 每日增加的好友度重置时间

	public void setResettime(long _v_); // 每日增加的好友度重置时间
}
