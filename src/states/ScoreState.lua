--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen

	local victoryIcon = getVictoryIcon(self.score)
	love.graphics.draw(victoryIcon, (VIRTUAL_WIDTH / 2) - 38, 40, 0, 0.13, 0.13)

    love.graphics.setFont(flappyFont)
    love.graphics.printf(displayVictoryText(self.score), 0, 120, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 172, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter to Play Again!', 0, 210, VIRTUAL_WIDTH, 'center')
end

function displayVictoryText(score)
	-- return the corresponding victory text per the score the player reached
	if score >= 9 then
		return "Exceptional Performance!"
	elseif score >= 6 then
		return "Wow, You were amazing!"
	elseif score >= 3 then
		return "Good, Keep trying!"
	else
		return "Oof! You lost!"
	end
end

function getVictoryIcon(score)
	-- return the corresponding icon per the score the player reached
	if score >= 9 then
		return gVictoryIcons['exceptional']
	elseif score >= 6 then
		return gVictoryIcons['amazing']
	elseif score >= 3 then
		return gVictoryIcons['good']
	else
		return gVictoryIcons['poor']
	end
	
end

