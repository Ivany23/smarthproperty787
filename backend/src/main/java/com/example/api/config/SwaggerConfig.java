package com.example.api.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.EventListener;
import org.springframework.core.env.Environment;

@Configuration
public class SwaggerConfig {

    private static final Logger LOG = LoggerFactory.getLogger(SwaggerConfig.class);

    private final Environment environment;

    public SwaggerConfig(Environment environment) {
        this.environment = environment;
    }

    @EventListener(ApplicationReadyEvent.class)
    public void printSwaggerUrl() {
        String port = environment.getProperty("local.server.port", "8080");
        String swaggerUrl = "http://localhost:" + port + "/swagger-ui/index.html";

        LOG.info("=================================================================");
        LOG.info("✅ Swagger UI está pronto e acessível!");
        LOG.info("🔗 Link direto: {}", swaggerUrl);
        LOG.info("=================================================================");
    }
}
