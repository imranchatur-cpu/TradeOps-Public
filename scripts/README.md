# Public pack generation

`build_pack.py` produces the two-page `DESK-pack.pdf` from sanitized text only. It uses ReportLab
and FontTools, downloads Syne, Inter and JetBrains Mono from Google Fonts into ignored
`.build-fonts/`, and embeds them in the PDF. Their OFL licenses are downloaded beside the fonts.

Install `scripts/requirements.txt` in a virtual environment, then run
`python scripts/build_pack.py` from the repo. Keep the text consistent with CONTRACT and ROSTER;
inspect both rendered pages before publishing. No private environment, configuration or API keys
are required. The pack remains CC BY 4.0 with Imran Chatur / Lift Off attribution.

Font licenses are preserved in [font-licenses/](font-licenses/); embedded fonts retain their
SIL Open Font License terms separately from the pack's CC BY license.

`deno test -A --no-lock scripts/schema_test.ts` runs three isolated PGlite checks for the fresh
starter schema: arm gates (including SQL NULL handling), Wait/claim immutability and active-row
deletion/override behavior. Deno downloads the pinned test dependencies. This does not test
production permissions, backend deployment or any live integration.
