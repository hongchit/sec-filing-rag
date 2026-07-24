## Kestra MCP for Codex CLI

This trusted repository configures Kestra's public MCP server for Codex CLI.
Run Codex inside the Dev Container from the repository workspace. Start a new
Codex session after changing the MCP configuration so the server and its tools
are reloaded.

The Kestra MCP server provides current plugin properties and schemas, blueprint
flow YAML, product documentation, and related Kestra setup information.

## Local services

The Dev Container starts the application database, Kestra, its dedicated
PostgreSQL database, and Grafana. Rebuild the Dev Container after changing the
Compose or environment configuration.

- Kestra UI: [http://localhost:8082](http://localhost:8082)
- Kestra health: [http://localhost:8083/health](http://localhost:8083/health)
- Grafana: [http://localhost:3001](http://localhost:3001)

Kestra Basic Auth uses `KESTRA_BASIC_AUTH_USERNAME` and
`KESTRA_BASIC_AUTH_PASSWORD` from the ignored root `.env`. Its Gemini AI
Copilot uses `GEMINI_API_KEY`. Variables prefixed with `SECRET_` must contain
base64-encoded values before they can be used as Kestra secrets.

## License and copyright

This project is source-available under the [PolyForm Noncommercial License 1.0.0](LICENSE).
