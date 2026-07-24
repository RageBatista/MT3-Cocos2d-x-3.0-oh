//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.util;

import java.util.Properties;
import org.apache.log4j.Logger;

public class HikariCPConfig {
    private static final Logger logger = Logger.getLogger(HikariCPConfig.class);
    private String jdbcUrl;
    private String username;
    private String password;
    private String driverClassName = "com.mysql.cj.jdbc.Driver";
    private String poolName = "GameServerHikariCP";
    private int maximumPoolSize = 20;
    private int minimumIdle = 5;
    private long connectionTimeout = 30000L;
    private long idleTimeout = 600000L;
    private long maxLifetime = 1800000L;
    private long validationTimeout = 5000L;
    private long leakDetectionThreshold = 60000L;
    private String connectionTestQuery = "SELECT 1";
    private boolean registerMbeans = true;
    private boolean useServerPrepStmts = true;
    private boolean cachePrepStmts = true;
    private int prepStmtCacheSize = 250;
    private int prepStmtCacheSqlLimit = 2048;
    private boolean rewriteBatchedStatements = true;
    private boolean useLocalSessionState = true;
    private boolean cacheResultSetMetadata = true;
    private boolean cacheServerConfiguration = true;
    private boolean elideSetAutoCommits = true;
    private boolean maintainTimeStats = false;

    public static HikariCPConfig fromProperties(Properties properties) {
        HikariCPConfig config = new HikariCPConfig();

        try {
            config.jdbcUrl = buildJdbcUrl(properties);
            config.username = properties.getProperty("sys.mysql.user", "root");
            config.password = properties.getProperty("sys.mysql.pass", "");
            config.poolName = properties.getProperty("hikari.pool.name", config.poolName);
            config.maximumPoolSize = getIntProperty(properties, "hikari.maximum.pool.size", config.maximumPoolSize);
            config.minimumIdle = getIntProperty(properties, "hikari.minimum.idle", config.minimumIdle);
            config.connectionTimeout = getLongProperty(properties, "hikari.connection.timeout", config.connectionTimeout);
            config.idleTimeout = getLongProperty(properties, "hikari.idle.timeout", config.idleTimeout);
            config.maxLifetime = getLongProperty(properties, "hikari.max.lifetime", config.maxLifetime);
            config.validationTimeout = getLongProperty(properties, "hikari.validation.timeout", config.validationTimeout);
            config.leakDetectionThreshold = getLongProperty(properties, "hikari.leak.detection.threshold", config.leakDetectionThreshold);
            config.connectionTestQuery = properties.getProperty("hikari.connection.test.query", config.connectionTestQuery);
            config.registerMbeans = getBooleanProperty(properties, "hikari.register.mbeans", config.registerMbeans);
            config.useServerPrepStmts = getBooleanProperty(properties, "hikari.mysql.use.server.prep.stmts", config.useServerPrepStmts);
            config.cachePrepStmts = getBooleanProperty(properties, "hikari.mysql.cache.prep.stmts", config.cachePrepStmts);
            config.prepStmtCacheSize = getIntProperty(properties, "hikari.mysql.prep.stmt.cache.size", config.prepStmtCacheSize);
            config.prepStmtCacheSqlLimit = getIntProperty(properties, "hikari.mysql.prep.stmt.cache.sql.limit", config.prepStmtCacheSqlLimit);
            logger.info("HikariCP配置加载完成");
            return config;
        } catch (Exception e) {
            logger.error("加载HikariCP配置失败", e);
            throw new RuntimeException("配置加载失败", e);
        }
    }

    private static String buildJdbcUrl(Properties properties) {
        String ip = properties.getProperty("sys.mysql.ip", "localhost");
        String port = properties.getProperty("sys.mysql.port", "3306");
        String dbname = properties.getProperty("sys.mysql.dbname", "test");
        StringBuilder urlBuilder = new StringBuilder();
        urlBuilder.append("jdbc:mysql://").append(ip).append(":").append(port).append("/").append(dbname);
        urlBuilder.append("?useUnicode=true");
        urlBuilder.append("&characterEncoding=utf8mb4");
        urlBuilder.append("&useSSL=false");
        urlBuilder.append("&allowPublicKeyRetrieval=true");
        urlBuilder.append("&serverTimezone=Asia/Shanghai");
        urlBuilder.append("&autoReconnect=true");
        urlBuilder.append("&failOverReadOnly=false");
        urlBuilder.append("&maxReconnects=3");
        urlBuilder.append("&initialTimeout=2");
        return urlBuilder.toString();
    }

    public boolean validate() {
        try {
            if (this.jdbcUrl != null && !this.jdbcUrl.trim().isEmpty()) {
                if (this.username != null && !this.username.trim().isEmpty()) {
                    if (this.maximumPoolSize <= 0) {
                        logger.error("最大连接池大小必须大于0");
                        return false;
                    } else if (this.minimumIdle < 0) {
                        logger.error("最小空闲连接数不能小于0");
                        return false;
                    } else if (this.minimumIdle > this.maximumPoolSize) {
                        logger.error("最小空闲连接数不能大于最大连接池大小");
                        return false;
                    } else if (this.connectionTimeout <= 0L) {
                        logger.error("连接超时时间必须大于0");
                        return false;
                    } else if (this.validationTimeout <= 0L) {
                        logger.error("验证超时时间必须大于0");
                        return false;
                    } else if (this.maxLifetime > 0L && this.maxLifetime < 30000L) {
                        logger.error("连接最大生命周期不能小于30秒);");
                        return false;
                    } else {
                        logger.info("HikariCP配置验证通过");
                        return true;
                    }
                } else {
                    logger.error("数据库用户名不能为空");
                    return false;
                }
            } else {
                logger.error("JDBC URL不能为空");
                return false;
            }
        } catch (Exception e) {
            logger.error("配置验证异常", e);
            return false;
        }
    }

    public String getConfigSummary() {
        StringBuilder summary = new StringBuilder();
        summary.append("HikariCP配置摘要:\n");
        summary.append("- 连接池名称 ").append(this.poolName).append("\n");
        summary.append("- JDBC URL: ").append(this.maskPassword(this.jdbcUrl)).append("\n");
        summary.append("- 用户名 ").append(this.username).append("\n");
        summary.append("- 最大连接数: ").append(this.maximumPoolSize).append("\n");
        summary.append("- 最小空闲连接 ").append(this.minimumIdle).append("\n");
        summary.append("- 连接超时: ").append(this.connectionTimeout).append("ms\n");
        summary.append("- 空闲超时: ").append(this.idleTimeout).append("ms\n");
        summary.append("- 最大生命周期 ").append(this.maxLifetime).append("ms\n");
        summary.append("- JMX监控: ").append(this.registerMbeans ? "启用" : "禁用").append("\n");
        return summary.toString();
    }

    private String maskPassword(String url) {
        return url == null ? null : url.replaceAll("password=[^&]*", "password=***");
    }

    private static int getIntProperty(Properties props, String key, int defaultValue) {
        try {
            String value = props.getProperty(key);
            return value != null ? Integer.parseInt(value.trim()) : defaultValue;
        } catch (NumberFormatException e) {
            logger.warn("无效的整数配置: " + key + ", 使用默认值: " + defaultValue);
            return defaultValue;
        }
    }

    private static long getLongProperty(Properties props, String key, long defaultValue) {
        try {
            String value = props.getProperty(key);
            return value != null ? Long.parseLong(value.trim()) : defaultValue;
        } catch (NumberFormatException e) {
            logger.warn("无效的长整数配置: " + key + ", 使用默认值: " + defaultValue);
            return defaultValue;
        }
    }

    private static boolean getBooleanProperty(Properties props, String key, boolean defaultValue) {
        try {
            String value = props.getProperty(key);
            return value != null ? Boolean.parseBoolean(value.trim()) : defaultValue;
        } catch (Exception e) {
            logger.warn("无效的布尔配置: " + key + ", 使用默认值: " + defaultValue);
            return defaultValue;
        }
    }

    public String getJdbcUrl() {
        return this.jdbcUrl;
    }

    public String getUsername() {
        return this.username;
    }

    public String getPassword() {
        return this.password;
    }

    public String getDriverClassName() {
        return this.driverClassName;
    }

    public String getPoolName() {
        return this.poolName;
    }

    public int getMaximumPoolSize() {
        return this.maximumPoolSize;
    }

    public int getMinimumIdle() {
        return this.minimumIdle;
    }

    public long getConnectionTimeout() {
        return this.connectionTimeout;
    }

    public long getIdleTimeout() {
        return this.idleTimeout;
    }

    public long getMaxLifetime() {
        return this.maxLifetime;
    }

    public long getValidationTimeout() {
        return this.validationTimeout;
    }

    public long getLeakDetectionThreshold() {
        return this.leakDetectionThreshold;
    }

    public String getConnectionTestQuery() {
        return this.connectionTestQuery;
    }

    public boolean isRegisterMbeans() {
        return this.registerMbeans;
    }

    public boolean isUseServerPrepStmts() {
        return this.useServerPrepStmts;
    }

    public boolean isCachePrepStmts() {
        return this.cachePrepStmts;
    }

    public int getPrepStmtCacheSize() {
        return this.prepStmtCacheSize;
    }

    public int getPrepStmtCacheSqlLimit() {
        return this.prepStmtCacheSqlLimit;
    }

    public boolean isRewriteBatchedStatements() {
        return this.rewriteBatchedStatements;
    }

    public boolean isUseLocalSessionState() {
        return this.useLocalSessionState;
    }

    public boolean isCacheResultSetMetadata() {
        return this.cacheResultSetMetadata;
    }

    public boolean isCacheServerConfiguration() {
        return this.cacheServerConfiguration;
    }

    public boolean isElideSetAutoCommits() {
        return this.elideSetAutoCommits;
    }

    public boolean isMaintainTimeStats() {
        return this.maintainTimeStats;
    }
}
