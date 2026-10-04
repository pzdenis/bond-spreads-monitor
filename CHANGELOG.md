# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Added
- Static issuer master dataset (`issuer_master.csv`)
- Issuer profile section in the dashboard
- Public issuer metadata including country, location, institution type, business model and funding profile
- Issuer profile navigation for multiple selected issuers

### Changed
- Extended the dashboard sidebar with contextual issuer information
- Integrated issuer metadata separately from market and bond analytics data

### Technical
- Added loading of `issuer_master.csv` via relative project paths
- Added reactive issuer-profile logic linked to the existing issuer selection
- Preserved all existing chart, filter, table and export functionality
