import React, { useState, useEffect } from 'react';
import { useAuth } from "react-oidc-context";
import axios from 'axios';
import { jwtDecode } from 'jwt-decode'; 
import { useNavigate } from 'react-router-dom';
import { useSelector, useDispatch } from 'react-redux';
import { setUserInfo, setYearMonth } from '../data/slice/PlannerDataSlice';
import * as Constants from '../Constants';

const Login = () => {
    const [isOnline, setIsOnline] = useState(false);
    const auth = useAuth();
    const navigate = useNavigate();
    const dispatch = useDispatch();
    const [errorMessage, setErrorMessage] = useState('');
    const [formData, setFormData] = useState({ username: '', password: '' });

    useEffect(() => {
         const checkTime = () => {
            // Get current time in Hong Kong timezone
            const hkTimeStr = new Date().toLocaleString("en-US", { timeZone: "Asia/Hong_Kong" });
            const hkDate = new Date(hkTimeStr);
            const hours = hkDate.getHours();

            // Check if hours are between 08:00 and 19:59
            setIsOnline(hours >= 8 && hours < 20);
        };
        checkTime();
        const interval = setInterval(checkTime, 60000); // Re-check every minute

        return () => clearInterval(interval);
    }, []);

    // const signOutRedirect = () => {
    //     const clientId = Constants.COGNITO_CLIENT_ID;
    //     const logoutUri = window.location.origin;
    //     const cognitoDomain = Constants.COGNITO_DOMAIN;
    //     window.location.href = `${cognitoDomain}/logout?client_id=${clientId}&logout_uri=${encodeURIComponent(logoutUri)}`;
    // };

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
    }

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
        },
        card: {
            backgroundColor: '#fff',
            padding: '40px',
            borderRadius: '12px',
            boxShadow: '0 4px 12px rgba(0, 0, 0, 0.08)',
            maxWidth: '480px',
        },
        icon: {
            fontSize: '48px',
            marginBottom: '20px',
        },
        h1: {
            fontSize: '24px',
            fontWeight: 600,
            marginBottom: '16px',
            color: '#222',
            marginTop: 0,
        },
        p: {
            fontSize: '16px',
            lineHeight: 1.6,
            color: '#555',
            margin: 0,
        }
    };

    return (
        <div style={styles.container}>
            <div style={styles.formBox}>
                <h2>Workout Planner</h2>

                {!isOnline &&
                    <div class="{styles.card}">
                        {/* <div class="{styles.icon}">🛠️</div> */}
                        <p>The website is online during office hour (08:00-20:00) in Hong Kong only.</p>
                    </div>
                }

                <div style={styles.inputGroup}>
                    <button style={styles.button} onClick={() => auth.signinRedirect()}>Sign in</button>
                    {/* <button style={styles.button} onClick={() => signOutRedirect()}>Sign out</button> */}
                </div>
            </div>
        </div>
    );
};

export default Login;