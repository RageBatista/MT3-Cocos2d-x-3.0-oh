//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.util;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;
import org.apache.log4j.Logger;

public class DatabaseInitializer {
    private static final Logger logger = Logger.getLogger(DatabaseInitializer.class);
    private static final String DEFAULT_CONFIG_FILE = "properties/sys.properties";
    private static volatile boolean initialized = false;

    public static boolean initialize() {
        return initialize("properties/sys.properties");
    }

    public static boolean initialize(String configFile) {
        if (initialized) {
            logger.warn("Database already initialized");
            return true;
        } else {
            try {
                logger.info("Starting database initialization...");
                Properties properties = loadProperties(configFile);
                if (properties == null) {
                    logger.error("Failed to load database configuration");
                    return false;
                } else {
                    HikariCPDataSourceManager manager = HikariCPDataSourceManager.getInstance();
                    boolean success = manager.initialize(properties);
                    if (success) {
                        initialized = true;
                        logger.info("Database initialization completed successfully");
                        performInitialHealthCheck();
                        registerShutdownHook();
                        return true;
                    } else {
                        logger.error("Failed to initialize HikariCP DataSource");
                        return false;
                    }
                }
            } catch (Exception e) {
                logger.error("Database initialization failed", e);
                return false;
            }
        }
    }

    private static Properties loadProperties(String configFile) {
        Properties properties = new Properties();

        try (FileInputStream fis = new FileInputStream(configFile)) {
            properties.load(fis);
            logger.info("Loaded database configuration from: " + configFile);
            if (validateConfiguration(properties)) {
                Properties validatedProperties = properties;
                return validatedProperties;
            } else {
                logger.error("Invalid database configuration");
                Object nullProperties = null;
                return (Properties)nullProperties;
            }
        } catch (IOException e) {
            logger.error("Failed to load configuration file: " + configFile, e);
            return null;
        }
    }

    private static boolean validateConfiguration(Properties properties) {
        String[] requiredKeys = new String[]{"sys.mysql.ip", "sys.mysql.port", "sys.mysql.user", "sys.mysql.pass", "sys.mysql.dbname"};

        for(String key : requiredKeys) {
            if (!properties.containsKey(key) || properties.getProperty(key).trim().isEmpty()) {
                logger.error("Missing required configuration: " + key);
                return false;
            }
        }

        return true;
    }

    private static void performInitialHealthCheck() {
        try {
            logger.info("Performing initial database health check...");
            HikariCPUtil.HealthCheckResult result = HikariCPUtil.performHealthCheck();
            if (result.isHealthy()) {
                logger.info("Initial health check passed - Response time: " + result.getResponseTime() + "ms");
                logger.info("Pool status: " + result.getPoolStatus());
            } else {
                logger.warn("Initial health check failed: " + result.getMessage());
            }
        } catch (Exception e) {
            logger.error("Initial health check error", e);
        }

    }

    private static void registerShutdownHook() {
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            logger.info("Shutting down database connection pool...");
            shutdown();
        }, "DatabaseShutdownHook"));
    }

    public static void shutdown() {
        if (initialized) {
            try {
                HikariCPDataSourceManager.getInstance().shutdown();
                initialized = false;
                logger.info("Database shutdown completed");
            } catch (Exception e) {
                logger.error("Error during database shutdown", e);
            }
        }

    }

    public static boolean isInitialized() {
        return initialized;
    }

    public static boolean reinitialize() {
        logger.info("Reinitializing database connection pool...");
        if (initialized) {
            shutdown();
        }

        return initialize();
    }

    public static boolean reinitialize(String configFile) {
        logger.info("Reinitializing database connection pool with config: " + configFile);
        if (initialized) {
            shutdown();
        }

        return initialize(configFile);
    }
}
