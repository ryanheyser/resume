# CLAUDE.md

LaTeX resumes for Ryan Heyser, built to PDF by CI. Two targeted variants, one shared preamble
convention. Read this before editing any `.tex` — several conventions here are load-bearing and are
not obvious from the source.

## Variants

| File | Targets | Sections |
|---|---|---|
| `systems-engineer-principal-resume.tex` | Senior/staff **IC** roles — SRE, platform, distributed systems | Profile, Skills, Projects, Education, Experience |
| `systems-engineer-manager-resume.tex` | Engineering **management** roles | Profile, Leadership & People, Education, Experience |

Edit the variant that matches the target role. Do not merge them into one hybrid — the split is
deliberate, and a document tuned for both is sharp for neither. A genuinely universal improvement
(a new real skill, a corrected fact) should be applied to **both**.

Adding a third variant means adding a `matrix.include` entry in `.github/workflows/generatepdf.yaml`.

## Hard formatting rules

Breaking any of these silently degrades the PDF.

- **Bullets:** `  \item \textbf{Label:} Sentence.` — two-space indent, space after `\item`.
- **`description` headers:** `\item\textbf{...}` — **no** space after `\item`. Different convention
  from bullets; both are intentional.
- **Labels are alphabetized within each job's `itemize`.** This holds in every block of both files.
  Insert new bullets at their alphabetical position, not at the end.
- **Escaping:** `\%`, `\&`, `\textasciitilde{}`. Quotes are `` ``text'' `` — never ASCII `"text"`,
  which LaTeX renders as two right-quotes. Date ranges use `--`. Em-dash is the literal character `—`
  (safe: utf8 `inputenc` + XCharter).
- **Never touch the spacing hacks:** the negative `\vspace{-18.5pt}` / `{-6.5pt}` / `{-9.5pt}` and
  `\setlist[itemize]{itemsep=-2.5pt, ...}`. They are hand-tuned; "cleaning them up" reflows everything.
- **Skills section** is two `\parbox{\linewidth}` blocks inside `multicols{2}` — left `\raggedright`,
  right `\raggedleft`, every line ending `\\`. Adding lines to one side can move the column break;
  rebalance by moving a whole category across, never by editing the scaffolding.
- **Keep `pdfkeywords` in sync.** It is ATS surface area, not decoration. Add new technologies there
  whenever they enter the body. Additive only — don't drop existing terms.
- **Don't remove** `\input{glyphtounicode}` / `\pdfgentounicode=1`. They make the PDF text
  machine-readable for resume parsers.

## Factual-accuracy ledger

**The single most important rule: never add a technology, title, or claim that isn't true.** A resume
is a factual document that gets interviewed against. Padding it with plausible keywords creates
questions with no good answer.

Distinguish precisely, and pick the verb that matches reality: **designed** (authored the
schema/architecture) vs **implemented** (built against someone else's contract) vs **integrated**
(consumed it) vs **operated** (ran it in production).

Confirmed constraints as of 2026-08:

| Claim | Status |
|---|---|
| Java, C# | **Academic only — keep off the resume.** Compete on Go concurrency/profiling instead. |
| Spring Boot, DI frameworks | No experience. |
| Kafka | No. Real experience is **GCP Pub/Sub** — say Pub/Sub. |
| Cassandra, Elasticsearch/OpenSearch | No experience. |
| AWS | No. Cloud experience is **GCP** (primary) and **Azure**. |
| gRPC / GraphQL | **Integrated, not designed.** Never claim API/schema design. |
| Redis/Memcached, Pub/Sub | Yes — genuine, from Go applications. |
| Consensus, Raft/Paxos, sharding | No hands-on. |

Before adding anything to this list, confirm it with Ryan. Don't infer capability from adjacency
(operating Vault ≠ implementing Raft; running operators ≠ writing leader election).

## Length discipline

**Target: 2 pages.** Field norm for a senior/staff IC resume, and the manager variant holds it.

Calibration measured from a real 5-page render (2026-08): ~3,777 rendered chars/page; page 1 is
heading-heavy (~3,637 usable) and dense pages hold ~5,000. Rendered ≈ 1.235 × visible-body chars.
So **~7,300 visible body chars ≈ 2 pages** — a useful budget check before compiling.

When it runs long, in this order:

1. **Tighten prose first.** Cut words, not achievements. Recurring offenders: doubled adjectives
   ("reproducible, auditable"), explanatory asides ("a deliberate, cost-conscious design"), restated
   scope ("50+ non-production and production clusters" → "50+ clusters"), wind-up verbs ("Served as",
   "Worked to", "was able to", "Designed and implemented" → "Built"), and trailing justification
   clauses that repeat the metric already stated.
2. **Remove repetition.** The `` ``80\% customer'' `` philosophy once appeared 4x (Profile + three
   roles); it belongs in the Profile plus at most one role. Check for verbatim-duplicated bullets
   across jobs before adding anything.
3. **Compress old roles.** Anything >10 years old gets one line or goes. Recent roles keep their depth.
4. **Only then cut bullets**, weakest-against-the-target-JD first. This sacrifices real
   accomplishments — it is Ryan's call, never an autonomous one.

## Verification

**No local TeX toolchain.** No `pdflatex`, `latexmk`, `pdfinfo`, or poppler. Options:

```bash
docker run --rm -v "$PWD":/work -w /work ghcr.io/xu-cheng/texlive-alpine:latest latexmk -pdf <file>.tex
```

(Docker is installed via Rancher Desktop but its daemon is often down — ask before assuming.)
Otherwise the PR builds both resumes and uploads them as workflow artifacts.

Two traps that have already caused wrong conclusions:

1. **The committed PDFs are stale and must not be trusted for page count.** As of 2026-08,
   `systems-engineer-principal-resume.pdf` dated from 2025-08-24 while the `.tex` had moved on three
   commits to 2026-07-02 — the PDF was missing PagerDuty, Gatekeeper, Venafi, Chainguard and SLO/SLI,
   and showed 2 pages for a ~4-page document. Always check `git log` dates on both files before
   citing a page count, or compile fresh.
2. **`generatepdf.yaml` sets `continue-on-error: true` on the compile step**, so a green check does
   **not** mean LaTeX compiled. Confirm the artifact exists and opens.

Page count from a PDF without poppler (the page tree is inside a compressed object stream, so
grepping for `/Count` on the raw bytes finds nothing):

```python
import re, zlib
d = open('resume.pdf','rb').read()
for m in re.finditer(rb'stream\r?\n', d):
    try: raw = zlib.decompressobj().decompress(d[m.end():d.find(b'endstream', m.end())])
    except Exception: continue
    for c in re.findall(rb'/Count\s+(\d+)', raw): print('Pages:', int(c))
```

Worth checking by reading, before compiling: alphabetical label order per block, escaping, brace
balance, that `\\` terminators survive in the Skills lines, and that scaffolding construct counts are
unchanged.

## Current positioning of the principal variant

Tuned (2026-08) for distributed-systems IC roles, e.g. Netflix *Distributed Systems Engineer 5*.
The reframing insight worth preserving: the existing work **is** distributed systems engineering and
mostly needed relabeling, not new claims — an Envoy/xDS control plane is gRPC streaming config
distribution; Terraform providers implement a gRPC/protobuf plugin protocol; DERP relays are NAT
traversal and connection relaying; AlloyDB→BigQuery is change-data-capture replication.

Known genuine gaps, closable through the homelab repos already cited in `Projects`:

- **Workflow orchestration** — no durable execution, saga/compensation, or task-queue experience.
  Industry-standard: Temporal, Argo Workflows, Airflow. Largest single gap for workflow-platform roles.
- **Event streaming** — deploying Kafka or Redpanda would make that keyword genuine rather than
  approximated by Pub/Sub.

Add these to `Projects` **only after the work is actually done.**

## Working preferences

- Ryan merges changes himself. Produce edits as a patch plus the full modified file rather than
  writing into the repo, unless he says otherwise.
- Don't commit generated PDFs as part of a content change; CI builds them.
