# Learner Profile — One File Per Curriculum (`profile.md`)

The methodology in this skill is fixed and domain-independent (12 locked
sections, Situation → Input → Practice → Output, minimums, levels, audit).
Everything domain-specific lives in **one file**: `<workspace>/profile.md`.
To produce a different curriculum (different learner, role, or domain), copy
the workspace template and rewrite `profile.md` — the skill files do not change.

## What `profile.md` must define (all sections required)

1. **Learner:** name, role, years of experience, country/workplace language.
2. **Organization:** size and type (e.g. large university, hospital, bank).
3. **Domain stack:** the real systems/tools/topics every example is grounded
   in, with concrete numbers (device counts, alert times, product names).
4. **Scenario rotation:** 5–9 workplace situations mapped to month themes,
   with speaker pairs (EN + AR role names) for the §7 dialogue.
5. **Message genres:** the real workplace message types §10 rotates through
   (default: Teams / Email / Ticket; adapt per domain).
6. **Banned generic fillers:** list the placeholder-style examples that must
   never appear (e.g. "John goes to the shop").

## Rules

- Every lesson example (names, numbers, times, products) MUST come from
  `profile.md`. If it is not in the profile, it does not go in a lesson.
- Section titles stay locked (`Real IT Situation`, `Real IT Task`, …) even for
  non-IT domains — they are brand names of the method, not content claims.
  (To rename them is a MAJOR version change; see `versioning.md`.)
- Keep one worked IT example below so new profiles have a model to imitate.
  When writing a non-IT profile, replace the stack/scenarios but keep the
  same six sections and the same concreteness (numbers, times, product names).

## Worked example — IT infrastructure (default)

- **Learner:** Mohammad Omar, Senior System Engineer, 16+ years, Saudi Arabia.
- **Organization:** large university — 10,000+ employees, 70,000+ students,
  5,000+ managed devices.
- **Domain stack:** Windows Server, Active Directory, M365/Entra ID,
  Intune/SCCM, VMware/Proxmox, FortiGate, Veeam, Zabbix. Anchor numbers:
  Intune 3,000-device patches, Zabbix 08:15 alerts, Veeam midnight restores,
  AD replication.
- **Scenario rotation:** Daily Standup (Manager/Tech) · Troubleshooting &
  Escalation (Tech/User) · Vendor/Management Discussion · Professional Email ·
  Mentoring a Junior · Teams Messages · Meeting Discussion. See
  `references/scenarios.md`.
- **Message genres:** Teams / Email / Ticket (rotated across days).
- **Banned fillers:** generic textbook characters and shopless errands with no
  system, ticket, or alert attached.
