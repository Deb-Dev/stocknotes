---
name: Stock Notes MVP Implementation
overview: Build a fully functional stock notes iOS app with note creation, symbol management, tagging, search, and image attachments. Using SwiftData for persistence, Yahoo Finance API for stock data, and implementing all core features step-by-step.
todos:
  - id: step1_models
    content: Create SwiftData models (Note, Symbol, Tag) and configure model container
    status: completed
  - id: step2_services
    content: Implement core services (NoteService, SymbolService, TagService, YahooFinanceService)
    status: completed
    dependencies:
      - step1_models
  - id: step3_home
    content: Build home screen dashboard with stats and recent notes feed
    status: completed
    dependencies:
      - step2_services
  - id: step4_notes
    content: Implement note creation/editing with rich text editor and symbol autocomplete
    status: completed
    dependencies:
      - step2_services
  - id: step5_symbols
    content: Build symbol management (list view, detail view, symbol cards) and quick snap feature
    status: completed
    dependencies:
      - step2_services
  - id: step6_tags
    content: Implement tagging system with autocomplete and tag views
    status: completed
    dependencies:
      - step2_services
  - id: step7_search
    content: Add search and filtering functionality across notes and symbols
    status: completed
    dependencies:
      - step4_notes
      - step5_symbols
      - step6_tags
  - id: step8_images
    content: Implement image attachment functionality (picker, storage, display)
    status: completed
    dependencies:
      - step4_notes
  - id: step9_export
    content: Add PDF export functionality for notes
    status: completed
    dependencies:
      - step4_notes
  - id: step10_backup
    content: Implement JSON backup and restore functionality
    status: completed
    dependencies:
      - step2_services
  - id: step11_navigation
    content: Set up app navigation structure and wire all views together
    status: completed
    dependencies:
      - step3_home
      - step4_notes
      - step5_symbols
      - step6_tags
      - step7_search
      - step8_images
      - step9_export
      - step10_backup
---

# Stock Notes MVP Implementation Plan

## Architecture Overview

The app will use:

- **SwiftData** for local data persistence
- **Yahoo Finance API** for symbol autocomplete and price data (free, no API key)
- **MVVM pattern** with SwiftUI views and service layer
- **Modular structure** with separate services for notes, symbols, tags, and API calls

## Data Models (SwiftData)

### Core Entities

- `Note`: id, content (String, max 5000 chars), symbol (relationship), tags (many-to-many), createdDate, lastEditedDate, images (array of Data), isSnap (Bool) - indicates if note was created via quick snap
- `Symbol`: ticker (String, unique), companyName, currentPrice (Double?), lastPriceUpdate (Date?), notes (one-to-many)
- `Tag`: name (String, unique), notes (many-to-many)

## Implementation Steps

### Step 1: Data Models & SwiftData Setup

**Files to create:**

- `stocknotes/Models/Note.swift` - Note model with SwiftData
- `stocknotes/Models/Symbol.swift` - Symbol model with SwiftData  
- `stocknotes/Models/Tag.swift` - Tag model with SwiftData
- `stocknotes/Models/AppDataModel.swift` - SwiftData model container configuration

**Details:**

- Define all three models with proper relationships
- Set up SwiftData schema with migration support
- Configure model container in app entry point

### Step 2: Core Services Layer

**Files to create:**

- `stocknotes/Services/NoteService.swift` - CRUD operations for notes
- `stocknotes/Services/SymbolService.swift` - Symbol management, price fetching
- `stocknotes/Services/TagService.swift` - Tag management and autocomplete
- `stocknotes/Services/YahooFinanceService.swift` - Yahoo Finance API integration
- `stocknotes/Services/SnapService.swift` - Quick snap functionality (capture stock state)

**Details:**

- NoteService: Create, read, update, delete notes with auto-save
- SymbolService: Add symbols, fetch prices, get all symbols
- TagService: Create tags, get suggested tags, tag autocomplete
- YahooFinanceService: Symbol search/autocomplete, price fetching (using yfinance or direct API calls)
- SnapService: Quick snap functionality - capture current stock price/state and create note instantly

### Step 3: Home Screen & Dashboard

**Files to create:**

- `stocknotes/Views/HomeView.swift` - Main dashboard
- `stocknotes/Views/Components/StatsCard.swift` - Statistics display
- `stocknotes/Views/Components/RecentNotesList.swift` - Recent notes feed

**Details:**

- Display total notes, total symbols, notes this month
- Show last 10 notes in reverse chronological order
- Add floating action button (FAB) for quick note creation
- Quick snap button/action accessible from home screen
- Navigation to symbols, search, settings

### Step 4: Note Creation & Editing

**Files to create:**

- `stocknotes/Views/NoteEditorView.swift` - Rich text editor
- `stocknotes/Views/NoteDetailView.swift` - View/edit existing note
- `stocknotes/Views/Components/SymbolAutocompleteView.swift` - Inline symbol search

**Details:**

- Rich text editor with markdown support (using TextEditor with markdown formatting)
- Inline symbol autocomplete (search as user types)
- Character counter (5000 limit)
- Auto-save functionality (debounced)
- Timestamp display (created/edited dates)

### Step 5: Symbol Management & Quick Snap

**Files to create:**

- `stocknotes/Views/SymbolListView.swift` - All symbols (watchlist-style)
- `stocknotes/Views/SymbolDetailView.swift` - Notes for a specific symbol
- `stocknotes/Views/Components/SymbolCard.swift` - Symbol card display
- `stocknotes/Views/QuickSnapView.swift` - Quick snapshot capture interface
- `stocknotes/Services/SnapService.swift` - Quick snap functionality

**Details:**

- Display all symbols with ticker, company name, note count, latest note date
- Quick actions: view notes, add note, delete symbol
- Support custom symbols (e.g., XYZ.TO)
- Fetch and display current price from Yahoo Finance
- **Quick Snap Feature**: 
  - "Snap" button available from symbol detail view and global quick action
  - Instantly captures current stock state: symbol, current price, timestamp
  - Creates a note automatically with pre-filled content showing price snapshot
  - Optional: Allow user to add quick note text before saving
  - Accessible via long-press on symbol card or dedicated snap button

### Step 6: Tagging System

**Files to create:**

- `stocknotes/Views/Components/TagInputView.swift` - Tag input with autocomplete
- `stocknotes/Views/TagView.swift` - View all notes for a tag

**Details:**

- Tag input field with autocomplete during note creation
- Suggested tags based on common usage
- Multiple tags per note
- Tag cloud visualization on home screen

### Step 7: Search & Filters

**Files to create:**

- `stocknotes/Views/SearchView.swift` - Full search interface
- `stocknotes/Views/NoteListView.swift` - Filtered note list
- `stocknotes/Views/Components/FilterBar.swift` - Filter controls

**Details:**

- Full-text search across note content
- Filter by tag, symbol, date range
- Sort by creation date, edit date, symbol name
- Search symbols by ticker or company name

### Step 8: Image Attachments

**Files to create:**

- `stocknotes/Views/Components/ImagePickerView.swift` - Image picker
- `stocknotes/Views/Components/ImageAttachmentView.swift` - Display attached images
- `stocknotes/Services/ImageService.swift` - Image storage management

**Details:**

- Attach up to 3 images per note (MVP limit)
- Store images as Data in SwiftData (or file references)
- Display images in note view
- Support screenshots, photos from library

### Step 9: Export Functionality

**Files to create:**

- `stocknotes/Services/ExportService.swift` - PDF generation
- `stocknotes/Views/ExportView.swift` - Export options UI

**Details:**

- Export all notes as PDF
- Export notes for single symbol as PDF
- Format: Title, symbol, notes with timestamps, tags
- Share sheet integration for email/airdrop

### Step 10: Settings & Backup

**Files to create:**

- `stocknotes/Views/SettingsView.swift` - Settings screen
- `stocknotes/Services/BackupService.swift` - JSON backup/restore

**Details:**

- One-tap local backup (export as JSON)
- Import from JSON backup
- Settings for app preferences

### Step 11: Navigation & App Structure

**Files to modify:**

- `stocknotes/stocknotesApp.swift` - Add SwiftData model container
- `stocknotes/ContentView.swift` - Main navigation structure

**Details:**

- Set up TabView or NavigationStack for main navigation
- Configure SwiftData model container
- Wire up all views with proper navigation

## Technical Considerations

### Yahoo Finance API Integration

- Use `yfinance` library via Swift Package Manager, or
- Direct API calls to Yahoo Finance endpoints
- Handle rate limiting and errors gracefully
- Cache symbol data to reduce API calls

### Rich Text Editing

- Use `TextEditor` with markdown parsing for display
- Consider `AttributedString` for formatting
- Markdown support: bold, italic, bullet lists, links

### Image Storage

- Store images as `Data` in SwiftData (for MVP simplicity)
- Consider file-based storage for better performance in future
- Compress images before storage

### Auto-save

- Debounce note saves (e.g., 2 seconds after last keystroke)
- Show save indicator in UI
- Handle save errors gracefully

### Quick Snap Feature

- **Purpose**: Allow users to instantly capture a stock's current state (price, timestamp) at any time
- **Access Points**:
  - Dedicated "Snap" button on symbol detail view
  - Quick action from symbol card (long-press menu)
  - Global quick snap button on home screen (opens symbol picker)
- **Functionality**:
  - Fetches current price for selected symbol
  - Creates a note with pre-filled content: "Snap: [SYMBOL] @ $[PRICE] - [TIMESTAMP]"
  - Optionally allows user to add quick note text before saving
  - Marks note with `isSnap` flag for filtering/display purposes
  - Can be accessed from anywhere in the app for quick capture
- **UI Flow**:
  - User taps snap button → fetches current price → shows quick confirmation → creates note
  - Or: User selects symbol → taps snap → instant note creation

## Dependencies

Add via Swift Package Manager:

- For Yahoo Finance: Consider `yfinance-swift` or implement direct API calls
- For PDF generation: Use native `PDFKit` framework
- For markdown: Consider `MarkdownUI` or implement basic parsing

## File Structure

```
stocknotes/
├── Models/
│   ├── Note.swift
│   ├── Symbol.swift
│   ├── Tag.swift
│   └── AppDataModel.swift
├── Services/
│   ├── NoteService.swift
│   ├── SymbolService.swift
│   ├── TagService.swift
│   ├── YahooFinanceService.swift
│   ├── SnapService.swift
│   ├── ImageService.swift
│   ├── ExportService.swift
│   └── BackupService.swift
├── Views/
│   ├── HomeView.swift
│   ├── NoteEditorView.swift
│   ├── NoteDetailView.swift
│   ├── NoteListView.swift
│   ├── SymbolListView.swift
│   ├── SymbolDetailView.swift
│   ├── QuickSnapView.swift
│   ├── SearchView.swift
│   ├── TagView.swift
│   ├── SettingsView.swift
│   └── Components/
│       ├── StatsCard.swift
│       ├── RecentNotesList.swift
│       ├── SymbolCard.swift
│       ├── SymbolAutocompleteView.swift
│       ├── TagInputView.swift
│       ├── FilterBar.swift
│       ├── ImagePickerView.swift
│       └── ImageAttachmentView.swift
└── stocknotesApp.swift (modified)
```

## Testing Strategy

- Test each step before moving to next
- Verify data persistence after Step 1
- Test API integration after Step 2
- UI testing after each view is created
- End-to-end testing after all steps complete