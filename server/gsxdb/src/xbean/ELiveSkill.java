
package xbean;

public interface ELiveSkill extends mkdb.Bean {
	public ELiveSkill copy(); // 深拷贝
	public ELiveSkill toData(); // 一个 Data 实例
	public ELiveSkill toBean(); // 一个 Bean 实例
	public ELiveSkill toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ELiveSkill toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.LiveSkill> getLiveskilllist(); // 
	public java.util.Map<Integer, xbean.LiveSkill> getLiveskilllistAsData(); // 

}
