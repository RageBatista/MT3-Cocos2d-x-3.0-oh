
package xbean;

public interface ClanEventRecord extends mkdb.Bean {
	public ClanEventRecord copy(); // 深拷贝
	public ClanEventRecord toData(); // 一个 Data 实例
	public ClanEventRecord toBean(); // 一个 Bean 实例
	public ClanEventRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ClanEventRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getTime(); // 时间
	public int getEventtype(); // 时间
	public String getContent(); // 内容
	public com.locojoy.base.Octets getContentOctets(); // 内容
	public long getObjectroleid(); // 内容

	public void setTime(long _v_); // 时间
	public void setEventtype(int _v_); // 时间
	public void setContent(String _v_); // 内容
	public void setContentOctets(com.locojoy.base.Octets _v_); // 内容
	public void setObjectroleid(long _v_); // 内容
}
