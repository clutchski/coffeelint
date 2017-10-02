class Voldemort

  avadaKadavra: (enemy) ->
    enemy.die()

  generateHorcruxes: (scrifices = []) ->
    voldemort = []
    for s in scrifices
      voldemort.push new Horcrux @avadaKadavra(s)

    return voldemort

