package com.planner.workout.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.planner.workout.model.CalendarDayView;
import com.planner.workout.model.Exercise;
import com.planner.workout.model.Workout;

@Service
public interface WorkoutService {

    List<Workout> getAllWorkouts();

    Workout getWorkoutById(String workoutId);

    List<Workout> getWorkoutByDate(String workoutDate);

    List<Workout> getWorkoutByDateRange(String startDate, String endDate);

    List<CalendarDayView> getWorkoutsInCalendarView(String username, String year, String month);

    Workout createWorkout(Workout workout);

    Workout updateWorkout(String idString, String username, Workout workout);
    
    void deleteWorkout(String idString, String username);
    
    List<Exercise> getAllExercises();
    
}
