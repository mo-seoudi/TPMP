# TPMP F1 — React Frontend

Early UI implementation on an isolated feature branch. This is **demonstration data only**: no Supabase, production authentication, SQL migrations, or backend writes.

## GitHub build

The GitHub Actions workflow at `.github/workflows/f1-build.yml` runs `npm install` and `npm run build` from the `app/` directory. Build status is only confirmed once Actions completes.

## Local commands (optional)

`npm install` then `npm run dev` from `app/`.

## Architecture

`src/components/` shared navigation, `src/features/` independent feature screens, `src/data/` demo fixtures. F0 database security design remains separate.
