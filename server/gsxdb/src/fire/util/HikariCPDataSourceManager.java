//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import com.zaxxer.hikari.HikariPoolMXBean;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import org.apache.log4j.Logger;

public class HikariCPDataSourceManager {
    private static final Logger logger = Logger.getLogger(HikariCPDataSourceManager.class);
    private static volatile HikariCPDataSourceManager instance;
    private static final Object LOCK = new Object();
    private volatile HikariDataSource dataSource;
    private volatile HikariConfig config;
    private final AtomicBoolean initialized = new AtomicBoolean(false);
    private final AtomicBoolean shutdown = new AtomicBoolean(false);
    private final ReentrantReadWriteLock rwLock = new ReentrantReadWriteLock();
    private static final String DEFAULT_POOL_NAME = "GameServerHikariCP";
    private static final int DEFAULT_MAX_POOL_SIZE = 20;
    private static final int DEFAULT_MIN_IDLE = 5;
    private static final long DEFAULT_CONNECTION_TIMEOUT = 30000L;
    private static final long DEFAULT_IDLE_TIMEOUT = 600000L;
    private static final long DEFAULT_MAX_LIFETIME = 1800000L;
    private static final long DEFAULT_VALIDATION_TIMEOUT = 5000L;
    private static final long DEFAULT_LEAK_DETECTION_THRESHOLD = 60000L;

    private HikariCPDataSourceManager() {
    }

    public static HikariCPDataSourceManager getInstance() {
        if (instance == null) {
            synchronized(LOCK) {
                if (instance == null) {
                    instance = new HikariCPDataSourceManager();
                }
            }
        }

        return instance;
    }

    public boolean initialize(Properties properties) {
        if (this.initialized.get()) {
            logger.warn("HikariCP 数据源已初?");
            return true;
        } else {
            this.rwLock.writeLock().lock();

            boolean result;
            try {
                if (!this.initialized.get()) {
                    logger.info("正在初?HikariCP 数据?..");
                    this.config = this.createHikariConfig(properties);
                    this.dataSource = new HikariDataSource(this.config);
                    if (this.validateConnection()) {
                        this.initialized.set(true);
                        logger.info("HikariCP datasource initialized successfully");
                        this.logPoolConfiguration();
                        result = true;
                        return result;
                    }

                    this.closeDataSource();
                    logger.error("Unable to validate HikariCP connection");
                    result = false;
                    return result;
                }

                result = true;
            } catch (Exception e) {
                logger.error("无法初?HikariCP 数据?, e");
                this.closeDataSource();
                boolean initFailed = false;
                return initFailed;
            } finally {
                this.rwLock.writeLock().unlock();
            }

            return result;
        }
    }

    private HikariConfig createHikariConfig(Properties properties) {
        HikariConfig config = new HikariConfig();
        String jdbcUrl = this.buildJdbcUrl(properties);
        config.setJdbcUrl(jdbcUrl);
        config.setDriverClassName("com.mysql.cj.jdbc.Driver");
        config.setUsername(properties.getProperty("sys.mysql.user", "root"));
        config.setPassword(properties.getProperty("sys.mysql.pass", ""));
        config.setPoolName("GameServerHikariCP");
        config.setMaximumPoolSize(this.getIntProperty(properties, "hikari.maximum.pool.size", 20));
        config.setMinimumIdle(this.getIntProperty(properties, "hikari.minimum.idle", 5));
        config.setConnectionTimeout(this.getLongProperty(properties, "hikari.connection.timeout", 30000L));
        config.setIdleTimeout(this.getLongProperty(properties, "hikari.idle.timeout", 600000L));
        config.setMaxLifetime(this.getLongProperty(properties, "hikari.max.lifetime", 1800000L));
        config.setValidationTimeout(this.getLongProperty(properties, "hikari.validation.timeout", 5000L));
        config.setConnectionTestQuery("SELECT 1");
        config.setLeakDetectionThreshold(60000L);
        config.setRegisterMbeans(true);
        Properties dataSourceProperties = new Properties();
        dataSourceProperties.setProperty("useServerPrepStmts", "true");
        dataSourceProperties.setProperty("cachePrepStmts", "true");
        dataSourceProperties.setProperty("prepStmtCacheSize", "250");
        dataSourceProperties.setProperty("prepStmtCacheSqlLimit", "2048");
        dataSourceProperties.setProperty("rewriteBatchedStatements", "true");
        dataSourceProperties.setProperty("useLocalSessionState", "true");
        dataSourceProperties.setProperty("cacheResultSetMetadata", "true");
        dataSourceProperties.setProperty("cacheServerConfiguration", "true");
        dataSourceProperties.setProperty("elideSetAutoCommits", "true");
        dataSourceProperties.setProperty("maintainTimeStats", "false");
        config.setDataSourceProperties(dataSourceProperties);
        return config;
    }

    private String buildJdbcUrl(Properties properties) {
        String ip = properties.getProperty("sys.mysql.ip", "localhost");
        String port = properties.getProperty("sys.mysql.port", "3306");
        String dbname = properties.getProperty("sys.mysql.dbname", "test");
        return String.format("jdbc:mysql://%s:%s/%s?useUnicode=true&characterEncoding=utf8mb4&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai&autoReconnect=true&failOverReadOnly=false&maxReconnects=3&initialTimeout=2", ip, port, dbname);
    }

    public Connection getConnection() throws SQLException {
        if (this.initialized.get() && !this.shutdown.get()) {
            this.rwLock.readLock().lock();

            Connection connection;
            try {
                if (this.dataSource == null || this.dataSource.isClosed()) {
                    throw new SQLException("数据源不叔");
                }

                connection = this.dataSource.getConnection();
            } finally {
                this.rwLock.readLock().unlock();
            }

            return connection;
        } else {
            throw new SQLException("数据源未初化或已关?");
        }
    }

    private boolean validateConnection() {
        try (Connection conn = this.dataSource.getConnection()) {
            boolean isValid = conn != null && !conn.isClosed();
            return isValid;
        } catch (SQLException e) {
            logger.error("Connection validation failed", e);
            return false;
        }
    }

    public HikariPoolMXBean getPoolMXBean() {
        return this.dataSource != null && !this.dataSource.isClosed() ? this.dataSource.getHikariPoolMXBean() : null;
    }

    public String getPoolStatus() {
        HikariPoolMXBean poolBean = this.getPoolMXBean();
        return poolBean == null ? "Pool not available" : String.format("HikariCP Pool Status:\n- Pool Name: %s\n- Active Connections: %d/%d\n- Idle Connections: %d\n- Waiting Threads: %d\n- Total Connections: %d", this.config.getPoolName(), poolBean.getActiveConnections(), this.config.getMaximumPoolSize(), poolBean.getIdleConnections(), poolBean.getThreadsAwaitingConnection(), poolBean.getTotalConnections());
    }

    public void shutdown() {
        if (!this.shutdown.getAndSet(true)) {
            this.rwLock.writeLock().lock();

            try {
                logger.info("Shutting down HikariCP datasource...");
                this.closeDataSource();
                this.initialized.set(false);
                logger.info("HikariCP 数据源关问?");
            } finally {
                this.rwLock.writeLock().unlock();
            }

        }
    }

    private void closeDataSource() {
        if (this.dataSource != null && !this.dataSource.isClosed()) {
            try {
                this.dataSource.close();
            } catch (Exception e) {
                logger.error("Error while closing HikariCP datasource", e);
            }
        }

    }

    private void logPoolConfiguration() {
        logger.info("HikariCP Configuration:");
        logger.info("- Pool Name: " + this.config.getPoolName());
        logger.info("- JDBC URL: " + this.config.getJdbcUrl());
        logger.info("- Maximum Pool Size: " + this.config.getMaximumPoolSize());
        logger.info("- Minimum Idle: " + this.config.getMinimumIdle());
        logger.info("- Connection Timeout: " + this.config.getConnectionTimeout() + "ms");
        logger.info("- Idle Timeout: " + this.config.getIdleTimeout() + "ms");
        logger.info("- Max Lifetime: " + this.config.getMaxLifetime() + "ms");
    }

    private int getIntProperty(Properties props, String key, int defaultValue) {
        try {
            return Integer.parseInt(props.getProperty(key, String.valueOf(defaultValue)));
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private long getLongProperty(Properties props, String key, long defaultValue) {
        try {
            return Long.parseLong(props.getProperty(key, String.valueOf(defaultValue)));
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    public boolean isAvailable() {
        return this.initialized.get() && !this.shutdown.get() && this.dataSource != null && !this.dataSource.isClosed();
    }
}
