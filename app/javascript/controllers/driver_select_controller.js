import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "display", "color", "menu", "search"]
  static values = {
    drivers: Array,
    selected: Number
  }

  connect() {
    this.closeOnClickOutside = this.closeOnClickOutside.bind(this)
    this.updateDisplay()
  }

  toggle() {
    if (this.menuTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.menuTarget.classList.remove("hidden")
    if (this.hasSearchTarget) {
      this.searchTarget.focus()
      this.searchTarget.value = ""
      this.filterDrivers("")
    }
    document.addEventListener("click", this.closeOnClickOutside)
  }

  close() {
    this.menuTarget.classList.add("hidden")
    document.removeEventListener("click", this.closeOnClickOutside)
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  selectDriver(event) {
    const option = event.currentTarget
    const id = option.dataset.id
    const name = option.dataset.name
    const color = option.dataset.color

    this.selectTarget.value = id
    this.updateDisplayWith(name, color)
    this.close()
  }

  updateDisplayWith(name, color) {
    this.displayTarget.textContent = name
    this.displayTarget.classList.remove("text-neutral-400")
    this.displayTarget.classList.add("text-white")
    this.colorTarget.style.backgroundColor = color
    this.colorTarget.classList.remove("hidden")
  }

  updateDisplay() {
    const selectedOption = this.selectTarget.querySelector(`option[value="${this.selectTarget.value}"]`)
    
    if (selectedOption && selectedOption.value) {
      const color = selectedOption.dataset.teamColor || "#6B7280"
      const text = selectedOption.textContent
      
      this.displayTarget.textContent = text
      this.displayTarget.classList.remove("text-neutral-400")
      this.displayTarget.classList.add("text-white")
      this.colorTarget.style.backgroundColor = color
      this.colorTarget.classList.remove("hidden")
    } else {
      this.displayTarget.textContent = "Select driver..."
      this.displayTarget.classList.remove("text-white")
      this.displayTarget.classList.add("text-neutral-400")
      this.colorTarget.classList.add("hidden")
    }
  }

  filterDrivers(event) {
    const query = (event?.target?.value || "").toLowerCase()
    const items = this.menuTarget.querySelectorAll("[data-driver-option]")
    
    items.forEach(item => {
      const name = item.dataset.name?.toLowerCase() || ""
      const team = item.dataset.team?.toLowerCase() || ""
      if (name.includes(query) || team.includes(query)) {
        item.classList.remove("hidden")
      } else {
        item.classList.add("hidden")
      }
    })
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnClickOutside)
  }
}
