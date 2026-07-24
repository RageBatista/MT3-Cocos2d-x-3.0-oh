
package xbean;

public interface RoleClanPoint extends mkdb.Bean {
	public RoleClanPoint copy(); // 深拷贝
	public RoleClanPoint toData(); // 一个 Data 实例
	public RoleClanPoint toBean(); // 一个 Bean 实例
	public RoleClanPoint toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleClanPoint toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getFreezedclanpoint(); // 已冻结公会贡献度
	public int getCurrentclanpoint(); // 当前公会贡献度
	public int getHistoryclanpoint(); // 历史公会贡献度
	public int getWeekclanpoint(); // 周公会贡献度by hzl
	public int getPreweekclanpoint(); // 上周周公会贡献度by hzl
	public int getOldhistoryclanpoint(); // 旧的历史公会贡献度
	public int getOldfreezedclanpoint(); // 上次退出公会时候冻结公会贡献度

	public void setFreezedclanpoint(int _v_); // 已冻结公会贡献度
	public void setCurrentclanpoint(int _v_); // 当前公会贡献度
	public void setHistoryclanpoint(int _v_); // 历史公会贡献度
	public void setWeekclanpoint(int _v_); // 周公会贡献度by hzl
	public void setPreweekclanpoint(int _v_); // 上周周公会贡献度by hzl
	public void setOldhistoryclanpoint(int _v_); // 旧的历史公会贡献度
	public void setOldfreezedclanpoint(int _v_); // 上次退出公会时候冻结公会贡献度
}
