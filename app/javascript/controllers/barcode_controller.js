import { Controller } from "@hotwired/stimulus";
import Quagga from '@ericblade/quagga2';

export default class extends Controller {
  static targets = ["codeInput", 'form']

  connect() {
    this.scanner = Quagga.init({
      inputStream: {
        name: "Live",
        type: "LiveStream",
        constraints: {
          width: 640,
          height: 480,
          facingMode: "environment",
        },
        locator: {
          patchSize: "medium",
          halfSample: true
        },
        area: {
          top: "10%",
          right: "10%",
          left: "10%",
          bottom: "10%",
        },
        singleChannel: false,
        target: this.element
      },
      decoder: {
        readers: [
          // "code_128_reader",
          "ean_8_reader"
        ]
      }
    }, (err) => {
      if (err) {
        console.log(err);
        return;
      }
      Quagga.start();
    });
    Quagga.onDetected(this.handleDetection.bind(this));
  }

  handleDetection(data) {
    Quagga.stop()
    const code = data.codeResult.code
    this.codeInputTarget.value = code
    this.formTarget.submit()
  }

}
