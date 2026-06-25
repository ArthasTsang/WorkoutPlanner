package com.planner.workout.model;

import java.time.LocalDate;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import com.google.gson.annotations.JsonAdapter;
import com.planner.workout.utils.LocalDateAdapter;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "Workout")
public class Workout {

    @Id
    private String id;

    @Getter
    @Setter
    private String username;
    
    @Getter
    @Setter
    @JsonAdapter(LocalDateAdapter.class)
    private LocalDate workoutDate;
    
    @Getter
    @Setter
    private WorkoutExercise[] exercises;

    // @Getter
    // @Setter
    // private String exercise;

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("Workout [id=" + id + ", workoutDate=" + workoutDate + "\n\r");
        for (WorkoutExercise exercise : exercises) {
            sb.append(exercise.toString()+ "\n\r");
        }
        return sb.toString();
    }

}
