# Dungeon Koop Game

> Ein 2D-Pixel-Art Jump & Run mit Online-Koop-Modus für 2 Spieler – entwickelt mit **Godot 4** für mobile Geräte im Querformat.

---

## Screenshots

> _Screenshots folgen sobald die ersten Szenen implementiert sind._

| Hauptmenü | Kerker-Level | Höhlen-Level |
|-----------|-------------|--------------|
| ![Hauptmenü](docs/screenshots/mainmenu.png) | ![Kerker](docs/screenshots/dungeon.png) | ![Höhle](docs/screenshots/cave.png) |

---

## Spielkonzept

Zwei Spieler erkunden gemeinsam prozedural generierte Dungeons und Höhlen, kämpfen gegen Gegner, lösen Rätsel und besiegen mächtige Bosse. Das Spiel setzt auf engen Koop – manche Rätsel und Aktionen sind nur gemeinsam lösbar.

- **Querformat** optimiert für Smartphones und Tablets
- **Online-Koop** über Einladungscode – keine Anmeldung nötig
- **Prozedural generierte Level** – jeder Run ist anders
- **Pixel Art** Grafikstil mit animierten Charakteren und Tiles

---

## Tech Stack

| Bereich            | Technologie                          | Zweck                                        |
|--------------------|--------------------------------------|----------------------------------------------|
| **Engine**         | Godot 4.x (GDScript)                 | Spiellogik, Physik, Rendering                |
| **Netzwerk**       | Photon Fusion / ENet                 | Online-Koop, Lobby, Echtzeit-Synchronisation |
| **Backend**        | Firebase (Firestore + Auth)          | Spielstände, Bestenlisten, Nutzerkonten       |
| **Plattform**      | Android & iOS                        | Mobile Export via Godot Export-Templates      |
| **Grafik**         | Pixel Art (Aseprite)                 | Sprites, Tilesets, Animationen               |
| **Audio**          | FMOD / Godot AudioStreamPlayer       | Musik, Soundeffekte, Umgebungs-Audio         |

---

## Projektstruktur

```
dungeon-koop-game/
│
├── assets/
│   ├── characters/
│   │   ├── player1/       – Sprite-Sheets und Animationen für Spieler 1
│   │   └── player2/       – Sprite-Sheets und Animationen für Spieler 2
│   ├── enemies/
│   │   ├── gorilla/       – Gorilla-Gegner (Höhlen-Biom)
│   │   └── skeleton/      – Skelett-Gegner (Kerker-Biom)
│   ├── tilesets/
│   │   ├── dungeon/       – Kerker-Tiles (Steine, Fallen, Türen)
│   │   └── cave/          – Höhlen-Tiles (Felsen, Kristalle, Abgründe)
│   ├── ui/
│   │   ├── mainmenu/      – Grafiken für das Hauptmenü
│   │   └── hud/           – Lebensleiste, Koop-Anzeige, Minimap
│   └── audio/
│       ├── music/         – Hintergrundmusik je Biom
│       └── sfx/           – Soundeffekte (Sprung, Angriff, Treffer, etc.)
│
├── scenes/
│   ├── ui/                – Hauptmenü, Lobby, Pause-Menü, Game-Over
│   ├── game/              – Hauptspiel-Szene, Kamera, Welt-Node
│   └── enemies/           – Vorgefertigte Szenen für jeden Gegner-Typ
│
├── scripts/
│   ├── player/
│   │   └── player.gd           – Spieler-Steuerung, Kampf, Koop-Aktionen
│   ├── enemies/                 – KI-Skripte für Gorilla, Skelett, Bosse
│   ├── network/
│   │   └── network_manager.gd  – Online-Koop, Lobby, RPC-Synchronisation
│   ├── level/
│   │   └── level_generator.gd  – Prozeduraler Level-Generator
│   └── ui/                     – Menü-Logik, HUD-Aktualisierung
│
├── biomes/
│   ├── dungeon.json       – Kerker: Gegner, Tiles, Rätsel, Schwierigkeit
│   └── cave.json          – Höhle: Gegner, Tiles, Rätsel, Schwierigkeit
│
└── project.godot          – Godot 4 Projektdatei
```

---

## Biome

| Biom        | Gegner                           | Besonderheit                         |
|-------------|----------------------------------|--------------------------------------|
| **Kerker**  | Skelette, Skelett-Bogenschützen  | Schalter-Rätsel, enge Gänge          |
| **Höhle**   | Gorillas, Riesenfledermäuse      | Kristall-Rätsel, Abgründe, Echos     |

Jedes Biom hat 4 Schwierigkeitsgrade: `leicht`, `normal`, `schwer`, `albtraum`.

---

## Setup für neue Entwickler

### Voraussetzungen

- [Godot 4.x](https://godotengine.org/download) (Mono-Version für C# optional)
- Git

### Projekt einrichten

```bash
# Repository klonen
git clone https://github.com/DEIN_USERNAME/dungeon-koop-game.git
cd dungeon-koop-game

# Projekt in Godot öffnen
# → Godot starten → "Importieren" → project.godot auswählen
```

### Photon einrichten (Online-Koop)

1. Kostenloses Konto auf [photonengine.com](https://www.photonengine.com/) erstellen
2. Neue App anlegen → App-ID kopieren
3. Datei `PhotonServerSettings.asset` lokal anlegen (wird von `.gitignore` ausgeschlossen)
4. App-ID in `scripts/network/network_manager.gd` eintragen

### Firebase einrichten (Bestenliste / Spielstände)

1. Projekt auf [firebase.google.com](https://firebase.google.com/) erstellen
2. Android-App hinzufügen → `google-services.json` herunterladen
3. `google-services.json` ins Projektverzeichnis legen (wird von `.gitignore` ausgeschlossen)
4. Firestore-Datenbank im Firebase-Dashboard aktivieren

### Lokal testen (Netzwerk)

Für Online-Koop-Tests zwei Godot-Instanzen starten:

```
Instanz 1 (Host):   NetworkManager.hoste_spiel()   → Lobby-Code notieren
Instanz 2 (Client): NetworkManager.trete_bei(code) → Lobby-Code eingeben
```

---

## Geplante Features

### Kern-Gameplay
- [ ] Prozeduraler Level-Generator mit Seed-System
- [ ] Flüssige Spieler-Bewegung (Laufen, Springen, Doppelsprung)
- [ ] Nahkampf- und Fernkampf-Angriffe
- [ ] Koop-Aktionen (Spieler tragen, wiederbeleben)

### Online-Modus
- [ ] Online-Lobby mit 6-stelligem Einladungscode
- [ ] Echtzeit-Synchronisation über Photon Fusion
- [ ] Reconnect-Funktion bei Verbindungsabbruch
- [ ] Ping-Anzeige im HUD

### Inhalte
- [ ] 2 spielbare Charaktere mit unterschiedlichen Fähigkeiten
- [ ] 2 Biome: Kerker und Höhle, je mit eigenem Boss
- [ ] Koop-Rätsel (gleichzeitige Aktionen beider Spieler nötig)
- [ ] Truhen, Items und Gold-System

### Mobile & Polishing
- [ ] Touch-Controls mit virtuellem Joystick
- [ ] Pixel Art Animationen für alle Charaktere und Gegner
- [ ] Dynamischer Soundtrack je nach Biom und Spannung
- [ ] Firebase Bestenliste (schnellste Boss-Kills, meiste Runs)

---

## Lizenz

Dieses Projekt ist privat. Alle Rechte vorbehalten.
