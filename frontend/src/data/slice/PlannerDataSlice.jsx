import { createSlice } from '@reduxjs/toolkit';

const PlannerDataInitialState = {
    username: '',
    jwt: '',
    year: 2026,
    month: 4
};

export const PlannerDataSlice = createSlice({
    name: 'plannerData',
    initialState: PlannerDataInitialState,
    reducers: {
        setUserInfo: (state, action) => ({
            ...state,
            username: action.payload.username,
            jwt: action.payload.jwt
        }),
        setYearMonth: (state, action) => ({
            ...state,
            year: action.payload.year,
            month: action.payload.month
        }),
    }
});

export const { setUserInfo, setYearMonth } = PlannerDataSlice.actions;