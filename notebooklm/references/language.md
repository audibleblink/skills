# Language Configuration

Language setting controls the output language for generated artifacts (audio, video, etc.).

**Important:** Language is a **GLOBAL** setting that affects all notebooks in your account.

```bash
# List all 80+ supported languages with native names
notebooklm language list

# Show current language setting
notebooklm language get

# Set language for artifact generation
notebooklm language set zh_Hans  # Simplified Chinese
notebooklm language set ja       # Japanese
notebooklm language set en       # English (default)
```

## Common Language Codes

| Code | Language |
|------|----------|
| `en` | English |
| `zh_Hans` | 中文（简体） - Simplified Chinese |
| `zh_Hant` | 中文（繁體） - Traditional Chinese |
| `ja` | 日本語 - Japanese |
| `ko` | 한국어 - Korean |
| `es` | Español - Spanish |
| `fr` | Français - French |
| `de` | Deutsch - German |
| `pt_BR` | Português (Brasil) |

## Per-Command Override

Use `--language` flag on generate commands to override the global setting:

```bash
notebooklm generate audio --language ja    # Japanese podcast
notebooklm generate video --language zh_Hans  # Chinese video
```

## Offline Mode

Use `--local` flag to skip server sync:

```bash
notebooklm language set zh_Hans --local  # Save locally only
notebooklm language get --local          # Read local config only
```
