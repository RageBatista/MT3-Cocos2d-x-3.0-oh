
package xbean;

public interface ChatTime extends mkdb.Bean {
	public ChatTime copy(); // 深拷贝
	public ChatTime toData(); // 一个 Data 实例
	public ChatTime toBean(); // 一个 Bean 实例
	public ChatTime toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ChatTime toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getLastworldchattime(); // 上次世界聊天时间
	public long getLastcurrentchattime(); // 上次当前聊天时间
	public long getLastprofessionchattime(); // 上次职业聊天时间
	public long getLastclanchattime(); // 上次公会聊天时间
	public long getLastteamapplychattime(); // 上次组队申请喊话时间

	public void setLastworldchattime(long _v_); // 上次世界聊天时间
	public void setLastcurrentchattime(long _v_); // 上次当前聊天时间
	public void setLastprofessionchattime(long _v_); // 上次职业聊天时间
	public void setLastclanchattime(long _v_); // 上次公会聊天时间
	public void setLastteamapplychattime(long _v_); // 上次组队申请喊话时间
}
