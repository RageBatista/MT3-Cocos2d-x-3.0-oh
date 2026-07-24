package gnet;
import java.lang.management.ManagementFactory;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

import fire.pb.main.ConfigManager;
import fire.pb.main.Gs;
import fire.pb.mysql.HikariCPUtil;
import fire.pb.mysql.HikariCPUtil;
import fire.pb.util.FireProp;
import fire.util.ExceptionHandler;







import com.locojoy.base.Runnable;
// {{{ RPCGEN_IMPORT_BEGIN
// {{{ DO NOT EDIT THIS
import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

abstract class __ServerIDResponse__ extends mkio.Protocol { }

/** gs连上deliver上，发给gs；用户登录完成后，发给客户端
*/
// DO NOT EDIT THIS }}}
// RPCGEN_IMPORT_END }}}

public class ServerIDResponse extends __ServerIDResponse__ {

	private static String buildMysqlJdbcUrl(String dbName) {
		return "jdbc:mysql://" + HikariCPUtil.MYSQLIP + ":" + HikariCPUtil.MYSQLPORT + "/" + dbName
				+ "?useUnicode=true&characterEncoding=utf8&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai"
				+ "&useServerPrepStmts=true&cachePrepStmts=true&prepStmtCacheSize=250&prepStmtCacheSqlLimit=2048"
				+ "&rewriteBatchedStatements=true&useLocalSessionState=true&cacheResultSetMetadata=true";
	}
	
	private void testMysqlConnect() {
		Connection conn = HikariCPUtil.getConnection();
        Statement stmt = null;
        ResultSet rs = null;
        try {
        	if (conn == null) {
        		fire.log.Module.logger.error("HikariCP 获取连接失败，无法测试 mysql 连通性。");
        		return;
        	}
            stmt = conn.createStatement();
            if (stmt.execute("SELECT count(*) FROM role_relation")){
            	rs = stmt.getResultSet();
            }
            if (rs != null){
            	while(rs.next()) {
            		fire.log.Module.logger.info("mysql connect role_relation table,count(*):" + rs.getString("count(*)"));
            	}
            }
        } catch (SQLException ex1) {
        	fire.log.Module.logger.error("SQL执行有问题！数据库连接测试失败");
        	ExceptionHandler.handleSqlException(ex1, "SELECT count(*) FROM role_relation", "testMysqlConnect");
        } finally {
        	if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException sqlEx) {
                	ExceptionHandler.handleSilently(sqlEx, "testMysqlConnect - 关闭ResultSet");
                }
                rs = null;
            }
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException sqlEx) {
                	ExceptionHandler.handleSilently(sqlEx, "testMysqlConnect - 关闭Statement");
                }
                stmt = null;
            }
        }
        HikariCPUtil.close(conn,null,null);
 }
	
	@Override
	protected void process() {
		fire.pb.main.Gs.platType = plattype;
		try {
			String serverId = serverid.getString("ISO-8859-1");
			//
			if (fire.pb.PropConf.ServerId.ServerId != 0) {
				Integer id = Integer.parseInt(serverId);
				// 校生fire.pb.PropConf.ServerId.ServerId
				if (fire.pb.PropConf.ServerId.ServerId != id) {
					fire.log.Module.logger.error("fire.pb.PropConf.ServerId.ServerId:" + fire.pb.PropConf.ServerId.ServerId
							+ " != ServerIDResponse.serverId:" + id);
					ManagementFactory.getPlatformMBeanServer().setAttribute(
							new javax.management.ObjectName("bean:name=stopper"),
							new javax.management.Attribute("StopTime", 0));
				}
				// 校验fire.pb.main.Gs.serverid
				if (fire.pb.main.Gs.serverid.equals(serverId) == false) {
					fire.log.Module.logger.error("fire.pb.main.Gs.serverid:" + fire.pb.main.Gs.serverid
							+ " != ServerIDResponse.serverId:" + serverId);
					ManagementFactory.getPlatformMBeanServer().setAttribute(
							new javax.management.ObjectName("bean:name=stopper"),
							new javax.management.Attribute("StopTime", 0));
				}
			} else {
				fire.pb.main.Gs.serverid = serverId;
			}
			fire.log.Module.logger.info("plattype:"+plattype+",serverid:"+fire.pb.main.Gs.serverid);
			if(ConfigManager.getUseMysql()){
				String dbName = HikariCPUtil.MYSQLDBNAME;
				if (dbName == null || dbName.isEmpty()) {
					dbName = "mt3_weibo_" + fire.pb.main.Gs.serverid;
				}
				String jdbcUrl = buildMysqlJdbcUrl(dbName);
				fire.log.Module.logger.info("Real Connect JdbcUrl:" + jdbcUrl);
				HikariCPUtil.updateConfiguration(jdbcUrl, HikariCPUtil.MYSQLUSER, HikariCPUtil.MYSQLPASS);
				
				Gs.getExecService().execute(new Runnable() {
					@Override
					public void run() {
						testMysqlConnect();
					}
				});	
				 // 创建说不得大师空间数据
				fire.pb.friends.Module Module = new fire.pb.friends.Module();
		      Module.createXsh(Long.MAX_VALUE);
			}
		  
					
			Properties prop = ConfigManager.getInstance().getPropConf("sys");
			fire.pb.main.Gs.isYingyongbao = Integer.valueOf(FireProp.getStringValue(prop, "sys.plat.isYingyongbao")).intValue() == 1 ? true : false;
			fire.log.Module.logger.info("Gs.isYingyongbao=" + fire.pb.main.Gs.isYingyongbao);
		} catch (Exception e) {
			ExceptionHandler.handleException(e, "ServerIDResponse.process", ExceptionHandler.LogLevel.FATAL);
			fire.log.Module.logger.error("Mysql连接有问题！请确定配置并检查网络！将关闭服务器.");
        	try{
        		ManagementFactory.getPlatformMBeanServer().setAttribute(new javax.management.ObjectName("bean:name=stopper"),
					new javax.management.Attribute("StopTime", 1));
        	} catch(Exception ex){
        		ExceptionHandler.handleException(ex, "ServerIDResponse.process - 关闭服务器");
			}
		}
	}

	// {{{ RPCGEN_DEFINE_BEGIN
	// {{{ DO NOT EDIT THIS
	public static final int PROTOCOL_TYPE = 8902;

	public int getType() {
		return 8902;
	}

	public int plattype; // 当前服务器组，登录的是那个平台
	public com.locojoy.base.Octets serverid; // 当前服务器组的标识

	public ServerIDResponse() {
		serverid = new com.locojoy.base.Octets();
	}

	public ServerIDResponse(int _plattype_, com.locojoy.base.Octets _serverid_) {
		this.plattype = _plattype_;
		this.serverid = _serverid_;
	}

	public final boolean _validator_() {
		return true;
	}

	public OctetsStream marshal(OctetsStream _os_) {
		if (!_validator_()) {
			throw new VerifyError("validator failed");
		}
		_os_.marshal(plattype);
		_os_.marshal(serverid);
		return _os_;
	}

	public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		plattype = _os_.unmarshal_int();
		serverid = _os_.unmarshal_Octets();
		if (!_validator_()) {
			throw new VerifyError("validator failed");
		}
		return _os_;
	}

	public boolean equals(Object _o1_) {
		if (_o1_ == this) return true;
		if (_o1_ instanceof ServerIDResponse) {
			ServerIDResponse _o_ = (ServerIDResponse)_o1_;
			if (plattype != _o_.plattype) return false;
			if (!serverid.equals(_o_.serverid)) return false;
			return true;
		}
		return false;
	}

	public int hashCode() {
		int _h_ = 0;
		_h_ += plattype;
		_h_ += serverid.hashCode();
		return _h_;
	}

	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(plattype).append(",");
		_sb_.append("B").append(serverid.size()).append(",");
		_sb_.append(")");
		return _sb_.toString();
	}

	// DO NOT EDIT THIS }}}
	// RPCGEN_DEFINE_END }}}

}
