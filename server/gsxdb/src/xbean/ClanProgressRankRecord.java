
package xbean;

public interface ClanProgressRankRecord extends mkdb.Bean {
	public ClanProgressRankRecord copy(); // 深拷贝
	public ClanProgressRankRecord toData(); // 一个 Data 实例
	public ClanProgressRankRecord toBean(); // 一个 Bean 实例
	public ClanProgressRankRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ClanProgressRankRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getRank(); // 排名，作者 changhao
	public long getClankey(); // 
	public String getClanname(); // 公会名称，作者 changhao
	public com.locojoy.base.Octets getClannameOctets(); // 公会名称，作者 changhao
	public long getTime(); // 时间，作者 changhao
	public int getProgress(); // 进度，作者 changhao
	public String getClanmastername(); // 会长名字，作者 changhao
	public com.locojoy.base.Octets getClanmasternameOctets(); // 会长名字，作者 changhao
	public long getTriggertime(); // 触发时间，作者 changhao
	public int getCopyid(); // 副本id，作者 changhao
	public String getCopyname(); // 副本名字，作者 changhao
	public com.locojoy.base.Octets getCopynameOctets(); // 副本名字，作者 changhao
	public float getBosshp(); // BOSS血量，作者 changhao

	public void setRank(int _v_); // 排名，作者 changhao
	public void setClankey(long _v_); // 
	public void setClanname(String _v_); // 公会名称，作者 changhao
	public void setClannameOctets(com.locojoy.base.Octets _v_); // 公会名称，作者 changhao
	public void setTime(long _v_); // 时间，作者 changhao
	public void setProgress(int _v_); // 进度，作者 changhao
	public void setClanmastername(String _v_); // 会长名字，作者 changhao
	public void setClanmasternameOctets(com.locojoy.base.Octets _v_); // 会长名字，作者 changhao
	public void setTriggertime(long _v_); // 触发时间，作者 changhao
	public void setCopyid(int _v_); // 副本id，作者 changhao
	public void setCopyname(String _v_); // 副本名字，作者 changhao
	public void setCopynameOctets(com.locojoy.base.Octets _v_); // 副本名字，作者 changhao
	public void setBosshp(float _v_); // BOSS血量，作者 changhao
}
