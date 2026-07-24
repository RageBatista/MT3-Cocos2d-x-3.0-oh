
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class ListListenerTestEffect extends mkdb.XBean implements xbean.ListListenerTestEffect {
	private int id; // 
	private int type; // 

	@Override
	public void _reset_unsafe_() {
		id = 0;
		type = 0;
	}

	ListListenerTestEffect(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
	}

	public ListListenerTestEffect() {
		this(0, null, null);
	}

	public ListListenerTestEffect(ListListenerTestEffect _o_) {
		this(_o_, null, null);
	}

	ListListenerTestEffect(xbean.ListListenerTestEffect _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof ListListenerTestEffect) assign((ListListenerTestEffect)_o1_);
		else if (_o1_ instanceof ListListenerTestEffect.Data) assign((ListListenerTestEffect.Data)_o1_);
		else if (_o1_ instanceof ListListenerTestEffect.Const) assign(((ListListenerTestEffect.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(ListListenerTestEffect _o_) {
		id = _o_.id;
		type = _o_.type;
	}

	private void assign(ListListenerTestEffect.Data _o_) {
		id = _o_.id;
		type = _o_.type;
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.marshal(id);
		_os_.marshal(type);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		id = _os_.unmarshal_int();
		type = _os_.unmarshal_int();
		return _os_;
	}

	@Override
	public xbean.ListListenerTestEffect copy() {
		return new ListListenerTestEffect(this);
	}

	@Override
	public xbean.ListListenerTestEffect toData() {
		return new Data(this);
	}

	public xbean.ListListenerTestEffect toBean() {
		return new ListListenerTestEffect(this); // same as copy()
	}

	@Override
	public xbean.ListListenerTestEffect toDataIf() {
		return new Data(this);
	}

	public xbean.ListListenerTestEffect toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public int getId() { // 
		return id;
	}

	@Override
	public int getType() { // 
		return type;
	}

	@Override
	public void setId(int _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "id") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, id) {
					public void rollback() { id = _xdb_saved; }
				};}});
		id = _v_;
	}

	@Override
	public void setType(int _v_) { // 
		mkdb.Logs.logIf(new mkdb.LogKey(this, "type") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, type) {
					public void rollback() { type = _xdb_saved; }
				};}});
		type = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		ListListenerTestEffect _o_ = null;
		if ( _o1_ instanceof ListListenerTestEffect ) _o_ = (ListListenerTestEffect)_o1_;
		else if ( _o1_ instanceof ListListenerTestEffect.Const ) _o_ = ((ListListenerTestEffect.Const)_o1_).nThis();
		else return false;
		if (id != _o_.id) return false;
		if (type != _o_.type) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += id;
		_h_ += type;
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(id);
		_sb_.append(",");
		_sb_.append(type);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("id"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("type"));
		return lb;
	}

	private class Const implements xbean.ListListenerTestEffect {
		ListListenerTestEffect nThis() {
			return ListListenerTestEffect.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.ListListenerTestEffect copy() {
			return ListListenerTestEffect.this.copy();
		}

		@Override
		public xbean.ListListenerTestEffect toData() {
			return ListListenerTestEffect.this.toData();
		}

		public xbean.ListListenerTestEffect toBean() {
			return ListListenerTestEffect.this.toBean();
		}

		@Override
		public xbean.ListListenerTestEffect toDataIf() {
			return ListListenerTestEffect.this.toDataIf();
		}

		public xbean.ListListenerTestEffect toBeanIf() {
			return ListListenerTestEffect.this.toBeanIf();
		}

		@Override
		public int getId() { // 
			return id;
		}

		@Override
		public int getType() { // 
			return type;
		}

		@Override
		public void setId(int _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public void setType(int _v_) { // 
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean toConst() {
			return this;
		}

		@Override
		public boolean isConst() {
			return true;
		}

		@Override
		public boolean isData() {
			return ListListenerTestEffect.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return ListListenerTestEffect.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return ListListenerTestEffect.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return ListListenerTestEffect.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return ListListenerTestEffect.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return ListListenerTestEffect.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return ListListenerTestEffect.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return ListListenerTestEffect.this.hashCode();
		}

		@Override
		public String toString() {
			return ListListenerTestEffect.this.toString();
		}

	}

	public static final class Data implements xbean.ListListenerTestEffect {
		private int id; // 
		private int type; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
		}

		Data(xbean.ListListenerTestEffect _o1_) {
			if (_o1_ instanceof ListListenerTestEffect) assign((ListListenerTestEffect)_o1_);
			else if (_o1_ instanceof ListListenerTestEffect.Data) assign((ListListenerTestEffect.Data)_o1_);
			else if (_o1_ instanceof ListListenerTestEffect.Const) assign(((ListListenerTestEffect.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(ListListenerTestEffect _o_) {
			id = _o_.id;
			type = _o_.type;
		}

		private void assign(ListListenerTestEffect.Data _o_) {
			id = _o_.id;
			type = _o_.type;
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(id);
			_os_.marshal(type);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			id = _os_.unmarshal_int();
			type = _os_.unmarshal_int();
			return _os_;
		}

		@Override
		public xbean.ListListenerTestEffect copy() {
			return new Data(this);
		}

		@Override
		public xbean.ListListenerTestEffect toData() {
			return new Data(this);
		}

		public xbean.ListListenerTestEffect toBean() {
			return new ListListenerTestEffect(this, null, null);
		}

		@Override
		public xbean.ListListenerTestEffect toDataIf() {
			return this;
		}

		public xbean.ListListenerTestEffect toBeanIf() {
			return new ListListenerTestEffect(this, null, null);
		}

		// mkdb.Bean interface. Data Unsupported
		public boolean xdbManaged() { throw new UnsupportedOperationException(); }
		public mkdb.Bean xdbParent() { throw new UnsupportedOperationException(); }
		public String xdbVarname()  { throw new UnsupportedOperationException(); }
		public Long    xdbObjId()   { throw new UnsupportedOperationException(); }
		public mkdb.Bean toConst()   { throw new UnsupportedOperationException(); }
		public boolean isConst()    { return false; }
		public boolean isData()     { return true; }

		@Override
		public int getId() { // 
			return id;
		}

		@Override
		public int getType() { // 
			return type;
		}

		@Override
		public void setId(int _v_) { // 
			id = _v_;
		}

		@Override
		public void setType(int _v_) { // 
			type = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof ListListenerTestEffect.Data)) return false;
			ListListenerTestEffect.Data _o_ = (ListListenerTestEffect.Data) _o1_;
			if (id != _o_.id) return false;
			if (type != _o_.type) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += id;
			_h_ += type;
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(id);
			_sb_.append(",");
			_sb_.append(type);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}
