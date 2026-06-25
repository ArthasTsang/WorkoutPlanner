package com.planner.workout.repository;

import org.springframework.data.mongodb.repository.MongoRepository;

import com.planner.workout.model.Exercise;

public interface ExerciseRepository extends MongoRepository<Exercise, String> {

}
