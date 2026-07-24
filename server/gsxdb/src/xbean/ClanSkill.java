
package xbean;

public interface ClanSkill extends mkdb.Bean {
	public ClanSkill copy(); // 深拷贝
	public ClanSkill toData(); // 一个 Data 实例
	public ClanSkill toBean(); // 一个 Bean 实例
	public ClanSkill toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ClanSkill toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getClanskillid(); // 技能id
	public int getClanskilllevel(); // 技能当前等级
	public int getClanskillexp(); // 技能当前经验

	public void setClanskillid(int _v_); // 技能id
	public void setClanskilllevel(int _v_); // 技能当前等级
	public void setClanskillexp(int _v_); // 技能当前经验
}
