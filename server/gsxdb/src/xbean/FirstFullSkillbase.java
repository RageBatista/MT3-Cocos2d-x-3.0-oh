
package xbean;

public interface FirstFullSkillbase extends mkdb.Bean {
	public FirstFullSkillbase copy(); // 深拷贝
	public FirstFullSkillbase toData(); // 一个 Data 实例
	public FirstFullSkillbase toBean(); // 一个 Bean 实例
	public FirstFullSkillbase toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public FirstFullSkillbase toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, Long> getRoleids(); // 键=角色，值=时间
	public java.util.Map<Long, Long> getRoleidsAsData(); // 键=角色，值=时间

}
