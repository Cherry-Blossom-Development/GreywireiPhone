# GreywireiPhone - Claude Context

## What this project is

A native mobile app for **Greywire Studio**, Cherry Blossom Development's guitar-effects brand (the Linework pedals). It is one of two sibling apps:

| Project | Platform | Repo |
|---------|----------|------|
| **GreywireAndroid** | Android (Kotlin, Jetpack Compose, Retrofit) | https://github.com/Cherry-Blossom-Development/GreywireAndroid |
| **GreywireiPhone** | iOS (Swift, SwiftUI, XcodeGen) | https://github.com/Cherry-Blossom-Development/GreywireiPhone |

Both apps should offer the same features; build a feature in one, then match it in the other.

### How it relates to the other projects

- **GreywireStudio** (`../GreywireStudio`): the hardware side, meaning the pedal designs (KiCad, LTspice). The apps are the mobile companion to these products.
- **GreywireStudio-Website** (`../GreywireStudio-Website`): the Greywire web front end. Like these apps, it talks to the Breakroom backend (for example, the surveys post to `/api/surveys/<name>`).
- **Breakroom** (`../Breakroom`): the backend for these apps. They use the **same Express backend, MariaDB database and user accounts** as Prosaurus (`https://www.prosaurus.com/api`). **Any new backend endpoints or tables these apps need go into the Breakroom backend.** Don't create a separate backend.
- **Android** / **iPhone** (`../Android`, `../iPhone`): the Prosaurus mobile apps. **These are not the same apps.** The Greywire apps use the same tech stack and backend, and can reuse patterns and code from them (auth, API client, environment switching, Socket.IO), but the interface and structure are very different. Some Prosaurus features will be carried over; many Greywire features won't exist in Prosaurus at all.

## Status

Created 2026-11-09. **No app code yet.** GreywireAndroid already has its foundation (login and a home screen), so the first job here is to build the same thing in SwiftUI. The Android code is the spec for that foundation; see "First task" below.

## Setting up on a new machine (the Mac)

This app is developed on the Mac; GreywireAndroid is developed on the Windows PC. The docs refer to sibling folders, so clone these repos **side by side in one folder** (as on the PC, where they all live in one `Repo` folder), and `git pull` each before starting:

| Folder | Why it's needed | Repo |
|--------|-----------------|------|
| `GreywireiPhone` | This app | https://github.com/Cherry-Blossom-Development/GreywireiPhone |
| `iPhone` | Prosaurus iOS app: the template for code structure, `APIClient`, `KeychainManager`, `switch-env.sh`, `project.yml` | https://github.com/Cherry-Blossom-Development/iPhone |
| `GreywireAndroid` | The sibling app: the spec for screens and behavior, plus the font files | https://github.com/Cherry-Blossom-Development/GreywireAndroid |
| `GreywireStudio-Website` | The visual design (`css/site.css`) and the logo and pedal SVGs (`img/`) | https://github.com/Cherry-Blossom-Development/GreywireStudio-Website |
| `Breakroom` | The backend, needed to run a local test backend | https://github.com/Cherry-Blossom-Development/Breakroom |

Tools: Xcode, XcodeGen (`brew install xcodegen`), and Docker Desktop for the local test backend.

The local test backend needs `Breakroom/.env.test`, which is gitignored. If the Mac has already run the Prosaurus iPhone tests, the file is there; otherwise copy it from the PC. Without it, use the `dev-test` environment (`https://test.dev.prosaurus.com/`) instead.

## First task: match the GreywireAndroid foundation

Read these in `../GreywireAndroid` first: `CLAUDE.md`, `TODO.md`, and the Kotlin under `app/src/main/java/com/cherryblossomdev/greywire/` (mainly `ui/screens/LoginScreen.kt`, `ui/screens/HomeScreen.kt`, `ui/components/GreywireComponents.kt`, `ui/theme/`, `network/`, `data/`). Build the same screens and behavior in SwiftUI, structured like `../iPhone` (MVVM: Models, Views, ViewModels, Services, Components).

### Screens

- **Login**: the brand (logo and "Greywire"), a "LINEWORK SERIES" eyebrow, a "Sign in" heading, a line saying it's the same account as Prosaurus, "Username or email" and password fields (with show/hide), an error message, a copper "Sign in" button, and the version number below. Empty fields show "Enter your username and password". After a successful login, call `/api/auth/me`, then go to Home.
- **Home**: a header with the brand and a "Sign out" ghost button. A hero with the eyebrow "Signed in as <username>" and the heading "Your pedalboard, connected." (on two lines). A **Membership** card with three states: "Member" with a list of claimed pedals (model and serial), "Member" granted by the studio with no pedals yet, or "Not a member yet" with a short explanation. Then static cards for Flashover (Prototyping) and Switchyard (Design); copy their text from `HomeScreen.kt`.
- **Session**: if a token is saved, open on Home; otherwise open on Login. If `/me` or `/membership` returns 401, clear the session and go to Login. Sign out clears local data first, then calls the logout endpoint.

### Backend API (same backend as Prosaurus; see `../iPhone/Breakroom/Services/APIClient.swift`)

- `POST /api/auth/login` with `{ "handle", "password" }` returns `{ message, token }`. Save the token in the Keychain under a Greywire-specific service name, not the Prosaurus one.
- Send the token as `Authorization: Bearer <token>` and as a `jwtToken` cookie. If a response has an `X-New-Token` header, save the new token.
- Send `X-Client-Platform: ios`. The backend accepts only `web`, `android` and `ios`, so this traffic is counted with Prosaurus for now (see `TODO.md` in GreywireAndroid).
- `GET /api/auth/me` returns `{ username, userId, isGuest, greywireMember }`.
- `GET /api/greywire/membership` returns `{ member, grantedAt, pedals: [{ id, model, serial, buildDate, claimedAt }] }`.
- `POST /api/auth/logout` signs out.
- Not used yet: `POST /api/greywire/claim { serial }`.

### Visual design: match GreywireStudio-Website

Dark only. The colors are the site's `:root` variables:

| Token | Hex | Use |
|-------|-----|-----|
| bg | `#141619` | Screen background |
| surface | `#1c1f23` | Cards, text fields |
| surface-2 | `#24282d` | Raised surfaces, app icon background |
| line | `#33383e` | Borders, dividers |
| text | `#e8e6e1` | Main text |
| muted | `#9ba0a6` | Secondary text |
| copper | `#d07a3e` | Accent, primary button, focus |
| copper-soft | `#e9a46f` | Eyebrows |
| signal | `#5fd38a` | "Member" status dot |

- **Fonts**: Space Grotesk (text) and IBM Plex Mono (eyebrows and labels). Copy the `.ttf` files from `../GreywireAndroid/app/src/main/res/font/` and the license files from `../GreywireAndroid/licenses/`, and register them in `Info.plist` (`UIAppFonts`). There's no SemiBold Space Grotesk, so use Medium for weight 600.
- **Components**: make SwiftUI versions of the ones in `GreywireComponents.kt`: brand, header, eyebrow (uppercase mono, copper-soft, letter-spaced), section heading, card (surface, 1px line border, rounded), status pill, copper pill button, and ghost button (transparent with a line border).
- **Logo and app icon**: from `../GreywireStudio-Website/img/logo.svg`. The Android launcher icon is the wire and spark on surface-2.

### iOS specifics

- Bundle ID `com.cherryblossomdev.greywire` (matching the Android applicationId), display name "Greywire", iOS 17+, and the same `DEVELOPMENT_TEAM` as `../iPhone/project.yml`.
- Environments: copy `switch-env.sh` and `environments/` from `../iPhone`, writing `Config.swift`. The Simulator reaches a local backend at `http://localhost:3001` (the test backend). Production is `https://www.prosaurus.com`.
- Allow plain HTTP only to localhost, and only in Debug.
- Accessibility identifiers should match the Android test tags: `username-input`, `password-input`, `login-button`, `error-message`, `logout-button`, `home-title`, `membership-card`.
- Test users on the test backend: `testuser` / `TestPass123` and `testadmin` / `TestPass123`. Neither is a Greywire member, so "Not a member yet" is the state you'll see.

When this is done, update this Status section, add a `TODO.md` like GreywireAndroid's, and keep the two apps feature-matched from then on.

## Tech stack (same as ../iPhone)

- Swift, SwiftUI, iOS 17+, XcodeGen (`project.yml`)
- Backend: Breakroom API. Production is `https://www.prosaurus.com/api`; the Simulator reaches a local backend at `localhost`
- Look at `../iPhone/CLAUDE.md` for the environment switching (`switch-env.sh`), project generation and build conventions already worked out there, and reuse them here.
