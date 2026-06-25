package com.planner.workout.config;

import com.mongodb.MongoClientSettings;
import lombok.extern.slf4j.Slf4j;

import org.slf4j.LoggerFactory;
import org.slf4j.Logger;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;
import org.springframework.data.mongodb.config.AbstractMongoClientConfiguration;

import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManagerFactory;
import java.io.InputStream;
import java.security.KeyStore;
import java.security.cert.CertificateFactory;

@Configuration
@Slf4j
public class DocumentDbSslConfig extends AbstractMongoClientConfiguration {

    private static final Logger logger = LoggerFactory.getLogger(DocumentDbSslConfig.class);

    @Value("${documentdb.ssl.cert-path}")
    private Resource certResource;

    // @Value("${spring.mongodb.host}")
    // private String host;

    // @Value("${spring.mongodb.uri}")
    // private String mongoUri;

    @Value("${host}")
    private String host;

    @Value("${spring.mongodb.uri}")
    private String mongoUri;

    @Value("${dbname}")
    private String databaseName;

    @Override
    protected String getDatabaseName() {
        return databaseName;
    }

    // private OpenTelemetry openTelemetry;
    // private Tracer micrometerTracer;
    
    @Override
    protected void configureClientSettings(MongoClientSettings.Builder builder) {
        logger.info("Loading DocumentDB SSL configuration...");

        try (InputStream is = certResource.getInputStream()) {
            CertificateFactory cf = CertificateFactory.getInstance("X.509");
            
            // 1. IMPORTANT: Extract ALL certificates from the collection bundle
            java.util.Collection<? extends java.security.cert.Certificate> certs = cf.generateCertificates(is);

            // 2. Initialize a clean empty KeyStore
            KeyStore keyStore = KeyStore.getInstance(KeyStore.getDefaultType());
            keyStore.load(null, null);

            // 3. Loop through and inject every single certificate into the trust store
            int index = 1;
            for (java.security.cert.Certificate cert : certs) {
                keyStore.setCertificateEntry("docdb-ca-" + index, cert);
                index++;
            }
            System.out.println("Successfully loaded " + (index - 1) + " regional AWS certificates into trust store.");

            // 4. Bind the filled KeyStore to your SSL Context
            TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
            tmf.init(keyStore);

            SSLContext sslContext = SSLContext.getInstance("TLS");
            sslContext.init(null, tmf.getTrustManagers(), null);

            String safeUri = mongoUri;
            int doubleSlashIndex = mongoUri.indexOf("//") + 2;
            int atIndex = mongoUri.lastIndexOf("@");
            String credentialsSection = mongoUri.substring(doubleSlashIndex, atIndex);
            
            int colonIndex = credentialsSection.indexOf(":");
            String username = credentialsSection.substring(0, colonIndex);
            String rawPassword = credentialsSection.substring(colonIndex + 1);
            
            String encodedPassword = java.net.URLEncoder.encode(rawPassword, java.nio.charset.StandardCharsets.UTF_8);
            
            safeUri = mongoUri.substring(0, doubleSlashIndex) + username + ":" + encodedPassword + mongoUri.substring(atIndex);

            // This guarantees your scheduler's initialization constructor captures the CORRECT matching baseline strings!
            System.setProperty("host", username + ":" + encodedPassword + "@" + host); 
            logger.info("DocumentDB SSL configuration Host: "+System.getProperty("host"));

            // 5. Connect to Driver via SSL
            builder.applyConnectionString(new com.mongodb.ConnectionString(safeUri))
                .applyToSslSettings(ssl -> ssl.enabled(true).context(sslContext));
                // .addCommandListener(bridgeListener);

        } catch (Exception e) {
            throw new RuntimeException("Spring Boot failed to auto-load the multi-cert DocumentDB bundle", e);
        }

        logger.info("DocumentDB SSL configuration loaded.");
    }

}
