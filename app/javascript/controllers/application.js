import { Application } from "@hotwired/stimulus"
import GeolocationController from "controllers/geolocation_controller";

const application = Application.start()
application.register("geolocation", GeolocationController);

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
