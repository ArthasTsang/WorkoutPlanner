import React, { useState } from 'react';
import { useAuth } from "react-oidc-context";
import axios from 'axios';
import { jwtDecode } from 'jwt-decode'; 
import { useNavigate } from 'react-router-dom';
import { useSelector, useDispatch } from 'react-redux';
import { setUserInfo, setYearMonth } from '../data/slice/PlannerDataSlice';
import * as Constants from '../Constants';

const Login = () => {
    const auth = useAuth();
    const navigate = useNavigate();
    const dispatch = useDispatch();
    const [errorMessage, setErrorMessage] = useState('');
    const [formData, setFormData] = useState({ username: '', password: '' });

    const signOutRedirect = () => {
        const clientId = Constants.COGNITO_CLIENT_ID;
        const logoutUri = window.location.origin;
        const cognitoDomain = Constants.COGNITO_DOMAIN;
        window.location.href = `${cognitoDomain}/logout?client_id=${clientId}&logout_uri=${encodeURIComponent(logoutUri)}`;
    };

    if (auth.isLoading) {
        return <div>Loading...</div>;
    }

    if (auth.error) {
        return <div>Encountering error... {auth.error.message}</div>;
    }

    if (auth.isAuthenticated) {
        const username= auth.user?.profile.email;
        const jwt = auth.user?.id_token;
        console.log("Logged in successfully");
        // console.log(response.data);
        console.log("Username: "+username);
        console.log("Jwt: "+jwt);
        dispatch(setUserInfo({"username": username, "jwt": jwt}));
        dispatch(setYearMonth({"year": new Date().getFullYear(), "month": new Date().getMonth()+1}));
        navigate('/planner');

        // return (
        //     <div>
        //         <pre> Hello: {auth.user?.profile.email} </pre>
        //         <pre> ID Token: {auth.user?.id_token} </pre>
        //         <pre> Access Token: {auth.user?.access_token} </pre>
        //         <pre> Refresh Token: {auth.user?.refresh_token} </pre>

        //         <button onClick={() => auth.removeUser()}>Sign out</button>
        //     </div>
        // );
    }

    // Cognito generated code
    // return (
    //     <div>
    //         <button onClick={() => auth.signinRedirect()}>Sign in</button>
    //         <button onClick={() => signOutRedirect()}>Sign out</button>
    //     </div>
    // );


    // const handleChange = (e) => {
    //     setFormData({ ...formData, [e.target.name]: e.target.value });
    // };

    // const handleSubmit = (e) => {
    //     e.preventDefault();

    //     const bodyFormData = new FormData();
    //     bodyFormData.append('authType', "password");
    //     bodyFormData.append('username', formData.username);
    //     bodyFormData.append('password', formData.password);

    //     axios.post(Constants.API_URL_PREFIX+'/planner/auth', bodyFormData)
    //         .then((response) => {
    //             console.log("Logged in successfully");
    //             console.log(response.data);
    //             console.log("Username: "+response.data.username);
    //             console.log("Jwt: "+response.data.jwt);
    //             dispatch(setUserInfo({"username": response.data.username, "jwt": response.data.jwt}));
    //             dispatch(setYearMonth({"year": new Date().getFullYear(), "month": new Date().getMonth()+1}));
    //             navigate('/planner');
    //         })
    //         .catch(error => {
    //             console.log("Login failed: " + error);
    //             setErrorMessage("Invalid username or password");
    //         });
    // };

    // const handleSuccessResponse = (googleResponse) => {
    //     console.log(googleResponse);
    //     console.log("Access token: " + googleResponse.credential);
    //     // setProfile(jwtDecode(googleResponse.credential));

    //     const bodyFormData = new FormData();
    //     bodyFormData.append('authType', "google");
    //     bodyFormData.append('token', googleResponse.credential);

    //     axios.post(Constants.API_URL_PREFIX+'/planner/auth', bodyFormData)
    //         .then((response) => {
    //             console.log("Logged in successfully");
    //             console.log(response.data);
    //             console.log("Username: "+response.data.username);
    //             console.log("Jwt: "+response.data.jwt);
    //             dispatch(setUserInfo({"username": response.data.username, "jwt": response.data.jwt}));
    //             dispatch(setYearMonth({"year": new Date().getFullYear(), "month": new Date().getMonth() + 1}));
    //             navigate('/planner');
    //         })
    //         .catch(error => {
    //             console.log("Login failed: " + error);
    //             setErrorMessage("Invalid username or password");
    //         });
    // };

    // const handleErrorResponse = (error) => {
    //     console.log("Login failed: " + error);
    // };

    // Inline styles for quick implementation
    const styles = {
        container: {
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            alignItems: 'center',
            height: '100vh',
            fontFamily: 'Calibri, sans-serif',
            fontSize: 'clamp(16px, 2vw, 20px)'
        },
        formBox: {
            border: '2px solid #333',
            padding: '2rem',
            borderRadius: '8px',
            width: '300px',
            textAlign: 'center',
            backgroundColor: '#f9f9f9',
            fontFamily: 'Calibri, sans-serif',
            fontSize: 'clamp(12px, 2vw, 18px)'
        },
        inputGroup: {
            marginBottom: '1rem',
            textAlign: 'left'
        },
        input: {
            width: '100%',
            padding: '8px',
            marginTop: '5px',
            boxSizing: 'border-box',
            fontFamily: 'Calibri, sans-serif',
            fontSize: 'clamp(12px, 2vw, 18px)'
        },
        button: {
            width: '100%',
            padding: '10px',
            backgroundColor: '#007bff',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer',
            fontFamily: 'Calibri, sans-serif',
            fontSize: 'clamp(12px, 2vw, 18px)',
            fontWeight: 'bold'
        }
    };

    return (
        <div style={styles.container}>
            <div style={styles.formBox}>
                {/* <form onSubmit={handleSubmit}>
                    <h2>Workout Planner</h2>
                    
                    <div style={styles.inputGroup}>
                        <label>Username</label>
                        <input 
                            type="text" 
                            name="username" 
                            style={styles.input} 
                            onChange={handleChange} 
                            required 
                        />
                    </div>

                    <div style={styles.inputGroup}>
                        <label>Password</label>
                        <input 
                            type="password" 
                            name="password" 
                            style={styles.input} 
                            onChange={handleChange} 
                            required 
                        />
                    </div>

                    <div style={styles.inputGroup}>
                        <button type="submit" style={styles.button}>Login</button>
                    </div>

                    {errorMessage != '' &&
                    (<div style={styles.inputGroup}>
                        <label>{errorMessage}</label>
                    </div>)}
                </form> */}

                {/* <div style={styles.inputGroup}>
                    <GoogleLogin onSuccess={handleSuccessResponse} onError={handleErrorResponse}  />
                </div> */}
                <h2>Workout Planner</h2>

                <div style={styles.inputGroup}>
                    <button style={styles.button} onClick={() => auth.signinRedirect()}>Sign in</button>
                    {/* <button style={styles.button} onClick={() => signOutRedirect()}>Sign out</button> */}
                </div>
            </div>
        </div>
    );
};

export default Login;