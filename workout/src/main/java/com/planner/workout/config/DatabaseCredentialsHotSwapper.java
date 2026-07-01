package com.planner.workout.config; // Aligned cleanly to your application package namespace

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import lombok.extern.slf4j.Slf4j;
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueResponse;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import org.slf4j.LoggerFactory;
import org.slf4j.Logger;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.support.DefaultListableBeanFactory;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

@Configuration
@Slf4j
@EnableScheduling
@Profile({"demo", "dev", "uat", "prod"}) // Ensures this scheduler thread only executes on production EC2!
public class DatabaseCredentialsHotSwapper {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseCredentialsHotSwapper.class);

    private final ConfigurableApplicationContext applicationContext;
    private final ConfigurableEnvironment environment;
    private final SecretsManagerClient secretsManagerClient;
    private MongoClient activeMongoClient;
    private final ObjectMapper objectMapper; 
    private final String secretId;

    private String activeHostBaseline;
    private String activePasswordBaseline;

    public DatabaseCredentialsHotSwapper(ConfigurableApplicationContext applicationContext, 
                                         ConfigurableEnvironment environment,
                                         SecretsManagerClient secretsManagerClient,
                                         ObjectMapper objectMapper,
                                         @Value("${secretId}") String secretId) {
        logger.info("DatabaseCredentialsHotSwapper bean initialized by Spring Boot on the [main] thread!");
        this.applicationContext = applicationContext;
        this.environment = environment;
        this.secretsManagerClient = secretsManagerClient;
        this.objectMapper = objectMapper;
        this.secretId = secretId;

        this.activeHostBaseline = environment.getProperty("host");
        this.activePasswordBaseline = environment.getProperty("password");                        
    }

    // Executes every 1 minute (60,000 milliseconds)
    @Scheduled(fixedRate = 300000)
    public void hotSwapMongoPassword() {
        try {
            logger.debug("Polling AWS Secrets Manager over VPC Endpoint for live rotation check...");

            // // 1. Force a live API call to AWS Secrets Manager over your VPC Endpoint
            // GetSecretValueResponse secretValueResponse = secretsManagerClient.getSecretValue(
            //         GetSecretValueRequest.builder().secretId(secretId).build()
            // );

            // String secretString = secretValueResponse.secretString();
            // if (secretString == null) return;

            // // 2. Parse the live JSON payload
            // JsonNode jsonNode = objectMapper.readTree(secretString);
            // String currentAwsHost = jsonNode.has("host") ? jsonNode.get("host").asText() : null;
            // String currentAwsPassword = jsonNode.has("password") ? jsonNode.get("password").asText() : null;


             // 1. Force a live API call to AWS Secrets Manager over your VPC Endpoint
            GetSecretValueResponse secretValueResponse = secretsManagerClient.getSecretValue(
                    GetSecretValueRequest.builder().secretId(secretId).build()
            );

            String secretString = secretValueResponse.secretString();
            if (secretString == null) return;

            // 2. Parse the live JSON payload
            JsonNode jsonNode = objectMapper.readTree(secretString);
            String currentAwsHost = jsonNode.has("host") ? jsonNode.get("host").asText() : null;
            String rawAwsPassword = jsonNode.has("password") ? jsonNode.get("password").asText() : null;

            // NEW FIX: URL-encode the raw password immediately to escape special characters like '%'
            String currentAwsPassword = null;
            if (rawAwsPassword != null) {
                currentAwsPassword = java.net.URLEncoder.encode(
                        rawAwsPassword, 
                        java.nio.charset.StandardCharsets.UTF_8
                );
            }
            
            // 3. Compare the live AWS value against our active running baseline
            if ((currentAwsHost != null && !currentAwsHost.equals(activeHostBaseline)) ||
                (currentAwsPassword != null && !currentAwsPassword.equals(activePasswordBaseline))) {
                
                logger.warn(">>>> SUCCESS: NEW HOST OR PASSWORD DETECTED IN AWS SECRETS MANAGER! <<<<");
                logger.info("Updating environment property keys and destroying old connection pool...");

                // 4. Update Spring's environment properties in-memory so any new auto-configurations read it
                System.setProperty("host", currentAwsHost);
                System.setProperty("password", currentAwsPassword);

                // // 5. Evict and destroy the old MongoClient bean instance
                // applicationContext.getBeanFactory().destroyBean(applicationContext.getBean(MongoClient.class));
                
                // // 6. Update our tracking baseline to prevent duplicate resets
                // this.activeHostBaseline = currentAwsHost;
                // this.activePasswordBaseline = currentAwsPassword;

                // 5. Get hold of the raw Spring Bean Factory engine layers
                DefaultListableBeanFactory beanFactory = (DefaultListableBeanFactory) applicationContext.getBeanFactory();

                // 6. Evict and destroy the active runtime MongoClient bean instance safely
                if (beanFactory.containsBean("mongoClient")) {
                    beanFactory.destroySingleton("mongoClient");
                }

                // 7. Extract the updated raw configuration uri string from the environment context
                String updatedUri = environment.getProperty("spring.mongodb.uri");
                if (updatedUri == null) {
                    throw new IllegalStateException("Failed to resolve 'spring.mongodb.uri' after hot-swapping memory map properties.");
                }

                // 8. CRITICAL SSL BINDING FIX: Manually rebuild the multi-certificate SSLContext for the new pool instance
                org.springframework.core.io.Resource certResource = applicationContext.getResource(environment.getProperty("documentdb.ssl.cert-path", "file:/home/ec2-user/global-bundle.pem"));
                javax.net.ssl.SSLContext sslContext;
                
                try (java.io.InputStream is = certResource.getInputStream()) {
                    java.security.cert.CertificateFactory cf = java.security.cert.CertificateFactory.getInstance("X.509");
                    java.util.Collection<? extends java.security.cert.Certificate> certs = cf.generateCertificates(is);

                    java.security.KeyStore keyStore = java.security.KeyStore.getInstance(java.security.KeyStore.getDefaultType());
                    keyStore.load(null, null);

                    int index = 1;
                    for (java.security.cert.Certificate cert : certs) {
                        keyStore.setCertificateEntry("docdb-ca-hotswap-" + index, cert);
                        index++;
                    }

                    javax.net.ssl.TrustManagerFactory tmf = javax.net.ssl.TrustManagerFactory.getInstance(javax.net.ssl.TrustManagerFactory.getDefaultAlgorithm());
                    tmf.init(keyStore);

                    sslContext = javax.net.ssl.SSLContext.getInstance("TLS");
                    sslContext.init(null, tmf.getTrustManagers(), null);
                    logger.info("Successfully rebuilt and injected SSLContext with {} certificates for hotswapped connection pool.", index - 1);
                }

                // 9. Build MongoClientSettings applying the safeUri connection details AND the newly created SSLContext
                com.mongodb.MongoClientSettings clientSettings = com.mongodb.MongoClientSettings.builder()
                        .applyConnectionString(new com.mongodb.ConnectionString(updatedUri))
                        .applyToSslSettings(ssl -> ssl.enabled(true).context(sslContext))
                        // .addCommandListener(bridgeListener)
                        .build();

                // 10. Instantiate the fresh MongoClient and re-register back into Spring's active singleton index
                MongoClient newMongoClient = MongoClients.create(clientSettings);
                beanFactory.registerSingleton("mongoClient", newMongoClient);
                 // =========================================================================
                // ADDED STEP 10b: FORCE THE RUNNING FACTORY TO USE THE NEW INSTANCE POINTER
                // =========================================================================
                try {
                    org.springframework.data.mongodb.core.SimpleMongoClientDatabaseFactory factory = 
                        applicationContext.getBean(org.springframework.data.mongodb.core.SimpleMongoClientDatabaseFactory.class);
                    
                    // Access the internal private mongoClient field held inside Spring's active database factory object
                    java.lang.reflect.Field mongoClientField = org.springframework.data.mongodb.core.SimpleMongoClientDatabaseFactory.class.getSuperclass().getDeclaredField("mongoClient");
                    mongoClientField.setAccessible(true);
                    mongoClientField.set(factory, newMongoClient);
                    logger.info("Successfully redirected Spring MongoDatabaseFactory to use the new cluster connection.");
                } catch (Exception ex) {
                    logger.error("Failed to dynamically update MongoDatabaseFactory reference pointer!", ex);
                }
                
                // =========================================================================    
                // 11. Safely close the old client to kill background topology threads
                MongoClient oldMongoClient = this.activeMongoClient;
                this.activeMongoClient = newMongoClient;
                if (oldMongoClient != null) {
                    oldMongoClient.close();
                }

                // 12. Update our tracking baseline to prevent duplicate resets
                this.activeHostBaseline = currentAwsHost;
                this.activePasswordBaseline = currentAwsPassword;

                logger.info("Host: "+activeHostBaseline);
                logger.info(">>>> SUCCESS: MongoClient connection pool successfully hot-swapped to use the new password. <<<<");
            } else {
                logger.debug("No password rotation noted. Database properties are completely in sync.");
            }
        } catch (Exception e) {
            logger.error("Failed to check or execute runtime database credential swap: {}", e.getMessage());
        }
    }

}
