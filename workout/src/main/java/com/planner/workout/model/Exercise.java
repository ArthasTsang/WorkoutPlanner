package com.planner.workout.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "Exercise")
public class Exercise {

    @Id
    private String id;

    @Getter
    @Setter
    private String name;

    @Getter
    @Setter
    private String measurement;

    @Getter
    @Setter
    private String[] variations;

}
