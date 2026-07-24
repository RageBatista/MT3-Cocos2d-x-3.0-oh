
package xbean;

public interface ProfessionLeaderTicketInfo extends mkdb.Bean {
	public ProfessionLeaderTicketInfo copy(); // 深拷贝
	public ProfessionLeaderTicketInfo toData(); // 一个 Data 实例
	public ProfessionLeaderTicketInfo toBean(); // 一个 Bean 实例
	public ProfessionLeaderTicketInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ProfessionLeaderTicketInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 角色id
	public int getTickets(); // role的得票
	public String getWords(); // role的宣言
	public com.locojoy.base.Octets getWordsOctets(); // role的宣言

	public void setRoleid(long _v_); // 角色id
	public void setTickets(int _v_); // role的得票
	public void setWords(String _v_); // role的宣言
	public void setWordsOctets(com.locojoy.base.Octets _v_); // role的宣言
}
