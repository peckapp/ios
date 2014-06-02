# Peck iOS Application

This file provides basic documentation on the design of the app itself.

## User Interface Design
Two basic storyboards provide the layout of the app. One handles the initial login and configuration process, and the other handles the main app functionality.
The login process begins with the school selection and the user specifying if they are registering a new account or logging in from a previous session.

## Data Storage and Retreival
The app will use Core Data to store the most recent events that are relevant to the user. Upon opening the app, the last data retrieved from the server will appear in the UI.
At the same time, an asynchronous request will be sent to the server to retrieve the latest data. Once this request has been fulfilled, the data will be parsed, added to the core data model, and the visible user interface will be dynamically updated to display the new information to the user.
This will eliminate the loading screens and wait times present in the older versions of the app.
