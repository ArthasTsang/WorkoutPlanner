package com.planner.workout.model;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CalendarDayView {

    private int dayOfMonth;
    private int month;
    private List<String> workouts;
    
}
