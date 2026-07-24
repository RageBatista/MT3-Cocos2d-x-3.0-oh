
package xbean;

public interface SpecialSkill extends mkdb.Bean {
	public SpecialSkill copy(); // 深拷贝
	public SpecialSkill toData(); // 一个 Data 实例
	public SpecialSkill toBean(); // 一个 Bean 实例
	public SpecialSkill toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public SpecialSkill toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getSkillid(); // 
	public int getEquiptype(); // 

	public void setSkillid(int _v_); // 
	public void setEquiptype(int _v_); // 
}
