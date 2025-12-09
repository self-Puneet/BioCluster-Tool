# BioCluster Tool - Reformed UI/UX

## Project Structure

The project has been completely reformed with a modern, clean architecture:

```
lib/
├── main.dart                          # Application entry point
├── app_theme.dart                     # Theme configuration with orange primary colors
├── models/                            # Data models
│   ├── sequence_model.dart           # Sequence data model
│   └── cluster_result.dart           # Cluster result model
├── services/                          # Business logic & API
│   ├── api_service.dart              # API communication
│   └── export_service.dart           # File export functionality
├── screens/                           # Main application screens
│   ├── home_screen.dart              # Landing page with file upload/manual entry
│   ├── sequence_editor_screen.dart   # Sequence input and validation
│   └── analysis_screen.dart          # Clustering and results display
├── widgets/                           # Reusable UI components
│   ├── custom_app_bar.dart           # Branded app bar
│   ├── custom_buttons.dart           # Primary, secondary, text buttons
│   ├── custom_card.dart              # Card components
│   ├── file_upload_widget.dart       # File upload UI
│   └── loading_overlay.dart          # Loading states
└── utils/                             # Utilities
    ├── constants.dart                # App-wide constants
    └── validators.dart               # Sequence validation logic
```

## New Features

### 1. **Modern Home Screen**
   - Clean landing page with hero section
   - File upload area with drag-and-drop styling
   - Manual entry option
   - Feature showcase cards
   - Smooth animations

### 2. **Intuitive Sequence Editor**
   - Add/remove sequences dynamically
   - Real-time validation with visual feedback
   - Auto-detection of sequence type (nucleotide/protein)
   - Clear error messages
   - Numbered sequence cards

### 3. **Enhanced Analysis Screen**
   - Statistics cards showing total sequences and cluster count
   - Adjustable cluster count with real-time updates
   - Color-coded cluster cards
   - Expandable/collapsible cluster details
   - Export functionality with multiple formats

### 4. **Export Options**
   - **TXT**: Plain text format with clear structure
   - **CSV**: Comma-separated values for spreadsheets
   - **JSON**: Structured data with metadata
   - **Excel**: Professional spreadsheet with multiple sheets

## User Flow

1. **Home Screen** → Upload FASTA file OR enter sequences manually
2. **Sequence Editor** → Review, edit, add/remove sequences
3. **Analysis Screen** → View clustering results, adjust cluster count, export data

## Theme

- **Primary Color**: Orange (#FB8705) - Energy and innovation
- **Secondary Color**: Blue (#1565C0) - Balance and trust
- **Typography**: Google Fonts with clear hierarchy
- **Design**: Material Design 3 with modern card-based layout

## Dependencies Added

```yaml
google_fonts: ^6.2.1      # Beautiful typography
animate_do: ^3.3.4        # Smooth animations
dotted_border: ^2.1.0     # Dashed borders for upload area
excel: ^4.0.6             # Excel file generation
csv: ^6.0.0               # CSV file generation
provider: ^6.1.2          # State management (for future use)
```

## Running the Application

1. Install dependencies:
   ```
   flutter pub get
   ```

2. Run the application:
   ```
   flutter run -d chrome
   ```

## Key Improvements

- ✅ Clean, modern UI with consistent design language
- ✅ Improved user flow with clear navigation
- ✅ Real-time validation and feedback
- ✅ Multiple export formats (TXT, CSV, JSON, Excel)
- ✅ Responsive design with max content width
- ✅ Smooth animations and transitions
- ✅ Better error handling and user messages
- ✅ Organized code structure with separation of concerns
- ✅ Reusable widgets for maintainability
- ✅ Support for both FASTA and simple formats
- ✅ Auto-detection of sequence types

## Old Files (Can be safely removed)

- `lib/cluster_page.dart`
- `lib/component.dart`
- `lib/popup.dart`
- `lib/typewritter.dart`
- `lib/venv.dart` (replaced by constants.dart)
- `lib/main_new.dart` (duplicate, already merged into main.dart)
