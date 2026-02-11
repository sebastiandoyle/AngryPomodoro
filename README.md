# AngryPomodoro

A Pomodoro timer that gets progressively more annoyed at you the longer you ignore your break. Starts polite, ends unhinged. Built with SwiftUI and AVFoundation for increasingly aggressive audio cues.

## Features

- **Escalating personality** — the timer's tone shifts from gentle to exasperated as you overwork
- **Progressive audio alerts** — soft chime → persistent bell → angry buzzer → absurd sounds
- **Standard Pomodoro intervals** — 25/5 work/break with customizable durations
- **Session tracking** — daily and weekly Pomodoro counts
- **Focus mode** — minimal UI during work sessions
- **Break enforcement** — optional screen lock during breaks

## Tech Stack

- SwiftUI
- AVFoundation
- Combine
- Local notifications

## Getting Started

```bash
git clone https://github.com/sebastiandoyle/AngryPomodoro.git
cd AngryPomodoro
open *.xcodeproj
```

Requires Xcode 15+ and iOS 17+.

## The Escalation Ladder

1. **Polite** (0-2 min overdue): Gentle chime, "Time for a break!"
2. **Firm** (2-5 min): Repeated bells, "You really should stop."
3. **Annoyed** (5-10 min): Buzzer, screen shake, passive-aggressive copy
4. **Unhinged** (10+ min): Full chaos mode — you asked for this

## License

MIT
