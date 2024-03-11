import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-hover"
export default class extends Controller {
  static targets = ["imageContainer"];

  connect() {
    this.normalImage = this.imageContainerTarget.querySelector(".normal-image");
    this.hoverImage = this.imageContainerTarget.querySelector(".hover-image");
    }

    toggleImages() {
    this.normalImage.classList.toggle("hidden");
    this.hoverImage.classList.toggle("hidden");
    }
}
