
package xbean;

public interface PetScoreListRecord extends mkdb.Bean {
	public PetScoreListRecord copy(); // 深拷贝
	public PetScoreListRecord toData(); // 一个 Data 实例
	public PetScoreListRecord toBean(); // 一个 Bean 实例
	public PetScoreListRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public PetScoreListRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getTime(); // 达到这个数量的时间
	public xbean.MarshalPetScoreRecord getMarshaldata(); // 

	public void setTime(long _v_); // 达到这个数量的时间
}
