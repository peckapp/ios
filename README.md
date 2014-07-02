# Peck iOS Application

This file provides basic documentation on the design of the app.

## Feature Design

### Homepage
The homepage shows all items that the user has specifically expressed interest in, including through department subscriptions, attendence indications, or through being invited to an event. 

### Pecks
The Pecks dropdown shows all notifications relating directly to the user, including invitations to events, announcements to them, comments on their circles and events, and more. The position of each of these items will be specified by the server, the app simply reads in the content from the explore API and handles the display formatting correctly.

### Explore
The Explore dropdown displays content that the user has not shown direct interest in, but might find interesting. The current possible content types are events and announcements.

### Post
The Post dropdown allows users to both create events and create announcements. Events can be either public or private and are sent out via invitations to circles or specific users. They include information on the event itself such as the title, description, time, and place. Announcements are always public, and include a text portion and optional photos. Each announcement has an option to specify circles or individuals that are notified of the announcement's creation.

### Circles
The Circles dropdown displays groups of friends that the user has created or been invited to. Each tableviewcell represents a circle, and displays a title and a custom scrollview that shows all of the circle members. Tapping on the title of a circle cell opens up a viewcontroller for that circle which shows comments on the circle and options for editing the circle

### Profile
The Profile dropdown includes all the configuration options for the user. In addition to customizations of their personal information, users can further specify their subscriptions and change any other settings that we make available to them.

### Other

#### Media types
- Events
 - Events can be either automatically created by our scraping backend system, or user-created events from the Post dropdown.
 - Scraped events are all public and are related to a specific subscription based on where it was scraped from. User-created events can be either public or private.
 - Public user-created events can show up on the Explore tab of other users, while private events to not. User-created events can have specified invitations based on circles or individuals.
- Announcements
 - Announcements are always public, and are intended to send information out to all of campus.
 - They can contain text and photos.
 - Announcements can have notified parties specificed who will recieve a "peck" push notification when the announcement is posted to the server.
- Dining Options
 - Dining options are a default subscription that appears in the homepage. Each meal appears as an "event" and upon selection opens up a new window that displays the locations available for that meal.
- Comments
 - Every item in Peck can have comments posted on them, including events, announcements, dining options, and circles.
 - Comments are very lightweight and relate only to the item on which they were created.


## User Interface Design
The app is based around a central screen and interface called a dropdownViewController. The view controller is a non-standard interface utilizing the concepts and come implementation techniques from the TabBar interface, modal view presentation, and containers.

The dropdownViewController is based around a primary view that contains the most important functionality of the app. In our implementation, this is where the user sees an overview of their day, with menus and specific events available for them to view immediately. This is the main interface for interaction with the app. Contained in this view is a sliding selection bar along the top of the inset screen that allows users to choose the day for which they are viewing the events.

Along the very top of the screen, just below the status bar, sits the dropdownBar, which is where users can select alternate views to dropdown temporarily to perform secondary tasks. By the visual nature of the view presentation, it is clear that these views are secondary to the primary view that sits underneath. They are intended to perform momentary tasks.

Our dropdown views are Pecks, for notifications; feed, for general college news; add, to create your own events and content; circles, for groups of friends; and profile, to customize your information, subscriptions, and settings. Each of these is described in the section above.

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
