package com.planner.workout.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class WorkoutExercise {

    @Getter
    @Setter
    private String name;

    @Getter
    @Setter
    private WorkoutExerciseSet[] exerciseSets;

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("Exercise [name=" + name + "]"+ "\n\r");
        for (WorkoutExerciseSet exerciseSet : exerciseSets) {
           sb.append(exerciseSet.toString()+ "\n\r");
        }
        
        return sb.toString();
    }

}
