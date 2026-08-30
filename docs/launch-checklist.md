# Launch Checklist

Any unchecked launch-blocking item prevents mainnet deployment.

## Checklist Control

Use this file as the launch gate index. A checkbox can only move to done after
the owner has linked evidence in the evidence log and the required review gate
has passed.

Status terms:

- `TODO`: no merged evidence yet.
- `IN PROGRESS`: a PR or external review is active.
- `BLOCKED`: waiting on missing evidence, owner decision, external dependency,
  or failed validation.
- `DONE`: evidence is linked, reviewed, and merged.
- `N/A`: explicitly out of scope for the current launch, with rationale.

## Owner And Date Matrix

Dates are gate deadlines, not calendar promises. Replace role owners with named
owners before Shadownet deployment.

| Gate | Primary owner | Reviewers | Due gate | Required evidence | Status |
|---|---|---|---|---|---|
| Upstream and licensing | Release owner | Legal reviewer, protocol engineer | Before Shadownet deployment | Upstream SHA table, license review notes, NOTICE delta, fork policy review | TODO |
| Build and tests | Protocol engineer | Release owner | Every PR and before each deployment rehearsal | CI run, local command output where available, gas snapshot decision | TODO |
| Security review | Security reviewer | Protocol engineer, external auditor | Before mainnet approval | Static-analysis results, fork-diff report, finding tracker, audit package | TODO |
| Oracle readiness | Oracle reviewer | Risk owner, protocol engineer, monitoring owner | Before market approval | Feed proofs, decimals/freshness evidence, failure-mode tests, fallback decision | TODO |
| Market readiness | Risk owner | Oracle reviewer, security reviewer, operations lead | Before Shadownet market creation | Asset reviews, market config, LLTV/IRM/cap rationale, liquidation assumptions | TODO |
| Etherlink readiness | Operations lead | Deployment owner, monitoring owner | Before Shadownet deployment and again before mainnet | Chain/RPC/explorer proofs, failover plan, monitoring and bot readiness | TODO |
| Deployment readiness | Deployment owner | Release owner, security reviewer | Before each broadcast | Dry-run evidence, admin/multisig proof, artifact validation, final approval | TODO |
| Post-launch operations | Operations lead | Risk owner, monitoring owner | Before mainnet market visibility | Watch assignment, incident contacts, risk report cadence, public docs update | TODO |

## Evidence Log Format

Add evidence under the relevant checklist section or in a linked PR using this
format. Keep command output concise, but include enough detail for a reviewer to
reproduce the claim.

```text
Evidence ID: YYYYMMDD-short-slug
Checklist item(s): <section and checkbox text>
Status: TODO | IN PROGRESS | BLOCKED | DONE | N/A
Owner: <named owner or role owner>
Due gate: <gate from owner/date matrix>
Evidence source: <PR URL, commit SHA, CI run URL, doc path, artifact path, or external review link>
Validation: <commands run, CI jobs, on-chain calls, audit references, or manual review>
Result: <pass/fail/blocked summary>
Reviewer: <reviewer or required reviewer role>
Decision: <accepted, rejected, needs follow-up, or N/A with rationale>
Follow-up: <issue, PR, or explicit none>
```

## Upstream And Licensing

License review record: [License And Legal Review](license-review.md). The
technical review is complete; legal signoff is the outstanding gate and is
tracked in that document's Signoff section.

- [ ] Upstream SHAs pinned.
- [ ] Licenses reviewed.
- [ ] NOTICE updated.
- [ ] Legal review complete.

## Build And Tests

Baseline verification record: [Baseline Verification](baseline-verification.md).

- [ ] Clean build.
- [ ] Unit tests passing.
- [ ] Fork tests passing.
- [ ] Fuzz tests passing.
- [ ] Invariant tests passing.
- [ ] Gas snapshot reviewed.

## Security Review

- [ ] Static analysis complete.
- [ ] Fork diff reviewed.
- [ ] External audit complete.
- [ ] No unresolved criticals.
- [ ] No unresolved highs.
- [ ] Medium findings accepted or fixed.
- [ ] Security contact active.

## Oracle Readiness

Feed-support evidence:
[RedStone Etherlink Feed-Support Check](../config/oracles/redstone-etherlink-feed-support.md)
and [Pyth Etherlink Feed Verification](../config/oracles/pyth-etherlink-feed-verification.md).

Current blocker: RedStone supports XTZ/ETH/BTC only and **reverts on USDC**
(signer threshold 2, ~16s push cadence). Pyth **does** serve USDC/USD but its
freshness is not maintained — a 162s-old price was observed against a 60s
validity period, and the strict accessors revert. **Neither provider alone can
price WXTZ/USDC today**; see the Phase 3C options in the Pyth document.

- [ ] Oracle source selected.
- [ ] Feed exists.
- [ ] Feed decimals verified.
- [ ] Staleness policy defined.
- [ ] Failure mode tested.
- [ ] Fallback policy defined or explicitly rejected.
- [ ] RedStone RPC/relayer plan reviewed, if RedStone is used.
- [ ] RedStone data-service ID, signer threshold, adapter/feed address, and update conditions documented, if RedStone is used.

## Market Readiness

- [ ] Loan asset reviewed.
- [ ] Collateral asset reviewed.
- [ ] Token decimals verified.
- [ ] Token behavior reviewed.
- [ ] Liquidity reviewed.
- [ ] LLTV approved.
- [ ] IRM approved.
- [ ] Caps/curation controls configured where applicable.
- [ ] Liquidation tested.

## Etherlink Readiness

- [ ] Chain IDs verified.
- [ ] RPC provider selected.
- [ ] Explorer verification tested.
- [ ] Deployment method tested.
- [ ] Dedicated production RPC ready.
- [ ] RPC failover and relayer funding ready for oracle operations, if applicable.
- [ ] Monitoring ready.
- [ ] Liquidation bot ready.

## Deployment Readiness

- [ ] Deployer procedure reviewed.
- [ ] Multisig/admin addresses verified.
- [ ] Dry run complete.
- [ ] Shadownet deploy complete.
- [ ] Shadownet smoke tests complete.
- [ ] Mainnet config frozen.
- [ ] Final approval recorded.

## Post-Launch

- [ ] Deployment artifacts stored.
- [ ] Contracts verified.
- [ ] Monitoring active.
- [ ] First 24-hour watch assigned.
- [ ] Incident response contacts online.
- [ ] Public docs updated.

## Blocking TODOs

- Owner: release owner. Action: replace role owners in the owner/date matrix
  with named owners. Date: before Shadownet deployment.
- Owner: release owner. Action: require every future checklist-closing PR to
  include an evidence log entry. Date: effective immediately.
