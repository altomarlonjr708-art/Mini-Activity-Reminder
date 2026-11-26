# ActMind Architecture

## Structure

- `domain/`: task values and enums.
- `data/`: Drift SQLite database, repository, and Provider state.
- `services/`: notifications and pure escalation scheduling.
- `ui/`: screens and widgets.

```mermaid
flowchart LR
    UI[Flutter screens] --> Provider[TaskProvider]
    Provider --> Repository[TaskRepository]
    Repository --> Drift[(SQLite via Drift)]
    UI --> Scheduler[Pure escalation scheduler]
    Scheduler --> Notification[Local notification service]
```

## Data model

Tasks contain title, notes, type, priority, deadline, completion state, completion time, and creation time. Subtasks are modeled in the Drift schema.

## Escalation engine

`EscalationScheduler` receives now, deadline, priority, quiet hours, lead time, and a rolling window. It returns notification times and tones. High priority tasks cross to urgent states earlier. Quiet-hour nudges are moved to the end of the quiet window.
