# Storage Policy

## Why This Exists

The first weekly batch stored 10 original PDFs and used about 112 MB. If every week stores 10 PDFs, the repository can grow to more than 5 GB per year, before Git history overhead.

This repository should stay lightweight enough to clone, browse, and publish through GitHub Pages.

## Long-Term Storage Rules

Keep these in Git permanently:

- Weekly summary Markdown reports.
- Per-paper Markdown analysis reports.
- Static website files under `docs/`.
- Source notes, selection policy, and metadata.
- Links to original papers, project pages, model cards, GitHub repos, and PDFs.

Store PDFs selectively:

- Keep PDFs only for the most important papers, normally 3 to 5 per week.
- Prefer arXiv / official PDF links over committing every PDF.
- If a PDF is large, low-priority, or easy to retrieve, store only its link.
- If a file is over 50 MB, avoid committing it unless it is essential.
- If a file is over 100 MB, do not commit it to ordinary GitHub Git storage.

Use local-only cache for bulk downloads:

```text
local_cache/
tmp_downloads/
```

These folders should not be committed.

## Suggested Weekly Layout

```text
reports/
  2026-06-12/
    weekly_summary.md
    01_paper.md
    02_paper.md

sources/
  2026-06-12/
    candidates.json
    links.md

papers/
  2026-06-12/
    selected_pdf_01.pdf
    selected_pdf_02.pdf

docs/
  index.html
  weeks/
    2026-06-12.html
```

## Annual Maintenance

Every quarter:

- Check repository size.
- Remove nonessential PDFs from future commits before they enter history.
- Keep reports and source links even when PDFs are removed.

Avoid rewriting Git history unless explicitly requested, because it can disrupt clones and GitHub Pages.
