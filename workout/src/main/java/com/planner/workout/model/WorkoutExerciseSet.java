package com.planner.workout.model;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class WorkoutExerciseSet {

    @Getter
    @Setter
    private Integer reps;

    @Getter
    @Setter
    private Integer duration;

    @Getter
    @Setter
    private BigDecimal weight;

    @Getter
    @Setter
    private String variation;

    @Override
    public String toString() {
        return "ExerciseSet [" + 
                (reps!=null ? ", reps=" + reps.toString() : "") 
                + (duration!=null ? ", duration=" + duration.toString() : "") 
                + (weight!=null ? ", weight=" + weight.toString() : "") 
                + (variation!=null ? ", variation=" + variation : "")  
                + "]";
    }
    
}
