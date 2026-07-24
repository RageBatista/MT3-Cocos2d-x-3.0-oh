
package xbean;

public interface AssistSkill extends mkdb.Bean {
	public AssistSkill copy(); // 深拷贝
	public AssistSkill toData(); // 一个 Data 实例
	public AssistSkill toBean(); // 一个 Bean 实例
	public AssistSkill toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public AssistSkill toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getLevel(); // 
	public long getExp(); // 

	public void setLevel(int _v_); // 
	public void setExp(long _v_); // 
}
