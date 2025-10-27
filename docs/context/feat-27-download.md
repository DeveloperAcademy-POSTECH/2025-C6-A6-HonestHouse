## Feature Implementation: Save Selected Photos to Album

### 1. Goal

To implement a feature allowing users to save photos from the `selectedPhotosInGroup` array (within `GroupedPhotosViewModel`) into a dedicated album named "HonestHouse" in the device's photo library.

### 2. Implementation Steps

1.  **`PhotoManager` Creation:** A new `PhotoManager` class (conforming to `PhotoManagerType`) was created to encapsulate all interactions with the `Photos` framework. This isolates photo library logic from the ViewModel.

2.  **`ImageLoader` Singleton:** The existing `ImageLoader` was converted into a `final` singleton class by adding `static let shared` and a `private init()`. This was done to ensure resource efficiency (reusing `URLSession`) and provide a consistent, centralized point for image fetching and caching.

3.  **Dependency Injection:** The new `PhotoManager` was integrated into the app's existing service layer by adding it to the `Services` class, making it available through the `DIContainer`.

4.  **ViewModel Update:** `GroupedPhotosViewModel` was updated to:
    *   Receive the `PhotoManager` instance via its `configure` method.
    *   Add a `SavingState` enum (`.idle`, `.saving`, `.success`, `.failure`) to track the status of the save operation for UI feedback.
    *   Implement a `saveSelectedPhotos()` method that calls the `PhotoManager` to perform the save operation.

### 3. Key Challenges & Resolutions

*   **`Info.plist` Permissions:** This was a critical point. 
    *   Initially, only `NSPhotoLibraryAddUsageDescription` (write permission) was thought to be necessary.
    *   A crash occurred, with logs indicating `NSPhotoLibraryUsageDescription` (read permission) was missing.
    *   **Resolution:** We identified that checking for the album's existence with `PHAssetCollection.fetchAssetCollections` is a **read operation**. Therefore, both the read and write permission keys were required in `Info.plist` for the feature to function correctly.

*   **Image Data Type Mismatch:**
    *   `ImageLoader` was initially designed to return a `UIImage`.
    *   The `Photos` framework's `PHAssetCreationRequest` requires raw `Data` for saving.
    *   **Resolution:** The `ImageLoader` was updated with a `fetchImageData(from:)` method to provide the `Data` object directly, and `PhotoManager` was updated to use it. This keeps data conversion logic within the `ImageLoader`.

### 4. Documentation Update

*   The main project document, `docs/PRD.md`, was updated to reflect the new 'Save to Album' functionality. This included updates to the folder structure, key technologies (`Photos Framework`), core files, and feature workflow.

### 5. Core Files Affected/Created

*   **Created:**
    *   `HonestHouse/HonestHouse/Sources/Core/Managers/PhotoManager.swift`
    *   `HonestHouse/HonestHouse/Sources/Core/Managers/PhotoManagerType.swift`
    *   `HonestHouse/HonestHouse/Sources/Core/Managers/Error/PhotoError.swift` (or similar name)
    *   `context-summary.md`
*   **Modified:**
    *   `HonestHouse/HonestHouse/Sources/Core/Network/ImageLoader.swift`
    *   `HonestHouse/HonestHouse/Sources/Service/Services.swift`
    *   `HonestHouse/HonestHouse/Sources/Presentation/Archive/ViewModel/GroupedPhotosViewModel.swift`
    *   `HonestHouse/HonestHouse/Info.plist`
    *   `docs/PRD.md`
