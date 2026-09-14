# Athlete Spotlight — Resale Template

A reusable athlete recruiting website with a public profile, film links, achievements, recruiter inquiry form, and private family lead dashboard.

## Customize a new client

1. Edit `site-config.js` with the athlete's verified name, school, measurements, biography, film links, and achievements.
2. Add the athlete's licensed hero photo under `assets/` and set `heroImage` to its path.
3. Set the deployment environment variables listed in `.env.example`.
4. Replace “Build with Ronald” in the footer only if the sale includes white-label rights.
5. Test the inquiry form and `/management.html` before delivery.

## Local preview

```bash
python3 -m http.server 5173
```

Open `http://localhost:5173`. The form requires a Vercel deployment with Blob configured.

## What a buyer receives

- Responsive athlete recruiting profile
- Centralized one-file athlete customization
- Film and achievement sections
- Recruiter/media/sponsor inquiry form
- Password-protected family dashboard
- Lead statuses, search, archive, trash, and CSV export

Client photos, logos, copy, domains, analytics, email accounts, and third-party subscriptions are not included unless specifically listed in the sale agreement.
