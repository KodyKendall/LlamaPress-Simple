import { describe, it, expect, beforeEach } from 'vitest'
import { Application } from '@hotwired/stimulus'

// Example test for a Stimulus controller
// To use this, create your controller in app/javascript/controllers/

describe('Example Controller Test', () => {
  let application
  let container

  beforeEach(() => {
    // Create a container for the test
    container = document.createElement('div')
    document.body.appendChild(container)

    // Create a Stimulus application
    application = Application.start()
  })

  it('should mount a controller', () => {
    // Example controller definition
    class HelloController extends window.Controller {
      static targets = ['output']

      connect() {
        this.element.textContent = 'Hello, Stimulus!'
      }
    }

    // Register the controller
    application.register('hello', HelloController)

    // Add HTML with controller
    container.innerHTML = '<div data-controller="hello"></div>'

    // Assert
    const element = container.querySelector('[data-controller="hello"]')
    expect(element.textContent).toBe('Hello, Stimulus!')
  })
})
