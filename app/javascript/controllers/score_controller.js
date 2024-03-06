// app/javascript/controllers/score_controller.js
import { Controller } from "stimulus";
import Rails from "@rails/ujs";

export default class extends Controller {
  static targets = ["score"];

  connect() {
    console.log("Score controller connected");
  }

  increaseScore() {
    Rails.ajax({
      type: "POST",
      url: "/increase_score",
      dataType: "json",
      success: (data) => {
        this.scoreTarget.textContent = `Total CO2 Saved: ${data.total_score} kg`;
      },
      error: (error) => {
        console.error("Error increasing score:", error);
      },
    });
  }
}
