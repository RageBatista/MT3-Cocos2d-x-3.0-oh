
package xbean;

public interface MarshalPetScoreRecord extends mkdb.Bean {
	public MarshalPetScoreRecord copy(); // 深拷贝
	public MarshalPetScoreRecord toData(); // 一个 Data 实例
	public MarshalPetScoreRecord toBean(); // 一个 Bean 实例
	public MarshalPetScoreRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public MarshalPetScoreRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 角色id
	public long getUniquepetid(); // 宠物的唯一id
	public String getNickname(); // 名字
	public com.locojoy.base.Octets getNicknameOctets(); // 名字
	public String getPetname(); // 宠物名字
	public com.locojoy.base.Octets getPetnameOctets(); // 宠物名字
	public int getPetgrade(); // 宠物评分
	public int getRank(); // 排名
	public int getColour(); // 宠物颜色
	public int getShape(); // 宠物造型ID

	public void setRoleid(long _v_); // 角色id
	public void setUniquepetid(long _v_); // 宠物的唯一id
	public void setNickname(String _v_); // 名字
	public void setNicknameOctets(com.locojoy.base.Octets _v_); // 名字
	public void setPetname(String _v_); // 宠物名字
	public void setPetnameOctets(com.locojoy.base.Octets _v_); // 宠物名字
	public void setPetgrade(int _v_); // 宠物评分
	public void setRank(int _v_); // 排名
	public void setColour(int _v_); // 宠物颜色
	public void setShape(int _v_); // 宠物造型ID
}
