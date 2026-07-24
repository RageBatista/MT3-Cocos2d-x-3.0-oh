
package xbean;

public interface HookData extends mkdb.Bean {
	public HookData copy(); // 深拷贝
	public HookData toData(); // 一个 Data 实例
	public HookData toBean(); // 一个 Bean 实例
	public HookData toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public HookData toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public short getCangetdpoint(); // 可领取双倍点数
	public short getGetdpoint(); // 已领取双倍点数
	public boolean getIsautobattle(); // 是否自动战斗
	public short getCharoptype(); // 人物操作类型
	public int getCharopid(); // 人物操作id
	public short getPetoptype(); // 宠物操作类型
	public int getPetopid(); // 宠物操作id
	public long getOfflineexp(); // 离线经验
	public long getLastgettime(); // 上次系统发放双倍点数时间

	public void setCangetdpoint(short _v_); // 可领取双倍点数
	public void setGetdpoint(short _v_); // 已领取双倍点数
	public void setIsautobattle(boolean _v_); // 是否自动战斗
	public void setCharoptype(short _v_); // 人物操作类型
	public void setCharopid(int _v_); // 人物操作id
	public void setPetoptype(short _v_); // 宠物操作类型
	public void setPetopid(int _v_); // 宠物操作id
	public void setOfflineexp(long _v_); // 离线经验
	public void setLastgettime(long _v_); // 上次系统发放双倍点数时间
}
