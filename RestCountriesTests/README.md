# RestCountries App Guide:

## App Does ==>

Displays country information from restcountries.com API. Users can:
- Pin favorite countries (max 5)
- Search countries
- View country details (capital, currency, flag)
- Works offline with cached data

====================================================================

## Architecture ==>

SwiftUI Views → ViewModel → Repository → [API Service + SwiftData]


**Pattern:** MVVM (Model-View-ViewModel) + Repository

====================================================================
## Tests ==>

### CountryDTOTests.swift
Tests data parsing:
- JSON decoding
- Currency formatting
- Handling missing data

### CountryHomeViewModelTests.swift
Tests business logic:
- Loading with GPS location
- Pin limit enforcement
- Add/remove pins

### CountryRepositoryTests.swift
Tests data management:
- Network refresh saves to database
- Search filtering
- Pin limit validation

### Running Tests

Cmd + U
