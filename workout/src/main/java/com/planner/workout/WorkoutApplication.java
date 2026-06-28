package com.planner.workout;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@EnableScheduling
@SpringBootApplication
public class WorkoutApplication {

	private static final Logger logger = LoggerFactory.getLogger(WorkoutApplication.class);

	public static void main(String[] args) {
		logger.info("WorkoutApplication bean initialized by Spring Boot on the [main] thread!");
		SpringApplication.run(WorkoutApplication.class, args);
	}	 // This method is guaranteed to trigger every 60 seconds because it sits inside the main class

}
