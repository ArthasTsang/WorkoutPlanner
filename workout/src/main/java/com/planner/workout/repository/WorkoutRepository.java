package com.planner.workout.repository;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;

import com.planner.workout.model.Workout;

import java.util.List;
import java.time.Instant;

public interface WorkoutRepository extends MongoRepository<Workout, String> {

    List<Workout> findByUsernameAndWorkoutDateBetween(String username, Instant startDate, Instant endDate);

    @Query("{'workoutDate': {$gte: ?0, $lte: ?1}}")
    List<Workout> findByWorkoutDateBetweenInclusive(Instant startDate, Instant endDate);

    List<Workout> deleteByWorkoutDateBetween(Instant startDate, Instant endDate);

}
