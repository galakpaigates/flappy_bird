--[[
    GD50
    Flappy Bird Remake

    bird11
    "The Audio Update"

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A mobile game by Dong Nguyen that went viral in 2013, utilizing a very simple 
    but effective gameplay mechanic of avoiding pipes indefinitely by just tapping 
    the screen, making the player's bird avatar flap its wings and move upwards slightly. 
    A variant of popular games like "Helicopter Game" that floated around the internet
    for years prior. Illustrates some of the most basic procedural generation of game
    levels possible as by having pipes stick out of the ground by varying amounts, acting
    as an infinitely generated obstacle course for the player.
]]

-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'lib/push'

-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
--
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'lib/class'

-- a basic StateMachine class which will allow us to transition to and from
-- game states smoothly and avoid monolithic code in one file
require 'src/StateMachine'

require 'src/states/BaseState'
require 'src/states/CountdownState'
require 'src/states/PlayState'
require 'src/states/ScoreState'
require 'src/states/TitleScreenState'

require 'src/Bird'
require 'src/Pipe'
require 'src/PipePair'

-- physical screen dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- virtual resolution dimensions
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local background = love.graphics.newImage('graphics/background.png')
local backgroundScroll = 0

local ground = love.graphics.newImage('graphics/ground.png')
local groundScroll = 0

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

local BACKGROUND_LOOPING_POINT = 413

-- global variable we can use to scroll the map
scrolling = true

function love.load()
    -- initialize our nearest-neighbor filter
    love.graphics.setDefaultFilter('nearest', 'nearest')
    
    -- seed the RNG
    math.randomseed(os.time())

    -- app window title
    love.window.setTitle('Fifty Bird')

    -- initialize our nice-looking retro text fonts
    smallFont = love.graphics.newFont('fonts/font.ttf', 8)
    mediumFont = love.graphics.newFont('fonts/flappy.ttf', 14)
    flappyFont = love.graphics.newFont('fonts/flappy.ttf', 28)
    hugeFont = love.graphics.newFont('fonts/flappy.ttf', 56)
    love.graphics.setFont(flappyFont)

    -- initialize our table of sounds
    gSounds = {
        ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
        ['explosion'] = love.audio.newSource('sounds/explosion.wav', 'static'),
        ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),

        -- https://freesound.org/people/xsgianni/sounds/388079/
        ['music'] = love.audio.newSource('sounds/marios_way.mp3', 'static')
    }

	-- victory icons to dipslay per the player's score
	gVictoryIcons = {
		['exceptional'] = love.graphics.newImage('graphics/medal.png'),
		['amazing'] = love.graphics.newImage('graphics/star.png'),
		['good'] = love.graphics.newImage('graphics/bow.png'),
		['poor'] = love.graphics.newImage('graphics/sad.png')
    }

    -- kick off music
    gSounds['music']:setLooping(true)
    gSounds['music']:play()

    -- initialize our virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = true,
        resizable = false
    })

    -- initialize state machine with all state-returning functions
    gStateMachine = StateMachine {
        ['title'] = function() return TitleScreenState() end,
        ['countdown'] = function() return CountdownState() end,
        ['play'] = function() return PlayState() end,
        ['score'] = function() return ScoreState() end
    }
    gStateMachine:change('title')

    -- initialize input table
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true

    if key == 'escape' then
        love.event.quit()
	elseif key == 'p' and gStateMachine.currentState == 'play' then
		if scrolling then
			scrolling = false
			gSounds['music']:pause()

			-- slightly increase the birds dy so the bird
			-- don't immediate start dropping when the player
			-- resumes the game
			gStateMachine.current.bird.dy = gStateMachine.current.bird.dy + -2
		else
			scrolling = true
			gSounds['music']:play()
		end
    end
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.mousepressed(x, y, button)
	love.mouse.wasPressed = true
end

function love.mouse.wasPressed()
	-- checking the boolean we added to the `love.mouse` table
	-- to know whether the mouse was pressed on the previous frame
	return love.mouse.wasPressed
end

function love.update(dt)
    if scrolling then
        backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
        groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH
    end

    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
	love.mouse.wasPressed = false
end

function love.draw()
    push:start()
    
    love.graphics.draw(background, -backgroundScroll, 0)
    gStateMachine:render()
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)
    
	if not scrolling and gStateMachine.currentState == 'play' then
	-- if the user has paused the game and the `scrolling` variable
	-- has changed to false, then render the `Paused` text and don't
	-- update anything else
		love.graphics.setFont(hugeFont)
		love.graphics.print("Paused", VIRTUAL_WIDTH / 3, VIRTUAL_HEIGHT / 2 - 50)
	end
    push:finish()
end

