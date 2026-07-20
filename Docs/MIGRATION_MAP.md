# Public-release sanitization

The public repository was created as a new repository rather than by copying
the private repository's Git history.

The release process excluded:

- historical and organization-specific archives;
- personal notes and Office workbooks;
- book examples and code attributed to external authors without a confirmed
  redistribution license;
- generated reports, exports, logs, credentials, and editor metadata.

Environment-specific identifiers were replaced with neutral examples or made
runtime parameters. The resulting repository should still be reviewed before
each release because future commits can introduce new sensitive values.

