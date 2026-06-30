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
import org.springframework.context.annotation.Bean;
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

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
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

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("My Workout Planner API")
                        .version("1.0.0")
                        .description("This is the API documentation for My Workout Planner."));

    }
    
    @Operation(summary = "Health Check", description = "Allow health check of microservice")
    @GetMapping(value = "/planner/workout/health", produces = "application/json")
    public ResponseEntity<Object> healhCheck() {
        HttpHeaders responseHeaders = new HttpHeaders();
        responseHeaders.set("Content-Type", "application/json");

        return new ResponseEntity<>("", responseHeaders, HttpStatus.OK);
    }

    // @GetMapping(value = "/planner/workout", produces = "application/json")
    // public ResponseEntity<Object> getWorkouts(
    //     @RequestParam(value = "startDate", required = false) String startDate, 
    //     @RequestParam(value = "endDate", required = false) String endDate) {
    //     logger.debug("PlannerController::getPlanner");

    //     HttpHeaders responseHeaders = new HttpHeaders();
    //     responseHeaders.set("Content-Type", "application/json");
        
    //     Gson gson = new Gson();
    //     if((startDate!=null && !startDate.equals("")) && (endDate!=null && !endDate.equals(""))) {
    //         List<Workout> workouts = plannerService.getWorkoutByDateRange(startDate, endDate);
    //         return new ResponseEntity<>(gson.toJson(workouts), responseHeaders, HttpStatus.OK);
    //     }else if(startDate==null && endDate==null) {
    //         List<Workout> workouts = plannerService.getAllWorkouts();
    //         return new ResponseEntity<>(gson.toJson(workouts), responseHeaders, HttpStatus.OK);
    //     }

    //     return new ResponseEntity<>("", responseHeaders, HttpStatus.BAD_REQUEST);
    // }

    @Operation(summary = "Calendar view", description = "Getting all workouts of a customer in one calendar month for display in dashboard")
    @ApiResponse(
        responseCode = "200", 
        description = "Successfully retrieved the calendar dashboard",
        content = @Content(
            mediaType = "application/json",
            array = @ArraySchema(
                schema = @Schema(implementation = CalendarDayView.class)
            )
        )
    )
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

    @Operation(summary = "Get workout", description = "Get an existing workout record for customer")
    @ApiResponse(
        responseCode = "200", 
        description = "Successfully retrieved the workout record",
        content = @Content(
            mediaType = "application/json",
            schema = @Schema(implementation = Workout.class)
        )
    )
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
    
    @Operation(summary = "Create workout", description = "Create a new workout record for customer")
    @ApiResponse(
        responseCode = "200", 
        description = "Successfully saved the workout record",
        content = @Content(
            mediaType = "application/json",
            schema = @Schema(implementation = Workout.class)
        )
    )
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

    @Operation(summary = "Modify workout", description = "Modify an existing workout record for customer")
    @ApiResponse(
        responseCode = "200", 
        description = "Successfully modified the workout record",
        content = @Content(
            mediaType = "application/json",
            schema = @Schema(implementation = Workout.class)
        )
    )
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

    @Operation(summary = "Delete workout", description = "Delete an existing workout record for customer")
    @ApiResponse(
        responseCode = "200", 
        description = "Successfully deleted the workout record. No response body returned."
    )
    @DeleteMapping(value = "/planner/workout/{id}", produces = "application/json")
        public ResponseEntity<Object> deleteWorkout(@RequestHeader("X-USER-ID") String username, @PathVariable(value = "id") String idString) {
        logger.debug("PlannerController::deleteWorkout");
        logger.debug("Workout ID: " + idString);

        HttpHeaders responseHeaders = new HttpHeaders();
        responseHeaders.set("Content-Type", "application/json");
        
        plannerService.deleteWorkout(idString, username);

        return new ResponseEntity<>("", responseHeaders, HttpStatus.OK);
    }

    @Operation(summary = "Load exercises", description = "Loading all available exercises from database for customer to choose in workout pages")
    @ApiResponse(
        responseCode = "200", 
        description = "Successfully loaded all exercises",
        content = @Content(
            mediaType = "application/json",
            array = @ArraySchema(
                schema = @Schema(implementation = Exercise.class)
            )
        )
    )
    @GetMapping(value = "/planner/workout/exercise", produces = "application/json")
    public ResponseEntity<Object> getAllExercises() {
        HttpHeaders responseHeaders = new HttpHeaders();
        responseHeaders.set("Content-Type", "application/json");
        
        List<Exercise> exercises = plannerService.getAllExercises();

        Gson gson = new Gson();
        return new ResponseEntity<>(gson.toJson(exercises), responseHeaders, HttpStatus.OK);
    }
    

}
