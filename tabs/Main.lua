-- Speakeasy

-- A little demo of the speech API

-- When the demo runs it will show the keyboard and
--  allow you to type.
-- typing will start a timer, once finished it will
--  say what you've written using the speech API

-- See the Sounds chapter in the docs for more info
--  on the speech API

displayMode(FULLSCREEN)
supportedOrientations(LANDSCAPE_ANY)

function setup()
-- An example of voices

-- List all voices
for k,v in ipairs(speech.voices) do
    print(k, v)
end

-- Set default language
speech.language = "en-US"

-- Set specific voice
-- (Overrides language setting)
--speech.voice = speech.voices[35]

    print("Listen and type what you heard")
    MINCOUNT = 4
    MOVEONCOUNT = 5
    FALLBACKCOUNT = 3
    RANGE = "0123456789abcdefghijklmnopqrstuvwxyz"
    
    parameter.number("SpeechRate", 0, 1, 0.05, function(val)
        speech.rate = val
    end)
    
    parameter.number("SpeechPitch", 0.5, 2, 1, function(val)
        speech.pitch = val
    end)

    math.randomseed(os.time())
    numvals = MINCOUNT
    numcorrect = 0
    numwrong = 0
    initvalues()
    
    --speakWords()
    
    showKeyboard()

end

function initvalues()
    words = ""
    wordarray = {}
    for count = 1, numvals do
        pickone = math.random(1, #RANGE)
        oneword = RANGE:sub(pickone, pickone)
        wordarray[count] = oneword
        words = words .. oneword
    end
    reciteanswer()
    speech.postDelay = 0
    words = words:gsub(".", "%1,"):sub(1, -2)
    answer = words
    --print(words)
    typedwords=""
    lastSpoken = ""
    resetSpeakDelay()
    reinit = false
end

function reciteanswer()
    speech.say("Remember the following.")
    speech.postDelay = 1
    for count = 1, numvals do
        speech.say(wordarray[count])
    end
    recite = false
    debounce = 5
end

function resetSpeakDelay()
    speakDelay = 1.0
end

function speakWords()
    
    resetSpeakDelay()

    if words ~= "" then
        speech.say(words)
        
        lastSpoken = words
        
        words = ""
    end
end

function keyboard(key)
    
    if speech.speaking then
        return
    end
    resetSpeakDelay()
    if key == RETURN then
        words = typedwords:gsub(".", "%1,"):sub(1, -2)
        --words = typedwords
        if words == answer then
            words = words .. ".....You are correct!"
            numwrong = 0
            numcorrect = numcorrect + 1
            if numcorrect >= MOVEONCOUNT then
                numcorrect = 0
                numvals = numvals + 1
            end
            reinit = true
        else
            words = words .. ".....That is incorrect!"
            typedwords = ""
            numwrong = numwrong + 1
            if numwrong >= FALLBACKCOUNT and numvals > MINCOUNT then
                numvals = numvals - 1
                reinit = true
            else
                recite = true
            end
        end
        speakWords()
    elseif key == BACKSPACE then
        typedwords = string.sub(typedwords, 1, -2)
    elseif #typedwords < numvals then
        typedwords = typedwords .. key:lower()
    end

end

-- This function gets called once every frame
function draw()
    -- This sets a dark background color 
    background(40, 40, 50)
    fill(255, 0, 148, 255)

    local cursorspeed = 2
    local cursorlen = (ElapsedTime * cursorspeed % 2) // 1
    local cursor = string.rep("\u{25af}", cursorlen) .. string.rep("\u{25ae}", 1 - cursorlen)
    -- Do your drawing here
    --if typedwords then
    if not speech.speaking then
        if reinit then
            initvalues()
        elseif recite then
            reciteanswer()
        else
            if debounce > 0 then
                debounce = debounce - 1
            else
                font("Vegur")
                fontSize(80)
                textWrapWidth(WIDTH - 20)
                text(typedwords .. cursor, WIDTH/2, HEIGHT*0.75)
            end
        end
    end
    
    --[[
    if speakDelay <= 0 then
        speakWords()
    end
    ]]--
    
    speakDelay = speakDelay - DeltaTime 
    
end

function touched(touch)
    
    if touch.tapCount == 1 and touch.state == ENDED then
        showKeyboard()
    end
    
end

