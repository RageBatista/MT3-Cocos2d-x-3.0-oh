
package xbean;

public interface npcaward extends mkdb.Bean {
	public npcaward copy(); // 深拷贝
	public npcaward toData(); // 一个 Data 实例
	public npcaward toBean(); // 一个 Bean 实例
	public npcaward toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public npcaward toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getLasttime(); // 上次领取时间
	public int getCount(); // 已经领取次数
	public int getTotalcount(); // 领取总次数

	public void setLasttime(long _v_); // 上次领取时间
	public void setCount(int _v_); // 已经领取次数
	public void setTotalcount(int _v_); // 领取总次数
}
