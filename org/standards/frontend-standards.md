# Frontend Standards

Conventions for HTML/EJS pages across ETST web apps (primarily **emed_app**). Apply these by
**default, without being asked** — they are the house standard, not a per-request feature.

## Data tables (HARD STANDARD)

**Every data table we render in an HTML page MUST have all four of these.** If you build a table
and skip one, you are not done. This applies to any new table *and* to any existing table you touch.

1. **All columns sortable.**
2. **Relevant (categorical) columns get a filter icon** (a funnel in the header).
3. **The filter dropdown shows each unique value with its occurrence count next to it** — e.g.
   `Approved (12)`.
4. **Date/time columns sort chronologically, never alphanumerically.** (See the U+202F gotcha below —
   this one is silently wrong if you skip it.)

### The stack (emed_app)

- **Library:** `simple-datatables` **v10.0.0**, loaded from CDN — CSS in
  [views/partials/header.ejs:14](../../../emed_app/views/partials/header.ejs#L14), JS in
  [views/partials/footer.ejs](../../../emed_app/views/partials/footer.ejs#L26). (Not in
  `package.json` — it's a CDN pin. jQuery DataTables is *not* used.)
- **Always build tables through the house wrapper** `gen_datatable(div_name, json_data, table_name, options)`
  in [public/js/main.js:1227](../../../emed_app/public/js/main.js#L1227) — do **not** hand-roll
  `<table>` + `new simpleDatatables.DataTable(...)`. The wrapper builds the markup and passes
  `options.dt` straight through to the library, so `columns`, `type`, `format`, `sort`, `sortable`,
  and `perPageSelect` all work.

### 1. Sortable columns

`gen_datatable` makes every column sortable by default — you get this for free. Only turn it **off**
for a genuinely un-sortable column (e.g. an actions/buttons column):

```js
gen_datatable('table_x', rows, 'Title', { dt: { columns: [ { select: 5, sortable: false } ] } });
```

### 2. Filter icons + unique values + counts

Reference implementations to copy — do not reinvent:

- **[views/moct/visits.ejs](../../../emed_app/views/moct/visits.ejs)** — the MOCT/Peaks Visits
  per-column (Excel-style) filters. Inline CSS + popover + logic.
- **[public/js/cost-adjustment-column-filter.js](../../../emed_app/public/js/cost-adjustment-column-filter.js)**
  — a richer, self-contained, reusable version (searchable checkbox lists, numeric/date operators).

The load-bearing techniques (all present in visits.ejs):

- A Font Awesome `fa-filter` `<i>` is **injected into each filterable `<th>`** after render, keyed by
  a `label → raw-column` map. Normalize the header text first — `pretty_header` can inject a
  **non-breaking space (U+00A0)**; strip it before the lookup or the map misses.
- **Re-inject the icons after every redraw.** simple-datatables rebuilds the header (and drops your
  icons) on `sort` / `page` / `search` / `update` — rebind on those events and re-inject.
- **Capture-phase click delegation** so the funnel click isn't swallowed by the library's header
  sort handler and survives header re-renders:
  ```js
  document.addEventListener('click', e => {
      const btn = e.target.closest && e.target.closest('.col-filter-btn');
      if (!btn) return;
      e.stopPropagation(); e.preventDefault();
      openColumnFilter(btn.getAttribute('data-col'));
  }, true); // <-- true = CAPTURE phase, runs before the library's bubble-phase sort
  ```
- **Filter over one cached fetch — no re-query.** Keep the fetched rows in memory; applying a filter
  re-renders client-side, it does not hit the backend.
- **Show a count next to every value**, and compute a column's option list from the rows left by the
  **other** active filters (not its own) — so counts stay accurate and no option ever yields zero rows:
  ```js
  const counts = {};
  rowsMatchingOtherFilters(col).forEach(r => { const v = rawValue(r, col); counts[v] = (counts[v]||0)+1; });
  // render each option as:  <label> <span class="cf-count">(<count>)</span>
  ```

### 3. Date sorting — the U+202F gotcha (MANDATORY, silently wrong if skipped)

simple-datatables v10 **strict-parses each date cell's text with (bundled) dayjs against your
`format`**. `toLocaleString`/`Intl` on modern Node/V8 inserts a **narrow no-break space (U+202F)
before AM/PM**, which fails the parse — so the column **silently falls back to alphabetical string
sort** (rows scatter by month name). This looks fine until someone sorts by date.

The fix has **two halves that must match exactly** — reference
[views/tasks/my-tasks.ejs:600-616](../../../emed_app/views/tasks/my-tasks.ejs#L600) and
[:253-264](../../../emed_app/views/tasks/my-tasks.ejs#L253) (also
[views/admin/task-management.ejs](../../../emed_app/views/admin/task-management.ejs) for a date-only
variant):

**(a) Render the date yourself with plain ASCII spaces** — never `toLocaleDateString`/`Intl`:

```js
const DATE_SORT_FORMAT = 'MMM D, YYYY, h:mm A';
const MONTH_ABBR = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
function formatDate(s) {
    if (!s) return '';
    const d = new Date(s); if (isNaN(d.getTime())) return s;
    let h = d.getHours(); const ampm = h >= 12 ? 'PM' : 'AM'; h = h % 12 || 12;
    const m = String(d.getMinutes()).padStart(2, '0');
    return `${MONTH_ABBR[d.getMonth()]} ${d.getDate()}, ${d.getFullYear()}, ${h}:${m} ${ampm}`;
}
```

**(b) Declare the column `type:'date'` with the SAME format token string** (optionally `sort:'desc'`):

```js
gen_datatable('table_x', rows, 'Title', {
    dt: { columns: [ { select: 0, type: 'date', format: DATE_SORT_FORMAT, sort: 'desc' } ] }
});
```

Do **not** rely on `data-sort` / `data-order` attributes for dates — this codebase uses the
library's `type:'date'` + `format` mechanism. (For Liberty/DB datetimes, `gen_datatable`'s
`fix_date` option + `fmt_date()` in main.js already emit ASCII-space strings, sidestepping the same
bug.)

### Checklist for any new (or touched) table

- [ ] Built via `gen_datatable` (not a hand-rolled `DataTable`).
- [ ] All columns sortable (only intentional exceptions set `sortable:false`).
- [ ] Filter funnels on the categorical columns.
- [ ] Each filter value shows its count; options narrowed by sibling filters.
- [ ] Date/time columns are `type:'date'` with a matching **ASCII** `format` (no `Intl`/`toLocaleString`).
- [ ] Filter icons re-injected after redraw; click handled in the capture phase.
