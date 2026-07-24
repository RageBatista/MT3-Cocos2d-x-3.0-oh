
package xbean;

public interface LDVideoRoleInfoDes extends mkdb.Bean {
	public LDVideoRoleInfoDes copy(); // 深拷贝
	public LDVideoRoleInfoDes toData(); // 一个 Data 实例
	public LDVideoRoleInfoDes toBean(); // 一个 Bean 实例
	public LDVideoRoleInfoDes toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public LDVideoRoleInfoDes toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public xbean.LDRoleInfoDes getRole1(); // 对手1
	public xbean.LDRoleInfoDes getRole2(); // 对手1
	public java.util.List<xbean.LDTeamRoleInfoDes> getTeamlist1(); // //如果是组队，队员详情
	public java.util.List<xbean.LDTeamRoleInfoDes> getTeamlist1AsData(); // //如果是组队，队员详情
	public java.util.List<xbean.LDTeamRoleInfoDes> getTeamlist2(); // //如果是组队，队员详情
	public java.util.List<xbean.LDTeamRoleInfoDes> getTeamlist2AsData(); // //如果是组队，队员详情
	public int getBattleresult(); // 1胜利  -1失败  0平局
	public int getRosenum(); // 点赞次数
	public String getVideoid(); // 录像id
	public com.locojoy.base.Octets getVideoidOctets(); // 录像id
	public long getFighttime(); // 时间
	public int getBeforevideosize(); // 压缩前录像大小
	public long getAftervideosize(); // 压缩后录像大小
	public String getVideourl(); // 网址
	public com.locojoy.base.Octets getVideourlOctets(); // 网址
	public int getSaveresult(); // 0没有保存   1保存成功

	public void setBattleresult(int _v_); // 1胜利  -1失败  0平局
	public void setRosenum(int _v_); // 点赞次数
	public void setVideoid(String _v_); // 录像id
	public void setVideoidOctets(com.locojoy.base.Octets _v_); // 录像id
	public void setFighttime(long _v_); // 时间
	public void setBeforevideosize(int _v_); // 压缩前录像大小
	public void setAftervideosize(long _v_); // 压缩后录像大小
	public void setVideourl(String _v_); // 网址
	public void setVideourlOctets(com.locojoy.base.Octets _v_); // 网址
	public void setSaveresult(int _v_); // 0没有保存   1保存成功
}
