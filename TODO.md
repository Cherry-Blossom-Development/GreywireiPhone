# GreywireiPhone - To Do

Things to address later, gathered while building the foundation (login and home, 2026-11-10). When something here gets done, remove it, and match the change in GreywireAndroid.

## Accounts and auth

- **EULA acceptance.** The Prosaurus app sends new users to an EULA screen after login. Greywire skips this entirely. Decide whether Greywire users must accept the same EULA, or a Greywire-specific one, and add the screen.
- **Sign up.** There's no way to create an account in the app yet. Prosaurus hashes the password client-side for signup; reuse that pattern.
- **Forgot password.** Not built. The Prosaurus app has a forgot password flow using `/api/auth/forgot-password`.
- **Guest accounts.** `/api/auth/me` returns `isGuest`, and guests can never be Greywire members. The app doesn't handle guests specially yet.

## Greywire features

- **Claim a pedal.** `POST /api/greywire/claim { serial }` already exists in the backend and makes the user a member. The home screen's "Not a member yet" card should lead to a claim flow (serial entry, and maybe a QR scan later). The backend rate-limits failed claims (10 per hour), so show its error messages.
- **Pedal catalog from the backend.** The Flashover and Switchyard cards on Home are hard-coded text copied from the website. Move them to the backend once there's a pedal catalog, so the app, site and backend don't drift apart.
- **Pedal illustrations.** The website has an SVG for each pedal (`../GreywireStudio-Website/img/*.svg`). Add them to the pedal cards.
- **The real app features**: setlists, sounds, and talking to Switchyard (the website describes the phone setting up setlists and sounds that Switchyard stores). These are the core of the app and still need design.
- **Community.** The website links to `community.greywirestudio.com`. Decide which community features (chat and so on) come into the app.

## Backend

- **Analytics platform value.** The backend accepts only `web`, `android` and `ios` in `X-Client-Platform` (`backend/utilities/platform.js`), so Greywire traffic is counted as `ios` together with Prosaurus. Add `greywire-ios` there, then send it from `APIClient`.

## Release and infrastructure

- **App icon.** Currently a placeholder. Replace with the actual Greywire logo from `../GreywireStudio-Website/img/logo.svg`.
- **Push notifications.** Firebase isn't set up. Prosaurus registers device tokens on login and removes them on logout; do the same when notifications are needed.
- **App Store listing**: app name, icon assets, screenshots, privacy policy.
- **Version bumps**: `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` in `project.yml` (currently 1.0.0 / 1).

## Testing

- **E2E tests in BreakTest.** No Appium tests cover Greywire yet. The accessibility identifiers are already in place (see `CLAUDE.md`).
- **A Greywire member in the test seed data.** `breakroom_test` has no user who is a Greywire member or holds a claimed pedal, so the home screen's "Member" state has only been checked in code, not on screen. Add a seeded member to `BreakTest/database/setup.ts`.

## Polish

- **Logo placeholder.** The greywire_logo asset is a placeholder SVG. Replace it with the actual logo from GreywireStudio-Website.
- **Tablet and landscape.** The login form caps its width at 420pt, but Home doesn't cap its width yet.
- **Font fallbacks.** If custom fonts fail to load, the app falls back to system fonts. Consider adding explicit fallbacks.
