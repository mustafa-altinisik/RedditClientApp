![RedditClientApp](https://user-images.githubusercontent.com/8038008/222704806-b960135f-6a31-4528-aaea-807b812c8d1b.gif)

This project is an Reddit app written in swift. I developed this app as a part of my internship in Innova.

Project includes two screens: Home Screen and Posts Screen:
Home screen has the following UI elements:

- A search bar to search for subreddits
- A toggle button to set "Safe Search" preference
- A collection view to show trending posts
- A stack view to show pre-defined subreddit categories
- A table view to show favorite subreddits previously marked by the user

The view controller communicates with the Reddit API to fetch the posts for the searched subreddit or the trending subreddits. The fetched data is used to populate the trending posts collection view and the posts table view.

The code also uses several structs to decode the JSON response from the Reddit API. It has implemented the Codable protocol to convert the JSON data to Swift structs.

The code has defined RedditPost struct to store the information about a single post. It also has defined the toRedditPost() function to convert the data from the API call to RedditPost struct.

The code has several IBAction functions to handle user actions, such as when the user changes the safe search switch, taps on the search button or the trending button, and when the user taps on one of the category buttons.

Posts screen has the following UI elements:

- A button to mark the subreddit as favorite
- A table view to show the posts for the subreddit

The view controller gets an array of RedditPost objects from the previous screen and populates the table view with these posts. The RedditPost object has properties like title, description, imageURL, and permalink, which are displayed in the table view cell. The imageURL property is used to download the post image asynchronously and display it in the table view cell.

The view controller also maintains an array of favorite subreddits using UserDefaults, which is updated when the user taps the favorite button. The favorite subreddits are passed back to the previous screen when the user navigates back.

The view controller also has a list of predefined categories to exclude from the favorite subreddits, and it hides the favorite button for these categories.

Overall, this screen provides a basic implementation of displaying posts from a subreddit and allowing the user to mark subreddits as favorites.

Current problems with the project:

1. You cannot make a search for a subreddit that has a space in its name. RedditAPI should be reviewed in detail to fix this problem.
2. Trending posts might not be displayed when the app is launched for the first time. It should be fixed in the future.
