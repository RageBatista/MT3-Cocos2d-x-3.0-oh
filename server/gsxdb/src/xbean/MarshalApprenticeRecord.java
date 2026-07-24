
package xbean;

public interface MarshalApprenticeRecord extends mkdb.Bean {
	public MarshalApprenticeRecord copy(); // 深拷贝
	public MarshalApprenticeRecord toData(); // 一个 Data 实例
	public MarshalApprenticeRecord toBean(); // 一个 Bean 实例
	public MarshalApprenticeRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public MarshalApprenticeRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 角色id
	public String getNickname(); // 名字
	public com.locojoy.base.Octets getNicknameOctets(); // 名字
	public int getLevel(); // 等级
	public int getSchoolid(); // 职业id
	public int getApprenticenum(); // 出徒数量
	public int getRank(); // 排名

	public void setRoleid(long _v_); // 角色id
	public void setNickname(String _v_); // 名字
	public void setNicknameOctets(com.locojoy.base.Octets _v_); // 名字
	public void setLevel(int _v_); // 等级
	public void setSchoolid(int _v_); // 职业id
	public void setApprenticenum(int _v_); // 出徒数量
	public void setRank(int _v_); // 排名
}
