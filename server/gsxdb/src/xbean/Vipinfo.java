
package xbean;

public interface Vipinfo extends mkdb.Bean {
	public Vipinfo copy(); // 深拷贝
	public Vipinfo toData(); // 一个 Data 实例
	public Vipinfo toBean(); // 一个 Bean 实例
	public Vipinfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public Vipinfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getVipexp(); // 已充符石数量
	public int getViplevel(); // VIP等级
	public int getBonus(); // 可领奖励
	public int getGotbonus(); // 已领奖励

	public void setVipexp(int _v_); // 已充符石数量
	public void setViplevel(int _v_); // VIP等级
	public void setBonus(int _v_); // 可领奖励
	public void setGotbonus(int _v_); // 已领奖励
}
