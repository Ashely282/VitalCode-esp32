# VITALCODE Frontend

## Overview
The VITALCODE Frontend is an interactive, modern user interface for the VITALCODE smart healthcare and assistant system. Built as a Single Page Application (SPA), it provides real-time monitoring of patient/user vital signs, environmental metrics, fall detection alerts, medication schedules, voice interaction logs, and device configurations.

Designed with a sleek, high-tech dashboard interface, it communicates directly with the VITALCODE backend services over HTTP/REST and WebSocket protocols to render live updates, telemetry charts, and system status indicators.

---

## Features

* **Real-time Telemetry Dashboard**: Live monitoring of key metrics including heart rate (BPM), SpO2 levels, ambient temperature, and humidity.
* **Fall Detection & Alerts Panel**: Instant visual alerts and historical logging for detected fall events with action triggers.
* **Medication Scheduler & Verification**: Interface to create, view, and manage medication reminder schedules and pill verification logs.
* **Voice Assistant Logs**: Live tracking and display of voice command interactions, transcriptions, and device responses.
* **Device Control & Status**: Monitoring of connected ESP32 hardware status, Wi-Fi signal strength, and MQTT connection states.
* **Responsive High-Tech UI**: Dark-mode optimized layout built with CSS modules and grid layouts for seamless viewing across screens.

---

## Technology Stack

| Category | Technology |
| :--- | :--- |
| **Framework / Library** | React 18 / HTML5 / JavaScript (ES6+) |
| **Build Tool & Bundler** | Vite / Webpack |
| **Package Manager** | npm / yarn |
| **Styling** | CSS3 / PostCSS / Tailwind CSS / Styled Components |
| **Real-time Communication** | WebSockets / Socket.io / Native EventSource |
| **HTTP Client** | Axios / Native Fetch API |
| **Charting / Visualization** | Chart.js / Recharts |
| **Icons** | Lucide React / React Icons |

---

## Architecture

```mermaid
graph TD
    User([User / Caregiver]) <--> UI[React SPA Frontend]
    
    subgraph "Frontend Architecture"
        UI <--> State[State Management / Hooks]
        UI <--> Comp[Dashboard Components & Panels]
        Comp <--> Charts[Visualization Engine]
    end
    
    subgraph "Communication Layer"
        State <--> REST[REST API Client]
        State <--> WS[WebSocket Client]
    end

    REST <--> Backend[VITALCODE Backend Service]
    WS <--> Backend
    Backend <--> ESP32[ESP32 Hardware Module]