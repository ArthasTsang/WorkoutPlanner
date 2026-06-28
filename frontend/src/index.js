import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.jsx'
import { Provider } from 'react-redux';
import { configureStore } from "@reduxjs/toolkit";
import { AuthProvider } from "react-oidc-context";
import { BrowserRouter } from 'react-router-dom';
import { PlannerDataSlice } from './data/slice/PlannerDataSlice.jsx';

const store = configureStore({
    reducer: {
        plannerData: PlannerDataSlice.reducer, // plannerDataSlice.reducer
    },
});

const cognitoAuthConfig = {
    // authority: "https://cognito-idp.ap-east-1.amazonaws.com/ap-east-1_RPxKSqxJH",
    // client_id: "7tiseli3uu2ka2a26ossa2rd63",
    authority: process.env.REACT_APP_COGNITO_AUTHORITY,
    client_id: process.env.REACT_APP_COGNITO_CLIENT_ID,
    redirect_uri: window.location.origin,
    response_type: "code",
    scope: "email openid profile"
};

createRoot(document.getElementById('root')).render(
    <StrictMode>
        <BrowserRouter>
            <AuthProvider {...cognitoAuthConfig}>
                <Provider store={store}>
                    <App />
                </Provider>
            </AuthProvider>
        </BrowserRouter>
    </StrictMode>
)