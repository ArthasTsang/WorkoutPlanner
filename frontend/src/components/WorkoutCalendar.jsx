import React, { useEffect, useState } from 'react';
import CalendarDayView from './CalendarDayView';
import axios from 'axios';
import { useSelector, useDispatch } from 'react-redux';
import { setYearMonth } from '../data/slice/PlannerDataSlice';
import * as Constants from '../Constants';

const WorkoutCalendar = () => {
    // const [year, setYear] = useState(new Date().getFullYear());
    // const [month, setMonth] = useState(new Date().getMonth());
    const year = useSelector((store) => store.plannerData.year);
    const month = useSelector((store) => store.plannerData.month);
    const username = useSelector((store) => store.plannerData.username);
    const jwt = useSelector((store) => store.plannerData.jwt);
    const dispatch = useDispatch();
    const [calendarDays, setCalendarDays] = useState([]);   // calendarDays = [];
    const [loading, setLoading] = useState(false);

    const daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const displayDate = new Date(year, month-1, 1);

    useEffect(() => {
        const data= {
            "year": year,
            "month": month
        }

        setLoading(true);
        axios.get(Constants.API_URL_PREFIX+'/planner/workout/calendarView', 
                {
                    params: data, 
                    headers: { 
                        'X-USER-ID': username,
                        'Authorization': 'Bearer ' + jwt
                    }
                }
            )
            .then((response) => {
                console.log("Load calendar successfully");
                setCalendarDays(response.data);
                setLoading(false);
            })
            .catch(error => {
                console.log("Load calendar failed: " + error);
                setLoading(false);
            });
    }, [year, month]);

    // Month navigation logic
    const changeMonth = (offset) => {
        const offsetDate= new Date(year, month + offset, 1);
        dispatch(setYearMonth({"year": offsetDate.getFullYear(), "month": offsetDate.getMonth()}));
    };

    const styles = {
        container: { 
            width: 'fit-content', // Container shrinks/grows to fit the grid
            minWidth: '90vw',
            maxWidth: '95vw',     // Prevents it from going off-screen
            minHeight: '80vh',
            border: '1px solid #ccc', 
            borderRadius: '8px',
            boxShadow: '0 4px 6px rgba(0,0,0,0.1)',
            padding: '10px', 
            fontFamily: 'Calibri, sans-serif',
            justifyContent: 'center'
        },
        header: { 
            display: 'flex', 
            justifyContent: 'space-between', 
            alignItems: 'center', 
            marginBottom: '10px' 
        },
        grid: { 
            display: 'grid', 
            gridAutoRows: 'minmax(60px, 1fr)',
            gridTemplateColumns: 'repeat(7, minmax(60px, 1fr))', 
            gap: '5px',
            width: '100%',
            minHeight: '80vh',
            overflowX: 'auto',
            alignItems: 'stretch', 
            justifyItems: 'center'
        },
        weekdayRow: { 
            display: 'grid', 
            gridTemplateColumns: 'repeat(7, 1fr)', 
            fontWeight: 'bold', 
            textAlign: 'center', 
            marginBottom: '5px' 
        }
    };

    return (
        <div style={styles.container}>
            {/* Header with Buttons */}
            <div style={styles.header}>
                <button onClick={() => changeMonth(-1)}>Prev</button>
                <span>{displayDate.toLocaleString('default', { month: 'long' })} {year}</span>
                <button onClick={() => changeMonth(1)}>Next</button>
            </div>

            {/* Weekday Labels */}
            <div style={styles.weekdayRow}>
                {daysOfWeek.map(day => <div key={day}>{day}</div>)}
            </div>

            {/* Days Grid */}
            {loading ? (
                <></>
            ) : (
                <div style={styles.grid}>
                    {calendarDays.map((calendarDay, index) => (
                        <CalendarDayView key={index} calendarDay={calendarDay} />
                    ))}
                </div>
            )}
        </div>
    );
};

export default WorkoutCalendar;