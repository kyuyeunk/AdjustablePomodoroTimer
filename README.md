# Adjustable Pomodoro Timer
Pomodoro timer with ability change remaining time while timer is running

## Feature List
1. Able to start timer from positive and negative number
    1. Positive number denotes productive acitivity (e.g., Study) 
    2. Negative number denotes resting activity (e.g., web surfing)
2. Able to adjust time while timer is running
    1. Use case: extend your study session when you are on a roll
3. Integration with Toggl
    1. Able to input user's id and password
    2. Able to start tracking the user defined task when the timer starts
    3. Different user defined task for positive and negative mode
4. watchOS Support
    1. Has most feature sets of iOS counter part
    2. Able to sync user defined timers between iOS and watchOS
    3. Not Supported: active timer session is not sync between iOS and watchOS

## Build

This project does not require any external libraries  
Open PomodoroTimer.xcodeproj with Xcode to build the project  
(Tested with Xcode 11)

## Usage

![Initial Screen](Images/StartScreen.jpeg)

* Tap **Start** button to start the time
* Upper numbers denote default positive and negative times
    * When a timer ends, timer will be automatically set to the shown values
    * If the ended timer was positive timer, timer will set to negative default time
* Middle left and right numbers denote passed positive and negative times
    * Used to track how many times have been spent doing positive and negative activities
    * Will reset to *0m 0* and *0m 0* when **Start** button is tapped
* Circular pie or use time picker can be used to adjust timer
    * Adjusting remaining time can be done before or after **Start** button has been tapped
    * Red pie denotes positive timer and blue pie denotes negative timer
    * Switch between red and blue pie by dragging circular pie pass the *0m 0s* mark
* Number on top of circular clock denotes maximum time
    * Timer can not be set beyond this value
    * Maximum time can be adjusted by tapping **Timers** button on upper right

## Notes

As the app is not available in App Store, developer profile and build of the is required
App was tested with iPhone 11 Pro. UI might not scale correctly with phones of different size

