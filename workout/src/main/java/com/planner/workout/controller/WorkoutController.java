package com.planner.workout.controller;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;

import java.util.List;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.planner.workout.model.CalendarDayView;
import com.planner.workout.model.Exercise;
import com.planner.workout.model.Workout;
import com.planner.workout.repository.WorkoutRepository;
import com.planner.workout.service.WorkoutService;

import lombok.extern.slf4j.Slf4j;

import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestHeader;


@Slf4j
@RestController
public class WorkoutController {

    private static final Logger logger = LoggerFactory.getLogger(WorkoutController.class);

    @Autowired
    WorkoutService plannerService;

    @Autowired
    WorkoutRepository repository;

    @GetMapping(value = "/planner/workout/health", produces = "application/json")
    public ResponseEntity<Object> healhCheck() {
        HttpHeaders responseHeaders = new HttpHeaders();
        responseHeaders.set("Content-Type", "application/json");

        return new ResponseEntity<>("", responseHeaders, HttpStatus.OK);
    }

    @GetMapping(value = "/planner/workout", produces = "application/json")
    public ResponseEntity<Object> getWorkouts(
        @RequestParam(value = "startDate", required = false) String startDate, 
        @RequestParam(value = "endDate", required = false) String endDate) {
        logger.debug("PlannerController::getPlanner");

        HttpHeaders responseHeaders = new HttpHeaders();
        responseHeaders.set("Content-Type", "application/json");
        
        Gson gson = new Gson();
        if((startDate!=null && !startDate.equals("")) && (endDate!=null && !endDate.equals(""))) {
            List<Workout> workouts = plannerService.getWorkoutByDateRange(startDate, endDate);
            return new ResponseEntity<>(gson.toJson(workouts), responseHeaders, HttpStatus.OK);
        }else if(startDate==null && endDate==null) {
            List<Workout> workouts = plannerService.getAllWorkouts();
            return new ResponseEntity<>(gson.toJson(workouts), responseHeaders, HttpStatus.OK);
        }

        return new ResponseEntity<>("", responseHeaders, HttpStatus.BAD_REQUEST);
    }
    
    @GetMapping(value = "/planner/workout/{workoutId}", produces = "application/json")
    public ResponseEntity<Object> getWorkout(@RequestHeader("X-USER-ID") String username, @PathVariable(value = "workoutId", required = true) String workoutId) {
        logger.debug("PlannerController::getPlannerByDate");
        logger.debug("Workout: " + workoutId);

        HttpHeaders responseHeaders = new HttpHeaders();
        responseHeaders.set("Content-Type", "application/json");

        Workout workout = plannerService.getWorkoutById(workoutId);
        logger.debug("Workout: " + workout);

        Gson gson = new Gson();
        if(workout!=null) {
            if(!workout.getUsername().equals(username)){
                logger.debug("Workout does not belong to user");
                return new ResponseEntity<>("", responseHeaders, HttpStatus.NOT_FOUND);
            }
            
            return new ResponseEntity<>(gson.toJson(workout), responseHeaders, HttpStatus.OK);
        }else{
            return new ResponseEntity<>("", responseHeaders, HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping(value = "/planner/workout/calendarView", produces = "application/json")
    public ResponseEntity<Object> getWorkoutsInCalendarView(
        @RequestHeader("X-USER-ID") String username, 
        @RequestParam(value = "year", required = true) String year, 
        @RequestParam(value = "month", required = true) String month) {
        logger.debug("PlannerController::getWorkoutsInCalendarView");
        logger.debug("Blue/Green deployment: Blue");
        logger.debug("Username: " + username);
        logger.debug("Year: " + year + " Month: " + month);

        HttpHeaders responseHeaders = new HttpHeaders();
        responseHeaders.set("Content-Type", "application/json");

        List<CalendarDayView> days = plannerService.getWorkoutsInCalendarView(username, year, month);
        Gson gson = new Gson();
        return new ResponseEntity<>(gson.toJson(days), responseHeaders, HttpStatus.OK);
    }

    @PostMapping(value = "/planner/workout", produces = "application/json")
    public ResponseEntity<Object> createWorkout(@RequestHeader("X-USER-ID") String username, @RequestParam(value = "workout", required = true) String workout) {
        logger.debug("PlannerController::createPlanner");  
        logger.debug(workout);
        
        HttpHeaders responseHeaders = new HttpHeaders();
        responseHeaders.set("Content-Type", "application/json");

        Workout convertedWorkout= null;
        Gson gson = new Gson();
        try{
            convertedWorkout= gson.fromJson(workout, Workout.class); 
            convertedWorkout.setUsername(username);
            logger.debug("Converted workout");
            logger.debug(convertedWorkout.toString());
        }catch(JsonSyntaxException e) {
                return new ResponseEntity<>("", responseHeaders, HttpStatus.BAD_REQUEST); 
        }
        
        Workout savedWorkout = plannerService.createWorkout(convertedWorkout);
        logger.debug("Saved workout");
        logger.debug(savedWorkout.toString());

        return new ResponseEntity<>(gson.toJson(savedWorkout), responseHeaders, HttpStatus.OK);
    }

    @PutMapping(value = "/planner/workout/{id}", produces = "application/json")
    public ResponseEntity<Object> modifyWorkout(@RequestHeader("X-USER-ID") String username, @PathVariable(value = "id") String idString, @RequestParam(value = "workout", required = true) String workoutString) {
        logger.debug("PlannerController::putMethodName");
        logger.debug(workoutString);

        HttpHeaders responseHeaders = new HttpHeaders();
        responseHeaders.set("Content-Type", "application/json");

        Gson gson = new Gson();
        Workout workout= gson.fromJson(workoutString, Workout.class);
        logger.debug("Workout");
        logger.debug(workout.toString());
        Workout updatedWorkout = plannerService.updateWorkout(idString, username, workout);
        if(updatedWorkout != null){
            logger.debug("Updated workout");
        logger.debug(updatedWorkout.toString());
            return new ResponseEntity<>(gson.toJson(updatedWorkout), responseHeaders, HttpStatus.OK);
        }else{
            return new ResponseEntity<>("", responseHeaders, HttpStatus.NOT_FOUND);
        }
    }

    @DeleteMapping(value = "/planner/workout/{id}", produces = "application/json")
        public ResponseEntity<Object> deleteWorkout(@RequestHeader("X-USER-ID") String username, @PathVariable(value = "id") String idString) {
        logger.debug("PlannerController::deleteWorkout");
        logger.debug("Workout ID: " + idString);

        HttpHeaders responseHeaders = new HttpHeaders();
        responseHeaders.set("Content-Type", "application/json");
        
        plannerService.deleteWorkout(idString, username);

        return new ResponseEntity<>("", responseHeaders, HttpStatus.OK);
    }

    @GetMapping(value = "/planner/workout/exercise", produces = "application/json")
    public ResponseEntity<Object> getAllExercises() {
        HttpHeaders responseHeaders = new HttpHeaders();
        responseHeaders.set("Content-Type", "application/json");
        
        List<Exercise> exercises = plannerService.getAllExercises();

        Gson gson = new Gson();
        return new ResponseEntity<>(gson.toJson(exercises), responseHeaders, HttpStatus.OK);
    }
    

}
