
package xbean;

public interface LiveSkill extends mkdb.Bean {
	public LiveSkill copy(); // 深拷贝
	public LiveSkill toData(); // 一个 Data 实例
	public LiveSkill toBean(); // 一个 Bean 实例
	public LiveSkill toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public LiveSkill toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getLevel(); // 

	public void setLevel(int _v_); // 
}
