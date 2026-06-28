import axios, { all } from 'axios';
import { useState, useEffect } from 'react'
import { useParams, useNavigate, useSearchParams } from 'react-router-dom';
import { useSelector } from 'react-redux';
import { Plus, Trash2, Save } from 'lucide-react';
import * as Constants from '../Constants';

const UpsertWorkout = () => {
    const navigate = useNavigate();
    const username = useSelector((store) => store.plannerData.username);
    const jwt = useSelector((store) => store.plannerData.jwt);
    const { id } = useParams();
    const [searchParams, setSearchParams] = useSearchParams();
    const searchParamDate = searchParams.get('date');
    // searchParams.delete('date');
    // setSearchParams(searchParams);

    const [exercises, setExercises] = useState([]);
    const [availableExercises, setAvailableExercises] = useState([]);
    const [newExerciseName, setNewExerciseName] = useState("");
    const [workout, setWorkout] = useState({
        "workoutDate": id? new Date().toISOString().split('T')[0]: searchParamDate,
        "exercises": []
    });
    // const [loadingExercises, setLoadingExercises] = useState(false);
    // const [loadingWorkout, setLoadingWorkout] = useState(false);  
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        setLoading(true);

        const exercisesPromise = axios.get(Constants.API_URL_PREFIX + '/planner/workout/exercise', {
            headers: { 'Authorization': 'Bearer ' + jwt }
        });

        // Create a conditional promise for the workout (or a dummy resolved one if no ID)
        const workoutPromise = id 
            ? axios.get(Constants.API_URL_PREFIX + '/planner/workout/' + id, { headers: { 'X-USER-ID': username, 'Authorization': 'Bearer ' + jwt } })
            : Promise.resolve(null);

        Promise.all([exercisesPromise, workoutPromise])
        .then(([exerciseResponse, workoutResponse]) => {
            console.log("Loaded exercises");
            console.log(exerciseResponse.data);

            const loadedExercises = exerciseResponse.data;
            let loadedAvailableExercises = [...loadedExercises];
            setExercises(loadedExercises); 
            
            if(workoutResponse){
                console.log("Loaded workout");
                console.log(workoutResponse.data);
                const loadedWorkout = workoutResponse.data;
                // intialize ids
                for(let i = 0; i < loadedWorkout.exercises.length; i++){
                    loadedWorkout.exercises[i].id = i;
                    for(let j = 0; j < loadedWorkout.exercises[i].exerciseSets.length; j++){
                        loadedWorkout.exercises[i].exerciseSets[j].id = j;
                    }
                }
                setWorkout(loadedWorkout);
                let loadedExerciseNames = loadedWorkout.exercises.map(ex => ex.name);
                loadedAvailableExercises = loadedAvailableExercises.filter(ex => !loadedExerciseNames.includes(ex.name))
            }

            loadedAvailableExercises= [...loadedAvailableExercises].sort((a, b) => (a.name.localeCompare(b.name)));
            setAvailableExercises(loadedAvailableExercises);
            setNewExerciseName(loadedAvailableExercises.length > 0 ? loadedAvailableExercises[0].name : "");
        }).catch((error) => {
            console.log(error);
        }).finally(() => {
            setLoading(false);
        });
    }, []);

    /*
    useEffect(() => {
        setLoadingExercises(true);
        let loadedExercises = [];
        axios.get(Constants.API_URL_PREFIX+'/planner/workout/exercise', {
            headers: { 'Authorization': 'Bearer ' + jwt }
        }).then((response) => {
            console.log("Loaded exercises");
            console.log(response.data);
            loadedExercises = response.data;
            loadedExercises= [...loadedExercises].sort((a, b) => (a.name.localeCompare(b.name)));
            setExercises(loadedExercises); 
            setAvailableExercises(loadedExercises);
            setNewExerciseName(loadedExercises.length > 0 ? loadedExercises[0].name : "");
            setLoadingExercises(false);
        }).catch((error) => {
            console.log(error);
            setLoadingExercises(false);
        });

        if(id){
            console.log("Loading workout");
            setLoadingWorkout(true);
            axios.get(Constants.API_URL_PREFIX+'/planner/workout/'+id, {
                headers: { 'Authorization': 'Bearer ' + jwt }
            }).then((response) => {
                console.log(response.data);
                const loadedWorkout = response.data;
                // intialize ids
                for(let i = 0; i < loadedWorkout.exercises.length; i++){
                    loadedWorkout.exercises[i].id = i;
                    for(let j = 0; j < loadedWorkout.exercises[i].exerciseSets.length; j++){
                        loadedWorkout.exercises[i].exerciseSets[j].id = j;
                    }
                }
                setWorkout(loadedWorkout);
                let loadedExerciseNames = loadedWorkout.exercises.map(ex => ex.name);
                let loadedAvailableExercises = loadedExercises.filter(ex => !loadedExerciseNames.includes(ex.name))
                loadedAvailableExercises= [...loadedAvailableExercises].sort((a, b) => (a.name.localeCompare(b.name)));
                setAvailableExercises(loadedAvailableExercises);
                setNewExerciseName(loadedAvailableExercises.length > 0 ? loadedAvailableExercises[0].name : "");
                setLoadingWorkout(false);
            }).catch((error) => {
                console.log(error);
                setLoadingWorkout(false);
            });
        }
    },[])
    */

    const addExercise = () => {
        const matchedExercise = findExerciseByName(newExerciseName);
        const newSet= initializeSets(matchedExercise, 0);
        setWorkout({
            ...workout,
            exercises: [...workout.exercises, {
                "id": workout.exercises.length,
                "name": matchedExercise.name,
                "exerciseSets": [newSet]
            }]
        });
        const updatedAvailableExercises = availableExercises.filter(ex => ex.name !== newExerciseName);
        setAvailableExercises(updatedAvailableExercises);
        setNewExerciseName(updatedAvailableExercises.length > 0 ? updatedAvailableExercises[0].name : "");
    };

    const removeExercise = (exId, exName) => {
        const matchedExercise = findExerciseByName(exName);
        const newExercises = workout.exercises.filter(ex => ex.id !== exId);
        // reorder exercise ids
        for(let i = 0; i < newExercises.length; i++){
            newExercises[i].id = i;
        }
        setWorkout({ 
            ...workout, 
            "exercises": newExercises
        });
        const updatedAvailableExercises= [...availableExercises, matchedExercise].sort((a, b) => (a.name.localeCompare(b.name)));
        setAvailableExercises(updatedAvailableExercises);
        setNewExerciseName(updatedAvailableExercises.length > 0 ? updatedAvailableExercises[0].name : "");
    };

    const initializeSets = (ex, id) => {
        const newSet = {"id": id};
        ex.measurement==="reps" && (newSet.reps = 0);
        ex.measurement==="duration" && (newSet.duration = 0);
        newSet.weight= 0;
        ex.variations && (newSet.variation = ex.variations[0]);
        console.log(newSet);
        return newSet;
    }

    const addSet = (exId, exName) => {
        setWorkout({
            ...workout,
            "exercises": workout.exercises.map(ex => {
                if (ex.id === exId) {
                    const matchedExercise = findExerciseByName(exName);
                    const newSet= initializeSets(matchedExercise, ex.exerciseSets.length);
                    return {
                        ...ex,
                        "exerciseSets": [...ex.exerciseSets, newSet]
                    };
                }else{
                    return ex;
                } 
            })
        });
    };

    const updateSet = (exId, setId, field, value) => {
        setWorkout({
            ...workout,
            exercises: workout.exercises.map(ex => ex.id === exId ? {
                ...ex,
                exerciseSets: ex.exerciseSets.map(s => s.id === setId ? { ...s, [field]: value } : s)
            } : ex)
        });
    };

    const removeSet = (exId, setId) => {
        setWorkout({
            ...workout,
            "exercises": workout.exercises.map(ex => {
                if(ex.id === exId){
                    const newExerciseSets= ex.exerciseSets.filter(s => s.id !== setId)
                    // reorder exercise set ids
                    for(let i = 0; i < newExerciseSets.length; i++){
                        newExerciseSets[i].id = i;
                    }
                    return {
                        ...ex,
                        "exerciseSets": newExerciseSets
                    }
                }else{
                    return ex;
                }
            })
        });
    };

    const handleSubmit = () => {
        const submitWorkout = {
            ...workout,
            "exercises": workout.exercises.map(({ id, exerciseSets, ...exRest }) => ({
                ...exRest, // This includes 'name', etc., but excludes 'id'
                "exerciseSets": exerciseSets.map(({ id, ...setRest }) => ({
                    ...setRest // This includes 'reps', 'duration', etc., but excludes 'id'
                }))
            }))
        };
        id && (submitWorkout.id = id);
        console.log('Final Workout JSON:', JSON.stringify(submitWorkout, null, 2));

        const bodyFormData = new FormData();
        bodyFormData.append('workout', JSON.stringify(submitWorkout, null, 2));
        if(id){
            axios.put(Constants.API_URL_PREFIX+'/planner/workout/'+id, bodyFormData, {
                headers: { 
                    'X-USER-ID': username,
                    'Authorization': 'Bearer ' + jwt 
                }
            }).then((response) => {
                console.log("Modified existing workout");
                console.log(response.data);
                navigate("/planner/view-workout/"+id);
            }).catch((error) => {
                console.log(error);
            });
        }else{
            axios.post(Constants.API_URL_PREFIX+'/planner/workout', bodyFormData, {
                headers: { 
                    'X-USER-ID': username,
                    'Authorization': 'Bearer ' + jwt 
                }
            }).then((response) => {
                console.log("Created new workout");
                console.log(response.data);
                navigate("/planner");
            }).catch((error) => {
                console.log(error);
            });
        } 
    };

    const handleBack = (e) => {
        navigate("/planner")
    }

    const findExerciseByName= (name) => {
        return exercises.find(ex => ex.name === name);
    }
    
    const generateExercise = (ex) => {
        const matchedExercise = findExerciseByName(ex.name);
        console.log("Matched exercise: " + matchedExercise.name+", "+matchedExercise.measurement);
        
        return (
            <div key={ex.id} className="exercise-card">
                <div className="exercise-header">
                    <label>{ex.name}</label>
                    <button className="upsert-btn-delete" onClick={() => removeExercise(ex.id, ex.name)}>x</button>
                </div>
                
                <table className="sets-table">
                    <thead>
                    <tr>
                        <th style={{ width: '50px' }}>Set</th>
                        {matchedExercise.measurement === "reps" && <th>Reps</th>}
                        {matchedExercise.measurement === "duration" && <th>Duration</th>}
                        <th>Weight</th>
                        {matchedExercise.variations && <th>Variation</th>}
                        <th style={{ width: '40px' }}></th>
                    </tr>
                    </thead>
                    <tbody>
                        {ex.exerciseSets.map((set) => (
                            <tr key={set.id}>
                            <td>{set.id+1}</td>
                            {"reps" in set &&
                                <td>
                                    <input 
                                        className="input-field" 
                                        type="number" 
                                        value={set.reps} 
                                        onChange={(e) => updateSet(ex.id, set.id, 'reps', e.target.value)} 
                                    />
                                </td>
                            }
                            {"duration" in set &&
                                <td>
                                    <input 
                                        className="input-field" 
                                        type="text" 
                                        value={set.duration} 
                                        onChange={(e) => updateSet(ex.id, set.id, 'duration', e.target.value)} 
                                    />
                                </td>
                            }
                            <td>
                                <input 
                                    className="input-field" 
                                    type="number" 
                                    value={set.weight} 
                                    onChange={(e) => updateSet(ex.id, set.id, 'weight', e.target.value)} 
                                />
                            </td>
                            {"variation" in set && 
                                <td>
                                    <select 
                                        className="input-field" 
                                        value={set.variation} 
                                        onChange={(e) => updateSet(ex.id, set.id, 'variation', e.target.value)}>
                                            {matchedExercise.variations.map(v => <option key={v} value={v}>{v}</option>)}
                                    </select>
                                </td>
                            }
                            <td>
                                {ex.exerciseSets.length>1 &&
                                    <button 
                                        className="upsert-btn-delete" 
                                        onClick={(e) => removeSet(ex.id, set.id)}>
                                        ×
                                    </button>
                                }
                            </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
                <button className="btn-add-set" onClick={() => addSet(ex.id, ex.name)}>+ Add Set</button>
            </div>
        )
    }

    return (
        // loadingExercises || loadingWorkout
        (loading)? (
            <></>
        ) : (
            <div className="upsert-workout-container">
                <div className="upsert-workout-header">
                    <h1 className="upsert-workout-title">{id ? "Modify Workout" : "Create Workout"}</h1>
                    <label>{workout.workoutDate}</label>
                    <button className="btn-submit" onClick={handleSubmit}>Submit Workout</button>
                    <button className="btn btn-back" onClick={handleBack}>Back</button>
                </div>

                {workout.exercises.length >0 && 
                    workout.exercises.map((ex) => generateExercise(ex))
                }

                {availableExercises.length > 0 && (
                    <div>
                        <select 
                            className="input-field" 
                            value={newExerciseName} 
                            onChange={(e) => setNewExerciseName(e.target.value)}>
                                {availableExercises.map(v => <option key={v} value={v.name}>{v.name}</option>)}
                        </select>
                        <button className="btn-add-exercise" onClick={addExercise}>+ Add New Exercise</button>
                    </div>
                )}
            </div> 
        )
    )

};

export default UpsertWorkout;