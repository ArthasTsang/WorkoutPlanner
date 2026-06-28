package com.karate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;

import org.springframework.boot.test.context.SpringBootTest;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import com.planner.workout.WorkoutApplication;

@SpringBootTest(classes = WorkoutApplication.class, webEnvironment = SpringBootTest.WebEnvironment.DEFINED_PORT)
public class FeatureTest {

    // @Autowired
    // private ServletWebServerApplicationContext webContext;


    @Test
    void test() {
        System.out.println("Karate");
        // int port = webContext.getWebServer().getPort();
        int port = 8092;

        java.util.Map<String, Object> contextVariables = new java.util.HashMap<>();
        contextVariables.put("urlBase", "https://localhost:" + port);

        Results results = Runner.path("classpath:com/karate/workout.feature")
                // .systemProperty("server.port", port + "")
                .systemProperty("server.port", String.valueOf(port))
                .systemProperty("myAppUrl", "https://localhost:" + port) 
                .parallel(1);

        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

}
