package com.structs.config;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * Configuration loader for Superset properties
 */
public class SupersetConfig {
    private static SupersetConfig instance;
    private Properties properties;

    private SupersetConfig() {
        properties = new Properties();
        try (InputStream input = getClass().getClassLoader().getResourceAsStream("superset.properties")) {
            if (input == null) {
                throw new RuntimeException("Unable to find superset.properties");
            }
            properties.load(input);
        } catch (IOException ex) {
            throw new RuntimeException("Error loading superset.properties", ex);
        }
    }

    public static synchronized SupersetConfig getInstance() {
        if (instance == null) {
            instance = new SupersetConfig();
        }
        return instance;
    }

    public String getBaseUrl() {
        return properties.getProperty("superset.base.url");
    }

    public String getDashboardId() {
        return properties.getProperty("superset.dashboard.id");
    }

    public String getIssuer() {
        return properties.getProperty("jwt.issuer");
    }

    public String getAudience() {
        return properties.getProperty("jwt.audience");
    }

    public String getPrivateKeyPath() {
        return properties.getProperty("jwt.private.key.path");
    }

    public long getTokenTtl() {
        return Long.parseLong(properties.getProperty("jwt.token.ttl", "3600000"));
    }

    public String getGuestUsername() {
        return properties.getProperty("guest.username", "guest_user");
    }

    public String getGuestFirstName() {
        return properties.getProperty("guest.first.name", "Guest");
    }

    public String getGuestLastName() {
        return properties.getProperty("guest.last.name", "User");
    }
}

