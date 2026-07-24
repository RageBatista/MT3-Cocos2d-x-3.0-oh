
package xbean;

public interface PetSkill extends mkdb.Bean {
	public PetSkill copy(); // 深拷贝
	public PetSkill toData(); // 一个 Data 实例
	public PetSkill toBean(); // 一个 Bean 实例
	public PetSkill toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public PetSkill toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getSkillid(); // 技能id
	public int getSkilltype(); // 0=先天技能  1=后天通过技能书打上去的技能
	public int getCertification(); // 0=未认证 1=认证

	public void setSkillid(int _v_); // 技能id
	public void setSkilltype(int _v_); // 0=先天技能  1=后天通过技能书打上去的技能
	public void setCertification(int _v_); // 0=未认证 1=认证
}
