import axios from 'axios';
import { useState, useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom';
import { useSelector } from 'react-redux';
import * as Constants from '../Constants';

const ViewWorkout = () => {
    const navigate = useNavigate();
    const username = useSelector((store) => store.plannerData.username);
    const jwt = useSelector((store) => store.plannerData.jwt);
    const { id } = useParams();
    const [workoutData, setWorkoutData] = useState({"workoutDate": "", "exercises": []});
    const [loading, setLoading] = useState(false);  

    useEffect(() => {
        console.log("Load view workout page");

        setLoading(true);
        axios.get(Constants.API_URL_PREFIX+'/planner/workout/'+id, {
            headers: { 
                'X-USER-ID': username,
                'Authorization': 'Bearer ' + jwt 
            }
        }).then((response) => {
            console.log(response.data);
            setWorkoutData(response.data);
            setLoading(false);
        }).catch((error) => {
            console.log(error);
            setLoading(false);
        });
    }, []);

    const handleBack = (e) => {
        navigate("/planner")
    }

    const handleModify = (e) => {
    //    upsert-workout
        navigate("/planner/upsert-workout/"+id)
    }

    const handleDelete = (e) => {
         axios.delete(Constants.API_URL_PREFIX+'/planner/workout/'+id, {
            headers: { 
                'X-USER-ID': username,
                'Authorization': 'Bearer ' + jwt 
            }
        }).then((response) => {
            console.log(response.data);
        }).catch((error) => {
            console.log(error);
        });
        navigate("/planner")
    }

    return (
        <div className="workout-container">
            <div className="action-header">
                <label className="workout-title">Workout</label>
                <div className="action-group">
                    <button className="btn btn-back" onClick={handleBack}>Back</button>
                    <button className="btn btn-modify" onClick={handleModify}>Modify</button>
                    <button className="btn btn-delete" onClick={handleDelete}>Delete</button>
                </div>
            </div>
            
            
            {loading ? (
                <></>
            ) : (
                <>
                    <div>
                        <label className="workout-date">Date: {workoutData.workoutDate}</label>      
                    </div>

                    <div className="exercises-grid">
                        {workoutData.exercises.map((exercise, index) => (
                            <div key={index} className="exercise-card">
                                <label className="exercise-name">{exercise.name}</label>
                                
                                <div className="sets-container">
                                    {exercise.exerciseSets.map((set) => (
                                    <div key={set.number} className="set-row">
                                        <span className="set-number">Set {set.number}</span>
                                        <div className="set-attributes">
                                            {set.reps && <span className="attribute">Reps: {set.reps}</span>}
                                            {set.duration && <span className="attribute">Duration: {set.duration}s</span>}
                                            {set.weight>0 && <span className="attribute">Weight: {set.weight}kg</span>}
                                            {set.variation && <span className="attribute">Variation: {set.variation}</span>}
                                        </div>
                                    </div>
                                    ))}
                                </div>
                            </div>
                        ))}
                    </div>
                </>
            )}  
        </div>
    );
}

export default ViewWorkout