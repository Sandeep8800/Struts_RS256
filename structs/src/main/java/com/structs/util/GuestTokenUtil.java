package com.structs.util;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.structs.config.SupersetConfig;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.security.KeyFactory;
import java.security.interfaces.RSAPrivateKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Utility class for generating Superset Guest Tokens using RS256 algorithm
 */
public class GuestTokenUtil {
    private static final String TOKEN_TYPE = "guest";
    private static RSAPrivateKey cachedPrivateKey;

    /**
     * Read resource file as string
     */
    private static String readResource(String resourcePath) throws Exception {
        try (InputStream is = GuestTokenUtil.class.getResourceAsStream(resourcePath);
             BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            return br.lines().collect(Collectors.joining("\n"));
        }
    }

    /**
     * Load RSA private key from PEM file (PKCS#8 format)
     */
    private static synchronized RSAPrivateKey loadPrivateKeyFromPem(String resourcePath) throws Exception {
        if (cachedPrivateKey != null) {
            return cachedPrivateKey;
        }

        String pem = readResource(resourcePath);
        pem = pem.replaceAll("-----BEGIN (.*)-----", "")
                 .replaceAll("-----END (.*)-----", "")
                 .replaceAll("\\s", "");

        byte[] decoded = Base64.getDecoder().decode(pem);
        PKCS8EncodedKeySpec spec = new PKCS8EncodedKeySpec(decoded);
        KeyFactory kf = KeyFactory.getInstance("RSA");
        cachedPrivateKey = (RSAPrivateKey) kf.generatePrivate(spec);

        return cachedPrivateKey;
    }

    /**
     * Create a guest token with all required claims for Superset
     */
    public static String createGuestToken(String username,
                                          String firstName,
                                          String lastName,
                                          List<Map<String, Object>> resourcesClaim,
                                          List<Map<String, Object>> rlsRulesClaim) throws Exception {
        SupersetConfig config = SupersetConfig.getInstance();

        RSAPrivateKey privateKey = loadPrivateKeyFromPem(config.getPrivateKeyPath());
        Algorithm algorithm = Algorithm.RSA256(null, privateKey);

        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + config.getTokenTtl());
        String jti = UUID.randomUUID().toString();

        // Build user claim
        Map<String, Object> userClaim = new HashMap<>();
        userClaim.put("username", username);
        userClaim.put("first_name", firstName);
        userClaim.put("last_name", lastName);

        // Create JWT token with all claims
        String token = JWT.create()
                .withIssuer(config.getIssuer())
                .withSubject(username)
                .withAudience(config.getAudience())
                .withJWTId(jti)
                .withIssuedAt(now)
                .withExpiresAt(expiryDate)
                .withClaim("type", TOKEN_TYPE)
                .withClaim("user", userClaim)
                .withClaim("resources", resourcesClaim)
                .withClaim("rls_rules", rlsRulesClaim)
                .sign(algorithm);

        return token;
    }

    /**
     * Create a simple guest token with dashboard resource
     */
    public static String createGuestTokenForDashboard(String dashboardId) throws Exception {
        SupersetConfig config = SupersetConfig.getInstance();

        // Create resources claim for dashboard access
        List<Map<String, Object>> resourcesClaim = new ArrayList<>();
        Map<String, Object> dashboardResource = new HashMap<>();
        dashboardResource.put("type", "dashboard");
        dashboardResource.put("id", dashboardId);
        resourcesClaim.add(dashboardResource);

        // Empty RLS rules (can be customized based on requirements)
        List<Map<String, Object>> rlsRulesClaim = new ArrayList<>();

        return createGuestToken(
                config.getGuestUsername(),
                config.getGuestFirstName(),
                config.getGuestLastName(),
                resourcesClaim,
                rlsRulesClaim
        );
    }

    /**
     * Create guest token with custom RLS rules
     */
    public static String createGuestTokenWithRLS(String dashboardId,
                                                  List<Map<String, Object>> rlsRules) throws Exception {
        SupersetConfig config = SupersetConfig.getInstance();

        // Create resources claim for dashboard access
        List<Map<String, Object>> resourcesClaim = new ArrayList<>();
        Map<String, Object> dashboardResource = new HashMap<>();
        dashboardResource.put("type", "dashboard");
        dashboardResource.put("id", dashboardId);
        resourcesClaim.add(dashboardResource);

        return createGuestToken(
                config.getGuestUsername(),
                config.getGuestFirstName(),
                config.getGuestLastName(),
                resourcesClaim,
                rlsRules
        );
    }
}

