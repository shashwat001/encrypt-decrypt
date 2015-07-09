module.exports =
class VigenereView
  constructor: () ->
    @encrypt = true

    # Create root element
    @element = document.createElement('div')
    @element.classList.add('default-package')

    # Create message element
    message = document.createElement('div')
    message.textContent = "Enter the Encryption/Decryption Key for Vigenere (It should only be character from A-Z or a-z)"
    message.classList.add('message')
    @element.appendChild(message)

    @input = document.createElement('input')
    @input.type = "text"
    @input.size='35'
    @input.placeholder = "Encryption/Decryption Key"
    @element.appendChild(@input)

    @submit = document.createElement('input')
    @submit.type = "submit"
    @submit.value = "Go !"
    @element.appendChild(@submit)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  getInput: ->
    @input

  getSubmit: ->
    @submit

  setEncrypt:(isEncrypt) ->
    @encrypt = isEncrypt

  getEncrypt: ->
    @encrypt
