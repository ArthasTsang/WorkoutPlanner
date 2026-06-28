package com.workout.planner.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import com.google.gson.Gson;
import com.planner.workout.controller.WorkoutController;
import com.planner.workout.model.Workout;
import com.planner.workout.repository.WorkoutRepository;
import com.planner.workout.service.WorkoutService;

@ExtendWith(MockitoExtension.class)
public class WorkoutControllerTest {

    @Mock
    WorkoutService plannerService;

    @Mock
    WorkoutRepository repository;

    @InjectMocks
    WorkoutController plannerController;

    String payload;
    Workout workout;

    @BeforeEach
    void setup() {
        System.out.println("Mockito");
        payload= "{\"workoutDate\":\"2026-02-28\",\"exercises\":[{\"name\":\"Push Up\",\"exerciseSets\":[{\"number\":1,\"reps\":16},{\"number\":2,\"reps\":16},{\"number\":3,\"reps\":16}]}]}";
        workout = (new Gson()).fromJson(payload, Workout.class);
    }

    // @Test
    // void test_getWorkouts_noDates() {
    //     ResponseEntity<Object> actualResponse = plannerController.getWorkouts(null, null);
    //     assertEquals(HttpStatus.OK, actualResponse.getStatusCode());
    //     verify(plannerService, times(1)).getAllWorkouts();
    // }

    // @Test
    // void test_getWorkouts_validDates() {
    //     String startDate= "2026-03-01";
    //     String endDate= "2026-03-31";
    //     ResponseEntity<Object> actualResponse = plannerController.getWorkouts(startDate, endDate);
    //     assertEquals(HttpStatus.OK, actualResponse.getStatusCode());
    //     verify(plannerService, times(1)).getWorkoutByDateRange(startDate, endDate);
    // }

    // @Test
    // void test_getWorkouts_invalidDates() {
    //     String startDate= "2026-03-01";
    //     String endDate= null;
    //     ResponseEntity<Object> actualResponse = plannerController.getWorkouts(startDate, endDate);
    //     assertEquals(HttpStatus.BAD_REQUEST, actualResponse.getStatusCode());
    //     verify(plannerService, never()).getAllWorkouts();
    //     verify(plannerService, never()).getWorkoutByDateRange(anyString(), anyString());
    // }

    // @Test
    // void test_getWorkoutsByDate_validDate_recordFound() {
    //     String date= "2026-03-01";
    //     List<Workout> workouts = new ArrayList<>();
    //     workouts.add(workout);
    //     when(plannerService.getWorkoutByDate(anyString())).thenReturn(workouts);
    //     ResponseEntity<Object> actualResponse = plannerController.getWorkoutsByDate(date, null);
    //     assertEquals(HttpStatus.OK, actualResponse.getStatusCode());
    // }

    // @Test
    // void test_getWorkoutsByDate_validDate_noRecordFound() {
    //     String date= "2026-03-01";
    //     List<Workout> workouts = new ArrayList<>();
    //     when(plannerService.getWorkoutByDate(anyString())).thenReturn(workouts);
    //     ResponseEntity<Object> actualResponse = plannerController.getWorkoutsByDate(date, null);
    //     assertEquals(HttpStatus.NOT_FOUND, actualResponse.getStatusCode());
    // }

    @Test
    void test_createWorkout_validWorkout() {
        when(plannerService.createWorkout(any(Workout.class))).thenReturn(workout); 
        ResponseEntity<Object> actualResponse = plannerController.createWorkout("tester", payload);
        assertEquals(HttpStatus.OK, actualResponse.getStatusCode());
    }

    @Test
    void test_createWorkout_invalidWorkout() {
        ResponseEntity<Object> actualResponse = plannerController.createWorkout("tester", "invalid workout");
        assertEquals(HttpStatus.BAD_REQUEST, actualResponse.getStatusCode());
    }

    @Test
    void test_modifyWorkout_workoutFound() {
        when(plannerService.updateWorkout(anyString(), anyString(), any(Workout.class))).thenReturn(workout);
        ResponseEntity<Object> actualResponse = plannerController.modifyWorkout("", "", payload);
        assertEquals(HttpStatus.OK, actualResponse.getStatusCode());
    }

    @Test
    void test_modifyWorkout_noWorkoutFound() {
        when(plannerService.updateWorkout(anyString(), anyString(), any(Workout.class))).thenReturn(null);
        ResponseEntity<Object> actualResponse = plannerController.modifyWorkout("", "", payload);
        assertEquals(HttpStatus.NOT_FOUND, actualResponse.getStatusCode());
    }

}
