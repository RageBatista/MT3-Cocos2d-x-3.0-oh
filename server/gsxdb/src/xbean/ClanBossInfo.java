
package xbean;

public interface ClanBossInfo extends mkdb.Bean {
	public ClanBossInfo copy(); // 深拷贝
	public ClanBossInfo toData(); // 一个 Data 实例
	public ClanBossInfo toBean(); // 一个 Bean 实例
	public ClanBossInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ClanBossInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getBossmonsterid(); // 
	public long getMaxhp(); // 
	public long getHp(); // 
	public int getFighteindx(); // 
	public java.util.List<Long> getWinroleids(); // 最后一击的角色
	public java.util.List<Long> getWinroleidsAsData(); // 最后一击的角色
	public long getBossnpckey(); // 

	public void setBossmonsterid(int _v_); // 
	public void setMaxhp(long _v_); // 
	public void setHp(long _v_); // 
	public void setFighteindx(int _v_); // 
	public void setBossnpckey(long _v_); // 
}
