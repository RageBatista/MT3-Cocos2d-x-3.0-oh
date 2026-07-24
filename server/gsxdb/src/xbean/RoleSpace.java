
package xbean;

public interface RoleSpace extends mkdb.Bean {
	public RoleSpace copy(); // 深拷贝
	public RoleSpace toData(); // 一个 Data 实例
	public RoleSpace toBean(); // 一个 Bean 实例
	public RoleSpace toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleSpace toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getGift(); // 空间礼物
	public int getPopularity(); // 人气
	public int getRecvgift(); // 收到的礼物
	public int getGetgiftnum(); // 踩空间获得礼物的次数
	public long getGetgifttime(); // 上次踩空间获得礼物的时间

	public void setGift(int _v_); // 空间礼物
	public void setPopularity(int _v_); // 人气
	public void setRecvgift(int _v_); // 收到的礼物
	public void setGetgiftnum(int _v_); // 踩空间获得礼物的次数
	public void setGetgifttime(long _v_); // 上次踩空间获得礼物的时间
}
