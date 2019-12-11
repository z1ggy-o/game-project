# Human Interface and Computer Game Design Final Report

## Team Member and Role

- Team 28

- 주광우 20165953
  - Game concept and overall design
  - Models and animations
  - Game menu
  - Character enhance system
  - Maps, Scene change
- 김재환 20155265
  - Character moving
  - Character and enemy attack
  - Enemy AI
  - Skill system

## Tools & Extra Points

- Open-source game engine: [Godot](https://godotengine.org/)
- Open-source graphics software: [Blender](https://www.blender.org/)
- Free models: [Mixamo](https://www.mixamo.com/)

- Collision detection: Attack, prevent go through walls, shooting...
- Animations: Walk, run, die ...

## Game Contents

### Game Name

Get my body back

### Game story line

The main character accidentally entered a dungeon one day. The life of the demon in the dungeon is very boring. In order to have fun, our character’s body is taken away, but he is given the ability to gain strength from other monsters. To get his body back, our character decides to challenge the demon and starts the adventure.

### Overall Design

This is a **roguelike** game. We implemented 5 levels right now. Enemies in higher levels become stronger so our player cannot pass the game in one time.

At first, players may fail very quickly. After kill enemies, we can get some points (we call these points "soul" in our game). Player can use these "souls" to enhance character's ability, so next players can go further.

### User Input Interface

- **Moving (forward, backward, left, right)**:  keyboard "W", "S", "A", "D" keys
- **Angle moving**: Mouse moving
- **Attack**: Mouse left key click
- **Shoot fireball**l: keyboard "F" key

### Power Up System

Players can upgrade character's ability by souls. On main menu, there is a "Power Up" submenu. In that menu, players can upgrade:

- Maximum HP
- Attack
- Speed

### Skill System

After kill we have some probability to get skills from enemies. Each enemy has its own specific skills. Now we have three different skills in our game:

- Attack up
- Hp up
- Shoot fireball

Every time we start a new game, the skills will be clear.