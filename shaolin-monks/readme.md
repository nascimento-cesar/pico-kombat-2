# TODO LIST

- [x] 🐞 attacking a propelled opponent from ground breaks opponent's position
- [x] 🚀 block not implemented
- [x] 🚀 return to char selection screen after defeat in vs mode
- [x] 🚀 kl projectile sprites
- [x] 🚀 hold button support
- [x] 🐞 sometimes hitting an opponent doesn't make the special action end
- [x] 🚀 support triggering release action in middle of another action like jumping and walking
- [x] 🚀 create sk character
- [x] 🐞 move sz_freeeze_timer to cap
- [x] 🐞 fix morph kn bl+bl+bl
- [x] 🐞 fix morph ml hold button
- [x] 🐞 reversible actions that requires forced stop stuck at the last frame
- [x] 🚀 music
- [x] 🐞 pressing directionals after landing a hook does not work, also roundhouse kick and block
- [x] 🚀 time's up not implemented
- [x] 🚀 support draw
- [x] 🚀 all special moves
- [x] 🐞 do not allow damage after combat end
- [x] 🚀 select character animation
- [x] 🐞 loser should stay prone after combat end
- [x] 🚀 game end screen
- [x] 🚀 final boss defeat animation
- [x] 🚀 add a delay to some attacks like roundhouse kick and projectile firing so initial animation can run before damage
- [ ] 🚀 next combat screen
- [ ] 🚀 particles on projectiles
- [ ] 🚀 all finishing moves
- [ ] 🚀 pixel art stages
- [ ] 🚀 sfx
- [ ] 🚀 create sound for pressing buttons in character selection screen
- [ ] 🐞 should not allow tripping the opponent if it is not on ground level (ex: air frozen or jumping)
- [ ] 🐞 should not detect a hit when flying attack an opponent that is already behind the player
- [ ] 🐞 bug when special attack vs at the edge of the screen
- [ ] 🐞 finishing the round with a special attack does not end the action
- [ ] 🐞 freeze the opponent in middle air while overlapping it causes stack overflow (also happens on kl spin)
- [ ] 🐞 fire a projectile at a teleported opponent makes the projectile change direction
- [ ] 🐞 hit an opponent teleporting makes it stops inside the ground
- [ ] 🐞 should not push a frozen enemy in middle air
- [ ] 🐞 sc spear does not work on right side
- [ ] 🐞 fix infinity hat spin after hat toss (holding up during the toss adds multiple ⬆️ to action stack)
- [ ] 🐞 should allow just one aerial special attack (projectile) per jump (more than one might stuck player in air)
- [ ] 🚀 create rp invisibility animation and use the same for st morph
- [ ] 🚀 test blocked kl diving kick and ml teleport kick and sc teleport punch
- [ ] 🚀 create kr character

# LATEST COUNTS
tokens: 7.133/8.192
chars: 60.548/65.535
compressed: 97%

# SOUNDS
14 - light hit
15 - heavy hit
16 - blocked blow
17 - jump
18 - sweep
19 - generic projectile launch
20 - generic projectile hit
21 - generic flying attack
22 - lk bicycle kick | bk blade fury | rd electric grab
23 - kl spin
24 - generic teleport
25 - jc nut cracker
26 - rp invisibility | st morph
27 - sz freeze
28 - jx ground pound | rd torpedo hit
29 - jx gotcha
30 - jx back broken
31 - sc spear
32 - sc spear hit
33 - rd torpedo