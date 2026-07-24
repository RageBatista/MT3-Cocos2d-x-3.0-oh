
package xbean;

public interface ParticleSkill extends mkdb.Bean {
	public ParticleSkill copy(); // 深拷贝
	public ParticleSkill toData(); // 一个 Data 实例
	public ParticleSkill toBean(); // 一个 Bean 实例
	public ParticleSkill toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ParticleSkill toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getLevel(); // 
	public int getExp(); // 

	public void setLevel(int _v_); // 
	public void setExp(int _v_); // 
}
