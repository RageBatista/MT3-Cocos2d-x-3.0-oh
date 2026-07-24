
package xbean;

public interface EParticleSkill extends mkdb.Bean {
	public EParticleSkill copy(); // 深拷贝
	public EParticleSkill toData(); // 一个 Data 实例
	public EParticleSkill toBean(); // 一个 Bean 实例
	public EParticleSkill toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public EParticleSkill toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.ParticleSkill> getParticleskill(); // 
	public java.util.Map<Integer, xbean.ParticleSkill> getParticleskillAsData(); // 

}
