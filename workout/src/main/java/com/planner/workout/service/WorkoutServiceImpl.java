package com.planner.workout.service;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.YearMonth;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.planner.workout.model.CalendarDayView;
import com.planner.workout.model.Exercise;
import com.planner.workout.model.Workout;
import com.planner.workout.repository.ExerciseRepository;
import com.planner.workout.repository.WorkoutRepository;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class WorkoutServiceImpl implements WorkoutService {

    private static final Logger logger = LoggerFactory.getLogger(WorkoutServiceImpl.class);

    @Autowired
    WorkoutRepository workoutRepository;

    @Autowired
    ExerciseRepository exerciseRepository;

    public List<Workout> getAllWorkouts(){
        logger.debug("PlannerServiceImpl::getAllWorkouts");
        List<Workout> workouts= workoutRepository.findAll();
        return workouts;
    }

    public List<Workout> getWorkoutByDate(String workoutDate){
        logger.debug("PlannerServiceImpl::getWorkoutByDate");

        return getWorkoutByDateRange(workoutDate, workoutDate);
    }

    public Workout getWorkoutById(String workoutId){
        logger.debug("PlannerServiceImpl::getWorkoutById");

        Optional<Workout> workout = workoutRepository.findById(workoutId);
        if(workout.isPresent()){
            return workout.get();
        }
        
        return null;
    }

    public List<Workout> getWorkoutByDateRange(String startDate, String endDate) {
        logger.debug("PlannerServiceImpl::getWorkoutByDate");

        Instant convertedStartDate = LocalDate.parse(startDate).minusDays(1).atTime(LocalTime.MAX).toInstant(ZoneOffset.systemDefault().getRules().getOffset(Instant.now()));
        Instant convertedEndDate = LocalDate.parse(endDate).plusDays(1).atTime(LocalTime.MIN).toInstant(ZoneOffset.systemDefault().getRules().getOffset(Instant.now()));
        logger.debug(convertedStartDate.toString());
        logger.debug(convertedEndDate.toString());

        List<Workout> workouts= workoutRepository.findByUsernameAndWorkoutDateBetween("", convertedStartDate, convertedEndDate);
        return workouts;
    }

    public List<CalendarDayView> getWorkoutsInCalendarView(String username, String year, String month){
        YearMonth ym = YearMonth.of(Integer.parseInt(year), Integer.parseInt(month));
        LocalDate firstDayOfMonth = ym.atDay(1);
        LocalDate lastDayOfMonth = ym.atEndOfMonth();
        Instant convertedStartDate = firstDayOfMonth.minusDays(1).atTime(LocalTime.MAX).toInstant(ZoneOffset.systemDefault().getRules().getOffset(Instant.now()));
        Instant convertedEndDate = lastDayOfMonth.plusDays(1).atTime(LocalTime.MIN).toInstant(ZoneOffset.systemDefault().getRules().getOffset(Instant.now()));
        logger.debug(convertedStartDate.toString());
        logger.debug(convertedEndDate.toString());

        List<Workout> workouts= workoutRepository.findByUsernameAndWorkoutDateBetween(username, convertedStartDate, convertedEndDate);
        logger.debug("Number of workouts: " + workouts.size());
        List<CalendarDayView> calendar = new ArrayList<CalendarDayView>();
        for(int d=0; d<lastDayOfMonth.getDayOfMonth(); d++){
            calendar.add(new CalendarDayView(d+1, Integer.parseInt(month), new ArrayList<String>()));
        }
        workouts.forEach(workout -> {
            logger.debug("Workout date: "+ workout.getWorkoutDate().toString());
            calendar.get(workout.getWorkoutDate().getDayOfMonth()-1).getWorkouts().add(workout.getId());
        });

        // adjust day of week: Sun=0, Mon=1, ..., Sat=6
        int firstDayOfWeek = firstDayOfMonth.getDayOfWeek().getValue();
        firstDayOfWeek= firstDayOfWeek==7 ? 0 : firstDayOfWeek;
        int lastDayOfWeek = lastDayOfMonth.getDayOfWeek().getValue();
        lastDayOfWeek= lastDayOfWeek==7 ? 0 : lastDayOfWeek;
        int previousMonth= Integer.parseInt(month)-1;
        previousMonth= previousMonth==0 ? 12 : previousMonth;
        for(int d=0; d<firstDayOfWeek; d++){
            LocalDate dayInPreviousMonth= firstDayOfMonth.minusDays(d+1);
            calendar.add(0, new CalendarDayView(dayInPreviousMonth.getDayOfMonth(), previousMonth, new ArrayList<String>()));
        }
        int nextMonth= Integer.parseInt(month)+1;
        nextMonth= nextMonth==13 ? 1 : nextMonth;
        for(int d=0; d<6-lastDayOfWeek; d++){
            LocalDate dayInNextMonth= lastDayOfMonth.plusDays(d+1);
            calendar.add(new CalendarDayView(dayInNextMonth.getDayOfMonth(), nextMonth, new ArrayList<String>()));
        }

        // calendar.forEach(day -> {
        //     logger.debug("Day: "+day.getDayOfMonth()+", Month: "+day.getMonth()+", Workouts: "+day.getWorkouts().size());
        // });
        return calendar;
    }

    public Workout createWorkout(Workout workout) {
        logger.debug("PlannerServiceImpl::createWorkout");
        return workoutRepository.save(workout);    
    }

    public Workout updateWorkout(String idString, String username, Workout workout) {
        logger.debug("PlannerServiceImpl::updateWorkout");
        Optional<Workout> existingWorkout = workoutRepository.findById(idString);
        if(existingWorkout.isPresent()){// 
            // check if the user is the owner
            if(!existingWorkout.get().getUsername().equals(username)){
                logger.debug("User is not the owner");
                return null;
            }
            workout.setUsername(username);
            workout.setId(existingWorkout.get().getId());
            return workoutRepository.save(workout);
        }else{
            return null;
        }
    }

    public void deleteWorkout(String idString, String username) {
        logger.debug("PlannerServiceImpl::deleteWorkout");
        Optional<Workout> existingWorkout = workoutRepository.findById(idString);
        if(existingWorkout.isPresent()){
            // delete only if the user is the owner
            if(existingWorkout.get().getUsername().equals(username)){
                workoutRepository.deleteById(idString);;
            }else{
                logger.debug("User is not the owner");
            }
        }
    }

    public List<Exercise> getAllExercises(){
        logger.debug("PlannerServiceImpl::getAllExercises");
        return exerciseRepository.findAll();
    }

}
