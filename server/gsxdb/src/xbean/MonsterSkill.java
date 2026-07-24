
package xbean;

public interface MonsterSkill extends mkdb.Bean {
	public MonsterSkill copy(); // 深拷贝
	public MonsterSkill toData(); // 一个 Data 实例
	public MonsterSkill toBean(); // 一个 Bean 实例
	public MonsterSkill toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public MonsterSkill toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getId(); // 
	public int getSkilllevel(); // 
	public int getCastrate(); // 以千为底

	public void setId(int _v_); // 
	public void setSkilllevel(int _v_); // 
	public void setCastrate(int _v_); // 以千为底
}
