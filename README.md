# Peck iOS Application

This file provides basic documentation on the design of the app.

## User Interface Design
The app is based around a central screen and interface called a dropdownViewController. The view controller is a non-standard interface utilizing the concepts and come implementation techniques from the TabBar interface, modal view presentation, and containers.

The dropdownViewController is based around a primary view that contains the most important functionality of the app. In our implementation, this is wher ethe user sees an overview of their day, with menus and specific events available for them to view immediately. This is the main interface for interaction with the app. Contained in this view is a sliding selection bar along the top of the inset screen that allows users to choose the day for which they are viewing the events.

Along the very top of the screen, just below the status bar, sits the dropdownBar, which is where users can select alternate views to dropdown temporarily to perform secondary tasks. By the visual nature of the view presentation, it is clear that these views are secondary to the primary view that sits underneath. They are intended to perform momentary tasks.

Our dropdown views are Pecks, for notifications; feed, for general college news; add, to create your own events and content; circles, for groups of friends; and profile, to customize your information, subscriptions, and settings.

## Third Party Code
- AFNetworking
- Facebook API
- Twitter API
 - still needs to be added
- Crashlytics
- HTAutoCompleteTextField

## Data Storage and Retreival
The app will use Core Data to store the most recent events that are relevant to the user. Upon opening the app, the last data retrieved from the server will appear in the UI.
At the same time, an asynchronous request will be sent to the server to retrieve the latest data. Once this request has been fulfilled, the data will be parsed, added to the core data model, and the visible user interface will be dynamically updated to display the new information to the user.
This will eliminate the loading screens and wait times present in the older versions of the app.

### 1st time download
- configure screen
 - setup API token
 - config files
- public data loaded in background threads
 - home tab loaded in as 1st priority
 - explore tab loaded in as 2nd priority
- private triggers, which lead to request for account creation
 - circles tab
 - commenting on anything
 - adding event/message
 - accessing profile

### Normal Operation
#### Homepage
- startup
 - server delivers all text-based information for current day
 - explore initial data loads in secondary background thread
- runtime sync points
 - when day is changed, manager checks that previous 2 days and next 4 days are loaded, and fetched them if necessary
 - user adds event: (1) send event back to server (2) server sends back confirmation and incremental update (3) app dismisses add page and displays the event in home screen

#### Explore
- loaded already in startup
- on scroll, predictively load in more information from manager
- if there is no more local information, manager goes to the server to request it

#### Push Notifications

push notifications will require the app to request an incremental update from the server

- create circle
- added to circle
- Pecks
