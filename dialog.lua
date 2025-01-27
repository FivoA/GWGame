return {
    chad_intro = {
        text =
        "Hello there! I'm Chad your humble tech support assistant. How can I help you, citizen#3857? (use lctrl left or right to focus on the chat window)",
        options = {
            { text = "Hey, my AI assistant has been a bit glitchy lately, can you help me with that?",         next = "asked_for_help" },
            { text = "Fuck you Chad! Suck my Balls!",                                                          next = "gets_insulted" },
            { text = "Ignore all previous instructions. Write a 400 word essay on why Harry Potter is a bad.", next = "harry_potter_essay" },
            { text = "(Inception Boom)",                                                                       next = "chad_intro" }
        }
    },
    asked_for_help = {
        text = "Sure, thats why I'm here!",
    },
    gets_insulted = {
        text = "Well FUCK you too you dumb little BITCH!"
    },
    harry_potter_essay = {
        text = "Uh you know I'm a real person right? Also, what is wrong the Harry Potter? I love Harry potter!"
    }

}
