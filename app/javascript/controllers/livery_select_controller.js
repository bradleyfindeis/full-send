import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["option"]

  select(event) {
    const selectedLabel = event.target.closest("label")
    
    this.optionTargets.forEach(option => {
      const card = option.querySelector(".livery-card")
      const check = option.querySelector(".livery-check")
      
      if (option === selectedLabel) {
        card.classList.remove("border-neutral-700", "bg-neutral-800")
        card.classList.add("border-white", "bg-neutral-700")
        check.classList.remove("hidden")
      } else {
        card.classList.remove("border-white", "bg-neutral-700")
        card.classList.add("border-neutral-700", "bg-neutral-800")
        check.classList.add("hidden")
      }
    })
  }
}
