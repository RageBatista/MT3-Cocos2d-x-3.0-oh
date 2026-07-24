
package xbean;

public interface RBTest extends mkdb.Bean {
	public RBTest copy(); // deep clone
	public RBTest toData(); // a Data instance
	public RBTest toBean(); // a Bean instance
	public RBTest toDataIf(); // a Data instance If need. else return this
	public RBTest toBeanIf(); // a Bean instance If need. else return this

	public int getI(); // int test
	public xbean.RB getRb(); // int test
	public java.util.Set<xbean.RB> getSet(); // a
	public java.util.Set<xbean.RB> getSetAsData(); // a
	public java.util.List<xbean.RB> getList(); // b
	public java.util.List<xbean.RB> getListAsData(); // b
	public java.util.Map<Integer, xbean.RB> getMap(); // d
	public java.util.Map<Integer, xbean.RB> getMapAsData(); // d
	public java.util.NavigableMap<Integer, xbean.RB> getTree(); // d
	public java.util.NavigableMap<Integer, xbean.RB> getTreeAsData(); // d

	public void setI(int _v_); // int test
}
