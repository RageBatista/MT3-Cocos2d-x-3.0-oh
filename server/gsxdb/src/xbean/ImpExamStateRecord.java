
package xbean;

public interface ImpExamStateRecord extends mkdb.Bean {
	public ImpExamStateRecord copy(); // 深拷贝
	public ImpExamStateRecord toData(); // 一个 Data 实例
	public ImpExamStateRecord toBean(); // 一个 Bean 实例
	public ImpExamStateRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ImpExamStateRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<Long> getIdslist(); // 能参加智慧试炼state测试的id列表
	public java.util.List<Long> getIdslistAsData(); // 能参加智慧试炼state测试的id列表
	public java.util.List<Long> getPassidslist(); // 通过的角色id列表
	public java.util.List<Long> getPassidslistAsData(); // 通过的角色id列表
	public java.util.List<xbean.ImpExamStatePassRole> getPassrolelist(); // 通过的角色列表
	public java.util.List<xbean.ImpExamStatePassRole> getPassrolelistAsData(); // 通过的角色列表

}
