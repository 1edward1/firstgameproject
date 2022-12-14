function love.load()
    gameBackground = love.graphics.newImage("mountainlandscape.png")
    helicopter = love.graphics.newImage("helicopter.png")

    helicopterWidth = 45
    helicopterHeight = 27

    helicopterX = 62

    playingAreaWidth = 300
    playingAreaHeight = 388

    pipeSpaceHeight = 100
    pipeWidth = 54

    fontScore = love.graphics.newFont(30)
    fontTitle = love.graphics.newFont(20)
    fontCommands = love.graphics.newFont(16)

    function newPipeSpaceY()
        local pipeSpaceYMin = 54
        local pipeSpaceY = love.math.random(
            pipeSpaceYMin,
            playingAreaHeight - pipeSpaceHeight - pipeSpaceYMin
        )
        return pipeSpaceY
    end

    function reset()
        helicopterY = 200
        helicopterYSpeed = 0

        pipe1X = playingAreaWidth
        pipe1SpaceY = newPipeSpaceY()

        pipe2X = playingAreaWidth + ((playingAreaWidth + pipeWidth) / 2)
        pipe2SpaceY = newPipeSpaceY()

        score = 0

        upcomingPipe = 1
    end

    gameState = 'start'
    reset()
end

function love.update(dt)
    if gameState == 'play' then
        helicopterYSpeed = helicopterYSpeed + (516 * dt)
        helicopterY = helicopterY + (helicopterYSpeed * dt)

        local function movePipe(pipeX, pipeSpaceY)
            pipeX = pipeX - (60 * dt)

            if (pipeX + pipeWidth) < 0 then
                pipeX = playingAreaWidth
                pipeSpaceY = newPipeSpaceY()
            end

            return pipeX, pipeSpaceY
        end

        pipe1X, pipe1SpaceY = movePipe(pipe1X, pipe1SpaceY)
        pipe2X, pipe2SpaceY = movePipe(pipe2X, pipe2SpaceY)

        function isHelicopterCollidingWithPipe(pipeX, pipeSpaceY)
            return
            -- Left edge of bird is to the left of the right edge of pipe
            helicopterX < (pipeX + pipeWidth)
            and
            -- Right edge of bird is to the right of the left edge of pipe
            (helicopterX + helicopterWidth) > pipeX
            and (
                -- Top edge of bird is above the bottom edge of first pipe segment
                helicopterY < pipeSpaceY
                or
                -- Bottom edge of bird is below the top edge of second pipe segment
                (helicopterY + helicopterHeight) > (pipeSpaceY + pipeSpaceHeight)
            )
        end

        if isHelicopterCollidingWithPipe(pipe1X, pipe1SpaceY)
        or isHelicopterCollidingWithPipe(pipe2X, pipe2SpaceY)
        or helicopterY > playingAreaHeight then
            sound = love.audio.newSource("failsound.wav", "static")
            sound:play()
            reset()
            love.load()
            gameState = 'start'
        end

        local function updateScoreAndClosestPipe(thisPipe, pipeX, otherPipe)
            if upcomingPipe == thisPipe
            and (helicopterX > (pipeX + pipeWidth)) then
                score = score + 1
                upcomingPipe = otherPipe
                sound = love.audio.newSource("coinsound.wav", "static")
                sound:play()
            end
        end

        updateScoreAndClosestPipe(1, pipe1X, 2)
        updateScoreAndClosestPipe(2, pipe2X, 1)
    end
end

function love.keypressed(key)
    if key == "space" and gameState == 'play' then
        if helicopterY > 0 then
            helicopterYSpeed = -165
            sound = love.audio.newSource("playerjump.wav", "static")
            sound:play()
        end
    end

    if key == "escape" then
        love.event.quit()

    elseif key == 'enter' or key =='return' then
        if gameState == 'start' then
            gameState = 'play'
        end
    end
end

function love.draw()
    love.graphics.draw(gameBackground, 0, 0)
    love.graphics.draw(helicopter, helicopterX, helicopterY, 0, .75, .75, helicopterWidth / 2, helicopterHeight / 2)


    local function drawPipe(pipeX, pipeSpaceY)
        love.graphics.setColor(178/255, 34/255, 34/255)
        love.graphics.rectangle(
            'fill',
            pipeX,
            0,
            pipeWidth,
            pipeSpaceY
        )
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle(
            'line',
            pipeX,
            0,
            pipeWidth,
            pipeSpaceY
        )
        love.graphics.setColor(178/255, 34/255, 34/255)
        love.graphics.rectangle(
            'fill',
            pipeX,
            pipeSpaceY + pipeSpaceHeight,
            pipeWidth,
            playingAreaHeight - pipeSpaceY - pipeSpaceHeight
        )
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle(
            'line',
            pipeX,
            pipeSpaceY + pipeSpaceHeight,
            pipeWidth,
            playingAreaHeight - pipeSpaceY - pipeSpaceHeight
        )
    end

    drawPipe(pipe1X, pipe1SpaceY)
    drawPipe(pipe2X, pipe2SpaceY)

    local function drawScore()
        love.graphics.setFont(fontScore)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(score, 15, 15)
    end

    drawScore()

    local function drawStartMenu()
        love.graphics.draw(gameBackground, 0, 0)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle('fill', 0, 40, 300, 70)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('line', 0, 40, 300, 70)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('line', 50, 210, 200, 100)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle('fill', 50, 210, 200, 100)
        
    end
    
    
    local function drawText()
        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(fontTitle)
        love.graphics.print("It's A Chopper, Baby!", 45, 65)
        love.graphics.setFont(fontCommands)
        love.graphics.print("Try to dodge the pipes", 65, 220)
        love.graphics.print("Press 'enter' to start", 65, 250)
        love.graphics.print("Press 'space' to jump", 65, 280)

    end

    if gameState == 'start' then
        drawStartMenu()
        drawText()
    end
end