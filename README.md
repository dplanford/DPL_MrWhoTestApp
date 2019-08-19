# DPL_MrWhoTestApp
A iOS app built as a coding test for MrWho.com, coded in Swift 5.1

The coding problem:

Build an application (Android or iOS) using The Movie Database (TMDB) API (https://www.themoviedb.org/documentation/api). This will be a very simple app having only two screens.

The Home screen:
Display a grid of “Popular movies” upon launching the app.

-- Please include at least the movie image and title

Please add a text field so that the user can enter a maximum “vote_average” for the movies. Once the maximum vote average is entered, please only display the movies with a “vote_average” greater the inputted number.
The Movie screen:
On tapping any movie on the Home screen, display the Movie screen that shows the detailed information about the movie.
Put the app into GitHub and share the repository link with hr@mrowl.com

NOTE: To fetch popular movies from TMDB, you will use the API from themoviedb.org. If you don’t already have an account, you will need to create one in order to request an API Key. You will use this API key to request the popular and top-rated movies data.

# My Solution
I Built the two screens as requested. I didn't spend a lot of time on polishing the UI for the app... just mainly got it working. The test app runs in portrait orientation only.

On the main movie list screen, I added a couple of extras. First, I added a picker that allows the user to choose among 4 movie lists (popular, now playing, etc.). Second, I added a slider that ties in to the vote-average text field. You can either type in a value, or use the slider to set the value.

# If I Had More Time
- Think about unit tests, at least for the TMDBManager class.
- The ability to go through multiple pages of movies (this test app just displays the first page received)
- The ability to sort the movie list by various criteria (vote-average, release-date, etc., a toggle for asending/decending)
- UI polishing.
- Landscape layout and orientation handling.
- Figure out TMDb search, and add a searchbar.
- Pre-load the images for a movie list, and possibly keep a larger cache of images (the last 100?) that is not cleared on each movie list load.
