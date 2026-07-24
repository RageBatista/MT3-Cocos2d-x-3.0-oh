
package xbean;

public interface Set2 extends mkdb.Bean {
	public Set2 copy(); // deep clone
	public Set2 toData(); // a Data instance
	public Set2 toBean(); // a Bean instance
	public Set2 toDataIf(); // a Data instance If need. else return this
	public Set2 toBeanIf(); // a Bean instance If need. else return this

	public java.util.Set<xbean.First> getSf(); // comment
	public java.util.Set<xbean.First> getSfAsData(); // comment

}
