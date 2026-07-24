
package xbean;

public interface PracticeSkill extends mkdb.Bean {
	public PracticeSkill copy(); // 深拷贝
	public PracticeSkill toData(); // 一个 Data 实例
	public PracticeSkill toBean(); // 一个 Bean 实例
	public PracticeSkill toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public PracticeSkill toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getLevel(); // 
	public int getExp(); // 

	public void setLevel(int _v_); // 
	public void setExp(int _v_); // 
}
