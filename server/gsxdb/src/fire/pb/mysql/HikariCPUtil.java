//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mysql;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import com.zaxxer.hikari.HikariPoolMXBean;
import fire.pb.main.ConfigManager;
import fire.pb.util.FireProp;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;
import org.apache.log4j.Logger;

public class HikariCPUtil {
    private static final Logger logger = Logger.getLogger("HIKARI");
    static Properties prop = ConfigManager.getInstance().getPropConf("sys");
    public static final String MYSQLIP;
    public static final String MYSQLPORT;
    public static final String MYSQLUSER;
    public static final String MYSQLPASS;
    public static final String MYSQLDBNAME;
    static HikariDataSource hikariDataSource;

    public static HikariDataSource getHikariDataSource() {
        return hikariDataSource;
    }

    public static Connection getConnection() {
        try {
            Class.forName("com.zaxxer.hikari.HikariConfig");
            if (hikariDataSource == null || hikariDataSource.isClosed()) {
                logger.warn("HikariCP DataSource 尚未准备好，正在尝试初始化...");
                synchronized(HikariCPUtil.class) {
                    if (hikariDataSource == null || hikariDataSource.isClosed()) {
                        initializeHikariCP();
                    }
                }
            }

            return hikariDataSource.getConnection();
        } catch (ClassNotFoundException e) {
            logger.warn("HikariCP 课程不可用，无法连接：" + e.getMessage());
            return null;
        } catch (NoClassDefFoundError e) {
            logger.warn("HikariCP 依赖项缺失，无法连接 " + e.getMessage());
            return null;
        } catch (SQLException e) {
            logger.error("无法获取 HikariCP 连接", e);
            return null;
        } catch (Exception e) {
            logger.error("获取 HikariCP 连接时出现意外错误", e);
            return null;
        }
    }

    public static void close(Connection conn, PreparedStatement pst, ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                logger.error("无法关闭结果集", e);
            }
        }

        if (pst != null) {
            try {
                pst.close();
            } catch (SQLException e) {
                logger.error("无法关闭 PreparedStatement", e);
            }
        }

        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                logger.error("无法关闭 Connection", e);
            }
        }

    }

    public static void close(Connection conn, Statement stmt, ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                logger.error("无法关闭 ResultSet", e);
            }
        }

        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException e) {
                logger.error("无法关闭 Statement", e);
            }
        }

        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                logger.error("无法关闭 Connection", e);
            }
        }

    }

    public static void initializeHikariCP() {
        try {
            HikariConfig config = new HikariConfig();
            config.setDriverClassName("com.mysql.cj.jdbc.Driver");
            String jdbcUrl;
            if (MYSQLDBNAME != null && !MYSQLDBNAME.isEmpty()) {
                jdbcUrl = "jdbc:mysql://" + MYSQLIP + ":" + MYSQLPORT + "/" + MYSQLDBNAME + "?useUnicode=true&characterEncoding=utf8&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai&useServerPrepStmts=true&cachePrepStmts=true&prepStmtCacheSize=250&prepStmtCacheSqlLimit=2048&rewriteBatchedStatements=true&useLocalSessionState=true&cacheResultSetMetadata=true";
            } else {
                jdbcUrl = "jdbc:mysql://" + MYSQLIP + ":" + MYSQLPORT + "/mt3_weibo_?useUnicode=true&characterEncoding=utf8&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai&useServerPrepStmts=true&cachePrepStmts=true&prepStmtCacheSize=250&prepStmtCacheSqlLimit=2048&rewriteBatchedStatements=true&useLocalSessionState=true&cacheResultSetMetadata=true";
            }

            config.setJdbcUrl(jdbcUrl);
            config.setUsername(MYSQLUSER);
            config.setPassword(MYSQLPASS);
            config.setMaximumPoolSize(20);
            config.setMinimumIdle(10);
            config.setConnectionTimeout(3000L);
            config.setIdleTimeout(600000L);
            config.setMaxLifetime(1800000L);
            config.setLeakDetectionThreshold(60000L);
            config.setConnectionTestQuery("SELECT 1");
            config.setValidationTimeout(5000L);
            config.setPoolName("GameServerHikariCP");
            config.addDataSourceProperty("cachePrepStmts", "true");
            config.addDataSourceProperty("prepStmtCacheSize", "250");
            config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
            config.addDataSourceProperty("useServerPrepStmts", "true");
            config.addDataSourceProperty("useLocalSessionState", "true");
            config.addDataSourceProperty("rewriteBatchedStatements", "true");
            config.addDataSourceProperty("cacheResultSetMetadata", "true");
            config.addDataSourceProperty("cacheServerConfiguration", "true");
            config.addDataSourceProperty("elideSetAutoCommits", "true");
            config.addDataSourceProperty("maintainTimeStats", "false");
            hikariDataSource = new HikariDataSource(config);
            logger.info("HikariCP connection pool initialized successfully");
            logger.info("JDBC URL: " + jdbcUrl);
            logger.info("Max pool size: " + config.getMaximumPoolSize());
            logger.info("Min idle connections: " + config.getMinimumIdle());
        } catch (Exception e) {
            logger.error("HikariCP connection pool initialization failed", e);
            throw new RuntimeException("HikariCP initialization failed", e);
        }
    }

    public static void updateConfiguration(String jdbcUrl, String user, String password) {
        try {
            if (hikariDataSource != null && !hikariDataSource.isClosed()) {
                hikariDataSource.close();
            }

            HikariConfig config = new HikariConfig();
            config.setDriverClassName("com.mysql.cj.jdbc.Driver");
            config.setJdbcUrl(jdbcUrl);
            config.setUsername(user);
            config.setPassword(password);
            config.setMaximumPoolSize(20);
            config.setMinimumIdle(10);
            config.setConnectionTimeout(3000L);
            config.setIdleTimeout(600000L);
            config.setMaxLifetime(1800000L);
            config.setConnectionTestQuery("SELECT 1");
            config.setPoolName("GameServerHikariCP");
            hikariDataSource = new HikariDataSource(config);
            logger.info("HikariCP 连接池配置已更新");
            logger.info("New JDBC URL: " + jdbcUrl);
        } catch (Exception e) {
            logger.error("无法更新 HikariCP 配置", e);
            throw new RuntimeException("HikariCP 配置更新失败", e);
        }
    }

    public static String getPoolStatus() {
        if (hikariDataSource == null) {
            return "HikariCP not initialized";
        } else {
            try {
                return String.format("HikariCP Status - Active: %d, Idle: %d, Total: %d, Waiting: %d", hikariDataSource.getHikariPoolMXBean().getActiveConnections(), hikariDataSource.getHikariPoolMXBean().getIdleConnections(), hikariDataSource.getHikariPoolMXBean().getTotalConnections(), hikariDataSource.getHikariPoolMXBean().getThreadsAwaitingConnection());
            } catch (Exception e) {
                return "无法获取 HikariCP 状态: " + e.getMessage();
            }
        }
    }

    public static String getDetailedPoolStatus() {
        if (hikariDataSource == null) {
            return "HikariCP not initialized";
        } else {
            try {
                HikariPoolMXBean poolBean = hikariDataSource.getHikariPoolMXBean();
                return String.format("HikariCP详细状态:\n- 活跃连接: %d/%d\n- 空闲连接: %d\n- 等待线程: %d\n- 总连接数: %d\n- 连接超时: %d ms\n- 空闲超时: %d ms\n- 最大生命周期: %d ms", poolBean.getActiveConnections(), hikariDataSource.getMaximumPoolSize(), poolBean.getIdleConnections(), poolBean.getThreadsAwaitingConnection(), poolBean.getTotalConnections(), hikariDataSource.getConnectionTimeout(), hikariDataSource.getIdleTimeout(), hikariDataSource.getMaxLifetime());
            } catch (Exception e) {
                return "Failed to get detailed pool status: " + e.getMessage();
            }
        }
    }

    public static boolean performHealthCheck() {
        try (Connection conn = getConnection()) {
            if (conn != null && !conn.isClosed()) {
                PreparedStatement stmt = conn.prepareStatement("SELECT VERSION(), @@character_set_server, @@collation_server");
                Throwable var3 = null;

                boolean var8;
                try {
                    ResultSet rs = stmt.executeQuery();
                    if (!rs.next()) {
                        return false;
                    }

                    String version = rs.getString(1);
                    String charset = rs.getString(2);
                    String collation = rs.getString(3);
                    logger.info("Health Check - MySQL Version: " + version);
                    logger.info("Health Check - Character Set: " + charset);
                    logger.info("Health Check - Collation: " + collation);
                    var8 = true;
                } catch (Throwable var36) {
                    var3 = var36;
                    throw var36;
                } finally {
                    if (stmt != null) {
                        if (var3 != null) {
                            try {
                                stmt.close();
                            } catch (Throwable var35) {
                                var3.addSuppressed(var35);
                            }
                        } else {
                            stmt.close();
                        }
                    }

                }

                return var8;
            }
        } catch (SQLException e) {
            logger.error("Connection pool health check failed", e);
        }

        return false;
    }

    public static void shutdown() {
        if (hikariDataSource != null && !hikariDataSource.isClosed()) {
            hikariDataSource.close();
            logger.info("HikariCP connection pool closed");
        }

    }

    public static boolean testConnection() {
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT 1")) {

            if (rs.next()) {
                logger.info("HikariCP connection test successful");
                return true;
            }
        } catch (SQLException e) {
            logger.error("HikariCP connection test failed", e);
        } catch (Exception e) {
            logger.error("An unexpected error occurred during connection test", e);
        }
        return false;
    }

    static {
        MYSQLIP = FireProp.getStringValue(prop, "sys.mysql.ip");
        MYSQLPORT = FireProp.getStringValue(prop, "sys.mysql.port");
        MYSQLUSER = FireProp.getStringValue(prop, "sys.mysql.user");
        MYSQLPASS = FireProp.getStringValue(prop, "sys.mysql.pass");
        MYSQLDBNAME = FireProp.getStringValue(prop, "sys.mysql.dbname");
        logger.info("HikariCPUtil static initialization started");
        logger.info("MySQL config loaded - IP: " + MYSQLIP + ", Port: " + MYSQLPORT + ", User: " + MYSQLUSER);

        try {
            Class.forName("com.zaxxer.hikari.HikariConfig");
            Class.forName("com.zaxxer.hikari.HikariDataSource");
            logger.info("HikariCP classes found, initializing connection pool immediately...");
            initializeHikariCP();
            logger.info("HikariCP connection pool pre-initialized successfully in static block");
        } catch (ClassNotFoundException e) {
            logger.warn("HikariCP classes not found in classpath: " + e.getMessage());
            hikariDataSource = null;
        } catch (Exception e) {
            logger.error("Error initializing HikariCP in static block: " + e.getMessage(), e);
            logger.warn("HikariCP pre-initialization failed, will initialize on first use");
            hikariDataSource = null;
        }

    }
}
