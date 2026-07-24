
package xbean;

public interface Any2 extends mkdb.Bean {
	public Any2 copy(); // deep clone
	public Any2 toData(); // a Data instance
	public Any2 toBean(); // a Bean instance
	public Any2 toDataIf(); // a Data instance If need. else return this
	public Any2 toBeanIf(); // a Bean instance If need. else return this

	public xbean.Any getAny(); // comment
	public java.util.Set<xbean.Any> getAnyset(); // comment

}
