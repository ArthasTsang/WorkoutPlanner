package com.workout.planner.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.anyString;

import java.time.Instant;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.planner.workout.repository.WorkoutRepository;
import com.planner.workout.service.WorkoutServiceImpl;

@ExtendWith(MockitoExtension.class)
public class WorkoutServiceImplTest {

    @Mock
    WorkoutRepository repository;

    @InjectMocks
    WorkoutServiceImpl plannerService;

    @Test
    void test_getWorkoutByDate_validDates() {
        plannerService.getWorkoutByDate("2026-03-01");
        ArgumentCaptor<Instant> startDateCaptor = ArgumentCaptor.forClass(Instant.class);
        ArgumentCaptor<Instant> endDateCaptor = ArgumentCaptor.forClass(Instant.class);
        verify(repository, times(1)).findByUsernameAndWorkoutDateBetween(anyString(), startDateCaptor.capture(), endDateCaptor.capture());
        assertEquals(Instant.parse("2026-02-28T15:59:59.999999999Z"), startDateCaptor.getValue());
        assertEquals(Instant.parse("2026-03-01T16:00:00.000000000Z"), endDateCaptor.getValue());
    }

    @Test
    void test_getWorkoutByDateRange_validDates() {
        plannerService.getWorkoutByDateRange("2026-03-01", "2026-03-31");

        ArgumentCaptor<Instant> startDateCaptor = ArgumentCaptor.forClass(Instant.class);
        ArgumentCaptor<Instant> endDateCaptor = ArgumentCaptor.forClass(Instant.class);
        verify(repository, times(1)).findByUsernameAndWorkoutDateBetween(anyString(), startDateCaptor.capture(), endDateCaptor.capture());
        assertEquals(Instant.parse("2026-02-28T15:59:59.999999999Z"), startDateCaptor.getValue());
        assertEquals(Instant.parse("2026-03-31T16:00:00.000000000Z"), endDateCaptor.getValue());
    }

}
