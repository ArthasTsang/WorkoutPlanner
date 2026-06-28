import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useSelector, useDispatch } from 'react-redux';
import * as Constants from '../Constants';

// const BooksTable = ( {books} ) => {
const CalendarDayView = ({calendarDay}) => {
    const year = useSelector((store) => store.plannerData.year);
    const month = useSelector((store) => store.plannerData.month);
    const currentMonth= useSelector((store) => store.plannerData.month);
    const navigate = useNavigate();
    const [showButton, setShowButton] = useState(false);

    const handlePlusClick = (e) => {
        e.stopPropagation(); // Prevents the parent div from firing its own click
        console.log("Load create workout page");
        const dateString = `${year}-${String(month).padStart(2, '0')}-${String(calendarDay.dayOfMonth).padStart(2, '0')}`;
        navigate('/planner/upsert-workout?date='+dateString); 
    };

    const handleWorkoutBoxClick = (e, workoutId) => {
        e.stopPropagation();
        console.log("Load view workout page");
        navigate(`/planner/view-workout/${workoutId}`);
    }

    return (
        <div 
            className={calendarDay.month==currentMonth ? "calendar-day-container" : "disabled-calendar-day-container"}
            onMouseEnter={() => setShowButton(true)}
            onMouseLeave={() => setShowButton(false)}>
            {showButton && (
                <div className="add-workout-btn" onClick={handlePlusClick}>
                    +
                </div>
            )}
            <label 
                className="day-label"
                onMouseEnter={() => setShowButton(false)}
                onMouseLeave={() => setShowButton(true)}>
                {calendarDay.dayOfMonth}
            </label>
            <div 
                className="workout-list"
                onMouseEnter={() => setShowButton(false)}
                onMouseLeave={() => setShowButton(true)}>
                {calendarDay.workouts.map(workout => (
                    <div className="workout-box" key={workout} onClick={(e) => handleWorkoutBoxClick(e, workout)}>workout</div>
                ))}
            </div>
        </div>
    )
}

export default CalendarDayView