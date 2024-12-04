# TODO LIST

- [x] 🐞 attacking a propelled opponent from ground breaks opponent's position
- [x] 🚀 block not implemented
- [x] 🚀 return to char selection screen after defeat in vs mode
- [x] 🚀 kl projectile sprites
- [x] 🚀 hold button support
- [x] 🐞 sometimes hitting an opponent doesn't make the special ac end
- [x] 🚀 support triggering release ac in middle of another ac like jumping and walking
- [x] 🚀 create sk char
- [x] 🐞 move sz_freeeze_timer to cap
- [x] 🐞 fix morph kn bl+bl+bl
- [x] 🐞 fix morph ml hold button
- [x] 🐞 reversible acs that requires forced stop stuck at the last frame
- [x] 🚀 music
- [x] 🐞 pressing directionals after landing a hook does not work, also roundhouse kick and block
- [x] 🚀 time's up not implemented
- [x] 🚀 support draw
- [x] 🚀 all special moves
- [x] 🐞 do not allow damage after cb end
- [x] 🚀 select char animation
- [x] 🐞 loser should stay prone after cb end
- [x] 🚀 game end screen
- [x] 🚀 final boss defeat animation
- [x] 🚀 add a delay to some attacks like roundhouse kick and projectile firing so initial animation can run before damage
- [x] 🐞 finishing the round with a special attack does not end the ac
- [x] 🚀 sfx
- [x] 🚀 create sound for pressing buttons in char selection screen
- [x] 🐞 should not push a frozen enemy in middle air
- [x] 🐞 bug when special attack vs at the edge of the screen
- [x] 🐞 freeze the opponent in middle air while overlapping it causes stack overflow (also happens on kl spin)
- [x] 🐞 should not allow tripping the opponent if it is not on ground level (ex: air frozen or jumping)
- [x] 🐞 hit an opponent teleporting makes it stops inside the ground
- [x] 🐞 fire a projectile at a teleported opponent makes the projectile change direction
- [x] 🐞 should not detect a hit when flying attack an opponent that is already behind the player
- [x] 🐞 should allow just one aerial special attack (projectile) per jump (more than one might stuck player in air)
- [x] 🐞 sc spear does not work on right side
- [x] 🚀 test blocked kl diving kick and ml teleport kick and sc teleport punch
- [x] 🐞 fix infinity hat spin after hat toss (holding up during the toss adds multiple ⬆️ to ac stack)
- [x] 🐞 finishing the opponent with jx special attacks doesn't trigger finishing animation
- [ ] 🚀 all finishing moves
- [ ] 🚀 pixel art stages
- [ ] 🚀 create rp invisibility animation and use the same for st morph
- [ ] 🚀 particles on projectiles
- [ ] 🚀 next cb screen
- [ ] 🚀 create kr char

# SOUNDS
✅ 14 - light hit
✅ 15 - heavy hit
✅ 16 - blocked blow
✅ 17 - jump | ml ground roll
✅ 18 - sweep
✅ 19 - generic projectile launch
✅ 20 - generic projectile hit
✅ 21 - generic flying attack | generic teleport
✅ 22 - lk bicycle kick | bk blade fury | rd electric grab
✅ 23 - kl spin
✅ 24 - rd teleport
✅ 25 - jc nut cracker
✅ 26 - rp invisibility | st morph
✅ 27 - sz freeze
✅ 28 - jx ground pound | rd torpedo hit
✅ 29 - jx gotcha
✅ 30 - jx back broken
✅ 31 - sc spear
✅ 32 - sc spear hit
✅ 33 - rd torpedo
✅ 34 - char selection move
✅ 35 - char selection confirm

# LATEST COUNTS
tokens: 7.231/8.192
chars: 62.854/65.535
compressed: 95%