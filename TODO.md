# GreywireiPhone - To Do

Things to address later, gathered while building the app. When something here gets done, remove it, and match the change in GreywireAndroid.

## Accounts and auth

- **EULA status on error.** If `/api/eula/status` fails, the Legal screen shows the EULA as "Accepted", so a user isn't shown a status they can't act on. That's misleading; consider an "Unknown" state in both apps.

## Greywire features

- **Pedal catalog from the backend.** The Flashover and Switchyard cards on Home are hard-coded text copied from the website. Move them to the backend once there's a pedal catalog, so the app, site and backend don't drift apart.
- **The real app features**: setlists, sounds, and talking to Switchyard (the website describes the phone setting up setlists and sounds that Switchyard stores). These are the core of the app and still need design.

## Billing

- **In-app purchase (StoreKit).** The paywall currently directs users to the website. Add StoreKit integration to allow subscribing directly in the app. This requires backend work to verify App Store receipts.

## Backend

- **Analytics platform value.** The backend accepts only `web`, `android` and `ios` in `X-Client-Platform` (`backend/utilities/platform.js`), so Greywire traffic is counted as `ios` together with Prosaurus. Add `greywire-ios` there, then send it from `APIClient`.

## Release and infrastructure

- **Push notifications.** Firebase isn't set up. Prosaurus registers device tokens on login and removes them on logout; do the same when notifications are needed.
- **App Store listing**: app name, icon assets, screenshots, privacy policy.
- **Version bumps**: `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` in `project.yml` (currently 1.0.0 / 1).

## Testing

- **E2E tests in BreakTest.** No Appium tests cover Greywire yet. The accessibility identifiers are already in place (see `CLAUDE.md`).
- **A Greywire member in the test seed data.** `breakroom_test` has no user who is a Greywire member or holds a claimed pedal, so the home screen's "Member" state has only been checked in code, not on screen. Add a seeded member to `BreakTest/database/setup.ts`.

## Polish

- **Font fallbacks.** If custom fonts fail to load, the app falls back to system fonts. Consider adding explicit fallbacks.
