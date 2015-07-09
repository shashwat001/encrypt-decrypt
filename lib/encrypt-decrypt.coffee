vigenereView = require './vigenere-view'

module.exports =

  activate: (state) ->
    @vigenereView = new vigenereView(state.vigenereViewState)
    @vigenerePanel = atom.workspace.addModalPanel(item: @vigenereView.getElement(), visible: false)

    ### Frequency Analysis ###
    atom.commands.add 'atom-text-editor', 'encrypt-decrypt:frequency-analysis': => @frequencyanalysis()


    ### Tranform text ###
    atom.commands.add 'atom-text-editor', 'encrypt-decrypt:transform-charToCode': => @transformcharToCode()
    atom.commands.add 'atom-text-editor', 'encrypt-decrypt:transform-codeToChar': => @transformcodeToChar()
    atom.commands.add 'atom-text-editor', 'encrypt-decrypt:transform-toUpperCase': => @transformtoUpperCase()
    atom.commands.add 'atom-text-editor', 'encrypt-decrypt:transform-toLowerCase': => @transformtoLowerCase()

    ### Caesar ###
    atom.commands.add 'atom-text-editor', 'encrypt-decrypt:encrypt-caesar': => @encryptcaesar()
    atom.commands.add 'atom-text-editor', 'encrypt-decrypt:decrypt-caesar': => @decryptcaesar()

    ### Vigenere ###
    atom.commands.add 'atom-text-editor', 'encrypt-decrypt:encrypt-vigenere': => @encryptvigenere()
    atom.commands.add 'atom-text-editor', 'encrypt-decrypt:decrypt-vigenere': => @decryptvigenere()
    ### Set event on "Go" button ###
    submit = @vigenereView.getSubmit()
    submit.addEventListener "click", (e) => @vigenereFromInput()

  getTextSelected: ->
    @editor = atom.workspace.getActiveTextEditor()
    @selection = @editor.getLastSelection()
    return @selection.getText()

  replaceText:(newText, option) ->
    @selection.insertText(newText, option)

  frequencyanalysis: ->
    text = @getTextSelected()
    lengthText = text.length
    if(lengthText > 0)
        listChar = {}
        for i in [0..lengthText-1]
            char = text.charAt(i)
            nb = 0
            if(char of listChar)
                nb = listChar[char]
            listChar[char] = nb + 1

        console.log 'Length of the text: ' + lengthText
        for own key, value of listChar
            console.log key + ' : ' + ((value*100)/lengthText) + '%'

  transformcharToCode: ->
    text = @getTextSelected()
    lengthText = text.length
    if(lengthText > 0)
        newStr = ''
        charSplit = ' '
        for i in [0..lengthText-1]
            newStr = newStr + text.charCodeAt(i) + charSplit
        @replaceText(newStr.substring(0, newStr.length-1), {'select': true})

  transformcodeToChar: ->
    text = @getTextSelected()
    lengthText = text.length
    if(lengthText > 0)
        charSplit = ' '
        listCode = text.split charSplit
        newStr = ''
        for code in listCode
            newStr = newStr + String.fromCharCode(code)
        @replaceText(newStr , {'select': true})

  transformtoUpperCase: ->
    text = @getTextSelected()
    @replaceText(text.toUpperCase() , {'select': true})

  transformtoLowerCase: ->
    text = @getTextSelected()
    @replaceText(text.toLowerCase() , {'select': true})

  encryptshift:(length, toUp) ->
    ### The method charCodeAt() will always send a integer equal or less than 65535 ###
    modulus = 65535
    text = @getTextSelected()
    encryptedText = ''
    for i in [0..text.length-1]
        if(toUp)
            encryptedText += String.fromCharCode((text.charCodeAt(i)+length)%modulus)
        else
            codeTemp = text.charCodeAt(i)-length
            if(codeTemp < 0)
                codeTemp = modulus + codeTemp
            encryptedText += String.fromCharCode(codeTemp)
    @replaceText(encryptedText, {'select': true})

  encryptcaesar: ->
    @encryptshift(3, true)

  decryptcaesar: ->
    @encryptshift(3, false)

  vigenereFromInput: ->
    @vigenerePanel.hide()
    @vigenere(@vigenereView.getInput().value, @vigenereView.getEncrypt())

  vigenere:(key, encrypt) ->
    if(key.length == 0)
        console.error('No key given')
        return false
    console.log 'key : ' + key + ' - encrypt :'+ encrypt

    ### Definition of alphabet ###
    A = 'A'.charCodeAt(0)
    Z = 'Z'.charCodeAt(0)
    key = key.toUpperCase()

    ### Check if key is in alphabet ###
    for n in [0..key.length-1]
        charKeyCode = key.charCodeAt(n)
        if(charKeyCode < A or charKeyCode > Z)
            console.error('The key is not in the alphabet')
            return false;

    ### Variables declarations ###
    keyLength = key.length
    modulus = Z - A + 1
    text = @getTextSelected().toUpperCase()
    encryptedText = ''
    index = 0

    ### Encryption/Decryption of each characters ###
    for i in [0..text.length-1]
        char = text.charAt(i)
        charCode = char.charCodeAt(0)

        ### Check if character is in alphabet ###
        if(charCode >= A and charCode <= Z)
            charKey = key.charCodeAt(index) - A
            charCode = charCode - A
            if(encrypt)
                newCharCode = ((charCode + charKey)%modulus) + A
            else
                codeTemp = charCode - charKey
                ### Usefull because of the bad modulus result if the first numnber is < 0 ###
                if(codeTemp < 0)
                    codeTemp = modulus + codeTemp
                newCharCode = (codeTemp) + A

            encryptedText += String.fromCharCode(newCharCode)
            index = (index+1)%keyLength
        else
            encryptedText += char
    @replaceText(encryptedText, {'select': true})
    @pane.activate()

  encryptvigenere: ->
    @pane = atom.workspace.getActivePane()
    @vigenereView.setEncrypt(true)
    @vigenerePanel.show()

  decryptvigenere: ->
    @pane = atom.workspace.getActivePane()
    @vigenereView.setEncrypt(false)
    @vigenerePanel.show()
