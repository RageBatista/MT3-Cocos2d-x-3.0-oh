
package xbean;

public interface FirstCharge extends mkdb.Bean {
	public FirstCharge copy(); // 深拷贝
	public FirstCharge toData(); // 一个 Data 实例
	public FirstCharge toBean(); // 一个 Bean 实例
	public FirstCharge toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public FirstCharge toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getFirstchargetime(); // 首冲的时间,可以被刷新的
	public long getFirstchargeclearpresenttime(); // 
	public long getChargestatus(); // 记录玩家首冲数据，0-未充过值 1-－充值了，未领取礼包 2，领取礼包了

	public void setFirstchargetime(long _v_); // 首冲的时间,可以被刷新的
	public void setFirstchargeclearpresenttime(long _v_); // 
	public void setChargestatus(long _v_); // 记录玩家首冲数据，0-未充过值 1-－充值了，未领取礼包 2，领取礼包了
}
