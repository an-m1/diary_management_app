
# diary_management_app

A new Flutter project.

## Getting Started

Open the application on Windows, macOS, iOS, Android, and even on your preferred browser. This is a classic note-taking application, where you can:

- Write notes.
- Favourite certain notes.
- Search notes by title or body content.
- Edit notes.
- Delete notes.
- View recent notes on the home page.
- View all notes categorized as "Favourites" and "All Notes".
- Seamlessly add new notes using a floating action button.

## Features

1. **Add Notes**:
   - Use the floating action button in the bottom-right corner to add a new note.
   - Each note contains:
     - A title.
     - A body.
     - Creation date.
     - Last modified date.

2. **Edit Notes**:
   - Modify any existing note's title or body.
   - The last modified date updates automatically.

3. **Delete Notes**:
   - Remove any note permanently from the list.

4. **Favourite Notes**:
   - Mark notes as favourites by tapping the heart icon.
   - Favourited notes are displayed under the "Your Favourites" section in the "All Notes" tab.

5. **Search Notes**:
   - Search for notes in the "All Notes" tab using the search bar.
   - Filter notes by keywords in the title or body.

6. **Home Page**:
   - Displays up to 4 of your most recent notes under the "Your Recent Notes" heading.
   - If there are no notes, the app displays a message: "There are no notes to display."

7. **All Notes Page**:
   - Categorizes notes into:
     - "Your Favourites" for favourited notes.
     - "All Notes" for the rest.
   - If no notes exist, a message appears: "There are no notes to display."

8. **Cross-Platform Compatibility**:
   - Run seamlessly on Windows, macOS, Android, iOS, and browsers.

## Usage

- **Adding Notes**:
  Tap the circular button with the "+" icon in the bottom-right corner to create a new note.
- **Favouriting Notes**:
  Tap the heart icon next to a note to favourite it. Tap again to remove it from favourites.
- **Searching**:
  Use the search bar in the "All Notes" tab to find notes by keywords.
- **Editing or Deleting Notes**:
  Use the pencil icon to edit a note or the trash can icon to delete it.

## Future Improvements

- Support for adding tags or categories to notes.
- Integration with cloud storage for syncing across devices. Possibly with the use of Google Firebase's cloud storage.
- Dark mode support for better accessibility.

## How to Run

1. Clone the repository to your local machine.
2. Ensure Flutter SDK is installed.
3. Run `flutter pub get` to fetch dependencies.
4. Use `flutter run` to start the app on your preferred device or emulator.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
