---
layout: page
title: Sigstore
---

## Projects

- **Rekor** - tamper-resistant ledger of software metadata.
  - Interested parties query the ledger to decide whether to deploy or not.
  - It comes with a command line tool, `rekor-cli`
  - Uses [Trillian][trillian], a cryptographically verifiable data store.
- **Fulcio** - a free root CA for code signing certificates.
  - It produces certificates that are valid for 20 minutes.
  - Code signing CA.
- **Cosign** - container signing.
  - this is available in a container from `gcr.io`.
  - `cosign` uses `fulcio` to sign an image.

## Basic demo on OpenShift

See <https://github.com/redhat-et/sigstore-demo>.

[trillian]: https://github.com/google/trillian
