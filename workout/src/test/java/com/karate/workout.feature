Feature: workout end points

Background:
Given url (karate.properties['myAppUrl'])
* def workout = { "id": "69b988fa6241f478bf7c291f" }


Scenario: get all workouts, positive flow
Given path 'planner/workout'
When method GET
Then status 200


Scenario: get workout by date range, positive flow
Given path 'planner/workout'
And params { startDate: '2026-03-01', endDate: '2026-03-31' }
When method GET
Then status 200


Scenario Outline: get workout by date range, validation failed
Given path 'planner/workout'
And params { startDate: <starteDate>, endDate: <endDate> }
When method GET
Then status <status>

Examples:
    | index    | test case       | starteDate   | endDate       | status  |
    | 1        | null startDate  | null         | '2026-03-31'  | 400     |
    | 2        | empty startDate | ''           | '2026-03-31'  | 400     |
    | 3        | null endDate    | '2026-03-01' | null          | 400     |
    | 4        | empty endDate   | '2026-03-01' | ''            | 400     |


Scenario: create workout, modify and delete positive flow
Given path 'planner/workout'
And params {workout: '{"workoutDate":"2099-01-01","exercises":[{"name":"Squats","exerciseSets":[{"number":1,"reps":4,"weight":12},{"number":2,"reps":4,"weight":12},{"number":3,"reps":4,"weight":12}]}]}'}
When method POST
Then status 200
* def workoutId = response.id

Given path 'planner/workout/' + workoutId
And params {workout: '{"workoutDate":"2099-01-01","exercises":[{"name":"Squats","exerciseSets":[{"number":1,"reps":3,"weight":12},{"number":2,"reps":3,"weight":12},{"number":3,"reps":3,"weight":12}]}]}'}
When method PUT
Then status 200

Given path 'planner/workout/' + workoutId
When method DELETE
Then status 200


Scenario Outline: create workout, validation failed
Given path 'planner/workout'
And params {workout: <workout>}
When method POST
Then status <status>

Examples:
    | index    | test case       | starteDate   | status  |
    | 1        | null workout    | null         | 400     |
    | 2        | empty workout   | ''           | 400     |


Scenario: modify workout, validation fail
Given path 'planner/workout'
And params {workout: '{"workoutDate":"2099-01-01","exercises":[{"name":"Squats","exerciseSets":[{"number":1,"reps":3,"weight":12},{"number":2,"reps":3,"weight":12},{"number":3,"reps":3,"weight":12}]}]}'}
When method PUT
Then status 405


Scenario: delete workout, validation fail
Given path 'planner/workout'
When method PUT
Then status 405


Scenario: invalid endpoint
Given path 'planner'
When method GET
Then status 404

