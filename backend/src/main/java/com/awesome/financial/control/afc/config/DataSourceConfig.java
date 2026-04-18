package com.awesome.financial.control.afc.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.net.URI;
import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
@Profile({"staging", "prod"})
public class DataSourceConfig {

    @Bean
    public DataSource dataSource(@Value("${DATABASE_URL}") String databaseUrl) {
        URI uri = URI.create(databaseUrl.replace("postgres://", "postgresql://"));
        String[] userInfo = uri.getUserInfo().split(":", 2);

        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(
                "jdbc:postgresql://" + uri.getHost() + ":" + uri.getPort() + uri.getPath());
        config.setUsername(userInfo[0]);
        config.setPassword(userInfo[1]);
        config.setMaximumPoolSize(10);
        return new HikariDataSource(config);
    }
}
