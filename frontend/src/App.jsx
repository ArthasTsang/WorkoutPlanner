import './App.css'; 
import { Routes, Route } from 'react-router-dom'
import Login from './components/Login';
import WorkoutCalendar from './components/WorkoutCalendar';   
import UpsertWorkout from './components/UpsertWorkout';
import ViewWorkout from './components/ViewWorkout';

const App = () => {
    return (
        <Routes>
            <Route path="/" element={<Login />} />
            <Route path="/planner" element={<WorkoutCalendar />} />
            <Route path="/planner/upsert-workout/:id?" element={<UpsertWorkout />} />
            <Route path="/planner/view-workout/:id" element={<ViewWorkout />} />
        </Routes>  
    )
}

export default App;